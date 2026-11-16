SHELL := /bin/bash
MAKEFLAGS += --silent

XCCONFIG := xcconfigs/Config.xcconfig
xcconfig = $(shell awk -F' *= *' '/^$(1) *=/{print $$2}' $(XCCONFIG))
APP_NAME := $(call xcconfig,APP_NAME)
APP_BUNDLE_ID := $(call xcconfig,APP_BUNDLE_ID)
APP_SLUG := $(call xcconfig,APP_SLUG)
RELEASES_OWNER := $(call xcconfig,RELEASES_OWNER)
FEED_HOST := $(call xcconfig,FEED_HOST)
DEVELOPER_ID_CERTIFICATE := $(call xcconfig,DEVELOPER_ID_CERTIFICATE)
FEED_REPO := $(call xcconfig,FEED_REPO)
BUILD := $(call xcconfig,CURRENT_PROJECT_VERSION)
MIN_OS := $(call xcconfig,MACOSX_DEPLOYMENT_TARGET)
TEAM_ID := $(call xcconfig,DEVELOPMENT_TEAM)
APP_STORE_APP_ID := $(call xcconfig,APP_STORE_APP_ID)
DRY_RUN ?= 0
SKIP_BUILD ?= 0
DEMO_VARIABLE := $(shell printf '%s' '$(APP_NAME)' | tr a-z A-Z)_DEMO
GUMROAD_SLUG ?= $(APP_SLUG)
GUMROAD_DIR ?= $(HOME)/src/proj/storefronts/gumroad
LEMONSQUEEZY_DIR ?= $(HOME)/src/proj/storefronts/lemonsqueezy

WORKSPACE := __APP__.xcworkspace
XCODE_CLOUD_CONTAINER := __APP__.xcodeproj
SCHEME_APPSTORE := __APP__
SCHEME_DIRECT := __APP__-Direct
DESTINATION := platform=macOS,arch=arm64
TEST_LOG := /tmp/__SLUG__-test.log
TEST_DERIVED_DATA := build.noindex/DerivedData-tests
UI_TEST_DERIVED_DATA := build.noindex/DerivedData-ui-tests
XCODEBUILD_FLAGS ?=
XCBEAUTIFY ?=
XCODEBUILD_LOG ?=
XCODEBUILD_PREPARE = $(if $(XCODEBUILD_LOG),mkdir -p $(dir $(XCODEBUILD_LOG));)
XCODEBUILD_OUTPUT = $(if $(XCODEBUILD_LOG),2>&1 | tee $(XCODEBUILD_LOG)) $(if $(XCBEAUTIFY),2>&1 | $(XCBEAUTIFY))
PURGE ?= 0
INSTALLED_APP := /Applications/$(APP_NAME).app
RELEASE_DIR := build.noindex/release
ARCHIVE_DIRECT := $(RELEASE_DIR)/$(APP_NAME).xcarchive
EXPORT_DIRECT := $(RELEASE_DIR)/export
EXPORT_OPTIONS := $(RELEASE_DIR)/ExportOptions.plist
APP_DIRECT := $(EXPORT_DIRECT)/$(APP_NAME).app
VERSION := $(call xcconfig,MARKETING_VERSION)
DMG_DIRECT := $(RELEASE_DIR)/$(APP_NAME)-$(VERSION).dmg
NOTARY_PROFILE := notary
APPSTORE_DIR := build.noindex/appstore
COVERAGE_RESULT := build.noindex/coverage.xcresult
COVERAGE_MIN := 80
ITERATIONS ?= 100
PROFILE_SECONDS ?= 60
PROFILE_TOP ?= 20
PROFILE_STACKS ?= 0
LAUNCH_RUNS ?= 5
LAUNCH_BUDGET_MS ?= 500
STATUS_BUILDS ?= 5
TESTS ?=
STRINGS_CATALOG := __APP__/Localizable.xcstrings
ARCHIVE_APPSTORE := $(APPSTORE_DIR)/$(APP_NAME).xcarchive
EXPORT_APPSTORE := $(APPSTORE_DIR)/export
EXPORT_OPTIONS_APPSTORE := $(APPSTORE_DIR)/ExportOptions.plist
PKG_APPSTORE := $(EXPORT_APPSTORE)/$(APP_NAME).pkg
XCODE_AUTH ?=
SPARKLE_BIN := $(shell ls -d $$HOME/Library/Developer/Xcode/DerivedData/__APP__-*/SourcePackages/artifacts/sparkle/Sparkle/bin 2>/dev/null | head -1)

