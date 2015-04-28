cmd_arch/arm/boot/compressed/bswapsdi2.o := arm-linux-gnueabihf-gcc -Wp,-MD,arch/arm/boot/compressed/.bswapsdi2.o.d  -nostdinc -isystem /usr/lib/gcc/arm-linux-gnueabihf/4.6/include -I/users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include -Iarch/arm/include/generated  -Iinclude -I/users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi -Iarch/arm/include/generated/uapi -I/users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi -Iinclude/generated/uapi -include /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -Iarch/arm/mach-vexpress/include -Iarch/arm/plat-versatile/include  -D__ASSEMBLY__ -no-integrated-as -mabi=aapcs-linux -mno-thumb-interwork -mfpu=vfp -funwind-tables -marm -D__LINUX_ARM_ARCH__=7 -march=armv7-a  -include asm/unified.h -msoft-float     -DZIMAGE     -c -o arch/arm/boot/compressed/bswapsdi2.o arch/arm/boot/compressed/bswapsdi2.S

source_arch/arm/boot/compressed/bswapsdi2.o := arch/arm/boot/compressed/bswapsdi2.S

deps_arch/arm/boot/compressed/bswapsdi2.o := \
  /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/unified.h \
    $(wildcard include/config/arm/asm/unified.h) \
    $(wildcard include/config/thumb2/kernel.h) \
  include/linux/linkage.h \
  include/linux/compiler.h \
    $(wildcard include/config/sparse/rcu/pointer.h) \
    $(wildcard include/config/trace/branch/profiling.h) \
    $(wildcard include/config/profile/all/branches.h) \
    $(wildcard include/config/enable/must/check.h) \
    $(wildcard include/config/enable/warn/deprecated.h) \
    $(wildcard include/config/kprobes.h) \
  include/linux/stringify.h \
  include/linux/export.h \
    $(wildcard include/config/have/underscore/symbol/prefix.h) \
    $(wildcard include/config/modules.h) \
    $(wildcard include/config/modversions.h) \
    $(wildcard include/config/unused/symbols.h) \
  /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/linkage.h \

arch/arm/boot/compressed/bswapsdi2.o: $(deps_arch/arm/boot/compressed/bswapsdi2.o)

$(deps_arch/arm/boot/compressed/bswapsdi2.o):
