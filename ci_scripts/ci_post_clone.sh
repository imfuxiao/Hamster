#!/bin/sh

#  ci_post_clone.sh
#  Hamster
#
#  Created by morse on 2023/9/28.
#  
set -e

OUTPUT="${CI_PRIMARY_REPOSITORY_PATH}/Frameworks"

# 下载依赖的 librime framework
LibrimeKitVersion="2.3.0"
mkdir -p $OUTPUT
rm -rf $OUTPUT/*.xcframwork && (
  curl -OL https://github.com/imfuxiao/LibrimeKit/releases/download/${LibrimeKitVersion}/Frameworks.tgz
  mkdir -p $OUTPUT
  tar -zxf Frameworks.tgz -C $OUTPUT/..
  rm -rf Frameworks.tgz
)

# 生成 SharedSupport.zip 与 rime-ice.zip
OUTPUT="${CI_PRIMARY_REPOSITORY_PATH}/Resources/SharedSupport"
mkdir -p $OUTPUT
bash ${CI_PRIMARY_REPOSITORY_PATH}/InputSchemaBuild.sh
cp ${CI_PRIMARY_REPOSITORY_PATH}/.tmp/SharedSupport/SharedSupport.zip $OUTPUT
cp ${CI_PRIMARY_REPOSITORY_PATH}/.tmp/.rime-ice/rime-ice.zip $OUTPUT