SWIFT_FORMAT_PATHS := __APP__ __APP__Tests __APP__UITests \
        $(if $(wildcard Packages),$(shell find Packages -mindepth 2 -maxdepth 2 -type d \( -name Sources -o -name Tests \)))
COMPILER_LOG ?=
ANALYZE_PACKAGES :=

.PHONY: all
all: build

.PHONY: help
help:
	@cat scripts/help.txt

# --- App builds ---

.PHONY: generate-project
generate-project:
	xcodegen generate --spec project.yml --quiet

.PHONY: check-project
check-project:
	@schemes=$$(mktemp -d) && cp -R __APP__.xcodeproj/xcshareddata/xcschemes "$$schemes/" && \
	xcodegen generate --spec project.yml --quiet; status=$$?; \
	rm -rf __APP__.xcodeproj/xcshareddata/xcschemes && cp -R "$$schemes/xcschemes" __APP__.xcodeproj/xcshareddata/ && rm -rf "$$schemes"; \
	[ $$status -eq 0 ] && command git diff --exit-code --stat -- __APP__.xcodeproj/project.pbxproj

.PHONY: build
build:
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -configuration Debug -destination '$(DESTINATION)' $(XCODEBUILD_FLAGS) build

.PHONY: build-appstore
build-appstore:
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -configuration Release-AppStore -destination '$(DESTINATION)' build

.PHONY: build-direct
build-direct:
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_DIRECT) -configuration Release-Direct -destination '$(DESTINATION)' build

# --- Debug runs ---

.PHONY: run
run: build quit-built-app
	open -a "$$(xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -configuration Debug -showBuildSettings 2>/dev/null | awk -F'= ' '/ BUILT_PRODUCTS_DIR /{print $$2; exit}')/$(APP_NAME).app"

.PHONY: run-direct
run-direct: quit-built-app
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_DIRECT) -configuration Debug -destination '$(DESTINATION)' -allowProvisioningUpdates $(XCODEBUILD_FLAGS) build
	open -a "$$(xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_DIRECT) -configuration Debug -showBuildSettings 2>/dev/null | awk -F'= ' '/ BUILT_PRODUCTS_DIR /{print $$2; exit}')/$(APP_NAME)-Direct.app"

# --- Install to /Applications (Shortcuts/App Intents need a real install,

.PHONY: run-demo
run-demo: build quit-built-app
	$(DEMO_VARIABLE)=1 "$$(xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -configuration Debug -showBuildSettings 2>/dev/null | awk -F'= ' '/ BUILT_PRODUCTS_DIR /{print $$2; exit}')/$(APP_NAME).app/Contents/MacOS/$(APP_NAME)"

.PHONY: demo-app-path
demo-app-path:
	@echo "$$(xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -configuration Debug -showBuildSettings 2>/dev/null | awk -F'= ' '/ BUILT_PRODUCTS_DIR /{print $$2; exit}')/$(APP_NAME).app"

.PHONY: install-direct
install-direct: build-direct
	APP_NAME=$(APP_NAME) scripts/install-app.sh "$$(xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_DIRECT) -configuration Release-Direct -showBuildSettings 2>/dev/null | awk -F'= ' '/ BUILT_PRODUCTS_DIR /{print $$2; exit}')/$(APP_NAME).app" $(INSTALLED_APP)
	$(MAKE) unregister
	open $(INSTALLED_APP)

