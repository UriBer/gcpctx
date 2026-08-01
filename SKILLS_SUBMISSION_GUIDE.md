# AI Agent Skills Submission Guide

This guide explains where and how to submit the gcpctx AI agent skills to make them discoverable by AI agents.

## Overview

As of August 2026, there are **three primary venues** for publishing AI agent skills:

1. **Cursor Marketplace** (Official) - Manual review, broadest reach
2. **cursor.directory** (Community) - Auto-indexed, immediate listing
3. **GitHub + npx skills** (Direct Install) - No approval needed

## Submission Checklist

Before submitting, verify:

- [x] Skills in `skills/` directory with `SKILL.md` files
- [x] `.cursor-plugin/plugin.json` manifest created
- [x] `.cursor-plugin/marketplace.json` created
- [x] Logo in `assets/logo.svg` (512x512)
- [x] `SKILLS_README.md` with installation instructions
- [x] All skills have frontmatter (description, category, tags)
- [ ] All commits pushed to GitHub
- [ ] Repository is public
- [ ] README has clear installation instructions

## Venue 1: Cursor Marketplace (Official)

### Audience
- All Cursor IDE users
- Highest visibility
- Appears in **Cursor → Customize → Plugins**

### Process
1. **Prepare Repository:**
   ```bash
   git add .cursor-plugin/ skills/ assets/ SKILLS_README.md
   git commit -m "Add AI agent skills plugin"
   git push origin main
   ```

2. **Submit:**
   - Go to: https://cursor.com/marketplace/publish
   - Submit repository URL: `https://github.com/UriBer/gcpctx`
   - Wait for manual review by Cursor team (typically 3-7 days)

3. **Alternative Contact:**
   - Email: `kniparko@anysphere.com`
   - Subject: "Cursor Plugin Submission: gcpctx"
   - Body: Include GitHub URL, brief description, logo

### What Gets Reviewed
- ✅ Plugin manifest validity
- ✅ Skill quality and usefulness
- ✅ Security considerations
- ✅ License compatibility
- ✅ Logo and branding

### After Approval
Users can install directly:
- Open **Cursor → Customize → Plugins**
- Search "gcpctx"
- Click "Install"

### Status
⏳ **Pending Submission**

**Action Required:** Submit at https://cursor.com/marketplace/publish

---

## Venue 2: cursor.directory (Community Catalog)

### Audience
- Cursor and Claude Code users
- Community-driven discovery
- Immediate listing (no review)

### Process
1. **Ensure GitHub Repository is Public:**
   ```bash
   # Repository must be at: https://github.com/UriBer/gcpctx
   ```

2. **Submit to cursor.directory:**
   - Go to: https://cursor.directory/plugins/new
   - Paste: `https://github.com/UriBer/gcpctx`
   - Click "Submit"
   - Auto-detection validates structure
   - Listing appears immediately

### What Gets Auto-Detected
- ✅ `.cursor-plugin/plugin.json` manifest
- ✅ `skills/` directory with SKILL.md files
- ✅ Repository metadata (stars, description, license)
- ✅ Logo from `assets/` or GitHub social preview

### After Listing
Users find via:
- Browse: https://cursor.directory/plugins
- Search: "gcpctx", "gcp", "google cloud"
- Install: Click "Add to Cursor" → Opens Cursor IDE

### Status
⏳ **Ready to Submit**

**Action Required:** Submit at https://cursor.directory/plugins/new

---

## Venue 3: GitHub + npx skills (Direct Install)

### Audience
- Cursor, Claude Code, VS Code users
- Developers who want bleeding-edge updates
- Teams using custom skill workflows

### Process
**Already Complete!** Repository structure is ready.

Users can install via:

#### Method 1: npx skills CLI
```bash
npx skills add UriBer/gcpctx
```

#### Method 2: Cursor Team Marketplace
1. Open **Cursor → Customize → Plugins**
2. Click **Import marketplace**
3. Paste: `https://github.com/UriBer/gcpctx`
4. Install "gcpctx" plugin from imported marketplace

#### Method 3: Manual Clone
```bash
# Global installation
git clone https://github.com/UriBer/gcpctx ~/.cursor/skills/gcpctx

# Project-specific installation
git clone https://github.com/UriBer/gcpctx .cursor/skills/gcpctx
```

### Promotion Channels
Once repository is live, promote via:

- **README badges:** Add "Install with npx skills" badge
- **Twitter/X:** "New AI agent skills for gcpctx!"
- **Reddit:** r/cursor, r/ClaudeCode, r/googlecloud
- **Dev.to:** Tutorial on using skills
- **GitHub Topics:** Add topics: `cursor-plugin`, `ai-agents`, `agent-skills`, `gcp`

### Status
✅ **Live** (as soon as GitHub repo is public)

**Action Required:** Add GitHub topics and promote

---

## Installation Examples for Users

### Cursor IDE

**Via Marketplace (after approval):**
```
1. Cursor → Customize → Plugins
2. Search "gcpctx"
3. Click "Install"
```

**Via Team Marketplace (immediate):**
```
1. Cursor → Customize → Plugins
2. Import marketplace: https://github.com/UriBer/gcpctx
3. Install "gcpctx"
```

### Claude Code

```bash
npx skills add UriBer/gcpctx
```

### VS Code / OpenCode

```bash
npx skills add UriBer/gcpctx
```

---

## Validation

### Test Locally Before Submission

**Cursor IDE:**
```bash
# Copy to local plugins directory
mkdir -p ~/.cursor/plugins/local/gcpctx
cp -r .cursor-plugin skills assets ~/.cursor/plugins/local/gcpctx

# Restart Cursor
# Check: Cursor → Customize → Plugins → "gcpctx" appears
```

