#!/bin/sh

#  ci_post_clone.sh
#  Hamster
#
#  Created by morse on 2023/9/28.
#  
set -e

OUTPUT="${CI_PRIMARY_REPOSITORY_PATH}/Packages/RimeKit/Frameworks"

# 如果存在就不再执行
if [[ -d ${OUTPUT} ]]
then
  exit 0
fi

# 下载依赖的 librime framework
LibrimeKitVersion="2.0.0"
mkdir -p $OUTPUT
rm -rf $OUTPUT/*.xcframwork && (
  curl -OL https://github.com/imfuxiao/LibrimeKit/releases/download/${LibrimeKitVersion}/Frameworks.tgz
  tar -zxf Frameworks.tgz -C ${OUTPUT}/..
  rm -rf Frameworks.tgz
)

# debug show framework
ls -la ${OUTPUT}

# 如果方案存在就不再执行
OUTPUT="${CI_PRIMARY_REPOSITORY_PATH}/.HamsterInputSchemas"
mkdir -p ${CI_PRIMARY_REPOSITORY_PATH}/Resources/SharedSupport
rm -rf $OUTPUT && (
    git clone --depth 1 https://github.com/imfuxiao/HamsterInputSchemas.git -b v2.0 $OUTPUT
    cp ${CI_PRIMARY_REPOSITORY_PATH}/Resources/SharedSupport/hamster.yaml $OUTPUT/SharedSupport/
    cd $OUTPUT
    make
) && cp $OUTPUT/SharedSupport.zip ${CI_PRIMARY_REPOSITORY_PATH}/Resources/SharedSupport/

# debug show Schema
ls -la ${CI_PRIMARY_REPOSITORY_PATH}/Resources/SharedSupport/