.PHONY: install-appstore
install-appstore: build-appstore
	APP_NAME=$(APP_NAME) scripts/install-app.sh "$$(xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -configuration Release-AppStore -showBuildSettings 2>/dev/null | awk -F'= ' '/ BUILT_PRODUCTS_DIR /{print $$2; exit}')/$(APP_NAME).app" $(INSTALLED_APP)
	$(MAKE) unregister
	open $(INSTALLED_APP)

# --- Direct release: Developer ID + notarisation (Gumroad / Sparkle) ---

.PHONY: archive-direct
archive-direct:
	rm -rf $(ARCHIVE_DIRECT)
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_DIRECT) -configuration Release-Direct \
		-destination 'generic/platform=macOS' -archivePath $(ARCHIVE_DIRECT) archive

.PHONY: export-direct
export-direct:
	rm -rf $(EXPORT_DIRECT) $(EXPORT_OPTIONS)
	/usr/libexec/PlistBuddy -c 'Add :method string developer-id' $(EXPORT_OPTIONS)
	xcodebuild -exportArchive -archivePath $(ARCHIVE_DIRECT) -exportPath $(EXPORT_DIRECT) \
		-exportOptionsPlist $(EXPORT_OPTIONS) -allowProvisioningUpdates

.PHONY: notarize-direct
notarize-direct:
	rm -f $(RELEASE_DIR)/$(APP_NAME).zip
	ditto -c -k --keepParent $(APP_DIRECT) $(RELEASE_DIR)/$(APP_NAME).zip
	xcrun notarytool submit $(RELEASE_DIR)/$(APP_NAME).zip --keychain-profile $(NOTARY_PROFILE) --wait
	xcrun stapler staple $(APP_DIRECT)

.PHONY: dmg-image-direct
dmg-image-direct:
	rm -rf $(RELEASE_DIR)/dmg-staging $(DMG_DIRECT)
	mkdir -p $(RELEASE_DIR)/dmg-staging
	cp -R $(APP_DIRECT) $(RELEASE_DIR)/dmg-staging/
	ln -s /Applications $(RELEASE_DIR)/dmg-staging/Applications
	hdiutil create -volname $(APP_NAME) -srcfolder $(RELEASE_DIR)/dmg-staging -ov -format UDZO $(DMG_DIRECT)

.PHONY: dmg-direct
dmg-direct: dmg-image-direct
	codesign --force --sign $(DEVELOPER_ID_CERTIFICATE) --timestamp $(DMG_DIRECT)
	python3 scripts/check_signing_certificate.py $(DMG_DIRECT) $(DEVELOPER_ID_CERTIFICATE)
	xcrun notarytool submit $(DMG_DIRECT) --keychain-profile $(NOTARY_PROFILE) --wait
	xcrun stapler staple $(DMG_DIRECT)

.PHONY: verify-app-direct
verify-app-direct:
	codesign --verify --deep --strict --verbose=2 $(APP_DIRECT)
	codesign -dv --verbose=2 $(APP_DIRECT) 2>&1 | grep -E "Authority|TeamIdentifier|flags"
	spctl -a -t exec -vv $(APP_DIRECT)
	xcrun stapler validate $(APP_DIRECT)
	python3 scripts/check_entitlements.py $(APP_DIRECT) __APP__/__APP__-Direct.entitlements

.PHONY: verify-direct
verify-direct: verify-app-direct
	python3 scripts/check_signing_certificate.py $(APP_DIRECT) $(DEVELOPER_ID_CERTIFICATE)
	@if [ -f $(DMG_DIRECT) ]; then spctl -a -t open --context context:primary-signature -vv $(DMG_DIRECT); xcrun stapler validate $(DMG_DIRECT); fi

