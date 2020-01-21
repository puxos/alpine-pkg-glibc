# alpine-pkg-glibc

![x86_64](https://img.shields.io/badge/x86__64-supported-brightgreen.svg)
![aarch64](https://img.shields.io/badge/aarch64-supported-brightgreen.svg)
![arm32v7](https://img.shields.io/badge/arm32v7-supported-brightgreen.svg)

## Acknowlegement

This is a fork from https://github.com/sgerrand/alpine-pkg-glibc

## Introduction

This is the [GNU C Library](https://gnu.org/software/libc/) as a Alpine Linux package to run binaries linked against `glibc`. This package utilizes a custom built glibc binary based on the vanilla glibc source. 

This project supports multi-architecture, such as x86_64, aarch64, arm32v7, etc, I am using in my projects with x86_64 and aarch64, not yet verified on other CPU arch, but should be alright. 

### Build yourself in one line

    docker build alpine-glibc-builder .
    
    # OR simply
    
    docker-compose build

The Dockerfile is build with multi stage, the first stage is based on ubuntu to build glibc artifacts from source. The second stage is based on alpine for apk packaging. There will be 4 apk packages generated.

- glibc-${VERSION}-r0.apk
- glibc-bin-${VERSION}-r0.apk
- glibc-i18n-${VERSION}-r0.apk
- glibc-dev-${VERSION}-r0.apk

### How to obtain the packages

    # Create a container, the container will exit by default
    docker run --name container_name leadstec/glibc-builder:${VERSION}
    # Or simply
    docker-compose up

    # Use 'docker cp' to copy the whole artifacts folder from container
    docker cp container_name:/home/builder/packages/builder/x86_64 .

## Releases

See the [releases page](https://github.com/puxos/alpine-pkg-glibc/releases) for the latest download links. If you are using tools like `localedef` you will need the `glibc-bin` and `glibc-i18n` packages in addition to the `glibc` package.

## Installing

The current installation method for these packages is to pull them in using `wget` or `curl` and install the local file with `apk`:

    apk --allow-untrusted add glibc-${VERSION}-r0.apk

## Locales

You will need to generate your locale if you would like to use a specific one for your glibc application. You can do this by installing the `glibc-i18n` package and generating a locale using the `localedef` binary. An example for en_US.UTF-8 would be:

    apk --allow-untrusted add glibc-bin-${VERSION}-r0.apk glibc-i18n-${VERSION}-r0.apk
    /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8
