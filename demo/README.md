# gcpctx Demo & Social Media Content

This directory contains working examples and demo scenarios for showcasing **gcpctx** on social media.

## 📱 Social Media Ready Scenarios

Each scenario is designed to be recorded as a GIF (using tools like `asciinema` + `agg`, `vhs`, or `terminalizer`).

### Scenario 1: Quick Context Switch (15 seconds)
**Perfect for Twitter/X thread opener**

Shows the core value prop: switch GCP contexts safely and instantly.

```bash
# Show current context
gcpctx current

# List available contexts
gcpctx list

# Switch to production
gcpctx use prod

# Verify the switch
gcpctx current --json
```

**Caption idea:**
> 🚀 Stop typing `gcloud config set` over and over!
> 
> gcpctx lets you switch between GCP accounts/projects instantly.
> 
> No more credential mixups. No more scary "whoops wrong project" moments.

---

### Scenario 2: Project Safety (20 seconds)
**Perfect for LinkedIn/Twitter with security angle**

Shows the safety mechanism that prevents production accidents.

```bash
# Protect production context
gcpctx protect prod

# Try to switch (shows protection prompt)
gcpctx use prod

# Assert you're in the right context
gcpctx assert --context dev --project my-dev-project

# This fails if you're in the wrong place!
gcpctx assert --context prod
```

