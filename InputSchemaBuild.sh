#!/usr/bin/env bash
# encoding: utf-8
set -e
# 如果方案存在就不再执行
if [[  -f Resources/SharedSupport/SharedSupport.zip ]]
then
  exit 0
fi

# 输入方案
OUTPUT=".HamsterInputSchemas"
mkdir -p Resources/SharedSupport
rm -rf $OUTPUT && (
    git clone --depth 1 https://github.com/imfuxiao/HamsterInputSchemas.git -b v2.0 $OUTPUT
    cp Resources/SharedSupport/hamster.yaml $OUTPUT/SharedSupport/
    cd $OUTPUT
    make
) && cp $OUTPUT/SharedSupport.zip Resources/SharedSupport/
