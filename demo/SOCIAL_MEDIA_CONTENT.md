# gcpctx Social Media Content Pack

## 🎯 Ready-to-Post Content

### Twitter/X Thread (10 tweets)

**Tweet 1 (Thread starter):**
```
🧵 Stop wrestling with `gcloud config set`.

I built gcpctx to solve the "which GCP context am I in?" problem once and for all.

Thread: Why managing 5+ GCP projects drove me to create a better context switcher 👇

[GIF: 01-quick-switch]
```

**Tweet 2:**
```
The problem: You have 3 GCP accounts (dev, staging, prod) × 10 projects each.

Every day you type:
```bash
gcloud config set account dev@company.com
gcloud config set project my-dev-123
```

47 times.

There's a better way. 🚀

[GIF: 03-multi-project]
```

**Tweet 3:**
```
Enter: gcpctx

Think kubectl contexts, but for GCP.

```bash
gcpctx use dev
gcpctx use staging  
gcpctx use prod
```

That's it. Account + project + ADC + environment variables all switched together.

No more credential mixups. 🎯
```

**Tweet 4:**
```
But here's the real magic: folder markers.

Drop a `.gcpctx` file in your repo:

```json
{"name":"staging","project":"frontend-staging"}
```

Run `gcpctx activate` → boom. Right context, every time.

[GIF: 04-folder-markers]
```

**Tweet 5:**
```
"But what about production accidents?"

gcpctx has your back:

```bash
gcpctx protect prod
gcpctx assert --context dev
```

Try to switch to prod? Blocked.
In the wrong context? Command fails.

No more "oops wrong project" moments. 🛡️

[GIF: 02-project-safety]
```

**Tweet 6:**
```
Security-first design:

✅ Credentials never logged or printed
✅ Files locked down (0600/0700 permissions)
✅ No shell injection vectors
✅ Atomic credential updates
✅ Zero telemetry
✅ Input validation on everything

20 security invariants: github.com/UriBer/gcpctx/SECURITY.md
```

**Tweet 7:**
```
Works with everything:

• gcloud CLI
• Terraform / OpenTofu
• Python SDK (google-cloud-*)
• Node.js SDK
• Go SDK
• Any tool that reads ADC or env vars

One context switch. All tools aligned. 🔄
```

**Tweet 8:**
```
Production-ready tooling:

```bash
gcpctx doctor        # Health checks
gcpctx secrets fix   # Auto-repair
gcpctx --help        # Great docs
```

Shell completions for bash/zsh/powershell included.

[GIF: 06-doctor]
```

**Tweet 9:**
```
100% Bash. Zero npm dependencies.

✅ Works on macOS, Linux, WSL
✅ No runtime dependencies (just gcloud CLI)
✅ Installs in 30 seconds
✅ Apache 2.0 license

Install:
```bash
npm install -g gcpctx
gcpctx shell-setup
```
```

**Tweet 10 (Call to action):**
```
Managing multiple GCP projects?

Give gcpctx a try:

📦 npm: npmjs.com/package/gcpctx
⭐ GitHub: github.com/UriBer/gcpctx
📖 Docs: github.com/UriBer/gcpctx#readme

If it saves you even 5 minutes a day, it's worth it.

Questions? Drop them below 👇
```

---

## LinkedIn Post (Long-form)

```markdown
# Never Confuse GCP Projects Again 🚀

After accidentally running a destructive command in production (😱), I built gcpctx.

**The Problem:**

Managing 5+ GCP accounts across 30+ projects means constant context switching:

```bash
gcloud config set account dev@company.com
gcloud config set project my-dev-project
gcloud auth application-default login
export GOOGLE_CLOUD_PROJECT=my-dev-project
```

Every. Single. Day.

And one wrong command in production? Career-limiting move.

**The Solution:**

gcpctx is like kubectl contexts, but for GCP:

```bash
gcpctx use dev
gcpctx use staging
gcpctx use prod
```

One command. Account + project + ADC + environment variables all switched together.

**Safety Features:**

🛡️ Protected contexts (can't accidentally switch to prod)
✅ Assertions (fail fast if you're in the wrong place)
📁 Folder markers (auto-activate context per directory)
⚠️ Safe execution (commands blocked if context is wrong)

**Real-World Usage:**

```bash
# In your terraform repo
echo '{"name":"staging"}' > .gcpctx
gcpctx activate

