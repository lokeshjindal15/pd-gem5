cmd_lib/div64.o := arm-linux-gnueabi-gcc -Wp,-MD,lib/.div64.o.d  -nostdinc -isystem /usr/lib/gcc/arm-linux-gnueabi/4.6/include -I/research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include -Iarch/arm/include/generated  -Iinclude -I/research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi -Iarch/arm/include/generated/uapi -I/research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi -Iinclude/generated/uapi -include /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -Iarch/arm/mach-vexpress/include -Iarch/arm/plat-versatile/include -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -no-integrated-as -fno-delete-null-pointer-checks -O2 -fno-dwarf2-cfi-asm -mabi=aapcs-linux -mno-thumb-interwork -mfpu=vfp -funwind-tables -marm -D__LINUX_ARM_ARCH__=7 -march=armv7-a -msoft-float -Uarm -Wframe-larger-than=1024 -fno-stack-protector -Wno-unused-but-set-variable -fomit-frame-pointer -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -Werror=implicit-int -Werror=strict-prototypes    -D"KBUILD_STR(s)=\#s" -D"KBUILD_BASENAME=KBUILD_STR(div64)"  -D"KBUILD_MODNAME=KBUILD_STR(div64)" -c -o lib/div64.o lib/div64.c

source_lib/div64.o := lib/div64.c

deps_lib/div64.o := \
  include/linux/export.h \
    $(wildcard include/config/have/underscore/symbol/prefix.h) \
    $(wildcard include/config/modules.h) \
    $(wildcard include/config/modversions.h) \
    $(wildcard include/config/unused/symbols.h) \
  include/linux/kernel.h \
    $(wildcard include/config/lbdaf.h) \
    $(wildcard include/config/preempt/voluntary.h) \
    $(wildcard include/config/debug/atomic/sleep.h) \
    $(wildcard include/config/mmu.h) \
    $(wildcard include/config/prove/locking.h) \
    $(wildcard include/config/panic/timeout.h) \
    $(wildcard include/config/ring/buffer.h) \
    $(wildcard include/config/tracing.h) \
    $(wildcard include/config/ftrace/mcount/record.h) \
  /usr/lib/gcc/arm-linux-gnueabi/4.6/include/stdarg.h \
  include/linux/linkage.h \
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
  include/linux/stringify.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/linkage.h \
  include/linux/stddef.h \
  include/uapi/linux/stddef.h \
  include/linux/types.h \
    $(wildcard include/config/uid16.h) \
    $(wildcard include/config/arch/dma/addr/t/64bit.h) \
    $(wildcard include/config/phys/addr/t/64bit.h) \
    $(wildcard include/config/64bit.h) \
  include/uapi/linux/types.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/types.h \
  include/asm-generic/int-ll64.h \
  include/uapi/asm-generic/int-ll64.h \
  arch/arm/include/generated/asm/bitsperlong.h \
  include/asm-generic/bitsperlong.h \
  include/uapi/asm-generic/bitsperlong.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi/linux/posix_types.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/uapi/asm/posix_types.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi/asm-generic/posix_types.h \
  include/linux/bitops.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/bitops.h \
    $(wildcard include/config/smp.h) \
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
  include/linux/log2.h \
    $(wildcard include/config/arch/has/ilog2/u32.h) \
    $(wildcard include/config/arch/has/ilog2/u64.h) \
  include/linux/printk.h \
    $(wildcard include/config/early/printk.h) \
    $(wildcard include/config/printk.h) \
    $(wildcard include/config/dynamic/debug.h) \
  include/linux/init.h \
    $(wildcard include/config/broken/rodata.h) \
  include/linux/kern_levels.h \
  include/linux/cache.h \
    $(wildcard include/config/arch/has/cache/line/size.h) \
  include/uapi/linux/kernel.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi/linux/sysinfo.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/cache.h \
    $(wildcard include/config/arm/l1/cache/shift.h) \
    $(wildcard include/config/aeabi.h) \
  include/linux/dynamic_debug.h \
  include/linux/string.h \
    $(wildcard include/config/binary/printf.h) \
  include/uapi/linux/string.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/string.h \
  include/linux/errno.h \
  include/uapi/linux/errno.h \
  arch/arm/include/generated/asm/errno.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi/asm-generic/errno.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/include/uapi/asm-generic/errno-base.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/div64.h \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/compiler.h \
    $(wildcard include/config/cpu/v6.h) \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/bug.h \
    $(wildcard include/config/bug.h) \
    $(wildcard include/config/thumb2/kernel.h) \
    $(wildcard include/config/debug/bugverbose.h) \
    $(wildcard include/config/arm/lpae.h) \
  /research/ljindal/alian/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/include/asm/opcodes.h \
    $(wildcard include/config/cpu/endian/be32.h) \
  include/asm-generic/bug.h \
    $(wildcard include/config/generic/bug.h) \
    $(wildcard include/config/generic/bug/relative/pointers.h) \
  include/linux/math64.h \
    $(wildcard include/config/arch/supports/int128.h) \

lib/div64.o: $(deps_lib/div64.o)

$(deps_lib/div64.o):
