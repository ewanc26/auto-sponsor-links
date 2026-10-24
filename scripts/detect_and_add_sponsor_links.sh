#!/bin/bash
set -eo pipefail

KO_Fi_BADGE='[![Ko-fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/ewancroft)'
GH_SPONSORS_BADGE='[![GitHub Sponsors](https://img.shields.io/badge/GitHub%20Sponsors-30363D?style=for-the-badge&logo=github&logoColor=white)](https://github.com/sponsors/ewanc26)'

TARGET_USER="${TARGET_USER:-ewanc26}"
SPONSOR_LINK="github.com/sponsors/${TARGET_USER}"
BRANCH="add-sponsor-links"

# Runs with errexit suspended (it is called from an if), so every step that can fail returns explicitly.
add_sponsor_links() {
  local repo="$1"
  local workdir="/tmp/${repo//\//-}"
  local default_branch open_prs readme

  open_prs=$(gh pr list --repo "$repo" --head "$BRANCH" --state open --json number --jq 'length') || return 1
  if [ "$open_prs" != "0" ]; then
    echo "  An open sponsor-links PR already exists. Skipping."
    return 0
  fi

  default_branch=$(gh api "repos/${repo}" --jq '.default_branch') || return 1

  # Clone over HTTPS using the gh token: the runner has no SSH key.
  if ! gh repo clone "${repo}" "$workdir"; then
    echo "  ERROR: could not clone ${repo}."
    return 1
  fi
  cd "$workdir" || return 1

  git checkout -b "$BRANCH" "origin/${default_branch}" || return 1

  readme="README.md"
  if [ ! -f "$readme" ]; then
    echo "# ${repo#${TARGET_USER}/}" > "$readme"
  fi

  printf '\n%s\n%s\n%s\n%s\n' "## Support" "If you find this project useful, consider supporting its development:" "$KO_Fi_BADGE" "$GH_SPONSORS_BADGE" >> "$readme"

  git add "$readme" || return 1
  git commit -q -m "Add sponsor links to README" || return 1
  git push -q origin "$BRANCH" || return 1

  gh pr create \
    --repo "$repo" \
    --title "Add sponsor links to README" \
    --body "Automatically adds Ko-fi and GitHub Sponsors links to the README file." \
    --head "$BRANCH" || return 1

  echo "  PR created: https://github.com/${repo}/pull/new/${BRANCH}"
}

echo "Fetching all repositories owned by ${TARGET_USER}..."
repos=$(gh repo list "${TARGET_USER}" --limit 200 --visibility=public --json nameWithOwner,isFork,isArchived --jq '.[] | select(.isFork == false and .isArchived == false) | .nameWithOwner')

repo_count=$(echo "$repos" | grep -c . || true)
echo "Processing ${repo_count} repositories (non-forked, non-archived)."

failed_repos=()

for repo in $repos; do
  echo "Checking ${repo}..."

  readme_content=$(gh api "repos/${repo}/readme" --jq '.content' 2>/dev/null | base64 -d 2>/dev/null || echo "")
  if grep -q "$SPONSOR_LINK" <<< "$readme_content"; then
    echo "  Already has sponsor links. Skipping."
    continue
  fi

  echo "  Missing sponsor links. Creating PR to add them."

  if ! add_sponsor_links "$repo"; then
    echo "  FAILED: ${repo}. Continuing with the remaining repositories."
    failed_repos+=("$repo")
  fi

  cd /
  rm -rf "/tmp/${repo//\//-}"
done

if [ "${#failed_repos[@]}" -gt 0 ]; then
  echo "Sponsor link scan finished with failures in: ${failed_repos[*]}"
  exit 1
fi

echo "Sponsor link scan complete."
