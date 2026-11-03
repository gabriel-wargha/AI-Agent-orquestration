# How I built my AI agent team

This is a record of how I built a team of Claude Code agents that turns a project brief into tested code and pull requests, and keeps working overnight while I sleep. It covers what I built, the steps in order, every error I hit and how I fixed it, and what's still open.

Built on November 2 and 3, 2026. First project: **StudyRats**, a GymRats-style study tracker for BYU-Idaho students.

---

## What I built

**The team** (in this repo, `my-agents`):

| Agent | Job |
|---|---|
| **architect** | Turns the brief into a 3 to 4 day scope, designs the data model and pages, explains every decision, and writes `PLAN.md` as a checklist of tasks of about 20 minutes each. Never writes code. |
| **backend** | Database, API, login and file uploads with Neon. Real logic lives in plain functions in `server/`, every query is permission-checked, input is validated with Zod, and every route has tests. |
| **frontend** | Screens with Next.js and Tailwind, mobile first, using the frontend-design skill. |
| **reviewer** | Runs every check, looks for security holes, weak tests and usability problems, and approves or sends work back. Never edits code. |
| **`/ship`** (the lead) | Hands out tasks one at a time, saves and pushes after every task, posts a 3-line progress note on the pull request, runs the reviewer (up to 3 fix rounds) and marks the pull request ready. |

**The skills** the agents load:

| Skill | From | Used by |
|---|---|---|
| frontend-design | anthropics/skills | frontend |
| neon, neon-postgres, neon-auth, neon-object-storage | neondatabase/agent-skills | backend |
| verification-before-completion | obra/superpowers | frontend, backend, reviewer |
| systematic-debugging | obra/superpowers | frontend, backend (when something fails) |
| ui-ux-pro-max | nextlevelbuilder/ui-ux-pro-max-skill | reviewer (usability and accessibility check) |

**The stack:** Next.js 16 (App Router), TypeScript, Tailwind, Neon (Postgres, Neon Auth, Object Storage), Drizzle ORM, Vitest, Vercel.

**The night shift:** a GitHub Actions workflow in each project that runs `/ship` every night at 1:17 a.m. (Idaho time, 08:17 UTC) on GitHub's computers, using my Claude Pro plan. My laptop can be off.

---

## Step by step

### 1. Designed the team
I started from a single `agents.md` file and split it into specialised agents. Each agent file stays short (who it is and how it works). Deep know-how lives in skills, and project details live in each project's `CLAUDE.md` and `PLAN.md`.

### 2. Picked the stack
Next.js and TypeScript for frontend and backend in one project, because agents know it well and shared types catch their mistakes. I first chose Supabase, then **switched to Neon**: its free plan allows up to 100 projects that never pause (Supabase allows 2 active and pauses after a week), which matters when I ship a new project every week. Neon also has database branching.

### 3. Built the agents repo
```
agents/      architect, backend, frontend, reviewer
commands/    ship.md (the lead)
skills/      the 8 skills above
templates/   CLAUDE.md (project brief) and nightly-ship.yml (night shift)
scripts/     install-global.sh and add-to-project.sh
```
- `install-global.sh` links the team into `~/.claude`, so it works in every project on my Mac.
- `add-to-project.sh` copies the team into a project's `.claude` folder, because GitHub's computers can't see my Mac.

