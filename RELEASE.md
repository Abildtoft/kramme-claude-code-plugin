# Release Process

This document describes how to release a new version of kramme-cc-workflow.

## Version Numbering

- **Patch** (0.2.0 → 0.2.1): Bug fixes, documentation updates, minor improvements
- **Minor** (0.2.0 → 0.3.0): New commands, agents, skills, or hooks
- **Major** (0.2.0 → 1.0.0): Breaking changes

## Automated Release

### Option 1: GitHub Actions (Recommended)

Trigger a release from the GitHub UI:

1. Go to **Actions** → **Release**
2. Click **Run workflow**
3. Select version type (patch/minor/major)
4. Optionally enable dry run to preview changes
5. Click **Run workflow**

The workflow will:
- Run tests
- Bump version in `plugin.json`
- Create git tag
- Push changes
- Create GitHub Release with auto-generated notes

### Option 2: Local Script

Run the release script locally:

```bash
# Patch release (0.2.0 → 0.2.1)
python scripts/release.py patch

# Minor release (0.2.0 → 0.3.0)
python scripts/release.py minor

# Major release (0.2.0 → 1.0.0)
python scripts/release.py major

# Explicit version
python scripts/release.py 1.0.0

# Preview without making changes
python scripts/release.py patch --dry-run
```

The script will:
- Run tests
- Prompt for confirmation
- Bump version in `plugin.json`
- Create git commit and tag
- Create GitHub Release (requires `gh` CLI)

After running, push the changes:
```bash
git push origin main --tags
```

## Manual Release

If you prefer manual control:

### 1. Prepare

```bash
git checkout main
git pull
make test
```

### 2. Generate Changelog (Optional)

Use the changelog-generator skill:
```
Create a changelog for commits since the last release tag
```

### 3. Bump Version

Update `.claude-plugin/plugin.json`:
```json
{
  "version": "X.Y.Z"
}
```

### 4. Commit and Tag

```bash
git add .claude-plugin/plugin.json CHANGELOG.md
git commit -m "Release vX.Y.Z"
git tag vX.Y.Z
git push origin main --tags
```

### 5. Create GitHub Release

```bash
gh release create vX.Y.Z --title "vX.Y.Z" --generate-notes
```

## After Release

Users update via:

```bash
claude /plugin marketplace update kramme-cc-workflow
```

Or for git installs:

```bash
claude /plugin install git+https://github.com/Abildtoft/kramme-cc-workflow
```