# Now all commands use staging
terraform plan
gcloud compute instances list

# Want to be extra safe?
gcpctx assert --project staging-123 && terraform apply
```

**Open Source & Secure:**

✅ 100% Bash, Apache 2.0 license
✅ Zero dependencies (just gcloud CLI)
✅ 20 documented security invariants
✅ Socket.dev analyzed: transparent about what it does

**Try it:**

```bash
npm install -g gcpctx
gcpctx shell-setup
```

GitHub: https://github.com/UriBer/gcpctx

---

Have you ever deployed to the wrong environment? How do you manage GCP context switching? Let me know in the comments 👇

#DevOps #GoogleCloud #GCP #CloudEngineering #OpenSource #CLI
```

---

## Reddit Posts

### r/devops

**Title:** `[Tool] gcpctx - kubectl-style context switching for GCP`

```markdown
Hey r/devops,

I built **gcpctx** to solve the "which GCP project am I in?" problem.

**TL;DR:** Switch between GCP accounts/projects like kubectl contexts. No more `gcloud config set` spam.

**Why?**

If you manage multiple GCP accounts (dev/staging/prod) × many projects, you know the pain:

- Constantly typing `gcloud config set ...`
- "Wait, which project am I in?"
- That sinking feeling after running a command in production by accident

**How it works:**

```bash
# One-time setup
gcpctx init --name dev --account dev@company.com --project dev-123
gcpctx init --name prod --account admin@company.com --project prod-456

# Daily usage
gcpctx use dev
gcpctx use prod
```

**Features:**

- 🎯 One command switches: account + project + ADC + env vars
- 🛡️ Protected contexts (can't accidentally switch to prod)
- 📁 Folder markers (auto-activate per directory)
- ✅ Assertions (`gcpctx assert --context dev` before dangerous commands)
- 🔧 Health checks (`gcpctx doctor`)

**Demo GIF:** [quick-switch.gif]

**Links:**

- GitHub: https://github.com/UriBer/gcpctx
- npm: https://www.npmjs.com/package/gcpctx

**Install:**

```bash
npm install -g gcpctx
gcpctx shell-setup
```

100% Bash, Apache 2.0, zero npm dependencies.

Feedback welcome!
```

---

### r/googlecloud

**Title:** `Made a context switcher for GCP (like kubectl contexts)`

```markdown
If you work with multiple GCP projects, you might find **gcpctx** useful.

It's a CLI tool that lets you switch between GCP accounts/projects/ADC as one atomic unit:

```bash
gcpctx use dev      # Switch to dev context
gcpctx use staging  # Switch to staging
gcpctx use prod     # Switch to prod (with protection!)
```

**Key features:**

- Context = account + project + ADC + env vars bundled together
- Protected contexts (prevent accidental prod access)
- Folder markers (`.gcpctx` file auto-activates the right context)
- Assertions for safety
- Works with gcloud, Terraform, Python/Node/Go SDKs

**Demo:** [folder-markers.gif]

**Security:**

Socket.dev score breakdown in the README. It flags shell/filesystem/env access (which is what a credential manager does), but all operations are validated and safe. 20 documented security invariants.

**Links:**

- GitHub: https://github.com/UriBer/gcpctx
- npm: https://www.npmjs.com/package/gcpctx

Open to feedback!
```

---

## Dev.to / Hashnode Article

**Title:** Never Confuse GCP Projects Again: A kubectl-style Context Switcher

**Tags:** #googlecloud #devops #cli #productivity #opensource

```markdown
# Never Confuse GCP Projects Again: A kubectl-style Context Switcher

## The Problem

You're a cloud engineer managing:
- 3 GCP accounts (dev, staging, prod)
- 10 projects per account
- Multiple services per project

Every day you type variations of:

```bash
gcloud config set account dev@company.com
gcloud config set project my-dev-project-123
gcloud auth application-default login
export GOOGLE_CLOUD_PROJECT=my-dev-project-123
```

And the worst part? One typo means you just deployed to production. Or deleted the wrong database. Or racked up a $10k bill.

## The Solution: gcpctx

I built **gcpctx** to solve this exact problem. It's like kubectl contexts, but for GCP.

### Installation

```bash
npm install -g gcpctx
gcpctx shell-setup
```

### Quick Start

```bash
# Initialize contexts (one-time)
gcpctx init --name dev --account dev@company.com
gcpctx init --name staging --account staging@company.com
gcpctx init --name prod --account admin@company.com

