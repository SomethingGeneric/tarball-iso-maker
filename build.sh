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

## FACTS

if [[ "$1" == "" ]]; then
    prompt "Disk image filename"
    fn="$response.raw"
else
    fn="$1"
fi

if [[ "$2" != "" ]]; then
    tbname="$2"
else
    prompt "Tarball filename"
    tbname="$response"
fi

## END FACTS

inf "Creating blank image file"
fallocate -l15G $fn

inf "Making partitions"
parted $fn mklabel gpt --script
parted $fn mkpart primary fat32 0 250MiB --script
parted $fn set 1 esp on --script
parted $fn mkpart ext4 250MiB 100% --script

inf "Creating loop device"
loopdev=$(losetup -Pf --show $fn)

[[ -d mntpt ]] && rm -rf mntpt
mkdir mntpt

inf "Creating filesystems"
mkfs.vfat -F32 ${loopdev}p1
mkfs.ext4 ${loopdev}p2

inf "Mounting filesystems"
mount ${loopdev}p2 mntpt
mkdir -p mntpt/boot/efi
mount ${loopdev}p1 mntpt/boot/efi

tmpd=$(mktemp -d)
inf "Extracting tarball"
tar -xf $tbname --strip-components=1 -C $tmpd
cp -r $tmpd/* mntpt

rm -rf $tmpd

inf "Installing grub"
arch-chroot mntpt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck --no-floppy --removable --debug

# inf "Installing grub bios"
# arch-chroot mntpt grub-install --target=i386-pc --boot-directory=mntpt/boot --recheck --no-floppy --removable --debug $loopdev

arch-chroot mntpt /usr/bin/grub-mkconfig -o /boot/grub/grub.cfg

inf "Partition info:"
partuuid=$(fdisk -l $fn | grep "Disk identifier" | awk '{split($0,a,": "); print a[2]}' | sed 's/0x//g')
echo "Partuuid: $partuuid"

#mv mntpt/boot/grub/grub.cfg .
#prompt "Edit grub config, then press enter"
#mv "grub.cfg" "mntpt/boot/grub/grub.cfg"

inf "Unmounting filesystems"
umount mntpt/boot/efi
umount mntpt

inf "Removing loop device"
losetup -d $loopdev

inf "Cleanup mnt dir"
rm -rf mntpt

inf "Should be done"