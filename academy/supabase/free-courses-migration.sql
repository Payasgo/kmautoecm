-- KMAutos free-course catalogue and student self-enrolment
-- Run once in Supabase SQL Editor after the academy code is deployed.
drop policy if exists "Students enroll in published courses" on public.enrollments;
create policy "Students enroll in published courses" on public.enrollments
for insert to authenticated with check (
 student_id = auth.uid()
 and exists (select 1 from public.courses c where c.id = course_id and c.published = true)
);
-- Publish the three starter courses so students can see them.
update public.courses set published = true where slug in (
 'automotive-electrical-fundamentals','ecu-sensors-actuators','scan-tools-fault-finding'
);
