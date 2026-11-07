# AGENTS.md

Guidance for AI coding agents working in **auto-sponsor-links**.

## Project overview

Monthly GitHub Actions workflow that detects repositories missing sponsor links and creates PRs to add them

- Language: Shell
- Default branch: main

## Working rules

- Inspect the README, manifests, CI workflows, and nearby code before editing.
- Preserve existing architecture, naming, formatting, and error-handling conventions.
- Use project scripts for validation; never claim checks you did not run.
- Keep changes scoped and update tests or documentation when behavior changes.
- Use feature branches and pull requests.
- Treat generated files, credentials, deployment configuration, and release metadata as sensitive.

## Recent history

Report per-repo failures from sponsor link script (#5); Merge pull request #3 from ewanc26/add-license; Add AGPL-3.0 license; Merge pull request #2 from ewanc26/fix/clone-via-gh-token; fix: clone with gh over HTTPS and stop masking clone failures; Merge branch 'main' of github.com:ewanc26/auto-sponsor-links; docs: tailor contributor and agent guidance (#1)