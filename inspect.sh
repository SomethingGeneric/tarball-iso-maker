#!/usr/bin/env bash

if [[ "$EUID" != "0" ]]; then
    echo "Run as root"
    exit 1
fi

if [[ "$2" == "m" ]]; then
    loopdev=$(losetup -Pf --show $1)

    mkdir tmpmnt

    mount ${loopdev}p2 tmpmnt
elif [[ "$2" == "u" ]]; then
    umount tmpmnt
    losetup -D
    rm -rf tmpmnt
else
    echo "Usage: $0 <image> <m/u>"
fi