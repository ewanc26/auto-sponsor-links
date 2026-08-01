#!/bin/bash
set -e

KO_Fi_BADGE='[![Ko-fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/ewancroft)'
GH_SPONSORS_BADGE='[![GitHub Sponsors](https://img.shields.io/badge/GitHub%20Sponsors-30363D?style=for-the-badge&logo=github&logoColor=white)](https://github.com/sponsors/ewanc26)'

TARGET_USER="${TARGET_USER:-ewanc26}"
SPOILER_BADGE_REGEX="github.com/sponsors/${TARGET_USER}"

echo "Fetching all repositories owned by ${TARGET_USER}..."
repos=$(gh repo list "${TARGET_USER}" --public --limit 200 --json nameWithOwner,isFork,archived,name,primaryBranch --jq '.[] | select(.isFork == false and .archived == false) | .nameWithOwner')

echo "Processing ${#repos[@]} repositories (non-forked, non-archived)."

for repo in $repos; do
  echo "Checking ${repo}..."

  if gh api repos/${repo}/readme -q content | base64 --decode 2>/dev/null | grep -q "${SPOILER_BADGE_REGEX}"; then
    echo "  Already has sponsor links. Skipping."
    continue
  fi

  echo "  Missing sponsor links. Creating PR to add them."

  branch="add-sponsor-links"
  default_branch=$(gh api repos/${repo} -q '.default_branch')

  git clone "git@github.com:${repo}.git" "/tmp/${repo//\//-}" 2>&1 | tail -1
  cd "/tmp/${repo//\//-}"

  git checkout -b "$branch" "origin/$default_branch"

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
    --head "$branch"

  echo "  PR created successfully: https://github.com/${repo}/pull/new/${branch}"
  cd -
  rm -rf "/tmp/${repo//\//-}"
done

echo "Sponsor link scan complete."