**Test Skills:**
```
1. Open Cursor
2. Start Agent chat
3. Type "/" - gcpctx skills should appear
4. Test each skill with sample prompts
```

### Validate Plugin Structure

Run validation script (if available):
```bash
# From cursor/plugin-template
node scripts/validate-template.mjs
```

Or manually check:
- [ ] `.cursor-plugin/plugin.json` is valid JSON
- [ ] `.cursor-plugin/marketplace.json` is valid JSON
- [ ] All skills have `SKILL.md` with frontmatter
- [ ] Logo exists at `assets/logo.svg`
- [ ] No syntax errors in markdown

---

## Post-Submission Actions

### 1. Update Main README

Add installation section to main `README.md`:

```markdown
## AI Agent Skills

AI agents can use gcpctx through our official skills:

**Install in Cursor:**
1. Cursor → Customize → Plugins
2. Search "gcpctx" or import: https://github.com/UriBer/gcpctx

**Install in Claude Code:**
```bash
npx skills add UriBer/gcpctx
```

Skills included:
- `gcpctx-usage` - Core context management
- `gcpctx-safety` - Production safety features
- `gcpctx-troubleshooting` - Debug and fix issues
- `gcpctx-cicd` - CI/CD integration

See [AI Agent Skills](./SKILLS_README.md) for details.
```

### 2. Add GitHub Topics

Add these topics to the GitHub repository:

- `cursor-plugin`
- `agent-skills`
- `ai-agents`
- `gcp`
- `google-cloud`
- `devops`
- `context-switching`
- `credentials`

**How to add:**
1. Go to: https://github.com/UriBer/gcpctx
2. Click "About" → ⚙️ (settings)
3. Add topics
4. Save

### 3. Add Badges to README

Add these badges to the top of README.md:

```markdown
[![Cursor Plugin](https://img.shields.io/badge/Cursor-Plugin-blue)](https://cursor.com/marketplace)
[![Agent Skills](https://img.shields.io/badge/Agent-Skills-green)](https://cursor.directory/plugins)
[![Install with npx](https://img.shields.io/badge/npx-skills_add-orange)](https://npmjs.com/package/npx)
```

### 4. Announce on Social Media

**Twitter/X:**
```
🚀 New: AI agent skills for gcpctx!

Teach AI agents to:
✅ Switch GCP contexts safely
✅ Prevent production accidents
✅ Troubleshoot credential issues
✅ Automate CI/CD deployments

Install in Cursor: https://github.com/UriBer/gcpctx

#AIAgents #Cursor #GCP #DevOps
```

**Reddit (r/cursor):**
```
Title: [Plugin] gcpctx AI Agent Skills - GCP Context Management

I've published AI agent skills for gcpctx (GCP context switcher).

Skills included:
- Core usage (init, switch, multi-project)
- Production safety (protect, assert, safe exec)
- Troubleshooting (doctor, secrets fix)
- CI/CD integration (GitHub Actions, GitLab)

Install: Cursor → Plugins → Import: https://github.com/UriBer/gcpctx
Or: npx skills add UriBer/gcpctx

Feedback welcome!
```

### 5. Monitor Installations

Track via:
- GitHub stars and forks
- npm downloads (for CLI tool)
- cursor.directory stats (if available)
- GitHub traffic analytics

---

## Maintenance

### Updating Skills

When you update skills:

```bash
# Update version in plugin.json
# Edit: .cursor-plugin/plugin.json
# Increment "version": "1.0.0" → "1.0.1"

# Commit changes
git add skills/ .cursor-plugin/plugin.json
git commit -m "Update skills: [description]"
git push

# Users update via:
# - Cursor: Plugins → Update
# - npx: npx skills add UriBer/gcpctx (reinstall)
```

### Versioning Strategy

Follow semantic versioning:
- `1.0.0` - Initial release
- `1.0.1` - Bug fixes, typos
- `1.1.0` - New skill added
- `2.0.0` - Breaking changes to skill format

---

## Troubleshooting Submission

### "Repository not found"
- Ensure repository is public
- Check URL is correct: `https://github.com/UriBer/gcpctx`
- Verify you're logged into GitHub

### "Invalid plugin structure"
- Run validation: Check `.cursor-plugin/plugin.json` syntax
- Ensure `skills/` directory exists
- Verify each skill has `SKILL.md`

### "Skills not appearing in Cursor"
- Restart Cursor IDE
- Check plugin is enabled: Customize → Plugins
- Verify skills directory path in manifest

### "npx skills fails"
- Ensure repository has proper structure
- Check `skills/*/SKILL.md` files have frontmatter
- Verify repository is cloneable: `git clone https://github.com/UriBer/gcpctx`

---

## Summary

| Venue | Submission URL | Review Time | Reach |
|-------|---------------|-------------|-------|
| **Cursor Marketplace** | https://cursor.com/marketplace/publish | 3-7 days | ⭐⭐⭐⭐⭐ Highest |
| **cursor.directory** | https://cursor.directory/plugins/new | Immediate | ⭐⭐⭐⭐ High |
| **GitHub + npx** | (Already live) | None | ⭐⭐⭐ Medium |

### Next Steps

1. ✅ Skills created (complete)
2. ✅ Plugin manifest created (complete)
3. ✅ Logo created (complete)
4. ⏳ **Push to GitHub** (if not done)
5. ⏳ **Submit to Cursor Marketplace**
6. ⏳ **Submit to cursor.directory**
7. ⏳ **Add GitHub topics**
8. ⏳ **Announce on social media**

---

## Contact

For submission issues:
- **Cursor Team:** `kniparko@anysphere.com`
- **cursor.directory:** Support via their website
- **GitHub:** Open issue at https://github.com/cursor/plugin-template/issues

---

**Good luck with your submission!** 🚀