**Caption idea:**
> 🛡️ "Did I just delete the production database?"
> 
> gcpctx has your back with:
> • Protected contexts (can't accidentally switch)
> • Assertions (fails fast if you're in wrong project)
> • Folder markers (auto-activates the right context per project)

---

### Scenario 3: Multi-Project Workflow (25 seconds)
**Perfect for DevOps/SRE communities**

Shows managing multiple projects within one account/context.

```bash
# Initialize a dev context
gcpctx init --name dev --account dev@company.com

# Scan for available projects
gcpctx scan dev

# List all projects
gcpctx projects dev

# Switch between projects without re-login
gcpctx use dev --project project-alpha
gcpctx current

gcpctx project project-beta
gcpctx current
```

**Caption idea:**
> 🔄 Managing 50 GCP projects across 3 accounts?
> 
> gcpctx makes it painless:
> 1. Scan once to discover all your projects
> 2. Switch projects instantly (no re-auth!)
> 3. One command to see where you are
> 
> Stop context switching. Start shipping.

---

### Scenario 4: Folder Markers (20 seconds)
**Perfect for developer workflow demos**

Shows automatic context activation per project directory.

```bash
# Go to project directory
cd ~/projects/frontend-app

# Create a context marker
echo '{"name":"dev","project":"frontend-dev"}' > .gcpctx

# Activate (reads .gcpctx in current directory)
gcpctx activate

# Environment variables are set!
env | grep GOOGLE_
env | grep GCPCTX_

# Any gcloud/terraform commands now use the right context
gcloud config list
```

**Caption idea:**
> 📁 Your code knows which GCP project it belongs to.
> 
> Drop a `.gcpctx` file in your repo:
> ```json
> {"name":"staging","project":"my-staging-project"}
> ```
> 
> Run `gcpctx activate` → boom, right context every time.
> 
> Works with gcloud, Terraform, Python SDK, everything.

---

### Scenario 5: Safe Execution (15 seconds)
**Perfect for security-focused posts**

Shows the exec wrapper that ensures commands run in the right context.

```bash
# Run a command with explicit context requirement
gcpctx exec --require-context dev -- gcloud compute instances list

# This fails if you're not in 'dev' context
gcpctx exec --require-context prod -- terraform apply

# Assert before running dangerous commands
gcpctx assert --project safe-sandbox && terraform destroy
```

**Caption idea:**
> ⚠️ `terraform destroy` in production by accident?
> 
> Never again.
> 
> ```bash
> gcpctx exec --require-context dev -- terraform apply
> ```
> 
> If you're not in the 'dev' context, the command won't run. Period.

---

### Scenario 6: Doctor & Troubleshooting (20 seconds)
**Perfect for showing polish and production-readiness**

Shows health checks and credential management.

```bash
# Run health check
gcpctx doctor

# Fix credential permissions
gcpctx secrets fix

# Check all contexts with detailed JSON
gcpctx doctor --json

# Verify everything is working
gcpctx list
gcpctx current
```

**Caption idea:**
> 🔧 Production-ready tooling includes health checks.
> 
> `gcpctx doctor` verifies:
> ✓ Credential file permissions (0600)
> ✓ ADC validity
> ✓ gcloud config integrity
> ✓ Context metadata consistency
> 
> `gcpctx secrets fix` → auto-repairs common issues.

---

## 🎬 Recording Commands

### Using asciinema + agg
```bash
# Install
brew install asciinema
cargo install --git https://github.com/asciinema/agg

# Record
asciinema rec demo-scenario-1.cast -c "bash demo/scenarios/01-quick-switch.sh"

# Convert to GIF
agg demo-scenario-1.cast demo-scenario-1.gif
```

### Using vhs
```bash
# Install
brew install vhs

# Record (using .tape file)
vhs demo/scenarios/01-quick-switch.tape
```

### Using terminalizer
```bash
# Install
npm install -g terminalizer

# Record
terminalizer record demo-1 -c demo/terminalizer-config.yml

# Render
terminalizer render demo-1 -o demo-1.gif
```

---

## 📊 Socket.dev Security Score Analysis

**Why gcpctx scores 51 in Supply Chain Security:**

### Detected Alerts

1. **Shell Access (MEDIUM)** 🔴
   - gcpctx is a Bash CLI that executes shell commands
   - **Why it's safe:** All shell execution is controlled and validated
   - Scripts use strict bash modes (`set -eo pipefail`)
   - No eval of user input, no command injection vectors

2. **Filesystem Access (LOW)** 🟡
   - Manages context files in `~/.gcpctx/`
   - Writes credential files with secure permissions (0600)
   - **Why it's safe:** All paths are validated and confined to GCPCTX_HOME
   - Uses atomic file writes with temp files

3. **Environment Variable Access (LOW)** 🟡
   - Reads/writes GCP SDK environment variables
   - **Why it's safe:** Only allowlisted variables are exported
   - No credential data in env vars (only file paths)

4. **Recently Published (MEDIUM)** 🟡
   - Version 0.3.0 was published recently
   - **Why it's safe:** See security invariants below

### Security Posture

gcpctx follows 20 documented security invariants (see [SECURITY.md](../SECURITY.md)):

- ✅ **No credential leakage:** Secrets never printed or logged
- ✅ **Restrictive file permissions:** 0700 dirs, 0600 files
- ✅ **Input validation:** Names/IDs validated, shell injection prevented
- ✅ **Atomic operations:** Credential updates use atomic replace
- ✅ **No telemetry:** Zero external network calls
- ✅ **Tested:** Security behavior covered by automated tests

### Other Scores

| Metric | Score | Status |
|--------|-------|--------|
| Vulnerability | 100 | ✅ Excellent |
| License | 100 | ✅ Excellent (Apache-2.0) |
| Quality | 81 | ✅ Good |
| Maintenance | 86 | ✅ Good |
| **Supply Chain** | **51** | ⚠️ **Expected for CLI tools** |

### The Bottom Line

**The score of 51 is completely normal and expected** for a Bash-based credential management tool.

Socket.dev's scoring is intentionally conservative. It flags *any* shell/filesystem/env access as potentially risky because these are common malware vectors.

**gcpctx is legitimate and secure** - the alerts reflect *what the tool does* (manage credentials via shell), not *vulnerabilities*.

---

## 🎨 Visual Assets

### GIF Specifications
- **Format:** GIF or MP4
- **Duration:** 15-30 seconds per scenario
- **Size:** Optimize for Twitter (< 15MB), LinkedIn (< 5MB)
- **Terminal theme:** Use high-contrast theme (dracula, nord, monokai)
- **Window size:** 80x24 or 100x30 for readability

### Recommended Tools
- **asciinema + agg:** Best quality, lightweight
- **vhs:** Declarative, great for consistent styling
- **terminalizer:** Feature-rich, good for editing

---

## 📝 Social Media Copy Templates

### Thread Starter (Twitter/X)
> 🧵 Stop wrestling with `gcloud config set`.
> 
> I built gcpctx to solve the "which GCP context am I in?" problem once and for all.
> 
> Thread: Why managing 5+ GCP projects drove me to create a better context switcher 👇

### Problem/Solution (LinkedIn)
> After accidentally running `terraform destroy` in production (😱), I built gcpctx.
> 
> It's like kubectl contexts, but for GCP:
> • Switch accounts/projects instantly
> • Protect production with assertions
> • Auto-activate contexts per directory
> 
> 100% Bash, zero dependencies, just works.
> 
> [GIF demo]

### Developer Audience (Dev.to / Hashnode)
> # Never Confuse GCP Projects Again
> 
> If you've ever:
> - Run `gcloud config set project` 47 times a day
> - Wondered "wait, which project am I in?"
> - Had a heart attack after deploying to production by accident
> 
> ...then gcpctx is for you.
> 
> [Detailed tutorial with embedded GIFs]

---

## 🚀 Launch Checklist

- [ ] Record all 6 scenario GIFs
- [ ] Create demo video (2-3 minutes)
- [ ] Write blog post with embedded demos
- [ ] Prepare Twitter thread (8-10 tweets)
- [ ] LinkedIn post with use cases
- [ ] Reddit post for r/devops, r/googlecloud
- [ ] Dev.to / Hashnode article
- [ ] Product Hunt launch page
- [ ] Hacker News Show HN post

---

## 📧 Contact & Links

- **GitHub:** https://github.com/UriBer/gcpctx
- **npm:** https://www.npmjs.com/package/gcpctx
- **Socket.dev:** https://socket.dev/npm/package/gcpctx
- **Issues:** https://github.com/UriBer/gcpctx/issues
