SHELL := /bin/bash

APP_NAME := __APP__
WORKSPACE := __APP__.xcworkspace
SCHEME := __SLUG__
DESTINATION := platform=macOS,arch=arm64
STRINGS_CATALOG := __SLUG__/Localizable.xcstrings
ANALYZE_PACKAGES :=

XCODEBUILD_FLAGS ?=
XCBEAUTIFY ?=
XCODEBUILD_LOG ?=
XCODEBUILD_PREPARE = $(if $(XCODEBUILD_LOG),mkdir -p $(dir $(XCODEBUILD_LOG));)
XCODEBUILD_OUTPUT = $(if $(XCODEBUILD_LOG),2>&1 | tee $(XCODEBUILD_LOG)) $(if $(XCBEAUTIFY),2>&1 | $(XCBEAUTIFY))
COMPILER_LOG ?=
COVERAGE_RESULT := build.noindex/coverage.xcresult
COVERAGE_MIN := 80
ITERATIONS ?= 100
TESTS ?=
PROFILE_SECONDS ?= 60
PROFILE_TOP ?= 20

.PHONY: help generate-project check-project build run test test-coverage test-tsan test-until-failure \
        check-warnings check-release lint lint-analyze fmt fmt-check test-scripts \
        scan-secrets scan-staged-secrets scan-dependencies install-hooks generate-licences profile-memory

help:
	@echo "generate-project   - xcodegen generate from project.yml"
	@echo "check-project      - Fail if the committed .pbxproj differs from project.yml"
	@echo "build / run        - Debug build / build and open the app"
	@echo "test               - Full test plan"
	@echo "test-coverage      - Full tests with coverage, fail below COVERAGE_MIN%"
	@echo "test-tsan          - Tests under Thread Sanitizer, fail on any race"
	@echo "test-until-failure - Repeat tests until one fails (TESTS=<target/suite>, ITERATIONS=100)"
	@echo "check-warnings     - Fail on any warning in project sources (XCODEBUILD_LOG=<raw xcodebuild log>)"
	@echo "check-release      - Release gate: every check plus full tests, coverage and warnings"
	@echo "lint / lint-analyze - SwiftLint and string keys / SwiftLint analyzer rules"
	@echo "fmt / fmt-check    - swift-format in place / check only"
	@echo "test-scripts       - Unit tests for scripts/"
	@echo "scan-secrets       - gitleaks over the full history (scan-staged-secrets: staged changes)"
	@echo "scan-dependencies  - OSV-Scanner over every Package.resolved"
	@echo "install-hooks      - Install the lefthook pre-commit hook"
	@echo "generate-licences  - Third-party licence acknowledgements, fail on a missing licence"
	@echo "profile-memory     - Release build under Instruments (Leaks): peak, final, leaks, top classes, growth, .trace, .memgraph (PROFILE_SECONDS=60, PROFILE_TOP=20)"

generate-project:
	xcodegen generate --spec project.yml --quiet

check-project:
	@tmp=$$(mktemp -d); cp -R __SLUG__.xcodeproj/xcshareddata/xcschemes "$$tmp/" 2>/dev/null || true; \
	xcodegen generate --spec project.yml --quiet; status=$$?; \
	if [ -d "$$tmp/xcschemes" ]; then rm -rf __SLUG__.xcodeproj/xcshareddata/xcschemes; cp -R "$$tmp/xcschemes" __SLUG__.xcodeproj/xcshareddata/; fi; \
	rm -rf "$$tmp"; [ $$status -eq 0 ] || exit $$status; \
	command git diff --exit-code --stat -- __SLUG__.xcodeproj/project.pbxproj

build:
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) -configuration Debug -destination '$(DESTINATION)' $(XCODEBUILD_FLAGS) build

run: build
	open -a "$$(xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) -configuration Debug -showBuildSettings 2>/dev/null | awk -F'= ' '/ BUILT_PRODUCTS_DIR /{print $$2; exit}')/$(APP_NAME).app"

