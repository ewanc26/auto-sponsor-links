#!/bin/bash
set -e

KO_Fi_BADGE='[![Ko-fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/ewancroft)'
GH_SPONSORS_BADGE='[![GitHub Sponsors](https://img.shields.io/badge/GitHub%20Sponsors-30363D?style=for-the-badge&logo=github&logoColor=white)](https://github.com/sponsors/ewanc26)'

TARGET_USER="${TARGET_USER:-ewanc26}"
SPONSOR_LINK="github.com/sponsors/${TARGET_USER}"

echo "Fetching all repositories owned by ${TARGET_USER}..."
repos=$(gh repo list "${TARGET_USER}" --limit 200 --visibility=public --json nameWithOwner,isFork,isArchived --jq '.[] | select(.isFork == false and .isArchived == false) | .nameWithOwner')

repo_count=$(echo "$repos" | grep -c . || true)
echo "Processing ${repo_count} repositories (non-forked, non-archived)."

for repo in $repos; do
  echo "Checking ${repo}..."

  # Check if sponsor links already exist
  readme_content=$(gh api "repos/${repo}/readme" --jq '.content' 2>/dev/null | base64 -d 2>/dev/null || echo "")
  if echo "$readme_content" | grep -q "$SPONSOR_LINK"; then
    echo "  Already has sponsor links. Skipping."
    continue
  fi

  echo "  Missing sponsor links. Creating PR to add them."

  branch="add-sponsor-links"
  default_branch=$(gh api "repos/${repo}" --jq '.default_branch')

  git clone "git@github.com:${repo}.git" "/tmp/${repo//\//-}" 2>&1 | tail -1
  cd "/tmp/${repo//\//-}"

  git checkout -b "$branch" "origin/${default_branch}"

  readme="README.md"
  if [ ! -f "$readme" ]; then
    echo "# ${repo#${TARGET_USER}/}" > "$readme"
  fi

  printf '\n%s\n%s\n%s\n%s\n' "## Support" "If you find this project useful, consider supporting its development:" "$KO_Fi_BADGE" "$GH_SPONSORS_BADGE" >> "$readme"

  git add "$readme"
  git commit -m "Add sponsor links to README" --no-verify
  git push origin "$branch"

  gh pr create \
    --repo "$repo" \
    --title "Add sponsor links to README" \
    --body "Automatically adds Ko-fi and GitHub Sponsors links to the README file." \
    --head "$branch" 2>/dev/null || echo "  PR may already exist."

  echo "  PR created or updated: https://github.com/${repo}/pull/new/${branch}"
  cd - >/dev/null
  rm -rf "/tmp/${repo//\//-}"
done

echo "Sponsor link scan complete."