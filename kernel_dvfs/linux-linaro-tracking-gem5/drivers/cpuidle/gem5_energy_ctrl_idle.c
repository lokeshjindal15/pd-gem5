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

#define GEM5_MAX_STATES	2

/* Actual code that puts the SoC in different idle states */
static int gem5_enter_idle(struct cpuidle_device *dev,
			struct cpuidle_driver *drv,
			       int index)
{
	// at91_standby();
        pr_info("%s: gem5_enter_idle has been called\n", __func__);
	return index;
}

static struct cpuidle_driver gem5_idle_driver = {
	.name			= "gem5_idle",
	.owner			= THIS_MODULE,
	.states[0]		= ARM_CPUIDLE_WFI_STATE,
	.states[1]		= {
		.enter			= gem5_enter_idle,
		.exit_latency		= 10,
		.target_residency	= 10000,
		.flags			= CPUIDLE_FLAG_TIME_VALID,
		.name			= "RAM_SR",
		.desc			= "WFI and DDR Self Refresh",
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
