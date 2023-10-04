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


mkdir pacdest

inf "Starting pacstrap"
pacstrap -c pacdest linux linux-firmware base grub efibootmgr crystal-core
inf "Pacstrap done"

inf "Purging pacman cache in target to save disk space"
rm -rf pacdest/var/cache/pacman/pkg/*

inf "Starting tarball make"
tar -czf cryst.tgz pacdest/*
inf "Tarball done. Removing chroot dir"
rm -rf pacdest
inf "All done."