# Daily usage
gcpctx use dev
gcpctx current
# → dev (my-dev-project-123)

gcpctx use staging
gcpctx current
# → staging (my-staging-project-456)
```

[GIF: 01-quick-switch.gif]

## Core Concepts

### 1. Contexts Bundle Everything

A context includes:
- GCP account
- Default project
- ADC (Application Default Credentials)
- Region/zone
- Environment variables

One `gcpctx use` command switches all of them atomically.

### 2. Multi-Project Management

You can scan all projects for an account and switch between them without re-authenticating:

```bash
gcpctx scan dev
gcpctx projects dev
# → Lists all 50 projects

gcpctx use dev --project project-alpha
gcpctx project project-beta  # Switch project only
```

[GIF: 03-multi-project.gif]

### 3. Folder Markers

This is where it gets magical. Drop a `.gcpctx` file in your repo:

```json
{
  "name": "staging",
  "project": "my-staging-project-456"
}
```

Now when you `cd` into that directory and run `gcpctx activate`, you're automatically in the right context:

```bash
cd ~/projects/frontend-app
gcpctx activate
# ✓ Loaded context from .gcpctx
# ✓ Activated: staging → my-staging-project-456
```

All gcloud commands, Terraform, Python SDK, everything now uses `staging`.

[GIF: 04-folder-markers.gif]

### 4. Production Safety

The scariest moment in DevOps: realizing you just ran something in prod.

gcpctx has built-in safety features:

**Protected contexts:**

```bash
gcpctx protect prod

gcpctx use prod
# ⚠️  Context 'prod' is protected!
#    Use --force to switch
```

**Assertions:**

```bash
gcpctx assert --context dev
# ✅ Pass: you're in dev

gcpctx assert --context prod
# ❌ Fail: expected prod, got dev
# Exit code: 1 (blocks pipelines!)
```

**Safe execution:**

```bash
gcpctx exec --require-context dev -- terraform apply
# ✅ Runs only if you're in 'dev'
# ❌ Blocks if you're in 'staging' or 'prod'
```

[GIF: 02-project-safety.gif]

## Real-World Workflows

### Workflow 1: Multi-environment deployment

```bash
# Deploy to dev
gcpctx use dev
terraform apply

# Test in dev
gcpctx exec --require-context dev -- ./integration-tests.sh

# Deploy to staging
gcpctx use staging
terraform apply

# Only deploy to prod after manual confirmation
gcpctx use prod --force
gcpctx assert --project prod-project-789 && terraform apply
```

### Workflow 2: Project-specific development

```bash
# Each repo has its context marker
cd ~/projects/frontend-app
cat .gcpctx
# {"name":"dev","project":"frontend-dev"}

gcpctx activate
gcloud run deploy frontend --source .

cd ~/projects/backend-api
cat .gcpctx
# {"name":"dev","project":"backend-dev"}

gcpctx activate
gcloud run deploy api --source .
```

### Workflow 3: Support/debugging

```bash
# Customer: "My data is missing in project customer-x"
gcpctx use support
gcpctx scan support  # Find customer-x in list

