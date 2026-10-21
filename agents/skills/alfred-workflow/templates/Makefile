DIST := dist
NAME := Example.alfredworkflow
BUILD := $(DIST)/.build
RUN := uv run --no-sync
SHELL_SCRIPTS := $(shell git ls-files '*.sh')
ZSH_SCRIPTS := $(shell git ls-files '*.zsh')
APPLESCRIPTS := $(shell git ls-files '*.applescript')
JSON_FILES := $(shell git ls-files '*.json')
export HOMEBREW_NO_AUTO_UPDATE := 1

.PHONY: setup icons test lint lint-python lint-shell lint-applescript lint-data lint-md lint-actions format format-check audit check ci clean build verify release sync-plist link-live

setup:
	brew bundle --quiet
	uv sync --group dev

icons:
	tools/build_icons.sh

test:
	$(RUN) pytest

lint: lint-python lint-shell lint-applescript lint-data lint-md lint-actions

lint-python:
	$(RUN) ruff check .
	$(RUN) pyright

lint-shell:
	$(if $(SHELL_SCRIPTS),shellcheck $(SHELL_SCRIPTS))
	$(foreach script,$(ZSH_SCRIPTS),zsh -n $(script) &&) true

lint-applescript:
ifdef CI
	@echo "lint-applescript: skipped in CI, compiling needs the target app installed"
else
	@mkdir -p $(BUILD)
	$(foreach script,$(APPLESCRIPTS),osacompile -o $(BUILD)/lint.scpt $(script) &&) rm -f $(BUILD)/lint.scpt
endif

lint-data:
	plutil -lint info.plist
	$(if $(JSON_FILES),jq empty $(JSON_FILES))

lint-md:
	markdownlint-cli2 "**/*.md"

lint-actions:
	actionlint

format:
	$(RUN) ruff format .

format-check:
	$(RUN) ruff format --check .

audit:
	$(RUN) pip-audit --skip-editable

check: lint format-check test

ci: check audit
