# auto-sponsor-links

Monthly GitHub Actions workflow that detects repositories under an organization or user account missing sponsor links (Ko-fi and GitHub Sponsors) and automatically creates pull requests to add them.

## What It Does

1. Scans all non-archived, non-fork repositories owned by a specified GitHub user/organization
2. Checks each repository's `README.md` for existing GitHub Sponsors badge
3. For repositories missing sponsor links:
   - Clones the repository
   - Creates a new branch (`add-sponsor-links`)
   - Appends a `## Support` section with Ko-fi and GitHub Sponsors badges to `README.md`
   - Commits and pushes changes
   - Creates a pull request

## Sponsor Links

If you find this project useful, consider supporting its development:

[![Ko-fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/ewancroft)
[![GitHub Sponsors](https://img.shields.io/badge/GitHub%20Sponsors-30363D?style=for-the-badge&logo=github&logoColor=white)](https://github.com/sponsors/ewanc26)