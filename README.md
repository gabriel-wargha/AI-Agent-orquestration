# My agent team

A team of Claude Code agents that takes a project from idea to pull request, and can keep working overnight while I sleep.

| Agent | Job |
|---|---|
| **architect** | Turns the idea into a 3 to 4 day scope, designs the data model and pages, explains every decision, and writes the task list in `PLAN.md`. Never writes code. |
| **backend** | Builds the database, API routes and auth with Supabase. Row level security on every table, input checked with Zod, tests for every route. |
| **frontend** | Builds the screens with Next.js and Tailwind, mobile first, using the `frontend-design` skill so it doesn't look like a generic AI app. |
| **reviewer** | Runs every check, looks for security holes and weak tests, and writes `REVIEW.md` with "approved" or "changes needed". Never edits code. |

The **`/ship`** command is the team lead. It runs architect → backend → frontend → reviewer, loops back for fixes up to 3 times, and leaves one pull request to review.

## Folder map

```
agents/      the four agents
commands/    /ship, the team lead
skills/      frontend-design (from anthropics/skills, Apache 2.0 licence)
templates/   CLAUDE.md with the StudyRats brief, and the night shift workflow
scripts/     install-global.sh and add-to-project.sh
```

**To set it up, follow [SETUP.md](SETUP.md).**
