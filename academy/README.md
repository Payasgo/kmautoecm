# KMAutos Academy

Standalone Next.js 15 + Supabase application for `learn.kmautoecm.com`. The existing `www.kmautoecm.com` business website is separate and should not be modified as part of academy deployment.

## Included in this milestone
- Responsive academy landing page.
- Email/password student registration and sign-in using Supabase Auth.
- Email confirmation support (controlled by Supabase Auth settings).
- Protected student dashboard and sign-out.
- Initial course catalogue, profile, module, lesson, enrolment and lesson-progress schema.
- Row Level Security (RLS) for student-owned profile/enrolment/progress data and published course content.
- Public signup always creates the default `student` role; profile permissions prevent users from promoting themselves.

## Local setup
1. Install Node.js 20.9+.
2. From this folder run `npm install`.
3. Copy `.env.example` to `.env.local` and fill in the Supabase project URL and anon/publishable key.
4. In Supabase SQL Editor, run `supabase/schema.sql`.
5. In Supabase Authentication > URL Configuration, set the Site URL to your deployed academy URL and add local/deployed redirect URLs.
6. Run `npm run dev` and open `http://localhost:3000`.

Never put a Supabase service-role key in browser-visible environment variables or commit real secrets.

## Deploy independently
Create a separate Vercel project from this repository with **Root Directory = `academy`**. Add the two environment variables from `.env.example` in Vercel. Connect `learn.kmautoecm.com` to that Vercel project and add only the DNS record Vercel instructs you to add for the academy subdomain. Do not change the existing root or `www` website DNS records.

## Important current scope
This is the authentication and student-dashboard foundation. Course lesson delivery, checkout/payments, instructor/admin management screens, assessments, and interactive diagnostic simulators are not implemented yet. The dashboard shows published courses and a student's enrolments; course enrolment currently needs to be assigned by an academy administrator until the enrolment workflow is built. Starter course records are seeded as unpublished until lesson content is added.

## Security notes
- RLS is enabled on all academy tables.
- Students can read only their own profile, enrolments and progress.
- Students can update their profile name but cannot update their role.
- Students can write progress only for lessons belonging to courses they are enrolled in.
- Promote trusted staff roles only through a trusted server/admin process, never by editing a client-side form.
