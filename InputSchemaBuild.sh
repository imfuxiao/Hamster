#!/usr/bin/env bash
# encoding: utf-8
set -e

# 输入方案
OUTPUT=".HamsterInputSchemas"
rm -rf $OUTPUT && (
    git clone --depth 1 https://github.com/imfuxiao/HamsterInputSchemas.git $OUTPUT
    cd $OUTPUT
    make
) && rm -rf Resources/SharedSupport/* && cp -R $OUTPUT/.SharedSupport/* Resources/SharedSupport/
