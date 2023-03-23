.PHONY: init librime

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))

init:
	git submodule update --init

librime: init
	cd Packages/LibrimeKit && git submodule update --init
	$(MAKE) -C Packages/LibrimeKit boost-build
	$(MAKE) -C Packages/LibrimeKit librime-build

minimal:
	bash ./minimal-build.sh