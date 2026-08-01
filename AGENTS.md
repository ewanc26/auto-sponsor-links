# auto-sponsor-links

Automated monthly workflow that detects and adds sponsor links (Ko-fi and GitHub Sponsors) to repositories under the `ewanc26` GitHub account.

## Repository Purpose

This repository hosts a GitHub Actions workflow that scans all owned, non-forked, non-archived repositories monthly. For any repository missing sponsor links in its README file, it automatically creates a pull request with the appropriate sponsorship badges added.

## Prerequisites

1. GitHub CLI (`gh`) available on the runner
2. `jq` installed
3. `base64` available (standard on Ubuntu)

## Script Usage

The script `scripts/detect_and_add_sponsor_links.sh` performs the following steps:

1. Fetches all public repositories owned by the target user/organization using the GitHub API via `gh`
2. Filters out forks and archived repositories
3. For each remaining repository:
   - Clones the repository to `/tmp`
   - Checks for existing sponsor links in README.md
   - If missing, adds a Support section with Ko-fi and GitHub Sponsors badges
   - Commits changes and creates a PR

### Environment Variables

| Variable     | Description                          | Default |
|--------------|--------------------------------------|---------|
| TARGET_USER  | GitHub username to scan              | ewanc26 |

## Workflow Configuration

The GitHub Actions workflow (`.github/workflows/detect_missing_sponsor_links.yml`) runs:

- On the 1st of every month at 00:00 UTC
- Manually via `workflow_dispatch`

Permissions required:
- `contents: write` (for pushing branches)
- `pull-requests: write` (for creating PRs)

## Output

For each processed repository, the workflow logs:
- Whether sponsor links were found (skip) or missing (action taken)
- PR URL if a pull request was created

All new branches use the name `add-sponsor-links`.