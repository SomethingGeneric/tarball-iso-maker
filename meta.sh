#!/usr/bin/env bash

inf() {
    echo -e "\e[1m♠ $@\e[0m"
}

err() {
    echo -e "\e[1m\e[31m✗ $@\e[0m"
}

response=""
prompt() {
    printf "\e[1m\e[33m$@ : \e[0m"
    read response
}

if [[ "$EUID" != "0" ]]; then
    err "Run as root"
    exit 1
fi

[[ ! -f cryst.tgz ]] && ./mk_arch_tarball.sh

./build.sh cryst.raw cryst.tgz

qemu-system-x86_64 -enable-kvm -bios /usr/share/edk2/x64/OVMF.fd -hda foo.raw