### 4. Chose the skills
I researched popular skills and checked their code before adding anything.
- **Added:** the official frontend-design skill, Neon's own skills, two small Superpowers skills, and ui-ux-pro-max for the reviewer.
- **Skipped:** the rest of Superpowers and GSD (they bring their own workflow, which competes with `/ship`, and Superpowers' brainstorming stops to ask questions), taste-skill (built for landing pages, needs Chrome screenshots), and ECC (very heavy: 27 automatic scripts and 314 skills). GSD also had trust issues.
- **Rule I follow:** skills that add knowledge fit the team; skills that add a process fight it.

### 5. Put the team on GitHub and my Mac
```bash
git init && git add . && git commit -m "My agent team"
gh repo create my-agents --private --source=. --push
./scripts/install-global.sh
```

### 6. Created StudyRats
```bash
npx create-next-app@latest studyrats     # recommended defaults
./scripts/add-to-project.sh ~/Desktop/studyrats
gh repo create studyrats --public --source=. --push
```
I made StudyRats public: GitHub Actions minutes are free for public repos, and interviewers can see the work.

### 7. Got the plan written
In Claude Code: *"Use the architect agent to write PLAN.md from CLAUDE.md. Don't build anything yet."* The architect produced 29 tasks: 17 backend, 11 frontend and 1 human step, grouped into 4 days, each with an acceptance check.

### 8. Turned on the night shift
1. Installed the Claude GitHub app on the `studyrats` repo only.
2. Ran `claude setup-token` and saved the token as the repo secret `CLAUDE_CODE_OAUTH_TOKEN`.
3. Checked that **usage credits** are off in claude.ai → Settings → Usage, so I can never be charged beyond my Pro plan.

### 9. Improved the workflow
- Save and push after **every** task, and post a 3-line progress note on the pull request.
- Tasks sized to about 20 minutes.
- Night run limit raised from 60 to 120 minutes.
- Batches raised from 6 to 12 tasks after the first run (6 tasks used about 15% of a 5-hour session; my limit is 50%).

### 10. First successful run
Night shift #2 built tasks B1 to B6 in 14 minutes: 7 agents (6 backend, 1 reviewer), 26 tests passing, approved in the first review round. I merged pull request #1.

---

## Errors and how I fixed them

### 1. The reviewer couldn't save its review
- **What happened:** the reviewer was told to write `REVIEW.md` but only had Read, Grep, Glob and Bash.
- **Fix:** gave it Write, with the rule that `REVIEW.md` is the only file it may write.

### 2. A skill couldn't find its own script
- **What happened:** ui-ux-pro-max was written to be installed as a plugin, so its commands pointed at `${CLAUDE_PLUGIN_ROOT}/...`, which doesn't exist for a plain skill.
- **Fix:** changed the path to `${CLAUDE_SKILL_DIR}`, and the reviewer runs the script with `python3 -B` so it leaves no cache files in the project.

### 3. The Neon setup didn't land in the project
- **What happened:** after Step 5 of the setup there was no `neon.ts`, `.neon` or `.env.local` in StudyRats.
- **Status:** not needed for the night shift (it runs without database keys on purpose). Still to do before running the app locally. See "Still open" below.

### 4. The first scheduled run started hours late
- **What happened:** the 1:17 a.m. run didn't start until the next morning. At 8 a.m. the Actions tab said "This workflow has no runs yet".
- **Why:** GitHub's scheduled runs are best effort and can be delayed or dropped when GitHub is busy.
- **Fix:** none needed in my setup. I watch whether later nights start on time, and use **Run workflow** to start one by hand.

### 5. Claude failed in 0.1 seconds
- **What happened:** `Action failed with error: Claude execution failed: result is_error:true`, with `"modelUsage": {}` and `"total_cost_usd": 0`. Claude never reached the model.
- **Why:** the login token was rejected straight away, most likely because it was cut off when copied (it's long, and Terminal wraps it onto two lines).
- **Fix:** widened Terminal, ran `claude setup-token` again, checked the token starts with `sk-ant-oat` and is one line, and updated the GitHub secret.

### 6. Runs "succeeded" in a minute but saved nothing (the main bug)
- **What happened:** green ticks, but only 4 or 5 turns in 12 to 45 seconds, no branch and no pull request.
- **Wrong first guess:** I thought Claude stopped to ask about the open questions at the end of `PLAN.md`.
- **How I found the real cause:** recreated the run's start locally with the same prompt and tools. The lead sent task B1 to the backend agent, the tool answered *"Async agent launched successfully"*, and the lead said *"B1 is running with the backend agent. I'm waiting for it to finish."*
- **Why:** in the current Claude Code, subagents run **in the background** by default. In a terminal, Claude gets woken up when they finish. On GitHub, the action treats the end of the lead's turn as the end of the run and shuts the machine down, killing the backend agent mid-task.
- **Fix:** in the workflow's "Run the team" step:
  ```yaml
  env:
    CLAUDE_CODE_DISABLE_BACKGROUND_TASKS: "1"   # keep agents in the foreground
    BASH_DEFAULT_TIMEOUT_MS: "600000"          # give npm install and builds 10 minutes
  ```
  Verified locally: the backend agent then starts in the foreground and the lead waits for it.

### 7. My fixes weren't being tested
- **What happened:** after each fix I pressed **Re-run** on run #1, and nothing changed.
- **Why:** a re-run repeats the old run with its **old code**. The commit shown on the run page stayed at the original one.
- **Fix:** use **Actions → Night shift → Run workflow** for a brand-new run with the latest code, and check the run number goes up (#2, #3...).

### 8. The log hid what Claude said
- **What happened:** the log only said "full output hidden for security".
- **Fix:** added `show_full_output: true` for one debugging run, then removed it again, because logs of a public repo are public.

### 9. Agents were blocked from simple commands
- **What happened:** an agent's `cd … && grep …` was denied, because only npm, npx, node, python3, git, `gh pr`, ls, mkdir and cat were allowed.
- **Fix:** also allowed the read-only helpers `cd`, `pwd`, `grep`, `head`, `tail`, `wc`, `sort`, `find` and `echo`.

### 10. The type check failed on a fresh copy
- **What happened:** `npx tsc --noEmit` failed with *"Cannot find name 'LayoutProps'"* in `app/layout.tsx`.
- **Why:** Next.js 16 generates some types (like `LayoutProps`) itself, and a fresh copy doesn't have them yet.
- **Fix:** run `npx next typegen && npx tsc --noEmit`. The team added this as `npm run typecheck`, and `CLAUDE.md` now uses it.

---

## Costs and limits
- **Claude:** Pro plan only. The token from `claude setup-token` uses the subscription, and usage credits are off, so a run stops at the plan limit instead of charging. One 6-task batch used about 15% of a 5-hour session. My cap is 50% per night, so batches are 12 tasks.
- **GitHub Actions:** free, because StudyRats is public.
- **Neon and Vercel:** free plans, no card.

---

## Still open
1. Neon setup in StudyRats, then `neon deploy`, set `NEON_AUTH_COOKIE_SECRET` and run the migration.
2. Upload settings (CORS) for the `photos` bucket: `@neon/config` 1.10.1 can't declare them yet, so set them by hand or upload photos through the server.
3. Connect Vercel and add the Vercel address to Neon Auth's trusted domains.
4. Watch whether tonight's scheduled run starts on time.
5. `actions/setup-node@v4` shows a Node 20 deprecation warning. Harmless for now; update it later.

---

## What I learned
- **Splitting one big prompt into specialised agents** keeps each one focused, and a reviewer that never writes code keeps everyone honest.
- **Headless isn't the same as a terminal.** Something that works on my Mac (background subagents) silently breaks in CI. The fix came from reproducing the run and reading what the lead actually did.
- **Save after every task.** If a run stops for any reason, the finished work is already on GitHub.
- **Check before trusting a skill:** read its code, check who maintains it, and only add skills that give knowledge, not a competing process.