gcpctx project customer-x
gcloud sql export sql customer-db gs://backup/debug.sql
```

## Technical Details

### What Gets Switched

When you run `gcpctx use <context>`:

1. **gcloud config**: Updates active configuration
2. **ADC**: Updates `application_default_credentials.json`
3. **Environment variables**:
   - `GOOGLE_APPLICATION_CREDENTIALS`
   - `GOOGLE_CLOUD_PROJECT`
   - `GOOGLE_CLOUD_QUOTA_PROJECT`
   - `CLOUDSDK_CORE_PROJECT`
   - `CLOUDSDK_ACTIVE_CONFIG_NAME`
   - `GCPCTX_NAME`

### Security Model

gcpctx follows 20 security invariants (see [SECURITY.md](https://github.com/UriBer/gcpctx/blob/main/SECURITY.md)):

- ✅ Credentials never printed or logged
- ✅ Files use restrictive permissions (0600/0700)
- ✅ No shell injection vectors
- ✅ Atomic credential updates
- ✅ Zero telemetry, no network calls
- ✅ Input validation prevents command injection

### Socket.dev Analysis

**Supply Chain Security Score: 51**

Socket.dev flags gcpctx for:
- Shell access (MEDIUM) - It's a Bash CLI
- Filesystem access (LOW) - Manages credential files
- Environment variables (LOW) - Sets GCP env vars

**This is expected and safe.** gcpctx is a credential manager - these operations are its job.

Other scores:
- Vulnerability: 100
- License: 100
- Quality: 81
- Maintenance: 86

Full analysis: https://socket.dev/npm/package/gcpctx

## Advanced Features

### Shell Integration

Add to your `.zshrc`:

```bash
source <(gcpctx shell-path --zsh)
```

Now `gcpctx use`, `gcpctx activate`, and `gcpctx deactivate` auto-eval without typing `eval "$(...)"`

### Health Checks

```bash
gcpctx doctor
# ✅ gcloud CLI found
# ✅ All contexts valid
# ⚠️  Credential permissions need fixing

gcpctx secrets fix
# ✓ Fixed permissions on 3 files
```

[GIF: 06-doctor.gif]

### JSON Output

All commands support `--json` for scripting:

```bash
gcpctx current --json
gcpctx list --json
gcpctx projects dev --json
```

### Shell Completions

```bash
gcpctx completion zsh > ~/.zsh/completions/_gcpctx
gcpctx completion bash > /etc/bash_completion.d/gcpctx
```

## Comparison to Other Tools

| Feature | gcpctx | gcloud configs | kubectx | direnv |
|---------|--------|----------------|---------|--------|
| Switch account + project | ✅ | ❌ | N/A | ✅ |
| ADC management | ✅ | ❌ | N/A | ❌ |
| Folder markers | ✅ | ❌ | ❌ | ✅ |
| Protected contexts | ✅ | ❌ | ❌ | ❌ |
| Assertions | ✅ | ❌ | ❌ | ❌ |
| Works with all SDKs | ✅ | ⚠️ | N/A | ✅ |

## Installation & Setup

### Prerequisites

- Node.js 18+
- gcloud CLI
- macOS, Linux, or Windows + Git Bash/WSL

### Install

```bash
npm install -g gcpctx
```

### Initial Setup

```bash
# Add shell integration
gcpctx shell-setup

# Reload shell
exec $SHELL

# Initialize your first context
gcpctx init --name dev --account dev@example.com

# Log in (opens browser for OAuth)
gcpctx login dev

# Scan projects
gcpctx scan dev

# You're ready!
gcpctx list
```

## Limitations

- Requires gcloud CLI (doesn't replace it, wraps it)
- Bash-based (works on Windows via Git Bash/WSL)
- Context names must be filesystem-safe (no spaces, special chars)

## Contributing

Contributions welcome!

- GitHub: https://github.com/UriBer/gcpctx
- Issues: https://github.com/UriBer/gcpctx/issues
- License: Apache 2.0

## Conclusion

If you manage multiple GCP projects, **gcpctx** can save you hours of context-switching friction and eliminate the fear of production accidents.

Give it a try:

```bash
npm install -g gcpctx
```

Questions? Drop them in the comments! 👇

---

*Follow me for more DevOps tools and tips.*
```

---

## Product Hunt Launch

**Tagline:**
> kubectl-style context switching for Google Cloud Platform

**Description:**
```
Switch between GCP accounts, projects, and credentials as one atomic unit.

Stop typing `gcloud config set` 47 times a day. Prevent production accidents with protected contexts and assertions. Auto-activate the right context per directory with folder markers.

100% Bash. Zero dependencies. Open source.

Perfect for DevOps engineers managing multiple GCP environments.
```

