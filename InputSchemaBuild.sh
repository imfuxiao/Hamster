#!/usr/bin/env bash
# encoding: utf-8
set -e

# 输入方案
OUTPUT=".HamsterInputSchemas"
if [[ ! -d Resources/SharedSupport ]]
then
  mkdir -p Resources/SharedSupport
else
  rm -rf Resources/SharedSupport/*
fi
rm -rf $OUTPUT && (
    git clone --depth 1 https://github.com/imfuxiao/HamsterInputSchemas.git $OUTPUT
    cd $OUTPUT
    make
) && cp -R $OUTPUT/.SharedSupport/* Resources/SharedSupport/
