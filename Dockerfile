#
# AUTHOR            Frank,H.L.Lai <frank@leadstec.com>
# DOCKER-VERSION    19.03
# Copyright         (C) 2020 LEADSTEC Solutions. All rights reserved.
#
FROM ubuntu:19.04 as glibc-builder

ENV PREFIX_DIR="/usr/glibc-compat" \
	GLIBC_VERSION="2.30"

COPY scripts/sources.list /etc/apt/sources.list
COPY configparams /glibc-build/configparams

RUN apt-get -q update && \
	apt-get -qy install bison build-essential gawk gettext openssl python3 texinfo curl && \
    curl -LfsS https://mirrors.tuna.tsinghua.edu.cn/gnu/glibc/glibc-${GLIBC_VERSION}.tar.xz | tar xfJ - && \
    mkdir -p /glibc-build && cd /glibc-build && \
    /glibc-${GLIBC_VERSION}/configure \
        --prefix=${PREFIX_DIR} \
        --libdir=${PREFIX_DIR}/lib \
        --libexecdir=${PREFIX_DIR}/lib \
        --enable-multi-arch \
        --enable-stack-protector=strong && \
    make && make install && \
    tar --dereference --hard-dereference -zcf glibc-bin-${GLIBC_VERSION}.tar.gz ${PREFIX_DIR}

#######################################################
# Create our user and setup Alpine for building APKs
#######################################################
FROM alpine:3.11.3

ENV GLIBC_VERSION="2.30"

RUN sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/" /etc/apk/repositories && \
    echo "@edge http://mirrors.aliyun.com/alpine/edge/main" >> /etc/apk/repositories && \
    echo "@testing http://mirrors.aliyun.com/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "@community http://mirrors.aliyun.com/alpine/edge/community" >> /etc/apk/repositories && \
    apk --no-cache add alpine-sdk coreutils && \
    adduser -G abuild -g "Alpine Package Builder" -s /bin/ash -D builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/builder/upstream

COPY --from=glibc-builder /glibc-build/glibc-bin-${GLIBC_VERSION}.tar.gz /home/builder/upstream
COPY ["APKBUILD", "glibc-bin.trigger", "ld.so.conf", "nsswitch.conf", "/home/builder/upstream/"]

USER builder
WORKDIR /home/builder
RUN abuild-keygen -a -i -n && \
    mkdir -p packages && \
    sudo chown -R builder:abuild upstream packages && \
    cd upstream && \
    abuild checksum && \
    abuild -r