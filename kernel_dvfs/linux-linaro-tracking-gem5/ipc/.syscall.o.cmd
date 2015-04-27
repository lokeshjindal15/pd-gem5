cmd_ipc/syscall.o := arm-linux-gnueabi-gcc -Wp,-MD,ipc/.syscall.o.d  -nostdinc -isystem /usr/lib/gcc/arm-linux-gnueabi/4.6/include -I/research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include -Iarch/arm/include/generated  -Iinclude -I/research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi -Iarch/arm/include/generated/uapi -I/research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi -Iinclude/generated/uapi -include /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -Iarch/arm/mach-vexpress/include -Iarch/arm/plat-versatile/include -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -no-integrated-as -fno-delete-null-pointer-checks -O2 -fno-dwarf2-cfi-asm -mabi=aapcs-linux -mno-thumb-interwork -mfpu=vfp -funwind-tables -marm -D__LINUX_ARM_ARCH__=7 -march=armv7-a -msoft-float -Uarm -Wframe-larger-than=1024 -fno-stack-protector -Wno-unused-but-set-variable -fomit-frame-pointer -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -Werror=implicit-int -Werror=strict-prototypes    -D"KBUILD_STR(s)=\#s" -D"KBUILD_BASENAME=KBUILD_STR(syscall)"  -D"KBUILD_MODNAME=KBUILD_STR(syscall)" -c -o ipc/syscall.o ipc/syscall.c

source_ipc/syscall.o := ipc/syscall.c

deps_ipc/syscall.o := \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi/linux/unistd.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/unistd.h \
    $(wildcard include/config/aeabi.h) \
    $(wildcard include/config/oabi/compat.h) \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi/asm/unistd.h \

ipc/syscall.o: $(deps_ipc/syscall.o)

$(deps_ipc/syscall.o):
