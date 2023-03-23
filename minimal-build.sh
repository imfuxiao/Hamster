#!/usr/bin/env bash
# encoding: utf-8
set -e

# 下载已编译过的rimelib
rime_version=1.8.5
rime_git_hash=08dd95f

rime_archive="rime-${rime_git_hash}-macOS.tar.bz2"
rime_download_url="https://github.com/rime/librime/releases/download/${rime_version}/${rime_archive}"

rime_deps_archive="rime-deps-${rime_git_hash}-macOS.tar.bz2"
rime_deps_download_url="https://github.com/rime/librime/releases/download/${rime_version}/${rime_deps_archive}"

rm -rf .deps && mkdir -p .deps && (
    cd .deps
    [ -z "${no_download}" ] && curl -LO "${rime_download_url}"
    tar --bzip2 -xf "${rime_archive}"
    [ -z "${no_download}" ] && curl -LO "${rime_deps_download_url}"
    tar --bzip2 -xf "${rime_deps_archive}"
)

# 输入方案
OUTPUT=".plum/output"
rm -rf .plum
git clone --depth 1 https://github.com/rime/plum.git .plum

# 可以在这里添加输入方案
for package in essay luna-pinyin prelude; do
  bash .plum/scripts/install-packages.sh "${package}" "${OUTPUT}"
done

pushd "${OUTPUT}" > /dev/null

awk '($2 >= 500) {print}' essay.txt > essay.txt.min
mv essay.txt.min essay.txt

sed -n '{
  s/^version: \(["]*\)\([0-9.]*\)\(["]*\)$/version: \1\2.minimal\3/
  /^#以下爲詞組$/q;p
}' luna_pinyin.dict.yaml > luna_pinyin.dict.yaml.min
mv luna_pinyin.dict.yaml.min luna_pinyin.dict.yaml

for schema in *.schema.yaml; do
  sed '{
    s/version: \(["]*\)\([0-9.]*\)\(["]*\)$/version: \1\2.minimal\3/
    s/\(- stroke\)$/#\1/
    s/\(- reverse_lookup_translator\)$/#\1/
  }' ${schema} > ${schema}.min
  mv ${schema}.min ${schema}
done

ls *.schema.yaml | sed 's/^\(.*\)\.schema\.yaml/  - schema: \1/' > schema_list.yaml
# 这里不需要只替换luna_pinyin
# grep -Ff schema_list.yaml default.yaml > schema_list.yaml.min
# mv schema_list.yaml.min schema_list.yaml
sed '{
  s/^config_version: \(["]*\)\([0-9.]*\)\(["]*\)$/config_version: \1\2.minimal\3/
  /- schema:/d
  /^schema_list:$/r schema_list.yaml
}' default.yaml > default.yaml.min
rm schema_list.yaml
mv default.yaml.min default.yaml

popd > /dev/null

# copy
# 先将squirrel.yaml拷贝出来, 然后在删除
cp Resources/SharedSupport/squirrel.yaml ${OUTPUT}/ && rm -rf Resources/SharedSupport/*
cp -R .deps/share/opencc Resources/SharedSupport/
cp -R ${OUTPUT}/* Resources/SharedSupport/

# 一定要提前编译
.deps/dist/bin/rime_deployer --build Resources/SharedSupport/
rm -rf Resources/SharedSupport/user.yaml