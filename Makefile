.PHONY: framework cleanFramework schema cleanSchema

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