.PHONY: sign-update-direct
sign-update-direct:
	@test -n "$(SPARKLE_BIN)" || { echo "Sparkle tools not found - build __APP__-Direct once so SPM fetches them"; exit 1; }
	$(SPARKLE_BIN)/sign_update $(DMG_DIRECT)

.PHONY: package-direct
package-direct: check-release archive-direct export-direct notarize-direct dmg-direct verify-direct sign-update-direct

RELEASE_ENV = APP_NAME=$(APP_NAME) APP_SLUG=$(APP_SLUG) VERSION=$(VERSION) BUILD=$(BUILD) MIN_OS=$(MIN_OS) \
	RELEASES_OWNER=$(RELEASES_OWNER) FEED_HOST=$(FEED_HOST) FEED_REPO=$(FEED_REPO) DMG=$(DMG_DIRECT) APP_PATH=$(APP_DIRECT) SPARKLE_BIN=$(SPARKLE_BIN) \
	DRY_RUN=$(DRY_RUN) GUMROAD_SLUG=$(GUMROAD_SLUG) GUMROAD_DIR=$(GUMROAD_DIR) LEMONSQUEEZY_DIR=$(LEMONSQUEEZY_DIR)
PUBLISH = $(RELEASE_ENV) scripts/publish-direct.sh
UNPUBLISH = $(RELEASE_ENV) scripts/unpublish-direct.sh

.PHONY: bump
bump:
	@test -n "$(NEW_VERSION)" || { echo "usage: make bump NEW_VERSION=x.y.z"; exit 1; }
	sed -i '' -E 's/^MARKETING_VERSION *=.*/MARKETING_VERSION = $(NEW_VERSION)/; s/^CURRENT_PROJECT_VERSION *=.*/CURRENT_PROJECT_VERSION = $(shell expr $(BUILD) + 1)/' $(XCCONFIG)

.PHONY: preflight-direct
preflight-direct:
	$(PUBLISH) preflight

PUBLISH_DIRECT_STEPS := publish-github-release publish-appcast publish-blog publish-lemonsqueezy publish-homebrew publish-tag

.PHONY: publish-direct
publish-direct:
	$(PUBLISH) preflight
	@if [ "$(SKIP_BUILD)" != 1 ]; then $(MAKE) package-direct; fi
	$(PUBLISH) verify-artifacts
	set -e; for step in $(PUBLISH_DIRECT_STEPS); do $(PUBLISH) $$step; done

.PHONY: $(PUBLISH_DIRECT_STEPS) publish-gumroad
$(PUBLISH_DIRECT_STEPS) publish-gumroad:
	$(PUBLISH) verify-artifacts
	$(PUBLISH) $@

.PHONY: check-homebrew
check-homebrew:
	$(PUBLISH) verify-artifacts
	$(PUBLISH) $@

.PHONY: unpublish-direct
unpublish-direct:
	$(UNPUBLISH) tag
	$(UNPUBLISH) blog
	$(UNPUBLISH) appcast
	$(UNPUBLISH) gumroad
	$(UNPUBLISH) github-release

# --- App Store: asc (brew install asc), API key from Keychain asc:* or ASC_KEY_ID / ASC_ISSUER_ID / ASC_KEY_P8 ---
APPSTORE_LOCALE := en-GB
APPSTORE_LISTING = appstore/metadata/version/$(VERSION)/$(APPSTORE_LOCALE).json
BLOG_DIR ?= $(HOME)/src/proj/aleksgorbenko.dev
APPSTORE = APP_NAME=$(APP_NAME) APP_BUNDLE_ID=$(APP_BUNDLE_ID) APP_SLUG=$(APP_SLUG) XCODE_CLOUD_CONTAINER=$(XCODE_CLOUD_CONTAINER) \
	VERSION=$(VERSION) APP_STORE_APP_ID=$(APP_STORE_APP_ID) LOCALE=$(APPSTORE_LOCALE) \
	ARCHIVE=$(ARCHIVE_APPSTORE) PKG=$(PKG_APPSTORE) DRY_RUN=$(DRY_RUN) scripts/publish-appstore.sh

