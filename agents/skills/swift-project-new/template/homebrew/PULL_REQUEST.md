# Homebrew pull request

Open against `Homebrew/homebrew-cask` from your fork, adding `Casks/<first letter>/__SLUG__.rb` with the contents of `homebrew/__SLUG__.rb`.

Title: `__SLUG__ X.Y.Z (new cask)`

Commit message: `__SLUG__ X.Y.Z (new cask)`

Tick a box only after doing it yourself. Answer reviewers yourself, without AI.

## Body

After making any changes to a cask, existing or new, verify:

- [ ] The submission is for [a stable version](https://docs.brew.sh/Acceptable-Casks#stable-versions) or [documented exception](https://docs.brew.sh/Acceptable-Casks#but-there-is-no-stable-version).
- [ ] `brew audit --cask --online __SLUG__` is error-free.
- [ ] `brew style --fix __SLUG__` reports no offenses.

Additionally, if adding a new cask:

- [ ] Named the cask according to the [token reference](https://docs.brew.sh/Cask-Cookbook#token-reference).
- [ ] Checked the cask was not [already refused](https://github.com/search?q=repo%3AHomebrew%2Fhomebrew-cask+is%3Aclosed+is%3Aunmerged+__SLUG__&type=pullrequests).
- [ ] `brew audit --cask --new __SLUG__` worked successfully.
- [ ] `HOMEBREW_NO_INSTALL_FROM_API=1 brew install --cask __SLUG__` worked successfully.
- [ ] `brew uninstall --cask __SLUG__` worked successfully.

-----

- [ ] I did not use AI/LLM to create this PR, or I disclosed the tool/model below and reviewed its output, including [`zap` stanza](https://docs.brew.sh/Cask-Cookbook#stanza-zap) paths; every commit has a human author or co-author and I will answer maintainer questions and review comments myself without AI/LLM.

I'm the developer of __APP__. I used Claude Code (Claude Opus) to draft this cask from the app's build settings and to run the checks above. I reviewed the cask myself: the `zap` paths are the folders and files __APP__ writes, named by its bundle ID `__BUNDLE_ID__`.

-----
