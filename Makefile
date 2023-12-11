.PHONY: framework cleanFramework scheme cleanScheme run-swiftgen

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))
framework:
	bash ./librimeFramework.sh
cleanFramework:
	rm -rf Packages/RimeKit/Frameworks
schema:
	bash ./InputSchemaBuild.sh
cleanSchema:
	rm -rf .tmp Resources/SharedSupport/*.zip

run-swiftgen:
	xcrun --sdk macosx swift run --package-path "Packages/Tools" swiftgen config run -c "./Packages/HamsteriOS/Sources/swiftgen.yml"

