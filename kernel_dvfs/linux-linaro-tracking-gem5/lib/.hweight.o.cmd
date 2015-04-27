cmd_lib/hweight.o := arm-linux-gnueabi-gcc -Wp,-MD,lib/.hweight.o.d  -nostdinc -isystem /usr/lib/gcc/arm-linux-gnueabi/4.6/include -I/research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include -Iarch/arm/include/generated  -Iinclude -I/research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi -Iarch/arm/include/generated/uapi -I/research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi -Iinclude/generated/uapi -include /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -Iarch/arm/mach-vexpress/include -Iarch/arm/plat-versatile/include -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -no-integrated-as -fno-delete-null-pointer-checks -O2 -fno-dwarf2-cfi-asm -mabi=aapcs-linux -mno-thumb-interwork -mfpu=vfp -funwind-tables -marm -D__LINUX_ARM_ARCH__=7 -march=armv7-a -msoft-float -Uarm -Wframe-larger-than=1024 -fno-stack-protector -Wno-unused-but-set-variable -fomit-frame-pointer -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -Werror=implicit-int -Werror=strict-prototypes    -D"KBUILD_STR(s)=\#s" -D"KBUILD_BASENAME=KBUILD_STR(hweight)"  -D"KBUILD_MODNAME=KBUILD_STR(hweight)" -c -o lib/hweight.o lib/hweight.c

source_lib/hweight.o := lib/hweight.c

deps_lib/hweight.o := \
  include/linux/export.h \
    $(wildcard include/config/have/underscore/symbol/prefix.h) \
    $(wildcard include/config/modules.h) \
    $(wildcard include/config/modversions.h) \
    $(wildcard include/config/unused/symbols.h) \
  include/linux/bitops.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/types.h \
  include/asm-generic/int-ll64.h \
  include/uapi/asm-generic/int-ll64.h \
  arch/arm/include/generated/asm/bitsperlong.h \
  include/asm-generic/bitsperlong.h \
    $(wildcard include/config/64bit.h) \
  include/uapi/asm-generic/bitsperlong.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/bitops.h \
    $(wildcard include/config/smp.h) \
  include/linux/compiler.h \
    $(wildcard include/config/sparse/rcu/pointer.h) \
    $(wildcard include/config/trace/branch/profiling.h) \
    $(wildcard include/config/profile/all/branches.h) \
    $(wildcard include/config/enable/must/check.h) \
    $(wildcard include/config/enable/warn/deprecated.h) \
    $(wildcard include/config/kprobes.h) \
  include/linux/compiler-gcc.h \
    $(wildcard include/config/arch/supports/optimized/inlining.h) \
    $(wildcard include/config/optimize/inlining.h) \
  include/linux/compiler-gcc4.h \
    $(wildcard include/config/arch/use/builtin/bswap.h) \
  include/linux/irqflags.h \
    $(wildcard include/config/trace/irqflags.h) \
    $(wildcard include/config/irqsoff/tracer.h) \
    $(wildcard include/config/preempt/tracer.h) \
    $(wildcard include/config/trace/irqflags/support.h) \
  include/linux/typecheck.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/irqflags.h \
    $(wildcard include/config/cpu/v7m.h) \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/ptrace.h \
    $(wildcard include/config/arm/thumb.h) \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi/asm/ptrace.h \
    $(wildcard include/config/cpu/endian/be8.h) \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/hwcap.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi/asm/hwcap.h \
  include/linux/stddef.h \
  include/uapi/linux/stddef.h \
  include/linux/types.h \
    $(wildcard include/config/uid16.h) \
    $(wildcard include/config/lbdaf.h) \
    $(wildcard include/config/arch/dma/addr/t/64bit.h) \
    $(wildcard include/config/phys/addr/t/64bit.h) \
  include/uapi/linux/types.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi/linux/posix_types.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi/asm/posix_types.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi/asm-generic/posix_types.h \
  include/asm-generic/bitops/non-atomic.h \
  include/asm-generic/bitops/fls64.h \
  include/asm-generic/bitops/sched.h \
  include/asm-generic/bitops/hweight.h \
  include/asm-generic/bitops/arch_hweight.h \
  include/asm-generic/bitops/const_hweight.h \
  include/asm-generic/bitops/lock.h \
  include/asm-generic/bitops/le.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi/asm/byteorder.h \
  include/linux/byteorder/little_endian.h \
  include/uapi/linux/byteorder/little_endian.h \
  include/linux/swab.h \
  include/uapi/linux/swab.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/swab.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi/asm/swab.h \
  include/linux/byteorder/generic.h \
  include/asm-generic/bitops/ext2-atomic-setbit.h \

lib/hweight.o: $(deps_lib/hweight.o)

$(deps_lib/hweight.o):
