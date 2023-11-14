.PHONY: framework cleanFramework scheme cleanScheme

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))
framework:
	bash ./librimeFramework.sh
cleanFramework:
	rm -rf Packages/RimeKit/Frameworks
scheme:
	bash ./InputSchemeBuild.sh
cleanScheme:
	rm -rf Resources/SharedSupport/SharedSupport.zip 