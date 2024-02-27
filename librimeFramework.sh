#!/usr/bin/env bash
# encoding: utf-8
set -e

OUTPUT="${PWD}/Frameworks"

# 如果存在就不再执行
# if [[ -d ${OUTPUT} ]]
# then
#   exit 0
# fi

# 下载依赖的 librime framework
LibrimeKitVersion="2.4.2"
mkdir -p $OUTPUT
rm -rf $OUTPUT/*.xcframwork && (
  curl -OL https://github.com/imfuxiao/LibrimeKit/releases/download/${LibrimeKitVersion}/Frameworks.tgz
  tar -zxf Frameworks.tgz -C ${OUTPUT}/..
  rm -rf Frameworks.tgz
)
