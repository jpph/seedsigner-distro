# SeedSigner Distro

update : build with emulator from Enteropositivo

SeedSigner Distro can be started from a CDROM or an USB stick on a computer and being used to sign air gapped transactions.  
Use f12 or other keypress at bios boot to select the usb or cdrom to boot. Everything should start automatically and you should arrive to the seedsigner emulator.   
This is very minimal debian distro, I removed network driver to be sure to be airgapped. When finished, power down by long press power button of the PC. (to restart you can do ctrl-alt-f1 to go to console then ctrl-alt-del).


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
2) Write ISO to USB:: (replace sdf by the real device path)
```
$ sudo dd if=path/to/seedsigner_distro.iso of=/dev/sdf
$ lsblk | grep sdf
sdf                                8:80   1   7.4G  1 disk  
└─sdf1                             8:81   1   444M  1 part 
```

## How to build from source

Build is done using the build_seedsigner_distro.sh script. I use Ubuntu 20.04 to build it.
Need to be ran as root.

```
$ sudo ./build_seedsigner_distro.sh
```


## Credits

This project was inspired by airgap.it / airgap-distro.  
Seedsigner.appimage is from @kornpow  
new emulator is from Enteropositivo   
latest build script inspired from https://willhaley.com/blog/custom-debian-live-environment/  
