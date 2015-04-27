cmd_arch/arm/boot/compressed/piggy.gzip.o := arm-linux-gnueabihf-gcc -Wp,-MD,arch/arm/boot/compressed/.piggy.gzip.o.d  -nostdinc -isystem /usr/lib/gcc/arm-linux-gnueabihf/4.6/include -I/users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include -Iarch/arm/include/generated  -Iinclude -I/users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi -Iarch/arm/include/generated/uapi -I/users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi -Iinclude/generated/uapi -include /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -Iarch/arm/mach-vexpress/include -Iarch/arm/plat-versatile/include  -D__ASSEMBLY__ -no-integrated-as -mabi=aapcs-linux -mno-thumb-interwork -mfpu=vfp -funwind-tables -marm -D__LINUX_ARM_ARCH__=7 -march=armv7-a  -include asm/unified.h -msoft-float     -DZIMAGE     -c -o arch/arm/boot/compressed/piggy.gzip.o arch/arm/boot/compressed/piggy.gzip.S

source_arch/arm/boot/compressed/piggy.gzip.o := arch/arm/boot/compressed/piggy.gzip.S

deps_arch/arm/boot/compressed/piggy.gzip.o := \
  /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/unified.h \
    $(wildcard include/config/arm/asm/unified.h) \
    $(wildcard include/config/thumb2/kernel.h) \

arch/arm/boot/compressed/piggy.gzip.o: $(deps_arch/arm/boot/compressed/piggy.gzip.o)

$(deps_arch/arm/boot/compressed/piggy.gzip.o):
