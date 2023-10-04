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

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=LeahyCenter

grub-mkconfig -o /boot/grub/grub.cfg