#!/bin/bash -x

# Select different repo for suitable CPU arch
mv /etc/apt/sources.list /etc/apt/sources.list.bak

if [ $(uname -m) == 'x86_64' ]; then 
    mv /scripts/aliyun-disco.list /etc/apt/sources.list
elif [ `uname -m` == 'aarch64' ]; then
    mv /scripts/huawei-ports-disco.list /etc/apt/sources.list
fi

# configparams file
mkdir -p /glibc-build
mv /scripts/configparams /glibc-build/configparams