test:
	set -o pipefail; $(XCODEBUILD_PREPARE) xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) -destination '$(DESTINATION)' \
		$(XCODEBUILD_FLAGS) test $(XCODEBUILD_OUTPUT)

test-coverage:
	rm -rf $(COVERAGE_RESULT)
	set -o pipefail; $(XCODEBUILD_PREPARE) xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) -destination '$(DESTINATION)' \
		-enableCodeCoverage YES -resultBundlePath $(COVERAGE_RESULT) $(XCODEBUILD_FLAGS) test $(XCODEBUILD_OUTPUT)
	xcrun xccov view --report --json $(COVERAGE_RESULT) > $(COVERAGE_RESULT).json
	python3 scripts/check_coverage.py $(COVERAGE_RESULT).json $(COVERAGE_MIN)

test-tsan:
	set -o pipefail; $(XCODEBUILD_PREPARE) TEST_RUNNER_TSAN_OPTIONS=halt_on_error=1 xcodebuild -workspace $(WORKSPACE) \
		-scheme $(SCHEME) -destination '$(DESTINATION)' -enableThreadSanitizer YES $(XCODEBUILD_FLAGS) test $(XCODEBUILD_OUTPUT)

test-until-failure:
	set -o pipefail; $(XCODEBUILD_PREPARE) xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) -destination '$(DESTINATION)' \
		$(if $(TESTS),-only-testing:$(TESTS)) -test-iterations $(ITERATIONS) -run-tests-until-failure \
		$(XCODEBUILD_FLAGS) test $(XCODEBUILD_OUTPUT)

check-warnings:
	@test -n "$(XCODEBUILD_LOG)" || { echo "usage: make check-warnings XCODEBUILD_LOG=<raw xcodebuild log>"; exit 1; }
	python3 scripts/check_warnings.py $(XCODEBUILD_LOG)

check-release: XCODEBUILD_LOG = build.noindex/xcodebuild.log
check-release: check-project lint lint-analyze fmt-check test-scripts scan-secrets scan-dependencies test-coverage
	python3 scripts/check_warnings.py $(XCODEBUILD_LOG)

lint:
	swiftlint lint --strict --quiet
	@if [ -f $(STRINGS_CATALOG) ]; then python3 scripts/check_strings.py $(STRINGS_CATALOG); fi

lint-analyze:
	COMPILER_LOG=$(COMPILER_LOG) WORKSPACE=$(WORKSPACE) SCHEME=$(SCHEME) DESTINATION='$(DESTINATION)' \
		scripts/lint-analyze.sh $(ANALYZE_PACKAGES)

fmt:
	xcrun swift-format format --configuration .swift-format --in-place --recursive __SLUG__ __SLUG__Tests $(wildcard Packages)

fmt-check:
	xcrun swift-format lint --configuration .swift-format --strict --recursive __SLUG__ __SLUG__Tests $(wildcard Packages)

test-scripts:
	python3 -m unittest discover -s scripts/tests

scan-secrets:
	gitleaks git --redact --no-banner .

scan-staged-secrets:
	gitleaks git --pre-commit --staged --redact --no-banner .

scan-dependencies:
	@if command git ls-files '*Package.resolved' | grep -q .; then osv-scanner scan source -r .; else echo "No Package.resolved yet"; fi

install-hooks:
	lefthook install

generate-licences:
	license-plist --xcworkspace-path $(WORKSPACE) --output-path build.noindex/licences \
		--markdown-path build.noindex/licences/Acknowledgements.md --fail-if-missing-license --suppress-opening-directory --silence-mode

profile-memory:
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) -configuration Release -destination '$(DESTINATION)' $(XCODEBUILD_FLAGS) build
	scripts/profile-memory.sh "$$(xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) -configuration Release -showBuildSettings 2>/dev/null | awk -F'= ' '/ BUILT_PRODUCTS_DIR /{print $$2; exit}')/$(APP_NAME).app" $(PROFILE_SECONDS) $(PROFILE_TOP)
