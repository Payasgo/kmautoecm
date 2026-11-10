-- KMAutos Academy book library storage
-- Run once in Supabase SQL Editor. Then upload the three PDFs to Storage > academy-books.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('academy-books', 'academy-books', true, 31457280, array['application/pdf'])
on conflict (id) do update set public = true, file_size_limit = 31457280, allowed_mime_types = array['application/pdf'];

drop policy if exists "Academy books are publicly readable" on storage.objects;
create policy "Academy books are publicly readable"
on storage.objects for select
to public
using (bucket_id = 'academy-books');

drop policy if exists "Academy admins can upload books" on storage.objects;
create policy "Academy admins can upload books"
on storage.objects for insert
to authenticated
with check (
 bucket_id = 'academy-books'
 and exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
);

drop policy if exists "Academy admins can update books" on storage.objects;
create policy "Academy admins can update books"
on storage.objects for update
to authenticated
using (
 bucket_id = 'academy-books'
 and exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
)
with check (
 bucket_id = 'academy-books'
 and exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
);