.PHONY: archive-appstore
archive-appstore:
	@test -n "$(APPSTORE_BUILD)" || { echo "usage: make archive-appstore APPSTORE_BUILD=<n>"; exit 1; }
	rm -rf $(ARCHIVE_APPSTORE)
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -configuration Release-AppStore \
		-destination 'generic/platform=macOS' -archivePath $(ARCHIVE_APPSTORE) -skipPackagePluginValidation -allowProvisioningUpdates $(XCODE_AUTH) \
		CURRENT_PROJECT_VERSION=$(APPSTORE_BUILD) archive

.PHONY: export-appstore
export-appstore:
	rm -rf $(EXPORT_APPSTORE) $(EXPORT_OPTIONS_APPSTORE)
	/usr/libexec/PlistBuddy -c 'Add :method string app-store-connect' -c 'Add :teamID string $(TEAM_ID)' -c 'Add :manageAppVersionAndBuildNumber bool false' $(EXPORT_OPTIONS_APPSTORE)
	xcodebuild -exportArchive -archivePath $(ARCHIVE_APPSTORE) -exportPath $(EXPORT_APPSTORE) \
		-exportOptionsPlist $(EXPORT_OPTIONS_APPSTORE) -allowProvisioningUpdates $(XCODE_AUTH)

.PHONY: package-appstore
package-appstore: check-release
	$(MAKE) archive-appstore export-appstore APPSTORE_BUILD=$(if $(APPSTORE_BUILD),$(APPSTORE_BUILD),$$($(APPSTORE) next-build-number))
	$(MAKE) verify-appstore

.PHONY: verify-appstore
verify-appstore:
	codesign --verify --deep --strict --verbose=2 $(ARCHIVE_APPSTORE)/Products/Applications/$(APP_NAME).app
	python3 scripts/check_entitlements.py $(ARCHIVE_APPSTORE)/Products/Applications/$(APP_NAME).app __APP__/__APP__.entitlements

.PHONY: preflight-appstore
preflight-appstore:
	$(APPSTORE) preflight

.PHONY: status-appstore
status-appstore:
	@STATUS_BUILDS=$(STATUS_BUILDS) $(APPSTORE) status

.PHONY: status-distribution
status-distribution:
	APP_NAME=$(APP_NAME) APP_SLUG=$(APP_SLUG) VERSION=$(VERSION) FEED_HOST=$(FEED_HOST) RELEASES_OWNER=$(RELEASES_OWNER) \
		APP_STORE_APP_ID=$(APP_STORE_APP_ID) CHECKOUT_URL='$(call xcconfig,LEMON_SQUEEZY_CHECKOUT_URL)' \
		LEMONSQUEEZY_DIR=$(LEMONSQUEEZY_DIR) DMG=$(DMG_DIRECT) python3 scripts/distribution_status.py

.PHONY: validate-appstore
validate-appstore:
	$(APPSTORE) validate-appstore

.PHONY: status-xcode-cloud
status-xcode-cloud:
	@STATUS_BUILDS=$(STATUS_BUILDS) $(APPSTORE) status-xcode-cloud

.PHONY: generate-appstore
generate-appstore:
	python3 scripts/appstore-copy.py --blog-page $(BLOG_DIR)/content/apps/$(APP_SLUG)/_index.md \
		--listing $(APPSTORE_LISTING) $(if $(filter-out 1.0.0,$(VERSION)),--whats-new release-notes/$(VERSION).md)

.PHONY: create-appstore
create-appstore:
	$(APPSTORE) $@

.PHONY: setup-xcode-cloud
setup-xcode-cloud:
	$(APPSTORE) $@

.PHONY: setup-appstore
setup-appstore:
	$(APPSTORE) preflight
	$(APPSTORE) setup-appstore

