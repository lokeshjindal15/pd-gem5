How to create disk image for NPB
================================
1. Take the disk image tux0.img for DCBench.
2. Change permissions for the file: chmod 777 tux0.img
3. Mount the disk image: sudo mount -o loop,offset=32256 tux0.img mount_point
			 sudo mount -o bind /sys mount_point/sys
			 sudo mount -o bind /proc mount_point/proc
			 sudo mount -o bind /dev mount_point/dev
4. cd mount_point and sudo chroot .
5. Install MPI library in the image: sudo apt-get install libcr-dev mpich2 mpich2-doc
6. Install FORTRAN , if required: sudo apt-get install gfortran
7. You might have to do following if one of the apt-get install fails:
Add following to file /etc/apt/sources.list in the disk image

## EOL upgrade sources.list
# Required
deb http://old-releases.ubuntu.com/ubuntu/ CODENAME main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ CODENAME-updates main restricted universe multiverse
deb http://old-releases.ubuntu.com/ubuntu/ CODENAME-security main restricted universe multiverse

# Optional
#deb http://old-releases.ubuntu.com/ubuntu/ CODENAME-backports main restricted universe multiverse

Replace CODENAME with "natty" above.

then retry the apt-get install that failed...

8. Copy the NPB source code to directory /benchmarks in the disk image and do: cd benchmarks/<NPB directory>
9. Change Makefile to do NPROCS=$(NPROC)
10. make bt NPROC=16 CLASS=S to compile BT benchmark CLASS=S => small dataset
11. check "ls bin/" to have .16 files for 16 processor config. 
