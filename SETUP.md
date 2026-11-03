# Setup guide

Follow the steps in order. Part 1 is done once. Part 2 is done once for each new project. Part 3 turns on the night shift.

## Before you start

You need:

- A Claude Pro or Max plan, with Claude Code installed and logged in. Typing `claude` in a terminal should open it.
- Node.js 20 or newer (`node -v` to check).
- Git, a GitHub account and the GitHub CLI, which the team uses to open pull requests: `brew install gh`, then `gh auth login`.
- Free accounts on [neon.com](https://neon.com) and [vercel.com](https://vercel.com).

---

## Part 1: Your agents repo (once)

### Step 1. Put this folder on GitHub as a private repo

```bash
cd ~/Desktop/"AI Agent orquestration"
git init
git add .
git commit -m "My agent team"
gh repo create my-agents --private --source=. --push
```

### Step 2. Link the team to your computer

```bash
./scripts/install-global.sh
```

This links the agents, `/ship` and the skill into `~/.claude`, so the team shows up in every project you open.

**Check it worked:** open `claude` in any folder and type `/agents`. You should see architect, backend, frontend and reviewer.

From now on, improve the agents by editing the files in this folder. Thanks to the links, your computer sees the changes straight away.

---

## Part 2: Start StudyRats (once per project)

### Step 3. Create the app

```bash
cd ~/Desktop
npx create-next-app@latest studyrats
```

Choose the recommended defaults (TypeScript, ESLint, Tailwind and the App Router). Do this before adding the team, because create-next-app only works in an empty folder.

### Step 4. Add the team to the project

```bash
cd ~/Desktop/"AI Agent orquestration"
./scripts/add-to-project.sh ~/Desktop/studyrats
```

This copies the team into `studyrats/.claude`, and adds the night shift workflow and the StudyRats `CLAUDE.md`.

**Why copy it if it's already linked?** At night the team runs on GitHub's computers, and they can't see your laptop. So the team has to live inside the project too. After you improve an agent, run this script again to update the project's copy.

### Step 5. Create the database

StudyRats uses three parts of Neon: the database, Neon Auth for logins and Object Storage for the photos of notes.

1. Install the Neon command line tool and log in. The login opens your browser, and you can sign up there if you don't have an account yet.

```bash
npm i -g neon
neon login
```

2. Open Claude Code in the project and let it do the fiddly setup. It already has Neon's official skills, because the script in Step 4 added them.

```bash
cd ~/Desktop/studyrats
claude
```

Then paste this:

> Set up Neon for this project using the neon skills. Link it to a new Neon project called studyrats in the aws-us-east-2 region. In neon.ts, declare Neon Auth and a private Object Storage bucket called photos. Run neon deploy so the environment variables land in .env.local. Then add NEON_AUTH_COOKIE_SECRET to .env.local, generated with openssl rand -base64 32.

Approve its commands as it goes. Use the US East region, because Object Storage isn't available everywhere yet.

3. **Check it worked:** `.env.local` should now contain `DATABASE_URL`, `NEON_AUTH_BASE_URL`, four `AWS_...` lines for storage and `NEON_AUTH_COOKIE_SECRET`. Git ignores this file, so your keys never leave your computer.

### Step 6. Put StudyRats on GitHub

```bash
cd ~/Desktop/studyrats
git add .
git commit -m "Start StudyRats"
gh repo create studyrats --public --source=. --push
```

This also saves `neon.ts`, which describes your Neon setup but holds no secrets.

**Public or private?** I'd go public. GitHub Actions minutes are free for public repos, and interviewers can see your work. Your secrets stay secret either way. If you'd rather use `--private`, keep the workflow's 60-minute limit so you stay inside the 2,000 free minutes a month.

If GitHub refuses the push because of a workflow file, run `gh auth refresh -s workflow` and push again with `git push -u origin main`.

### Step 7. Do the first run in the daytime

```bash
cd ~/Desktop/studyrats
claude
```

Then type `/ship` and watch.

- The architect writes `PLAN.md` first. **Read it.** This is your chance to fix the scope before any code is written.
- The builders take the first batch of tasks, the reviewer checks them, and a pull request appears on GitHub.
- Claude Code asks for permission before commands like `git push`. That's normal, so approve the ones you're happy with.

Review the pull request and merge it if it looks good.

---

## Part 3: Turn on the night shift

### Step 8. Give GitHub access to Claude

1. Install the Claude GitHub app at <https://github.com/apps/claude>, and choose only the `studyrats` repo.
2. In a terminal, run `claude setup-token` and copy the token it gives you. It's linked to your plan, so you won't be billed separately.
3. On GitHub, go to `studyrats` → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**.
   - Name: `CLAUDE_CODE_OAUTH_TOKEN`
   - Value: the token

### Step 9. Test it now, don't wait for tonight

On GitHub, go to `studyrats` → **Actions** → **Night shift** → **Run workflow**.

It runs for up to an hour, then leaves a pull request. The pull request is a draft if the team didn't finish or the reviewer didn't approve. If the run fails, open its log. The most common cause is a missing or misspelt `CLAUDE_CODE_OAUTH_TOKEN`.

### Step 10. Connect Vercel

1. On vercel.com, choose **Add New** → **Project** and import `studyrats`.
2. Under **Environment Variables**, add every line from your `.env.local`. You can paste the whole file in at once. Then deploy.
3. Tell Neon Auth that your Vercel address is allowed to log people in. Use your real address:

```bash
neon neon-auth domain add https://studyrats.vercel.app
```

From now on, Vercel gives every pull request its own preview link, so each morning you can try the night's work on your phone. If logging in on a preview link says "invalid domain", add that preview address the same way.

---

## Your daily rhythm

- **Daytime:** code with Claude as usual, or steer the team by editing `PLAN.md` or `CLAUDE.md`.
- **Night (about 1:17 a.m.):** the team takes the next 12 tasks and opens a pull request. After each task it saves the work and posts a 3-line progress note on the pull request, so you can follow along from your phone.
- **Morning:**
  1. Open the pull request, and read the summary and `REVIEW.md`.
  2. If it added files to the `drizzle` folder, it changed the database. Update your database first: `gh pr checkout <number>`, then `npm run db:migrate`.
  3. Tap the Vercel preview link and try the app.
  4. Merge it if you're happy. If not, leave a comment or fix it during the day.

**Merge or close each pull request before the next night.** Every night starts from `main`, so unmerged work would get done again.

---

## Costs and limits

- **Claude:** the night shift uses your plan. When you hit the limit, the run stops and the pull request stays a draft. Check that extra usage is switched off in your claude.ai settings, so you're never charged beyond your plan.
- **GitHub Actions:** free for public repos. Private repos get 2,000 free minutes a month, and with no payment method, jobs just stop when they run out rather than charging you.
- **Neon:** the free plan allows up to 100 projects, and they're never paused. The database sleeps after 5 minutes without use and wakes up on the next request, which can make the first page load a little slower. Each project gets 1 GB for the database and 5 GB for files.
- **Vercel:** the free Hobby plan is plenty for portfolio projects.

## Safety rules built in

- The team never works on `main`. Every run gets its own branch.
- Agents never merge. You do.
- The reviewer has to approve before a pull request is marked ready, with a maximum of 3 fix rounds.
- At night, the team can only run the commands listed in the workflow (npm, npx, node, python3, git and `gh pr`).
- The night shift has no database keys, so it can never touch your real data.
- Secrets live in `.env.local`, Vercel and GitHub secrets, never in code.

## Level up later: previews with their own database

Right now your preview links and your live app share one database. That's fine while StudyRats has no real users. Once it has some, give each preview its own Neon branch, a free instant copy of your data, so testing never touches real users. Neon's guide for this is [preview-branches-with-vercel](https://github.com/neondatabase/preview-branches-with-vercel).

## Improving the team

When an agent keeps making the same mistake, add a rule to its file in this folder. Then:

1. Commit the change here, in `my-agents`.
2. Run `./scripts/add-to-project.sh ~/Desktop/studyrats` and commit the updated `.claude` folder in StudyRats.

For your next project, repeat Parts 2 and 3 with a new `CLAUDE.md` brief.