.PHONY: setup-appstore-promotional-text
setup-appstore-promotional-text:
	$(APPSTORE) preflight
	$(APPSTORE) $@

.PHONY: generate-storekit
generate-storekit:
	python3 scripts/storekit_config.py --products appstore/in-app-purchases.json \
		--app-config appstore/app.json --output __APP__.storekit

.PHONY: publish-appstore
publish-appstore:
	$(APPSTORE) preflight
	$(APPSTORE) setup-appstore
	@if [ "$(SKIP_BUILD)" != 1 ]; then $(MAKE) package-appstore; fi
	$(APPSTORE) publish-appstore

.PHONY: submit-appstore
submit-appstore:
	$(APPSTORE) preflight
	$(APPSTORE) submit-appstore

.PHONY: setup-testflight
setup-testflight:
	$(APPSTORE) preflight
	$(APPSTORE) setup-testflight

.PHONY: publish-testflight
publish-testflight:
	$(APPSTORE) preflight
	@if [ "$(SKIP_BUILD)" != 1 ]; then $(MAKE) package-appstore; fi
	$(APPSTORE) publish-testflight

.PHONY: submit-testflight
submit-testflight:
	$(APPSTORE) preflight
	$(APPSTORE) submit-testflight

# --- Tests ---

.PHONY: test
test: check-test-plan
	set -o pipefail; $(XCODEBUILD_PREPARE) xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -destination '$(DESTINATION)' -derivedDataPath $(TEST_DERIVED_DATA) $(XCODEBUILD_FLAGS) test $(XCODEBUILD_OUTPUT)

.PHONY: quit-built-app
quit-built-app:
	@APP_NAME=$(APP_NAME) scripts/quit-built-app.sh

.PHONY: test-unit
test-unit: check-test-plan quit-built-app
	set -o pipefail; $(XCODEBUILD_PREPARE) xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -destination '$(DESTINATION)' -testPlan __APP__-Unit -derivedDataPath $(TEST_DERIVED_DATA) $(XCODEBUILD_FLAGS) test $(XCODEBUILD_OUTPUT)

.PHONY: test-coverage test-keychain
test-coverage: check-test-plan quit-built-app
	WORKSPACE=$(WORKSPACE) SCHEME=$(SCHEME_APPSTORE) DESTINATION='$(DESTINATION)' XCODEBUILD_FLAGS='-derivedDataPath $(TEST_DERIVED_DATA) $(XCODEBUILD_FLAGS)' \
		XCODEBUILD_LOG=$(XCODEBUILD_LOG) RESULT=$(COVERAGE_RESULT) COVERAGE_MIN=$(COVERAGE_MIN) scripts/test-coverage.sh

.PHONY: test-unit-tsan
test-unit-tsan: check-test-plan quit-built-app
	set -o pipefail; $(XCODEBUILD_PREPARE) TEST_RUNNER_TSAN_OPTIONS=halt_on_error=1 xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -destination '$(DESTINATION)' \
		-testPlan __APP__-Unit -enableThreadSanitizer YES -derivedDataPath $(TEST_DERIVED_DATA) $(XCODEBUILD_FLAGS) test $(XCODEBUILD_OUTPUT)

.PHONY: test-keychain
test-keychain: check-test-plan quit-built-app
	set -o pipefail; $(XCODEBUILD_PREPARE) xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -destination '$(DESTINATION)' \
		-testPlan __APP__-Keychain -derivedDataPath $(TEST_DERIVED_DATA) $(XCODEBUILD_FLAGS) test $(XCODEBUILD_OUTPUT)

.PHONY: test-ui
test-ui: quit-built-app
	set -o pipefail; $(XCODEBUILD_PREPARE) xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -destination '$(DESTINATION)' \
		-testPlan __APP__-UI $(if $(TESTS),-only-testing:$(TESTS)) -derivedDataPath $(UI_TEST_DERIVED_DATA) $(XCODEBUILD_FLAGS) test $(XCODEBUILD_OUTPUT)

