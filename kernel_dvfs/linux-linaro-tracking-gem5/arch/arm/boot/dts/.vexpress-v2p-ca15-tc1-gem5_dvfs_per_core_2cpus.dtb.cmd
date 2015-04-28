cmd_arch/arm/boot/dts/vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dtb := arm-linux-gnueabihf-gcc -E -Wp,-MD,arch/arm/boot/dts/.vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dtb.d.pre.tmp -nostdinc -I/users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/boot/dts -I/users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/arch/arm/boot/dts/include -I/users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/drivers/of/testcase-data -undef -D__DTS__ -x assembler-with-cpp -o arch/arm/boot/dts/.vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dtb.dts.tmp arch/arm/boot/dts/vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dts ; /users/alian/Simulators/gem5/kernel_dvfs/linux-linaro-tracking-gem5/scripts/dtc/dtc -O dtb -o arch/arm/boot/dts/vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dtb -b 0 -i arch/arm/boot/dts/  -d arch/arm/boot/dts/.vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dtb.d.dtc.tmp arch/arm/boot/dts/.vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dtb.dts.tmp ; cat arch/arm/boot/dts/.vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dtb.d.pre.tmp arch/arm/boot/dts/.vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dtb.d.dtc.tmp > arch/arm/boot/dts/.vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dtb.d

source_arch/arm/boot/dts/vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dtb := arch/arm/boot/dts/vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dts

deps_arch/arm/boot/dts/vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dtb := \
  arch/arm/boot/dts/vexpress-v2m-rs1-gem5.dtsi \

arch/arm/boot/dts/vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dtb: $(deps_arch/arm/boot/dts/vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dtb)

$(deps_arch/arm/boot/dts/vexpress-v2p-ca15-tc1-gem5_dvfs_per_core_2cpus.dtb):
