-- Phase 2: learning progress and assessments
create table if not exists public.quizzes (
 id uuid primary key default gen_random_uuid(),
 course_id uuid not null references public.courses(id) on delete cascade,
 module_id uuid references public.modules(id) on delete cascade,
 title text not null,
 description text not null default '',
 pass_percent integer not null default 70 check (pass_percent between 1 and 100),
 published boolean not null default false,
 created_at timestamptz not null default now()
);
create table if not exists public.quiz_questions (
 id uuid primary key default gen_random_uuid(),
 quiz_id uuid not null references public.quizzes(id) on delete cascade,
 prompt text not null,
 options jsonb not null default '[]'::jsonb,
 correct_index integer not null default 0,
 explanation text not null default '',
 sort_order integer not null default 0
);
create table if not exists public.quiz_attempts (
 id uuid primary key default gen_random_uuid(),
 quiz_id uuid not null references public.quizzes(id) on delete cascade,
 student_id uuid not null references public.profiles(id) on delete cascade,
 score_percent integer not null check (score_percent between 0 and 100),
 passed boolean not null,
 answers jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now()
);
alter table public.quizzes enable row level security;
alter table public.quiz_questions enable row level security;
alter table public.quiz_attempts enable row level security;
drop policy if exists "Published quizzes visible to enrolled students" on public.quizzes;
create policy "Published quizzes visible to enrolled students" on public.quizzes for select to authenticated using (
 published = true and exists (select 1 from public.enrollments e where e.course_id=quizzes.course_id and e.student_id=auth.uid())
);
drop policy if exists "Questions visible for published quizzes" on public.quiz_questions;
create policy "Questions visible for published quizzes" on public.quiz_questions for select to authenticated using (
 exists(select 1 from public.quizzes q join public.enrollments e on e.course_id=q.course_id where q.id=quiz_id and q.published=true and e.student_id=auth.uid())
);
drop policy if exists "Students read own quiz attempts" on public.quiz_attempts;
create policy "Students read own quiz attempts" on public.quiz_attempts for select to authenticated using (student_id=auth.uid());
drop policy if exists "Students create own quiz attempts" on public.quiz_attempts;
create policy "Students create own quiz attempts" on public.quiz_attempts for insert to authenticated with check (
 student_id=auth.uid() and exists(select 1 from public.quizzes q join public.enrollments e on e.course_id=q.course_id where q.id=quiz_id and q.published=true and e.student_id=auth.uid())
);

create or replace function public.refresh_enrollment_progress() returns trigger
language plpgsql security definer set search_path=public as $$
declare target_course uuid; target_student uuid; total_lessons integer; done_lessons integer; pct integer;
begin
 target_student := coalesce(new.student_id,old.student_id);
 select m.course_id into target_course from public.lessons l join public.modules m on m.id=l.module_id where l.id=coalesce(new.lesson_id,old.lesson_id);
 if target_course is null then return coalesce(new,old); end if;
 select count(*) into total_lessons from public.lessons l join public.modules m on m.id=l.module_id where m.course_id=target_course and m.published=true and l.published=true;
 select count(*) into done_lessons from public.lesson_progress lp join public.lessons l on l.id=lp.lesson_id join public.modules m on m.id=l.module_id where m.course_id=target_course and m.published=true and l.published=true and lp.student_id=target_student and lp.completed=true;
 pct := case when total_lessons=0 then 0 else round(done_lessons*100.0/total_lessons)::integer end;
 update public.enrollments set progress_percent=pct where student_id=target_student and course_id=target_course;
 return coalesce(new,old);
end; $$;
drop trigger if exists lesson_progress_refresh_enrollment on public.lesson_progress;
create trigger lesson_progress_refresh_enrollment after insert or update or delete on public.lesson_progress for each row execute function public.refresh_enrollment_progress();