.PHONY: test-until-failure
test-until-failure: check-test-plan quit-built-app
	set -o pipefail; $(XCODEBUILD_PREPARE) xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -destination '$(DESTINATION)' \
		$(if $(TESTS),-only-testing:$(TESTS)) -test-iterations $(ITERATIONS) -run-tests-until-failure \
		-derivedDataPath $(TEST_DERIVED_DATA) $(XCODEBUILD_FLAGS) test $(XCODEBUILD_OUTPUT)

.PHONY: check-release
check-release:
	$(MAKE) check-release-gates XCODEBUILD_LOG=build.noindex/xcodebuild.log
	python3 scripts/check_warnings.py build.noindex/xcodebuild.log

.PHONY: check-release-gates
check-release-gates: check-project lint lint-workflows audit-images lint-analyze-full fmt-check test-scripts scan-secrets scan-dependencies test-coverage

.PHONY: check-warnings
check-warnings:
	@test -n "$(XCODEBUILD_LOG)" || { echo "usage: make check-warnings XCODEBUILD_LOG=<raw xcodebuild log>"; exit 1; }
	python3 scripts/check_warnings.py $(XCODEBUILD_LOG)

PROFILE_APP = "$$(xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_DIRECT) -configuration Release-Direct -showBuildSettings 2>/dev/null | awk -F'= ' '/ BUILT_PRODUCTS_DIR /{print $$2; exit}')/$(APP_NAME).app"

.PHONY: profile-memory
profile-memory: build-direct
	scripts/profile-memory.sh $(PROFILE_APP) $(PROFILE_SECONDS) $(PROFILE_TOP) $(PROFILE_STACKS)

.PHONY: profile-cpu
profile-cpu: build-direct
	scripts/profile-cpu.sh $(PROFILE_APP) $(PROFILE_SECONDS) $(PROFILE_TOP)

.PHONY: profile-launch
profile-launch: build-direct
	scripts/profile-launch.sh $(PROFILE_APP) $(LAUNCH_RUNS) $(LAUNCH_BUDGET_MS)

.PHONY: check-test-plan
check-test-plan:
	python3 scripts/check_test_plan.py

.PHONY: test-scripts
test-scripts:
	python3 -m unittest discover -s scripts/tests

.PHONY: test-result
test-result: check-test-plan
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -destination '$(DESTINATION)' -derivedDataPath $(TEST_DERIVED_DATA) $(XCODEBUILD_FLAGS) test > $(TEST_LOG) 2>&1; status=$$?; \
	grep -E "^Test Suite .* (passed|failed)|\*\* TEST (SUCCEEDED|FAILED) \*\*|Executed [0-9]+ test" $(TEST_LOG); \
	exit $$status

.PHONY: test-unit-result
test-unit-result: check-test-plan
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -destination '$(DESTINATION)' -testPlan __APP__-Unit -derivedDataPath $(TEST_DERIVED_DATA) $(XCODEBUILD_FLAGS) test > $(TEST_LOG) 2>&1; status=$$?; \
	grep -E "^Test Suite .* (passed|failed)|\*\* TEST (SUCCEEDED|FAILED) \*\*|Executed [0-9]+ test" $(TEST_LOG); \
	exit $$status

.PHONY: test-failures
test-failures: check-test-plan
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -destination '$(DESTINATION)' -derivedDataPath $(TEST_DERIVED_DATA) $(XCODEBUILD_FLAGS) test > $(TEST_LOG) 2>&1; status=$$?; \
	grep -E "error:|failed|FAILED|Fatal error|Issue recorded|✘" $(TEST_LOG) || echo "no failures found in $(TEST_LOG)"; \
	exit $$status

