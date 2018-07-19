#!/bin/sh

set -e

[ $# -lt 1 ] \
  && (echo "usage: $0 repository-name"; false)

version=`grep -e "alpine/.*/main" /etc/apk/repositories | sed -r "s/^.*\/alpine\/([^\
/]*)\/main$/\1/"`
echo "Running on Alpine $version"
echo

cd /tmp
git clone --depth=1 -q https://github.com/at-wat/aports-ros-experimental
cd aports-ros-experimental/$1

ls -1 | while read pkg
do
  if [ -f $pkg/ENABLE_ON ]
  then
    grep $version $pkg/ENABLE_ON > /dev/null || continue
  fi
  echo $pkg
done > /tmp/building

echo "----------------"
echo "building:"
cat /tmp/building
echo "----------------"

sudo apk update

cat /tmp/building | while read pkg
do
  (cd $pkg \
    && abuild checksum \
    && abuild -r) || echo "====== Failed to build $pkg ====="
done
