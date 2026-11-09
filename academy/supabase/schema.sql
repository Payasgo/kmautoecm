-- KMAutos Academy database foundation
-- Run in Supabase SQL Editor. Safe to re-run for policies/triggers where practical.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'student' check (role in ('student','instructor','admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  description text not null default '',
  level text not null default 'Foundation',
  published boolean not null default false,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);
create table if not exists public.modules (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  title text not null,
  description text not null default '',
  sort_order integer not null default 0,
  published boolean not null default false
);
create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  module_id uuid not null references public.modules(id) on delete cascade,
  title text not null,
  content text not null default '',
  video_url text,
  duration_minutes integer not null default 0,
  sort_order integer not null default 0,
  published boolean not null default false
);
create table if not exists public.enrollments (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  course_id uuid not null references public.courses(id) on delete cascade,
  progress_percent integer not null default 0 check (progress_percent between 0 and 100),
  created_at timestamptz not null default now(),
  unique(student_id,course_id)
);
create table if not exists public.lesson_progress (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  completed boolean not null default false,
  completed_at timestamptz,
  updated_at timestamptz not null default now(),
  unique(student_id,lesson_id)
);

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name',''))
  on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.courses enable row level security;
alter table public.modules enable row level security;
alter table public.lessons enable row level security;
alter table public.enrollments enable row level security;
alter table public.lesson_progress enable row level security;

drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile" on public.profiles for select to authenticated using (auth.uid() = id);
drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);
-- Prevent self-promotion: authenticated users may update their name, never their role.
revoke update on public.profiles from authenticated;
grant update (full_name) on public.profiles to authenticated;
drop policy if exists "Published courses are visible" on public.courses;
create policy "Published courses are visible" on public.courses for select to authenticated using (published = true);
drop policy if exists "Published modules are visible" on public.modules;
create policy "Published modules are visible" on public.modules for select to authenticated using (published = true and exists (select 1 from public.courses c where c.id = course_id and c.published = true));
drop policy if exists "Published lessons are visible" on public.lessons;
create policy "Published lessons are visible" on public.lessons for select to authenticated using (published = true and exists (select 1 from public.modules m join public.courses c on c.id = m.course_id where m.id = module_id and m.published = true and c.published = true));
drop policy if exists "Students read own enrollments" on public.enrollments;
create policy "Students read own enrollments" on public.enrollments for select to authenticated using (student_id = auth.uid());
drop policy if exists "Students read own progress" on public.lesson_progress;
create policy "Students read own progress" on public.lesson_progress for select to authenticated using (student_id = auth.uid());
drop policy if exists "Students create own progress" on public.lesson_progress;
create policy "Students create own progress" on public.lesson_progress for insert to authenticated with check (
  student_id = auth.uid() and exists (
    select 1 from public.lessons l
    join public.modules m on m.id = l.module_id
    join public.enrollments e on e.course_id = m.course_id
    where l.id = lesson_id and e.student_id = auth.uid()
  )
);
drop policy if exists "Students update own progress" on public.lesson_progress;
create policy "Students update own progress" on public.lesson_progress for update to authenticated using (student_id = auth.uid()) with check (
  student_id = auth.uid() and exists (
    select 1 from public.lessons l
    join public.modules m on m.id = l.module_id
    join public.enrollments e on e.course_id = m.course_id
    where l.id = lesson_id and e.student_id = auth.uid()
  )
);

-- Seed starter course catalogue (unpublished until the academy team is ready).
insert into public.courses (title,slug,description,level,sort_order) values
('Automotive Electrical Fundamentals','automotive-electrical-fundamentals','Voltage, current, resistance, wiring, grounds, fuses and measurement.','Foundation',1),
('ECU, Sensors & Actuators','ecu-sensors-actuators','Control modules, sensor signals, actuator control and system logic.','Intermediate',2),
('Scan Tools & Fault Finding','scan-tools-fault-finding','DTC strategy, live data interpretation, test plans and diagnosis.','Advanced',3)
on conflict (slug) do nothing;