.PHONY: test-unit-failures
test-unit-failures: check-test-plan
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) -destination '$(DESTINATION)' -testPlan __APP__-Unit -derivedDataPath $(TEST_DERIVED_DATA) $(XCODEBUILD_FLAGS) test > $(TEST_LOG) 2>&1; status=$$?; \
	grep -E "error:|failed|FAILED|Fatal error|Issue recorded|✘" $(TEST_LOG) || echo "no failures found in $(TEST_LOG)"; \
	exit $$status

.PHONY: clean
clean:
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME_APPSTORE) clean
	rm -rf $(TEST_DERIVED_DATA) $(UI_TEST_DERIVED_DATA)

.PHONY: unregister
unregister:
	DRY_RUN=$(DRY_RUN) scripts/unregister-stale-apps.sh $(APP_BUNDLE_ID)

.PHONY: uninstall
uninstall:
	@APP_NAME=$(APP_NAME) INSTALLED_APP=$(INSTALLED_APP) APP_BUNDLE_ID=$(APP_BUNDLE_ID) PURGE=$(PURGE) DRY_RUN=$(DRY_RUN) scripts/uninstall.sh

.PHONY: clean-all
clean-all:
	APP_NAME=$(APP_NAME) INSTALLED_APP=$(INSTALLED_APP) scripts/clean-all.sh

# --- Lint / format ---

.PHONY: lint
lint: lint-makefile lint-prose lint-spelling
	swiftlint lint --strict --quiet
	@if [ -f $(STRINGS_CATALOG) ]; then python3 scripts/check_strings.py $(STRINGS_CATALOG); fi

.PHONY: lint-makefile
lint-makefile:
	checkmake Makefile

.PHONY: lint-prose
lint-prose:
	vale $$(command git ls-files '*.md' '*.txt' '*.swift' '*.py' '*.sh' '*.yml' | grep -v '^\.claude/')

.PHONY: lint-spelling
lint-spelling:
	npx --yes cspell@9.2.1 --no-progress

.PHONY: lint-workflows
lint-workflows:
	yamllint --strict -c .yamllint.yaml .github .yamllint.yaml
	actionlint
	zizmor --persona=pedantic .github/workflows

.PHONY: audit-images
audit-images:
	@found=$$(exiftool -q -r -if '$$GPSLatitude or $$GPSPosition or $$SerialNumber or $$Make' -p '$$Directory/$$FileName' __APP__ $(wildcard marketing) $(wildcard Packages/*/Sources)); \
	if [ -n "$$found" ]; then echo "images with location or camera metadata:"; echo "$$found"; exit 1; fi

.PHONY: lint-analyze
lint-analyze:
	COMPILER_LOG=$(COMPILER_LOG) scripts/lint-analyze.sh $(ANALYZE_PACKAGES)

.PHONY: lint-analyze-full
lint-analyze-full:
	ANALYZE_MODE=full COMPILER_LOG=$(COMPILER_LOG) scripts/lint-analyze.sh $(ANALYZE_PACKAGES)

.PHONY: fmt
fmt:
	xcrun swift-format format --configuration .swift-format --in-place --recursive $(SWIFT_FORMAT_PATHS)

.PHONY: fmt-check
fmt-check:
	xcrun swift-format lint --configuration .swift-format --recursive --strict $(SWIFT_FORMAT_PATHS)

.PHONY: generate-licences
generate-licences:
	license-plist --xcworkspace-path $(WORKSPACE) --output-path build.noindex/licences \
		--markdown-path build.noindex/licences/Acknowledgements.md --fail-if-missing-license --suppress-opening-directory --silence-mode

.PHONY: scan-secrets
scan-secrets:
	gitleaks git --redact --no-banner .

.PHONY: scan-staged-secrets
scan-staged-secrets:
	gitleaks git --pre-commit --staged --redact --no-banner .

.PHONY: scan-dependencies
scan-dependencies:
	osv-scanner scan source -r .

.PHONY: install-hooks
install-hooks:
	lefthook install
