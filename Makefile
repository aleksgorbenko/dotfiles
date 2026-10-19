.DEFAULT_GOAL := help
SHELL := /bin/bash

BREW_TOOLS := shellcheck gitleaks fish jq yamllint taplo actionlint

TRACKED := $(shell git ls-files -co --exclude-standard | sort -u | grep -v '^agents/skills/' | while IFS= read -r f; do if [ -f "$$f" ] && [ ! -L "$$f" ]; then printf '%s\n' "$$f"; fi; done)
SHELL_FILES := $(sort $(filter aliases/%.sh config/env.sh script/%,$(TRACKED)) $(shell for f in $(TRACKED); do if head -n1 "$$f" | grep -qE '^\#!.*(ba)?sh( |$$)'; then printf '%s\n' "$$f"; fi; done))
EXEC_FILES := $(filter bin/% script/% agents/scripts/%,$(SHELL_FILES))
FISH_FILES := $(filter %.fish,$(TRACKED))
ZSH_FILES := $(filter zsh/zshrc zsh/%.zsh,$(TRACKED))
JSON_FILES := $(filter-out config/%,$(filter %.json,$(TRACKED)))
PLIST_FILES := $(filter %.plist,$(TRACKED))
YAML_FILES := $(filter %.yml %.yaml,$(TRACKED))
TOML_FILES := $(filter %.toml,$(TRACKED))
WORKFLOW_FILES := $(filter .github/workflows/%,$(TRACKED))

define require_files
@if [ -z "$(strip $(2))" ]; then echo "$(1): 0 files matched, refusing to pass"; exit 1; fi
@echo "$(1): $(words $(2)) files"
endef

.PHONY: help setup check lint lint-shell lint-exec lint-fish lint-zsh lint-json lint-plist lint-yaml lint-toml lint-links lint-actions scan-secrets

help:
	@grep -E '^[a-z-]+:.*\#\# ' $(MAKEFILE_LIST) | sed -E 's/:.*\#\# /\t/' | sort

setup: ## Install lint and scan tools with Homebrew
	HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 brew install $(BREW_TOOLS)

check: lint scan-secrets ## Run every check

lint: lint-shell lint-exec lint-fish lint-zsh lint-json lint-plist lint-yaml lint-toml lint-links lint-actions ## Run every linter

lint-shell: ## shellcheck all tracked shell scripts
	$(call require_files,lint-shell,$(SHELL_FILES))
	shellcheck --severity=warning $(SHELL_FILES)

lint-exec: ## Entry-point scripts must be executable
	$(call require_files,lint-exec,$(EXEC_FILES))
	@bad=0; for f in $(EXEC_FILES); do if [ ! -x "$$f" ]; then echo "not executable: $$f"; bad=1; fi; done; exit $$bad

lint-fish: ## fish syntax check
	$(call require_files,lint-fish,$(FISH_FILES))
	@bad=0; for f in $(FISH_FILES); do fish --no-execute "$$f" || bad=1; done; exit $$bad

lint-zsh: ## zsh syntax check
	$(call require_files,lint-zsh,$(ZSH_FILES))
	@bad=0; for f in $(ZSH_FILES); do zsh -n "$$f" || bad=1; done; exit $$bad

lint-json: ## Strict JSON validity (editor JSONC keymaps excluded)
	$(call require_files,lint-json,$(JSON_FILES))
	@bad=0; for f in $(JSON_FILES); do jq empty "$$f" || bad=1; done; exit $$bad

lint-plist: ## plist validity (macOS only)
	$(call require_files,lint-plist,$(PLIST_FILES))
	plutil -lint $(PLIST_FILES)

lint-yaml: ## yamllint
	$(call require_files,lint-yaml,$(YAML_FILES))
	yamllint --strict $(YAML_FILES)

lint-toml: ## taplo syntax check
	$(call require_files,lint-toml,$(TOML_FILES))
	@taplo check $(TOML_FILES) 2>&1 | grep -v ' INFO '; exit $${PIPESTATUS[0]}

lint-links: ## Tracked symlinks must resolve
	@links=$$(git ls-files -s | awk '$$1==120000{print $$4}' | grep -v '^agents/skills/'); \
	n=$$(echo "$$links" | grep -c .); \
	if [ "$$n" -eq 0 ]; then echo "lint-links: 0 symlinks matched, refusing to pass"; exit 1; fi; \
	echo "lint-links: $$n symlinks"; bad=0; \
	for l in $$links; do if [ ! -e "$$l" ]; then echo "broken symlink: $$l"; bad=1; fi; done; exit $$bad

lint-actions: ## actionlint on GitHub workflows
	$(call require_files,lint-actions,$(WORKFLOW_FILES))
	actionlint $(WORKFLOW_FILES)

scan-secrets: ## gitleaks over full git history
	gitleaks detect --no-banner --redact --config .gitleaks.toml
