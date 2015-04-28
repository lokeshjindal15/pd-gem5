cmd_arch/arm/boot/compressed/debug.o := arm-linux-gnueabihf-gcc -Wp,-MD,arch/arm/boot/compressed/.debug.o.d  -nostdinc -isystem /usr/lib/gcc/arm-linux-gnueabihf/4.6/include -I/users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include -Iarch/arm/include/generated  -Iinclude -I/users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi -Iarch/arm/include/generated/uapi -I/users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi -Iinclude/generated/uapi -include /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -Iarch/arm/mach-vexpress/include -Iarch/arm/plat-versatile/include  -D__ASSEMBLY__ -no-integrated-as -mabi=aapcs-linux -mno-thumb-interwork -mfpu=vfp -funwind-tables -marm -D__LINUX_ARM_ARCH__=7 -march=armv7-a  -include asm/unified.h -msoft-float     -DZIMAGE     -c -o arch/arm/boot/compressed/debug.o arch/arm/boot/compressed/debug.S

source_arch/arm/boot/compressed/debug.o := arch/arm/boot/compressed/debug.S

deps_arch/arm/boot/compressed/debug.o := \
    $(wildcard include/config/debug/semihosting.h) \
    $(wildcard include/config/debug/ll/include.h) \
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
  /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/debug/vexpress.S \
    $(wildcard include/config/debug/vexpress/uart0/detect.h) \
  /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/debug/pl01x.S \
    $(wildcard include/config/debug/uart/phys.h) \
    $(wildcard include/config/debug/uart/virt.h) \
  include/linux/amba/serial.h \
  include/linux/types.h \
    $(wildcard include/config/uid16.h) \
    $(wildcard include/config/lbdaf.h) \
    $(wildcard include/config/arch/dma/addr/t/64bit.h) \
    $(wildcard include/config/phys/addr/t/64bit.h) \
    $(wildcard include/config/64bit.h) \
  include/uapi/linux/types.h \
  /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/types.h \
  include/asm-generic/int-ll64.h \
  include/uapi/asm-generic/int-ll64.h \
  arch/arm/include/generated/asm/bitsperlong.h \
  include/asm-generic/bitsperlong.h \
  include/uapi/asm-generic/bitsperlong.h \

arch/arm/boot/compressed/debug.o: $(deps_arch/arm/boot/compressed/debug.o)

$(deps_arch/arm/boot/compressed/debug.o):
