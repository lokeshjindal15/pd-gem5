cmd_arch/arm/boot/compressed/lib1funcs.o := arm-linux-gnueabihf-gcc -Wp,-MD,arch/arm/boot/compressed/.lib1funcs.o.d  -nostdinc -isystem /usr/lib/gcc/arm-linux-gnueabihf/4.6/include -I/users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include -Iarch/arm/include/generated  -Iinclude -I/users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi -Iarch/arm/include/generated/uapi -I/users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi -Iinclude/generated/uapi -include /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -Iarch/arm/mach-vexpress/include -Iarch/arm/plat-versatile/include  -D__ASSEMBLY__ -no-integrated-as -mabi=aapcs-linux -mno-thumb-interwork -mfpu=vfp -funwind-tables -marm -D__LINUX_ARM_ARCH__=7 -march=armv7-a  -include asm/unified.h -msoft-float     -DZIMAGE     -c -o arch/arm/boot/compressed/lib1funcs.o arch/arm/boot/compressed/lib1funcs.S

source_arch/arm/boot/compressed/lib1funcs.o := arch/arm/boot/compressed/lib1funcs.S

deps_arch/arm/boot/compressed/lib1funcs.o := \
    $(wildcard include/config/aeabi.h) \
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
  /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/assembler.h \
    $(wildcard include/config/cpu/endian/be8.h) \
    $(wildcard include/config/cpu/feroceon.h) \
    $(wildcard include/config/trace/irqflags.h) \
    $(wildcard include/config/cpu/v7m.h) \
    $(wildcard include/config/smp.h) \
    $(wildcard include/config/cpu/use/domains.h) \
  /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/ptrace.h \
    $(wildcard include/config/arm/thumb.h) \
  /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi/asm/ptrace.h \
  /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/hwcap.h \
  /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi/asm/hwcap.h \
  /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/domain.h \
    $(wildcard include/config/io/36.h) \
  /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/opcodes-virt.h \
  /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/opcodes.h \
    $(wildcard include/config/cpu/endian/be32.h) \
  /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/unwind.h \
    $(wildcard include/config/arm/unwind.h) \

arch/arm/boot/compressed/lib1funcs.o: $(deps_arch/arm/boot/compressed/lib1funcs.o)

$(deps_arch/arm/boot/compressed/lib1funcs.o):