**First Comment (from maker):**
```
Hey Product Hunt! 👋

I'm Uri, and I built gcpctx after one too many "oh no, wrong GCP project" moments.

**The problem:** Managing 5+ GCP accounts across 30+ projects means constant context switching and high risk of accidents.

**The solution:** gcpctx bundles account + project + credentials into "contexts" you can switch instantly.

Think kubectl contexts, but for GCP.

**Key features:**
🎯 One-command switching
🛡️ Protected contexts (can't accidentally access prod)
📁 Folder markers (auto-activate per directory)
✅ Assertions (fail fast if wrong context)
🔧 Health checks & auto-repair

**Try it:**
```bash
npm install -g gcpctx
gcpctx shell-setup
```

Open source, Apache 2.0: https://github.com/UriBer/gcpctx

Happy to answer any questions!
```

---

## Hacker News (Show HN)

**Title:**
> Show HN: gcpctx – kubectl-style context switching for GCP

**Post:**
```
Hi HN,

I built gcpctx to solve the "which GCP project am I in?" problem.

GitHub: https://github.com/UriBer/gcpctx

**Why?**

If you manage multiple GCP accounts (dev/staging/prod) × many projects, you spend a lot of time typing:

```
gcloud config set account ...
gcloud config set project ...
```

And there's always the risk of running something in the wrong environment.

**What is it?**

gcpctx is like kubectl contexts, but for GCP. It bundles account + project + ADC + environment variables into "contexts" you can switch atomically:

```
gcpctx use dev
gcpctx use staging
gcpctx use prod
```

**Key features:**

- Protected contexts (prevent accidental prod access)
- Folder markers (`.gcpctx` file auto-activates context)
- Assertions (`gcpctx assert --context dev` before dangerous commands)
- Works with all GCP tools (gcloud, Terraform, Python/Node/Go SDKs)

**Technical details:**

- 100% Bash, ~1600 lines
- Zero npm dependencies (just gcloud CLI)
- Atomic file operations with temp files
- Strict input validation (no shell injection vectors)
- 20 documented security invariants

**Socket.dev analysis:**

Supply chain security score: 51 (expected for a shell-based credential manager)
- Flags: shell access, filesystem access, env vars
- These are necessary for the tool's function
- Full transparency: https://socket.dev/npm/package/gcpctx

**Install:**

```
npm install -g gcpctx
gcpctx shell-setup
```

Apache 2.0 licensed. Feedback welcome!
```

---

## YouTube Video Script (2-3 minutes)

**Title:** gcpctx: Never Confuse GCP Projects Again

**Description:**
```
Stop wrestling with `gcloud config set`. gcpctx is a kubectl-style context switcher for Google Cloud Platform.

Switch between GCP accounts, projects, and credentials with one command. Prevent production accidents with protected contexts and assertions.

Install:
npm install -g gcpctx

GitHub: https://github.com/UriBer/gcpctx
Docs: https://github.com/UriBer/gcpctx#readme

Timestamps:
0:00 The Problem
0:30 Quick Demo
1:00 Folder Markers
1:30 Production Safety
2:00 Installation
2:30 Conclusion
```

**Script:**

```
[0:00 - Intro]
"If you work with Google Cloud, you've probably typed 'gcloud config set project' more times than you'd like to admit.

And if you manage multiple environments - dev, staging, production - there's always that moment of panic: 'Wait... which project am I in?'

I built gcpctx to solve this problem once and for all."

[0:30 - Quick Demo]
[Screen: Terminal with demo]
"gcpctx works like kubectl contexts, but for GCP.

Watch: I can switch between dev, staging, and prod with one command.

(Type: gcpctx use dev)

That switched my account, project, ADC credentials, and environment variables all at once.

(Type: gcpctx current)

There it is. Dev context, project confirmed."

[1:00 - Folder Markers]
"But here's my favorite feature: folder markers.

Every project repo gets a .gcpctx file that says which GCP context it belongs to.

(Show: cat .gcpctx)

When I cd into this directory and run 'gcpctx activate'...

(Type: gcpctx activate)

...it automatically loads the right context. No manual switching. No mistakes."

[1:30 - Production Safety]
"And for production safety, gcpctx has protections built in.

(Type: gcpctx protect prod)

Now production is protected. If I try to switch to it...

(Type: gcpctx use prod)

...it blocks me.

You can also use assertions:

(Type: gcpctx assert --context dev && terraform apply)

This command only runs if I'm in the dev context. If I'm in prod by accident, it fails immediately."

[2:00 - Installation]
"Installing is simple:

(Show: npm install -g gcpctx)

Then run 'gcpctx shell-setup' to add shell integration.

It's 100% Bash, open source, Apache 2.0 licensed."

[2:30 - Conclusion]
"If you manage multiple GCP projects, give gcpctx a try.

Link in the description. Star it on GitHub if you find it useful.

Questions? Leave them in the comments. Thanks for watching!"

[End screen: GitHub link + subscribe button]
```

