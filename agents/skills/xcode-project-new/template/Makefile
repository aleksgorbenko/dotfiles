APP_NAME := __APP__
WORKSPACE := __APP__.xcworkspace
SCHEME := __SLUG__
DESTINATION := platform=macOS,arch=arm64

.PHONY: generate-project check-project build test

generate-project:
	xcodegen generate --spec project.yml --quiet

check-project: generate-project
	command git diff --exit-code --stat -- __SLUG__.xcodeproj/project.pbxproj

build: generate-project
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) -configuration Debug -destination '$(DESTINATION)' build

test: generate-project
	xcodebuild -workspace $(WORKSPACE) -scheme $(SCHEME) -destination '$(DESTINATION)' test
