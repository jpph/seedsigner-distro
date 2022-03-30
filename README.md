# SeedSigner Distro

SeedSigner Distro can be started from a CDROM or an USB stick on a computer and being used to sign air gapped transactions. T


## Setup Seedsigner Distribution  to a CDROM or USB stick

the iso image is hybrid and can be burned to cd or usb.

**CDROM:**  
use your favorite program to burn the ISO to CDROM.
Nothing special. CDROMs are naturally read-only and tamper resistant.

**USB:**  

On windows you can use balena etcher to write the iso to usb.

On linux :

1) Insert USB stick and detect the device path::
```
$ dmesg|grep Attached | tail --lines=1
[583494.891574] sd 19:0:0:0: [sdf] Attached SCSI removable disk
```
2) Write ISO to USB::
```
$ sudo dd if=path/to/seedsigner_distro.iso of=/dev/sdf
$ lsblk | grep sdf
sdf                                8:80   1   7.4G  1 disk  
└─sdf1                             8:81   1   444M  1 part 
```

## How to build from source

Build is done using the build_seedsigner_distro.sh script. I use Ubuntu 20.04 to build it.

```
$ sudo ./build_seedsigner_distro.sh
```


## Credits

This project was inspired by airgap.it / airgap-distro.
Seedsigner.appimage is from @kornpow
latest build script inspired from https://willhaley.com/blog/custom-debian-live-environment/
