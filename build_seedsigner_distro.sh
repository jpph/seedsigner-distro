
apt install \
    debootstrap \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-efi \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools

rm -rf $HOME/LIVE_BOOT
mkdir -p $HOME/LIVE_BOOT

debootstrap \
    --arch=amd64 \
    --variant=minbase \
    bullseye \
    $HOME/LIVE_BOOT/chroot \
    http://ftp.de.debian.org/debian/

wget -q https://github.com/jpph/seedsigner-distro/releases/download/first/seedsigner.AppImage
chmod +x seedsigner.AppImage
mv seedsigner.AppImage  $HOME/LIVE_BOOT/chroot/root/

cat << EOF >$HOME/LIVE_BOOT/chroot/chroot.sh
echo "seedsignerdistro" > /etc/hostname
echo "seedsignerdistro 127.0.0.1" > /etc/hosts
apt-get update
apt-get install -y --no-install-recommends \
    linux-image-amd64 \
    live-boot \
    systemd-sysv\
    xserver-xorg-core \
    xserver-xorg \
    xinit \
    xterm \
    fuse \
    libfuse2 \
    python3-zbar



echo "exec xterm -geometry 90x30+700+0 -hold -e /root/seedsigner.AppImage" > /root/.xinitrc;
chmod +x /root/.xinitrc;
cat << EOFCHROOT > /etc/systemd/system/x11.service
[Service]
ExecStart=/bin/su root -l -c xinit -- VT08
[Install]
WantedBy=multi-user.target
EOFCHROOT

systemctl enable x11

apt-get -y clean autoclean;
rm -rf /lib/modules/**/kernel/net
rm -rf /var/lib/apt
rm -rf /var/lib/dpkg
rm -rf /var/lib/cache
rm -rf /var/lib/log
rm -rf /usr/share/man
rm -rf /usr/share/doc
rm -rf /usr/share/icons
rm -rf /usr/share/locale


EOF

chmod +x $HOME/LIVE_BOOT/chroot/chroot.sh
chroot $HOME/LIVE_BOOT/chroot /chroot.sh

mkdir -p $HOME/LIVE_BOOT/staging/EFI/boot
mkdir -p $HOME/LIVE_BOOT/staging/boot/grub/x86_64-efi
mkdir -p $HOME/LIVE_BOOT/staging/isolinux
mkdir -p $HOME/LIVE_BOOT/staging/live
mkdir -p $HOME/LIVE_BOOT/tmp


mksquashfs \
    $HOME/LIVE_BOOT/chroot \
    $HOME/LIVE_BOOT/staging/live/filesystem.squashfs \
    -e boot

cp $HOME/LIVE_BOOT/chroot/boot/vmlinuz-* \
    $HOME/LIVE_BOOT/staging/live/vmlinuz && \
cp $HOME/LIVE_BOOT/chroot/boot/initrd.img-* \
    $HOME/LIVE_BOOT/staging/live/initrd

cat <<'EOF' >$HOME/LIVE_BOOT/staging/isolinux/isolinux.cfg
UI vesamenu.c32

MENU TITLE Boot Menu
DEFAULT linux
TIMEOUT 10
MENU RESOLUTION 640 480
MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #9033ccff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #30ffffff #00000000 std

LABEL linux
  MENU LABEL Debian Live [BIOS/ISOLINUX]
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live 

LABEL linux
  MENU LABEL Debian Live [BIOS/ISOLINUX] (nomodeset)
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live nomodeset
EOF

cat <<'EOF' >$HOME/LIVE_BOOT/staging/boot/grub/grub.cfg
search --set=root --file /DEBIAN_CUSTOM

set default="0"
set timeout=1

# If X has issues finding screens, experiment with/without nomodeset.

menuentry "Debian Live [EFI/GRUB]" {
    linux ($root)/live/vmlinuz boot=live 
    initrd ($root)/live/initrd
}

menuentry "Debian Live [EFI/GRUB] (nomodeset)" {
    linux ($root)/live/vmlinuz boot=live nomodeset
    initrd ($root)/live/initrd
}
EOF

cat <<'EOF' >$HOME/LIVE_BOOT/tmp/grub-standalone.cfg
search --set=root --file /DEBIAN_CUSTOM
set prefix=($root)/boot/grub/
configfile /boot/grub/grub.cfg
EOF

touch $HOME/LIVE_BOOT/staging/DEBIAN_CUSTOM

cp /usr/lib/ISOLINUX/isolinux.bin "${HOME}/LIVE_BOOT/staging/isolinux/" && \
cp /usr/lib/syslinux/modules/bios/* "${HOME}/LIVE_BOOT/staging/isolinux/"

cp -r /usr/lib/grub/x86_64-efi/* "${HOME}/LIVE_BOOT/staging/boot/grub/x86_64-efi/"

grub-mkstandalone \
    --format=x86_64-efi \
    --output=$HOME/LIVE_BOOT/tmp/bootx64.efi \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$HOME/LIVE_BOOT/tmp/grub-standalone.cfg"

(cd $HOME/LIVE_BOOT/staging/EFI/boot && \
    dd if=/dev/zero of=efiboot.img bs=1M count=20 && \
    mkfs.vfat efiboot.img && \
    mmd -i efiboot.img efi efi/boot && \
    mcopy -vi efiboot.img $HOME/LIVE_BOOT/tmp/bootx64.efi ::efi/boot/
)

xorriso \
    -as mkisofs \
    -iso-level 3 \
    -o "${HOME}/LIVE_BOOT/seedsigner_distro.iso" \
    -full-iso9660-filenames \
    -volid "DEBIAN_CUSTOM" \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -eltorito-boot \
        isolinux/isolinux.bin \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-catalog isolinux/isolinux.cat \
    -eltorito-alt-boot \
        -e /EFI/boot/efiboot.img \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
    -append_partition 2 0xef ${HOME}/LIVE_BOOT/staging/EFI/boot/efiboot.img \
    "${HOME}/LIVE_BOOT/staging"


cp $HOME/LIVE_BOOT/seedsigner_distro.iso .
