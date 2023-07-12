.PHONY: framework

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))
LibrimeKitVersion := 0.3.14

framework:
	curl -OL https://github.com/imfuxiao/LibrimeKit/releases/download/${LibrimeKitVersion}/Frameworks.tgz
	rm -rf Packages/RimeKit/Frameworks
	tar -zxf Frameworks.tgz -C Packages/RimeKit
	rm -rf Frameworks.tgz

schema:
	bash ./InputSchemaBuild.sh