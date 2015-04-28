cmd_firmware/e100/d101s_ucode.bin.gen.o := arm-linux-gnueabi-gcc -Wp,-MD,firmware/e100/.d101s_ucode.bin.gen.o.d  -nostdinc -isystem /usr/lib/gcc/arm-linux-gnueabi/4.6/include -I/research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include -Iarch/arm/include/generated  -Iinclude -I/research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi -Iarch/arm/include/generated/uapi -I/research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi -Iinclude/generated/uapi -include /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -Iarch/arm/mach-vexpress/include -Iarch/arm/plat-versatile/include  -D__ASSEMBLY__ -no-integrated-as -mabi=aapcs-linux -mno-thumb-interwork -mfpu=vfp -funwind-tables -marm -D__LINUX_ARM_ARCH__=7 -march=armv7-a  -include asm/unified.h -msoft-float         -c -o firmware/e100/d101s_ucode.bin.gen.o firmware/e100/d101s_ucode.bin.gen.S

source_firmware/e100/d101s_ucode.bin.gen.o := firmware/e100/d101s_ucode.bin.gen.S

deps_firmware/e100/d101s_ucode.bin.gen.o := \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/unified.h \
    $(wildcard include/config/arm/asm/unified.h) \
    $(wildcard include/config/thumb2/kernel.h) \

firmware/e100/d101s_ucode.bin.gen.o: $(deps_firmware/e100/d101s_ucode.bin.gen.o)

$(deps_firmware/e100/d101s_ucode.bin.gen.o):
