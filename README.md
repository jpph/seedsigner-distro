# SeedSigner Distro

SeedSigner Distro can be started from a CDROM or an USB stick on a computer and being used to sign air gapped transactions. T


## Setup Seedsigner Distribution  to a CDROM or USB stick


**CDROM:**  
use your favorite program to burn the ISO to CDROM.
Nothing special. CDROMs are naturally read-only and tamper resistant.

**USB:**  
If you don't burn Seedsigner distro to a CDROM, writing Seedsigner distro to a
USB stick with a hardware read-write toggle (e.g., Kanguru FlashBlu) is
the next best thing.

On USB sticks without write protection, you can remove the Seedsigner distro USB after
booting as an additional security measure. 

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

Build is done using the build_seedsigner_distro.sh script

```
$ sudo ./build_seedsigner_distro.sh
```


## Credits

This project was inspired by airgap.it / airgap-distro.
Seedsigner.appimage is from @kornpow
latest build script inspired from https://willhaley.com/blog/custom-debian-live-environment/
