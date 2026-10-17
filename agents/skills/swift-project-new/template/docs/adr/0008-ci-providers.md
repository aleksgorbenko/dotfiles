# 0008. Xcode Cloud runs macOS CI; GitHub runs Linux scans

- Status: Accepted __DATE__

## Decision
- Xcode Cloud (25 hours a month with the developer membership) tests main.
- GitHub runs secret and dependency scans on Linux for every pull request; its macOS jobs stay in `ci.yml` behind `vars.MACOS_CI == 'true'` or a manual run.
- CI triggers on pull requests only, never also on branch pushes.
- Dependabot is configured with `open-pull-requests-limit: 0` until the repository is public.

## Consequences
- GitHub bills macOS minutes at 10× on private repositories; the free 2,000 minutes buy 200 real macOS minutes.
- Switch GitHub macOS CI on with `gh variable set MACOS_CI --body true`.

## Rejected
- Paying for GitHub macOS minutes while Xcode Cloud covers the same tests.
