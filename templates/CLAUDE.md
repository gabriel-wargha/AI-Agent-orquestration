# StudyRats

A social study tracker for BYU-Idaho students, inspired by GymRats.
Students log study sessions, earn points, and compete on group leaderboards.

## Users
BYU-Idaho students who want accountability and a bit of friendly competition.

## Version 1 scope (ship in 3 to 4 days)
- Sign up and log in with email (Supabase Auth).
- Create or join a group with an invite code. A group is labelled "friends" or "class".
- Start and stop a built-in study timer, with an optional subject and a photo of your notes.
- 1 point per study minute.
- A group leaderboard for this week and for all time.
- A feed of recent check-ins where group members can react.
- Installable as a PWA.

## Not in version 1
Other metrics (questions, tasks), streaks, badges, notifications, a native app.

## Stack
Next.js App Router, TypeScript, Tailwind, Supabase, Vercel.

## Checks
- Lint: `npm run lint`
- Types: `npx tsc --noEmit`
- Tests: `npm test` (Vitest)
- Build: `npm run build`

## Rules
- Mobile first, since students will use it on their phones.
- Users only see the groups they belong to (row level security).
