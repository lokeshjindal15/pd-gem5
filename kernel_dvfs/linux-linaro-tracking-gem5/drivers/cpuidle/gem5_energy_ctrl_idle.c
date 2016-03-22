/*
 * Gem5 Multi-cluster CPUFreq Interface driver
 * (adapted from vexpress_big_little.c)
 *
 * It provides necessary opp's to arm_gem5_mc.c cpufreq driver and gets
 * frequency information from gem5 energy controller device.
 *
 * Copyright (C) 2013 - 2014 ARM Ltd.
 * Authors: Akash Bagdia <Akash.bagdia@arm.com>
 *          Vasileios Spiliopoulos <vasileios.spiliopoulos@arm.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed "as is" WITHOUT ANY WARRANTY of any
 * kind, whether express or implied; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 */

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/platform_device.h>
#include <linux/cpuidle.h>
#include <linux/io.h>
#include <linux/export.h>
#include <asm/proc-fns.h>
#include <asm/cpuidle.h>
#include <linux/ktime.h>

#define GEM5_MAX_STATES	4

/* Actual code that puts the SoC in different idle states */
static int gem5_enter_idle1(struct cpuidle_device *dev,
			struct cpuidle_driver *drv,
			       int index)
{
	// at91_standby();
    ktime_t time_start, time_end;
    s64 actual_time;
    time_start = ktime_get();

//    printk (KERN_EMERG "##### gem5_enter_idle_c1 has been called for CORE:%d\n", dev->cpu);
	pdgem5_energy_ctrl_enter_c1((int) dev->cpu);
    cpu_do_idle();
    time_end = ktime_get();
    actual_time = ktime_to_ns(ktime_sub(time_end, time_start));
//    printk(KERN_EMERG "##### Time spent in C1 state for core#%d: %lld\n",dev->cpu,(long long)actual_time);
    return index;
}

static int gem5_enter_idle2(struct cpuidle_device *dev,
            struct cpuidle_driver *drv,
                   int index)
{
    // at91_standby();
    ktime_t time_start, time_end;
    s64 actual_time;
    time_start = ktime_get();

//    printk (KERN_EMERG "##### gem5_enter_idle_c2 has been called for CORE:%d\n", dev->cpu);
    pdgem5_energy_ctrl_enter_c2((int) dev->cpu);
    cpu_do_idle();
    time_end = ktime_get();
    actual_time = ktime_to_ns(ktime_sub(time_end, time_start));
//    printk(KERN_EMERG "##### Time spent in C2 state for core#%d: %lld\n",dev->cpu,(long long)actual_time);
    return index;
}

static int gem5_enter_idle3(struct cpuidle_device *dev,
            struct cpuidle_driver *drv,
                   int index)
{
    // at91_standby();
    ktime_t time_start, time_end;
    s64 actual_time;
    time_start = ktime_get();

//    printk (KERN_EMERG "##### gem5_enter_idle_c6 has been called for CORE:%d\n", dev->cpu);
    pdgem5_energy_ctrl_enter_c3((int) dev->cpu);
    cpu_do_idle();
    time_end = ktime_get();
    actual_time = ktime_to_ns(ktime_sub(time_end, time_start));
//    printk(KERN_EMERG "##### Time spent in C6 state for core#%d: %lld\n",dev->cpu,(long long)actual_time);
    return index;
}


static struct cpuidle_driver gem5_idle_driver = {
	.name			= "gem5_idle",
	.owner			= THIS_MODULE,
	.states[0]		= ARM_CPUIDLE_WFI_STATE,
	.states[1]		= {
		.enter			= gem5_enter_idle1,
		.exit_latency		= 10,
		.target_residency	= 20,
		.flags			= CPUIDLE_FLAG_TIME_VALID,
		.name			= "C1",
		.desc			= "Intel C1 Idle state",
	},
    .states[2]      = {
        .enter          = gem5_enter_idle2,
        .exit_latency       = 20,
        .target_residency   = 40,
        .flags          = CPUIDLE_FLAG_TIME_VALID,
        .name           = "C2",
        .desc           = "Intel C2 Idle state",
    },
    .states[3]      = {
        .enter          = gem5_enter_idle3,
        .exit_latency       = 40,
        .target_residency   = 150,
        .flags          = CPUIDLE_FLAG_TIME_VALID,
        .name           = "C6",
        .desc           = "Intel C6 Idle state",
    },
	.state_count = GEM5_MAX_STATES,
};


static int gem5_cpuidle_init(void)
{
	return cpuidle_register(&gem5_idle_driver, NULL);
}
module_init(gem5_cpuidle_init);

static void gem5_cpuidle_exit(void)
{
        
                pr_info("%s: gem5_cpuidle_exit called! \n",
                        __func__);
	// return 0;
}
module_exit(gem5_cpuidle_exit);

// MODULE_DESCRIPTION("ARM gem5 cpuidle driver");
// MODULE_LICENSE("GPL");