---

## Image Assets Checklist

- [ ] Logo/icon (512x512, transparent PNG)
- [ ] Social media card (1200x630 for Twitter, LinkedIn)
- [ ] Terminal screenshots (high-contrast theme)
- [ ] 6 demo GIFs (one per scenario)
- [ ] Architecture diagram (how gcpctx works)
- [ ] Feature comparison chart
- [ ] Security model diagram

---

## Launch Timeline

**Week 1: Preparation**
- [ ] Record all demo GIFs
- [ ] Create logo and social media assets
- [ ] Write blog post with embedded demos
- [ ] Prepare Twitter thread
- [ ] Write LinkedIn post
- [ ] Write Reddit posts

**Week 2: Soft Launch**
- [ ] Post on Twitter (personal account)
- [ ] Share in relevant Slack communities
- [ ] Post on r/devops, r/googlecloud
- [ ] Submit to Dev.to, Hashnode

**Week 3: Product Hunt Launch**
- [ ] Schedule Product Hunt launch
- [ ] Coordinate with upvote network
- [ ] Monitor comments and respond
- [ ] Cross-post to Twitter/LinkedIn

**Week 4: Hacker News**
- [ ] Post Show HN on a weekday morning (PST)
- [ ] Monitor comments actively for 24 hours
- [ ] Engage with feedback and questions

**Ongoing:**
- [ ] YouTube video (if comfortable)
- [ ] Guest posts on DevOps blogs
- [ ] Conference talk proposals
- [ ] Integration guides (Terraform, CI/CD, etc.)

---

## Hashtags & Keywords

**Twitter/X:**
`#DevOps` `#GoogleCloud` `#GCP` `#CloudEngineering` `#OpenSource` `#CLI` `#Productivity` `#DevTools` `#Terraform` `#CloudNative`

**LinkedIn:**
`#DevOps` `#GoogleCloud` `#CloudEngineering` `#OpenSource` `#Terraform` `#CloudArchitecture` `#SRE` `#CloudSecurity`

**Dev.to:**
`#googlecloud` `#devops` `#cli` `#opensource` `#productivity` `#bash` `#terraform`

**YouTube:**
Google Cloud, GCP, DevOps, Cloud Engineering, CLI tools, productivity, context switching, Terraform, gcloud

---

## Engagement Strategies

### For High Engagement:

1. **Post at optimal times:**
   - Twitter: 8-10am PST, Tuesday-Thursday
   - LinkedIn: 7-9am PST, Tuesday-Wednesday
   - Reddit: 9am-12pm PST, Monday-Thursday
   - Hacker News: 8-10am PST, Tuesday-Thursday

2. **Lead with pain points:**
   - "Ever accidentally deployed to production?"
   - "Typed 'gcloud config set' 47 times today?"
   - "Which GCP project am I in again?"

3. **Show, don't tell:**
   - Always include GIFs/videos
   - Before/after comparisons
   - Real commands, real output

4. **Engage in comments:**
   - Respond to every question within 1 hour
   - Thank people for feedback
   - Address concerns directly
   - Ask follow-up questions

5. **Cross-promote:**
   - Tweet about Reddit post
   - LinkedIn post links to blog
   - Blog links back to GitHub
   - Pin important tweets

### For Long-term Growth:

1. **Content series:**
   - "GCP Tips" weekly series
   - "Tool Tuesday" features
   - "Production Lessons" stories

2. **Community building:**
   - Create Discussions on GitHub
   - Discord or Slack channel
   - Regular contributor recognition

3. **Educational content:**
   - Tutorial videos
   - Integration guides
   - Best practices docs
   - Common pitfalls

4. **Partnerships:**
   - Terraform community
   - Google Cloud Developer Relations
   - DevOps newsletters
   - Podcast appearances
