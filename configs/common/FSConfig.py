# Copyright (c) 2010-2012 ARM Limited
# All rights reserved.
#
# The license below extends only to copyright in the software and shall
# not be construed as granting a license to any other intellectual
# property including but not limited to intellectual property relating
# to a hardware implementation of the functionality of the software
# licensed hereunder.  You may use the software subject to the license
# terms below provided that you ensure that this notice is replicated
# unmodified and in its entirety in all distributions of the software,
# modified or unmodified, in source code or in binary form.
#
# Copyright (c) 2010-2011 Advanced Micro Devices, Inc.
# Copyright (c) 2006-2008 The Regents of The University of Michigan
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met: redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer;
# redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution;
# neither the name of the copyright holders nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Authors: Kevin Lim

from m5.objects import *
from Benchmarks import *
from m5.util import *

class CowIdeDisk(IdeDisk):
    image = CowDiskImage(child=RawDiskImage(read_only=True),
                         read_only=False)

    def childImage(self, ci):
        self.image.child.image_file = ci

class MemBus(CoherentXBar):
    badaddr_responder = BadAddr()
    default = Self.badaddr_responder.pio


def fillInCmdline(mdesc, template, **kwargs):
    kwargs.setdefault('disk', mdesc.disk())
    kwargs.setdefault('mem', mdesc.mem())
    kwargs.setdefault('script', mdesc.script())
    return template % kwargs

def makeLinuxAlphaSystem(mem_mode, mdesc=None, ruby=False, cmdline=None):

    class BaseTsunami(Tsunami):
        ethernet = NSGigE(pci_bus=0, pci_dev=1, pci_func=0)
        ide = IdeController(disks=[Parent.disk0, Parent.disk2],
                            pci_func=0, pci_dev=0, pci_bus=0)

    self = LinuxAlphaSystem()
    if not mdesc:
        # generic system
        mdesc = SysConfig()
    self.readfile = mdesc.script()

    self.tsunami = BaseTsunami()

    # Create the io bus to connect all device ports
    self.iobus = NoncoherentXBar()
    self.tsunami.attachIO(self.iobus)

    self.tsunami.ide.pio = self.iobus.master
    self.tsunami.ide.config = self.iobus.master

    self.tsunami.ethernet.pio = self.iobus.master
    self.tsunami.ethernet.config = self.iobus.master

    if ruby:
        # Store the dma devices for later connection to dma ruby ports.
        # Append an underscore to dma_ports to avoid the SimObjectVector check.
        self._dma_ports = [self.tsunami.ide.dma, self.tsunami.ethernet.dma]
    else:
        self.membus = MemBus()

        # By default the bridge responds to all addresses above the I/O
        # base address (including the PCI config space)
        IO_address_space_base = 0x80000000000
        self.bridge = Bridge(delay='50ns',
                         ranges = [AddrRange(IO_address_space_base, Addr.max)])
        self.bridge.master = self.iobus.slave
        self.bridge.slave = self.membus.master

        self.tsunami.ide.dma = self.iobus.slave
        self.tsunami.ethernet.dma = self.iobus.slave

        self.system_port = self.membus.slave

    self.mem_ranges = [AddrRange(mdesc.mem())]
    self.disk0 = CowIdeDisk(driveID='master')
    self.disk2 = CowIdeDisk(driveID='master')
    self.disk0.childImage(mdesc.disk())
    self.disk2.childImage(disk('linux-bigswap2.img'))
    self.simple_disk = SimpleDisk(disk=RawDiskImage(image_file = mdesc.disk(),
                                               read_only = True))
    self.intrctrl = IntrControl()
    self.mem_mode = mem_mode
    self.terminal = Terminal()
    self.kernel = binary('vmlinux')
    self.pal = binary('ts_osfpal')
    self.console = binary('console')
    if not cmdline:
        cmdline = 'root=/dev/hda1 console=ttyS0'
    self.boot_osflags = fillInCmdline(mdesc, cmdline)

    return self

def makeSparcSystem(mem_mode, mdesc=None):
    # Constants from iob.cc and uart8250.cc
    iob_man_addr = 0x9800000000
    uart_pio_size = 8

    class CowMmDisk(MmDisk):
        image = CowDiskImage(child=RawDiskImage(read_only=True),
                             read_only=False)

        def childImage(self, ci):
            self.image.child.image_file = ci

    self = SparcSystem()
    if not mdesc:
        # generic system
        mdesc = SysConfig()
    self.readfile = mdesc.script()
    self.iobus = NoncoherentXBar()
    self.membus = MemBus()
    self.bridge = Bridge(delay='50ns')
    self.t1000 = T1000()
    self.t1000.attachOnChipIO(self.membus)
    self.t1000.attachIO(self.iobus)
    self.mem_ranges = [AddrRange(Addr('1MB'), size = '64MB'),
                       AddrRange(Addr('2GB'), size ='256MB')]
    self.bridge.master = self.iobus.slave
    self.bridge.slave = self.membus.master
    self.rom.port = self.membus.master
    self.nvram.port = self.membus.master
    self.hypervisor_desc.port = self.membus.master
    self.partition_desc.port = self.membus.master
    self.intrctrl = IntrControl()
    self.disk0 = CowMmDisk()
    self.disk0.childImage(disk('disk.s10hw2'))
    self.disk0.pio = self.iobus.master

    # The puart0 and hvuart are placed on the IO bus, so create ranges
    # for them. The remaining IO range is rather fragmented, so poke
    # holes for the iob and partition descriptors etc.
    self.bridge.ranges = \
        [
        AddrRange(self.t1000.puart0.pio_addr,
                  self.t1000.puart0.pio_addr + uart_pio_size - 1),
        AddrRange(self.disk0.pio_addr,
                  self.t1000.fake_jbi.pio_addr +
                  self.t1000.fake_jbi.pio_size - 1),
        AddrRange(self.t1000.fake_clk.pio_addr,
                  iob_man_addr - 1),
        AddrRange(self.t1000.fake_l2_1.pio_addr,
                  self.t1000.fake_ssi.pio_addr +
                  self.t1000.fake_ssi.pio_size - 1),
        AddrRange(self.t1000.hvuart.pio_addr,
                  self.t1000.hvuart.pio_addr + uart_pio_size - 1)
        ]
    self.reset_bin = binary('reset_new.bin')
    self.hypervisor_bin = binary('q_new.bin')
    self.openboot_bin = binary('openboot_new.bin')
    self.nvram_bin = binary('nvram1')
    self.hypervisor_desc_bin = binary('1up-hv.bin')
    self.partition_desc_bin = binary('1up-md.bin')

    self.system_port = self.membus.slave

    return self

def makeArmSystem(mem_mode, machine_type, num_cpus=1, mdesc=None,
                  dtb_filename=None, options=None, bare_metal=False, cmdline=None):
    assert machine_type

    if bare_metal:
        self = ArmSystem()
    else:
        self = LinuxArmSystem()

    if not mdesc:
        # generic system
        mdesc = SysConfig()

    self.readfile = mdesc.script()
    self.iobus = NoncoherentXBar()
    self.membus = MemBus()
    self.membus.badaddr_responder.warn_access = "warn"
    self.bridge = Bridge(delay='50ns')
    self.bridge.master = self.iobus.slave
    self.bridge.slave = self.membus.master

    self.mem_mode = mem_mode

    if machine_type == "RealView_PBX":
        self.realview = RealViewPBX()
    elif machine_type == "RealView_EB":
        self.realview = RealViewEB()
    elif machine_type == "VExpress_EMM":
        self.realview = VExpress_EMM()
        if not dtb_filename:
            dtb_filename = 'vexpress.aarch32.ll_20131205.0-gem5.%dcpu.dtb' % num_cpus
    elif machine_type == "VExpress_EMM64":
        self.realview = VExpress_EMM64()
        if os.path.split(mdesc.disk())[-1] == 'linux-aarch32-ael.img':
            print "Selected 64-bit ARM architecture, updating default disk image..."
            mdesc.diskname = 'linaro-minimal-aarch64.img'
        if not dtb_filename:
            dtb_filename = 'vexpress.aarch64.20140821.dtb'
    else:
        print "Unknown Machine Type"
        sys.exit(1)

    self.cf0 = CowIdeDisk(driveID='master')
    self.cf0.childImage(mdesc.disk())
    self.cf1 = CowIdeDisk(driveID='master')
    self.cf1.childImage('/research/alian/DiskImageBackupGem5/My2GBWorkload1.img')

    # Attach any PCI devices this platform supports
    self.realview.attachPciDevices(options.mac, options.nic_rate_th_freq, options.nic_rate_cal_interval, options.enable_rate_calc,
        options.disable_freq_change_interval, options.nic_rate_th_low_freq, options.nic_rate_th_low_cnt)

    if options.network_topology == "star" and options.switch and (options.num_nodes == 4 or options.num_nodes == 5 or options.num_nodes == 8
                or options.num_nodes == 16 or options.num_nodes == 24):
        self.switch = EtherSwitch(port_count = options.num_nodes)

        self.etherlink0 = EtherLink(no_delay = "True")
        self.etherlink1 = EtherLink(no_delay = "True")
        self.etherlink2 = EtherLink(no_delay = "True")
        self.etherlink3 = EtherLink(no_delay = "True")

        self.ethertap0 = EtherTap(no_delay = "True")
        self.ethertap1 = EtherTap(no_delay = "True")
        self.ethertap2 = EtherTap(no_delay = "True")
        self.ethertap3 = EtherTap(no_delay = "True")

        self.etherlink0.int0 = self.ethertap0.tap
        self.etherlink0.int1 = self.switch.interface[0]
        self.etherlink1.int0 = self.ethertap1.tap
        self.etherlink1.int1 = self.switch.interface[1]
        self.etherlink2.int0 = self.ethertap2.tap
        self.etherlink2.int1 = self.switch.interface[2]
        self.etherlink3.int0 = self.ethertap3.tap
        self.etherlink3.int1 = self.switch.interface[3]

        if options.num_nodes == 5:
            self.etherlink4 = EtherLink(no_delay = "True")
            self.ethertap4 = EtherTap(no_delay = "True")
            self.etherlink4.int0 = self.ethertap4.tap
            self.etherlink4.int1 = self.switch.interface[4]

        if options.num_nodes >= 8:
            self.etherlink4 = EtherLink(no_delay = "True")
            self.etherlink5 = EtherLink(no_delay = "True")
            self.etherlink6 = EtherLink(no_delay = "True")
            self.etherlink7 = EtherLink(no_delay = "True")

            self.ethertap4 = EtherTap(no_delay = "True")
            self.ethertap5 = EtherTap(no_delay = "True")
            self.ethertap6 = EtherTap(no_delay = "True")
            self.ethertap7 = EtherTap(no_delay = "True")

            self.etherlink4.int0 = self.ethertap4.tap
            self.etherlink4.int1 = self.switch.interface[4]
            self.etherlink5.int0 = self.ethertap5.tap
            self.etherlink5.int1 = self.switch.interface[5]
            self.etherlink6.int0 = self.ethertap6.tap
            self.etherlink6.int1 = self.switch.interface[6]
            self.etherlink7.int0 = self.ethertap7.tap
            self.etherlink7.int1 = self.switch.interface[7]

        if options.num_nodes >= 16:
            self.etherlink8 = EtherLink(no_delay = "True")
            self.etherlink9 = EtherLink(no_delay = "True")
            self.etherlink10 = EtherLink(no_delay = "True")
            self.etherlink11 = EtherLink(no_delay = "True")
            self.etherlink12 = EtherLink(no_delay = "True")
            self.etherlink13 = EtherLink(no_delay = "True")
            self.etherlink14 = EtherLink(no_delay = "True")
            self.etherlink15 = EtherLink(no_delay = "True")

            self.ethertap8 = EtherTap(no_delay = "True")
            self.ethertap9 = EtherTap(no_delay = "True")
            self.ethertap10 = EtherTap(no_delay = "True")
            self.ethertap11 = EtherTap(no_delay = "True")
            self.ethertap12 = EtherTap(no_delay = "True")
            self.ethertap13 = EtherTap(no_delay = "True")
            self.ethertap14 = EtherTap(no_delay = "True")
            self.ethertap15 = EtherTap(no_delay = "True")

            self.etherlink8.int0 = self.ethertap8.tap
            self.etherlink8.int1 = self.switch.interface[8]
            self.etherlink9.int0 = self.ethertap9.tap
            self.etherlink9.int1 = self.switch.interface[9]
            self.etherlink10.int0 = self.ethertap10.tap
            self.etherlink10.int1 = self.switch.interface[10]
            self.etherlink11.int0 = self.ethertap11.tap
            self.etherlink11.int1 = self.switch.interface[11]
            self.etherlink12.int0 = self.ethertap12.tap
            self.etherlink12.int1 = self.switch.interface[12]
            self.etherlink13.int0 = self.ethertap13.tap
            self.etherlink13.int1 = self.switch.interface[13]
            self.etherlink14.int0 = self.ethertap14.tap
            self.etherlink14.int1 = self.switch.interface[14]
            self.etherlink15.int0 = self.ethertap15.tap
            self.etherlink15.int1 = self.switch.interface[15]

        if options.num_nodes >= 24:
            self.etherlink16 = EtherLink(no_delay = "True")
            self.etherlink17 = EtherLink(no_delay = "True")
            self.etherlink18 = EtherLink(no_delay = "True")
            self.etherlink19 = EtherLink(no_delay = "True")
            self.etherlink20 = EtherLink(no_delay = "True")
            self.etherlink21 = EtherLink(no_delay = "True")
            self.etherlink22 = EtherLink(no_delay = "True")
            self.etherlink23 = EtherLink(no_delay = "True")

            self.ethertap16 = EtherTap(no_delay = "True")
            self.ethertap17 = EtherTap(no_delay = "True")
            self.ethertap18 = EtherTap(no_delay = "True")
            self.ethertap19 = EtherTap(no_delay = "True")
            self.ethertap20 = EtherTap(no_delay = "True")
            self.ethertap21 = EtherTap(no_delay = "True")
            self.ethertap22 = EtherTap(no_delay = "True")
            self.ethertap23 = EtherTap(no_delay = "True")

            self.etherlink16.int0 = self.ethertap16.tap
            self.etherlink16.int1 = self.switch.interface[16]
            self.etherlink17.int0 = self.ethertap17.tap
            self.etherlink17.int1 = self.switch.interface[17]
            self.etherlink18.int0 = self.ethertap18.tap
            self.etherlink18.int1 = self.switch.interface[18]
            self.etherlink19.int0 = self.ethertap19.tap
            self.etherlink19.int1 = self.switch.interface[19]
            self.etherlink20.int0 = self.ethertap20.tap
            self.etherlink20.int1 = self.switch.interface[20]
            self.etherlink21.int0 = self.ethertap21.tap
            self.etherlink21.int1 = self.switch.interface[21]
            self.etherlink22.int0 = self.ethertap22.tap
            self.etherlink22.int1 = self.switch.interface[22]
            self.etherlink23.int0 = self.ethertap23.tap
            self.etherlink23.int1 = self.switch.interface[23]
    elif options.network_topology == "mesh" and options.switch and options.num_nodes == 12:
        self.switch0 = EtherSwitch(port_count = 6)
        self.switch1 = EtherSwitch(port_count = 6)
        self.switch2 = EtherSwitch(port_count = 6)

        self.etherlinkconn0 = EtherLink(no_delay = "False",ns_connector="True",
            delay=options.link_delay,delay_var=options.link_delay_var,
            tcp_speed = options.tcp_speed, no_ip_speed = options.no_ip_speed,
            udp_speed = options.udp_speed,tcp_retry_speed = options.tcp_retry_speed,
            udp_retry_speed = options.udp_retry_speed,tcp_process_speed = options.tcp_process_speed)

        self.etherlinkconn1 = EtherLink(no_delay = "False",ns_connector="True",
            delay=options.link_delay,delay_var=options.link_delay_var,
            tcp_speed = options.tcp_speed, no_ip_speed = options.no_ip_speed,
            udp_speed = options.udp_speed,tcp_retry_speed = options.tcp_retry_speed,
            udp_retry_speed = options.udp_retry_speed,tcp_process_speed = options.tcp_process_speed)

        self.etherlinkconn2 = EtherLink(no_delay = "False",ns_connector="True",
            delay=options.link_delay,delay_var=options.link_delay_var,
            tcp_speed = options.tcp_speed, no_ip_speed = options.no_ip_speed,
            udp_speed = options.udp_speed,tcp_retry_speed = options.tcp_retry_speed,
            udp_retry_speed = options.udp_retry_speed,tcp_process_speed = options.tcp_process_speed)

        self.etherlink00 = EtherLink(no_delay = "True")
        self.etherlink01 = EtherLink(no_delay = "True")
        self.etherlink02 = EtherLink(no_delay = "True")
        self.etherlink03 = EtherLink(no_delay = "True")

        self.etherlink10 = EtherLink(no_delay = "True")
        self.etherlink11 = EtherLink(no_delay = "True")
        self.etherlink12 = EtherLink(no_delay = "True")
        self.etherlink13 = EtherLink(no_delay = "True")

        self.etherlink20 = EtherLink(no_delay = "True")
        self.etherlink21 = EtherLink(no_delay = "True")
        self.etherlink22 = EtherLink(no_delay = "True")
        self.etherlink23 = EtherLink(no_delay = "True")

        self.ethertap00 = EtherTap(no_delay = "True")
        self.ethertap01 = EtherTap(no_delay = "True")
        self.ethertap02 = EtherTap(no_delay = "True")
        self.ethertap03 = EtherTap(no_delay = "True")

        self.ethertap10 = EtherTap(no_delay = "True")
        self.ethertap11 = EtherTap(no_delay = "True")
        self.ethertap12 = EtherTap(no_delay = "True")
        self.ethertap13 = EtherTap(no_delay = "True")

        self.ethertap20 = EtherTap(no_delay = "True")
        self.ethertap21 = EtherTap(no_delay = "True")
        self.ethertap22 = EtherTap(no_delay = "True")
        self.ethertap23 = EtherTap(no_delay = "True")

        self.etherlink00.int0 = self.ethertap00.tap
        self.etherlink00.int1 = self.switch0.interface[0]
        self.etherlink01.int0 = self.ethertap01.tap
        self.etherlink01.int1 = self.switch0.interface[1]
        self.etherlink02.int0 = self.ethertap02.tap
        self.etherlink02.int1 = self.switch0.interface[2]
        self.etherlink03.int0 = self.ethertap03.tap
        self.etherlink03.int1 = self.switch0.interface[3]

        self.etherlink10.int0 = self.ethertap10.tap
        self.etherlink10.int1 = self.switch1.interface[0]
        self.etherlink11.int0 = self.ethertap11.tap
        self.etherlink11.int1 = self.switch1.interface[1]
        self.etherlink12.int0 = self.ethertap12.tap
        self.etherlink12.int1 = self.switch1.interface[2]
        self.etherlink13.int0 = self.ethertap13.tap
        self.etherlink13.int1 = self.switch1.interface[3]

        self.etherlink20.int0 = self.ethertap20.tap
        self.etherlink20.int1 = self.switch2.interface[0]
        self.etherlink21.int0 = self.ethertap21.tap
        self.etherlink21.int1 = self.switch2.interface[1]
        self.etherlink22.int0 = self.ethertap22.tap
        self.etherlink22.int1 = self.switch2.interface[2]
        self.etherlink23.int0 = self.ethertap23.tap
        self.etherlink23.int1 = self.switch2.interface[3]

        self.etherlinkconn0.int0 = self.switch0.interface[4]
        self.etherlinkconn0.int1 = self.switch1.interface[4]
        self.etherlinkconn1.int0 = self.switch0.interface[5]
        self.etherlinkconn1.int1 = self.switch2.interface[4]
        self.etherlinkconn2.int0 = self.switch2.interface[5]
        self.etherlinkconn2.int1 = self.switch1.interface[5]

 
    elif options.eth and options.dual == None:
        self.ethertap0 = EtherTap(port=options.tap_port, delay = options.link_delay)
        self.etherlink = EtherLink(delay=options.link_delay,delay_var=options.link_delay_var,
                tcp_speed = options.tcp_speed, no_ip_speed = options.no_ip_speed,
                udp_speed = options.udp_speed,tcp_retry_speed = options.tcp_retry_speed,
                udp_retry_speed = options.udp_retry_speed, no_ip_retry_speed = options.no_ip_retry_speed,
                tcp_jmp_delay0 = options.tcp_jmp_delay0, tcp_jmp_delay1 = options.tcp_jmp_delay1,
                tcp_jmp_size0 = options.tcp_jmp_size0,tcp_jmp_size1 = options.tcp_jmp_size1,
                tcp_process_speed = options.tcp_process_speed
                )
        self.etherlink.int0 = self.ethertap0.tap
        self.etherlink.int1 = self.realview.ethernet.interface

    # default to an IDE controller rather than a CF one
    try:
        self.realview.ide.disks = [self.cf0,self.cf1]
    except:
        self.realview.cf_ctrl.disks = [self.cf0,self.cf1]

    self.mem_ranges = []
    size_remain = long(Addr(mdesc.mem()))
    for region in self.realview._mem_regions:
        if size_remain > long(region[1]):
            self.mem_ranges.append(AddrRange(region[0], size=region[1]))
            size_remain = size_remain - long(region[1])
        else:
            self.mem_ranges.append(AddrRange(region[0], size=size_remain))
            size_remain = 0
            break
        warn("Memory size specified spans more than one region. Creating" \
             " another memory controller for that range.")

    if size_remain > 0:
        fatal("The currently selected ARM platforms doesn't support" \
              " the amount of DRAM you've selected. Please try" \
              " another platform")

    if bare_metal:
        # EOT character on UART will end the simulation
        self.realview.uart.end_on_eot = True
    else:
        if machine_type == "VExpress_EMM64":
            self.kernel = binary('vmlinux.aarch64.20140821')
        elif machine_type == "VExpress_EMM":
            self.kernel = binary('vmlinux.aarch32.ll_20131205.0-gem5')
        else:
            self.kernel = binary('vmlinux.arm.smp.fb.2.6.38.8')

        if dtb_filename:
            self.dtb_filename = binary(dtb_filename)
        self.machine_type = machine_type
        # Ensure that writes to the UART actually go out early in the boot
        if not cmdline:
            cmdline = 'earlyprintk=pl011,0x1c090000 console=ttyAMA0 ' + \
                      'lpj=19988480 norandmaps rw loglevel=8 ' + \
                      'mem=%(mem)s root=/dev/sda1'

        self.realview.setupBootLoader(self.membus, self, binary)
        self.gic_cpu_addr = self.realview.gic.cpu_addr
        self.flags_addr = self.realview.realview_io.pio_addr + 0x30

        if mdesc.disk().lower().count('android'):
            cmdline += " init=/init "
        self.boot_osflags = fillInCmdline(mdesc, cmdline)
    self.realview.attachOnChipIO(self.membus, self.bridge)
    self.realview.attachIO(self.iobus)
    self.intrctrl = IntrControl()
    self.terminal = Terminal()
    self.vncserver = VncServer()

    self.system_port = self.membus.slave

    return self


def makeLinuxMipsSystem(mem_mode, mdesc=None, cmdline=None):
    class BaseMalta(Malta):
        ethernet = NSGigE(pci_bus=0, pci_dev=1, pci_func=0)
        ide = IdeController(disks=[Parent.disk0, Parent.disk2],
                            pci_func=0, pci_dev=0, pci_bus=0)

    self = LinuxMipsSystem()
    if not mdesc:
        # generic system
        mdesc = SysConfig()
    self.readfile = mdesc.script()
    self.iobus = NoncoherentXBar()
    self.membus = MemBus()
    self.bridge = Bridge(delay='50ns')
    self.mem_ranges = [AddrRange('1GB')]
    self.bridge.master = self.iobus.slave
    self.bridge.slave = self.membus.master
    self.disk0 = CowIdeDisk(driveID='master')
    self.disk2 = CowIdeDisk(driveID='master')
    self.disk0.childImage(mdesc.disk())
    self.disk2.childImage(disk('linux-bigswap2.img'))
    self.malta = BaseMalta()
    self.malta.attachIO(self.iobus)
    self.malta.ide.pio = self.iobus.master
    self.malta.ide.config = self.iobus.master
    self.malta.ide.dma = self.iobus.slave
    self.malta.ethernet.pio = self.iobus.master
    self.malta.ethernet.config = self.iobus.master
    self.malta.ethernet.dma = self.iobus.slave
    self.simple_disk = SimpleDisk(disk=RawDiskImage(image_file = mdesc.disk(),
                                               read_only = True))
    self.intrctrl = IntrControl()
    self.mem_mode = mem_mode
    self.terminal = Terminal()
    self.kernel = binary('mips/vmlinux')
    self.console = binary('mips/console')
    if not cmdline:
        cmdline = 'root=/dev/hda1 console=ttyS0'
    self.boot_osflags = fillInCmdline(mdesc, cmdline)

    self.system_port = self.membus.slave

    return self

def x86IOAddress(port):
    IO_address_space_base = 0x8000000000000000
    return IO_address_space_base + port

def connectX86ClassicSystem(x86_sys, numCPUs):
    # Constants similar to x86_traits.hh
    IO_address_space_base = 0x8000000000000000
    pci_config_address_space_base = 0xc000000000000000
    interrupts_address_space_base = 0xa000000000000000
    APIC_range_size = 1 << 12;

    x86_sys.membus = MemBus()

    # North Bridge
    x86_sys.iobus = NoncoherentXBar()
    x86_sys.bridge = Bridge(delay='50ns')
    x86_sys.bridge.master = x86_sys.iobus.slave
    x86_sys.bridge.slave = x86_sys.membus.master
    # Allow the bridge to pass through:
    #  1) kernel configured PCI device memory map address: address range
    #     [0xC0000000, 0xFFFF0000). (The upper 64kB are reserved for m5ops.)
    #  2) the bridge to pass through the IO APIC (two pages, already contained in 1),
    #  3) everything in the IO address range up to the local APIC, and
    #  4) then the entire PCI address space and beyond.
    x86_sys.bridge.ranges = \
        [
        AddrRange(0xC0000000, 0xFFFF0000),
        AddrRange(IO_address_space_base,
                  interrupts_address_space_base - 1),
        AddrRange(pci_config_address_space_base,
                  Addr.max)
        ]

    # Create a bridge from the IO bus to the memory bus to allow access to
    # the local APIC (two pages)
    x86_sys.apicbridge = Bridge(delay='50ns')
    x86_sys.apicbridge.slave = x86_sys.iobus.master
    x86_sys.apicbridge.master = x86_sys.membus.slave
    x86_sys.apicbridge.ranges = [AddrRange(interrupts_address_space_base,
                                           interrupts_address_space_base +
                                           numCPUs * APIC_range_size
                                           - 1)]

    # connect the io bus
    x86_sys.pc.attachIO(x86_sys.iobus)

    x86_sys.system_port = x86_sys.membus.slave

def connectX86RubySystem(x86_sys):
    # North Bridge
    x86_sys.iobus = NoncoherentXBar()

    # add the ide to the list of dma devices that later need to attach to
    # dma controllers
    x86_sys._dma_ports = [x86_sys.pc.south_bridge.ide.dma]
    x86_sys.pc.attachIO(x86_sys.iobus, x86_sys._dma_ports)


def makeX86System(mem_mode, options, numCPUs=1, mdesc=None, self=None, Ruby=False):
    if self == None:
        self = X86System()

    if not mdesc:
        # generic system
        mdesc = SysConfig()
    self.readfile = mdesc.script()

    self.mem_mode = mem_mode

    # Physical memory
    # On the PC platform, the memory region 0xC0000000-0xFFFFFFFF is reserved
    # for various devices.  Hence, if the physical memory size is greater than
    # 3GB, we need to split it into two parts.
    excess_mem_size = \
        convert.toMemorySize(mdesc.mem()) - convert.toMemorySize('3GB')
    if excess_mem_size <= 0:
        self.mem_ranges = [AddrRange(mdesc.mem())]
    else:
        warn("Physical memory size specified is %s which is greater than " \
             "3GB.  Twice the number of memory controllers would be " \
             "created."  % (mdesc.mem()))

        self.mem_ranges = [AddrRange('3GB'),
            AddrRange(Addr('4GB'), size = excess_mem_size)]

    # Platform
    self.pc = Pc()

    # Create and connect the busses required by each memory system
    if Ruby:
        connectX86RubySystem(self)
    else:
        connectX86ClassicSystem(self, numCPUs)

    self.intrctrl = IntrControl()

    # Disks
    disk0 = CowIdeDisk(driveID='master')
    disk2 = CowIdeDisk(driveID='master')
    disk0.childImage(mdesc.disk())
    disk2.childImage(disk('/research/alian/DiskImageBackupGem5/My2GBWorkload.img'))
    self.pc.south_bridge.ide.disks = [disk0, disk2]

    # Ethernet
    #  - connect to PCI bus (bus_id=0)
    #  - connect to I/O APIC use INT-A (InterruptPin=1)
    if options.eth and options.switch == None:
        self.pc.ethernet = IGbE_e1000(pci_bus=0, pci_dev=2, pci_func=0,
                                  InterruptLine=10, InterruptPin=1, hardware_address=options.mac)
        self.pc.ethernet.pio = self.iobus.master
        self.pc.ethernet.config = self.iobus.master
        self.pc.ethernet.dma = self.iobus.slave

    if options.switch and (options.num_nodes == 4 or options.num_nodes == 8
                or options.num_nodes == 16 or options.num_nodes == 24):
        self.switch = EtherSwitch(port_count = options.num_nodes)

        self.etherlink0 = EtherLink(no_delay = "True")
        self.etherlink1 = EtherLink(no_delay = "True")
        self.etherlink2 = EtherLink(no_delay = "True")
        self.etherlink3 = EtherLink(no_delay = "True")

        self.ethertap0 = EtherTap(no_delay = "True")
        self.ethertap1 = EtherTap(no_delay = "True")
        self.ethertap2 = EtherTap(no_delay = "True")
        self.ethertap3 = EtherTap(no_delay = "True")

        self.etherlink0.int0 = self.ethertap0.tap
        self.etherlink0.int1 = self.switch.interface[0]
        self.etherlink1.int0 = self.ethertap1.tap
        self.etherlink1.int1 = self.switch.interface[1]
        self.etherlink2.int0 = self.ethertap2.tap
        self.etherlink2.int1 = self.switch.interface[2]
        self.etherlink3.int0 = self.ethertap3.tap
        self.etherlink3.int1 = self.switch.interface[3]

        if options.num_nodes >= 8:
            self.etherlink4 = EtherLink(no_delay = "True")
            self.etherlink5 = EtherLink(no_delay = "True")
            self.etherlink6 = EtherLink(no_delay = "True")
            self.etherlink7 = EtherLink(no_delay = "True")

            self.ethertap4 = EtherTap(no_delay = "True")
            self.ethertap5 = EtherTap(no_delay = "True")
            self.ethertap6 = EtherTap(no_delay = "True")
            self.ethertap7 = EtherTap(no_delay = "True")

            self.etherlink4.int0 = self.ethertap4.tap
            self.etherlink4.int1 = self.switch.interface[4]
            self.etherlink5.int0 = self.ethertap5.tap
            self.etherlink5.int1 = self.switch.interface[5]
            self.etherlink6.int0 = self.ethertap6.tap
            self.etherlink6.int1 = self.switch.interface[6]
            self.etherlink7.int0 = self.ethertap7.tap
            self.etherlink7.int1 = self.switch.interface[7]

        if options.num_nodes >= 16:
            self.etherlink8 = EtherLink(no_delay = "True")
            self.etherlink9 = EtherLink(no_delay = "True")
            self.etherlink10 = EtherLink(no_delay = "True")
            self.etherlink11 = EtherLink(no_delay = "True")
            self.etherlink12 = EtherLink(no_delay = "True")
            self.etherlink13 = EtherLink(no_delay = "True")
            self.etherlink14 = EtherLink(no_delay = "True")
            self.etherlink15 = EtherLink(no_delay = "True")

            self.ethertap8 = EtherTap(no_delay = "True")
            self.ethertap9 = EtherTap(no_delay = "True")
            self.ethertap10 = EtherTap(no_delay = "True")
            self.ethertap11 = EtherTap(no_delay = "True")
            self.ethertap12 = EtherTap(no_delay = "True")
            self.ethertap13 = EtherTap(no_delay = "True")
            self.ethertap14 = EtherTap(no_delay = "True")
            self.ethertap15 = EtherTap(no_delay = "True")

            self.etherlink8.int0 = self.ethertap8.tap
            self.etherlink8.int1 = self.switch.interface[8]
            self.etherlink9.int0 = self.ethertap9.tap
            self.etherlink9.int1 = self.switch.interface[9]
            self.etherlink10.int0 = self.ethertap10.tap
            self.etherlink10.int1 = self.switch.interface[10]
            self.etherlink11.int0 = self.ethertap11.tap
            self.etherlink11.int1 = self.switch.interface[11]
            self.etherlink12.int0 = self.ethertap12.tap
            self.etherlink12.int1 = self.switch.interface[12]
            self.etherlink13.int0 = self.ethertap13.tap
            self.etherlink13.int1 = self.switch.interface[13]
            self.etherlink14.int0 = self.ethertap14.tap
            self.etherlink14.int1 = self.switch.interface[14]
            self.etherlink15.int0 = self.ethertap15.tap
            self.etherlink15.int1 = self.switch.interface[15]

        if options.num_nodes >= 24:
            self.etherlink16 = EtherLink(no_delay = "True")
            self.etherlink17 = EtherLink(no_delay = "True")
            self.etherlink18 = EtherLink(no_delay = "True")
            self.etherlink19 = EtherLink(no_delay = "True")
            self.etherlink20 = EtherLink(no_delay = "True")
            self.etherlink21 = EtherLink(no_delay = "True")
            self.etherlink22 = EtherLink(no_delay = "True")
            self.etherlink23 = EtherLink(no_delay = "True")

            self.ethertap16 = EtherTap(no_delay = "True")
            self.ethertap17 = EtherTap(no_delay = "True")
            self.ethertap18 = EtherTap(no_delay = "True")
            self.ethertap19 = EtherTap(no_delay = "True")
            self.ethertap20 = EtherTap(no_delay = "True")
            self.ethertap21 = EtherTap(no_delay = "True")
            self.ethertap22 = EtherTap(no_delay = "True")
            self.ethertap23 = EtherTap(no_delay = "True")

            self.etherlink16.int0 = self.ethertap16.tap
            self.etherlink16.int1 = self.switch.interface[16]
            self.etherlink17.int0 = self.ethertap17.tap
            self.etherlink17.int1 = self.switch.interface[17]
            self.etherlink18.int0 = self.ethertap18.tap
            self.etherlink18.int1 = self.switch.interface[18]
            self.etherlink19.int0 = self.ethertap19.tap
            self.etherlink19.int1 = self.switch.interface[19]
            self.etherlink20.int0 = self.ethertap20.tap
            self.etherlink20.int1 = self.switch.interface[20]
            self.etherlink21.int0 = self.ethertap21.tap
            self.etherlink21.int1 = self.switch.interface[21]
            self.etherlink22.int0 = self.ethertap22.tap
            self.etherlink22.int1 = self.switch.interface[22]
            self.etherlink23.int0 = self.ethertap23.tap
            self.etherlink23.int1 = self.switch.interface[23]
    elif options.eth and options.dual == None:
        self.ethertap0 = EtherTap(port=options.tap_port)
        self.etherlink = EtherLink(delay=options.link_delay,delay_var=options.link_delay_var,
                tcp_speed = options.tcp_speed, no_ip_speed = options.no_ip_speed,
                udp_speed = options.udp_speed,tcp_retry_speed = options.tcp_retry_speed,
                udp_retry_speed = options.udp_retry_speed, no_ip_retry_speed = options.no_ip_retry_speed,
                tcp_jmp_delay0 = options.tcp_jmp_delay0, tcp_jmp_delay1 = options.tcp_jmp_delay1,
                tcp_jmp_size0 = options.tcp_jmp_size0,tcp_jmp_size1 = options.tcp_jmp_size1,
                tcp_process_speed = options.tcp_process_speed
                )
        self.etherlink.int0 = self.ethertap0.tap
        self.etherlink.int1 = self.pc.ethernet.interface
        if options.etherdump:
                self.etherdump1 = EtherDump(file=options.etherdump+'Link.pcap')
                self.etherlink.dump = self.etherdump1

    # Add in a Bios information structure.
    structures = [X86SMBiosBiosInformation()]
    self.smbios_table.structures = structures

    # Set up the Intel MP table
    base_entries = []
    ext_entries = []
    for i in xrange(numCPUs):
        bp = X86IntelMPProcessor(
                local_apic_id = i,
                local_apic_version = 0x14,
                enable = True,
                bootstrap = (i == 0))
        base_entries.append(bp)
    io_apic = X86IntelMPIOAPIC(
            id = numCPUs,
            version = 0x11,
            enable = True,
            address = 0xfec00000)
    self.pc.south_bridge.io_apic.apic_id = io_apic.id
    base_entries.append(io_apic)
    # In gem5 Pc::calcPciConfigAddr(), it required "assert(bus==0)",
    # but linux kernel cannot config PCI device if it was not connected to PCI bus,
    # so we fix PCI bus id to 0, and ISA bus id to 1.
    pci_bus = X86IntelMPBus(bus_id = 0, bus_type='PCI')
    base_entries.append(pci_bus)
    isa_bus = X86IntelMPBus(bus_id = 1, bus_type='ISA')
    base_entries.append(isa_bus)
    connect_busses = X86IntelMPBusHierarchy(bus_id=1,
            subtractive_decode=True, parent_bus=0)
    ext_entries.append(connect_busses)
    pci_dev4_inta = X86IntelMPIOIntAssignment(
            interrupt_type = 'INT',
            polarity = 'ConformPolarity',
            trigger = 'ConformTrigger',
            source_bus_id = 0,
            source_bus_irq = 0 + (4 << 2),
            dest_io_apic_id = io_apic.id,
            dest_io_apic_intin = 16)
    base_entries.append(pci_dev4_inta)
    # Interrupt assignment for IGbE_e1000 (bus=0,dev=2,fun=0)
    pci_dev2_inta = X86IntelMPIOIntAssignment(
            interrupt_type = 'INT',
            polarity = 'ConformPolarity',
            trigger = 'ConformTrigger',
            source_bus_id = 0,
            source_bus_irq = 0 + (2 << 2),
            dest_io_apic_id = io_apic.id,
            dest_io_apic_intin = 10)
    base_entries.append(pci_dev2_inta)
    def assignISAInt(irq, apicPin):
        assign_8259_to_apic = X86IntelMPIOIntAssignment(
                interrupt_type = 'ExtInt',
                polarity = 'ConformPolarity',
                trigger = 'ConformTrigger',
                source_bus_id = 1,
                source_bus_irq = irq,
                dest_io_apic_id = io_apic.id,
                dest_io_apic_intin = 0)
        base_entries.append(assign_8259_to_apic)
        assign_to_apic = X86IntelMPIOIntAssignment(
                interrupt_type = 'INT',
                polarity = 'ConformPolarity',
                trigger = 'ConformTrigger',
                source_bus_id = 1,
                source_bus_irq = irq,
                dest_io_apic_id = io_apic.id,
                dest_io_apic_intin = apicPin)
        base_entries.append(assign_to_apic)
    assignISAInt(0, 2)
    assignISAInt(1, 1)
    for i in range(3, 15):
        assignISAInt(i, i)
    self.intel_mp_table.base_entries = base_entries
    self.intel_mp_table.ext_entries = ext_entries

def makeLinuxX86System(mem_mode, numCPUs=1, mdesc=None, Ruby=False, options=None,
                       cmdline=None):
    self = LinuxX86System()

    # Build up the x86 system and then specialize it for Linux
    makeX86System(mem_mode, options, numCPUs, mdesc, self, Ruby)

    # We assume below that there's at least 1MB of memory. We'll require 2
    # just to avoid corner cases.
    phys_mem_size = sum(map(lambda r: r.size(), self.mem_ranges))
    assert(phys_mem_size >= 0x200000)
    assert(len(self.mem_ranges) <= 2)

    entries = \
       [
        # Mark the first megabyte of memory as reserved
        X86E820Entry(addr = 0, size = '639kB', range_type = 1),
        X86E820Entry(addr = 0x9fc00, size = '385kB', range_type = 2),
        # Mark the rest of physical memory as available
        X86E820Entry(addr = 0x100000,
                size = '%dB' % (self.mem_ranges[0].size() - 0x100000),
                range_type = 1),
        ]

    # Mark [mem_size, 3GB) as reserved if memory less than 3GB, which force
    # IO devices to be mapped to [0xC0000000, 0xFFFF0000). Requests to this
    # specific range can pass though bridge to iobus.
    if len(self.mem_ranges) == 1:
        entries.append(X86E820Entry(addr = self.mem_ranges[0].size(),
            size='%dB' % (0xC0000000 - self.mem_ranges[0].size()),
            range_type=2))

    # Reserve the last 16kB of the 32-bit address space for the m5op interface
    entries.append(X86E820Entry(addr=0xFFFF0000, size='64kB', range_type=2))

    # In case the physical memory is greater than 3GB, we split it into two
    # parts and add a separate e820 entry for the second part.  This entry
    # starts at 0x100000000,  which is the first address after the space
    # reserved for devices.
    if len(self.mem_ranges) == 2:
        entries.append(X86E820Entry(addr = 0x100000000,
            size = '%dB' % (self.mem_ranges[1].size()), range_type = 1))

    self.e820_table.entries = entries

    # Command line
    if not cmdline:
        cmdline = 'earlyprintk=ttyS0 console=ttyS0 lpj=7999923 root=/dev/hda1'
    self.boot_osflags = fillInCmdline(mdesc, cmdline)
    self.kernel = binary('x86_64-vmlinux-2.6.22.9')
    return self


def makeDualRoot(full_system, testSystem, driveSystem, dumpfile):
    self = Root(full_system = full_system)
    self.testsys = testSystem
    self.drivesys = driveSystem
    self.etherlink = EtherLink()

    if hasattr(testSystem, 'realview'):
        self.etherlink.int0 = Parent.testsys.realview.ethernet.interface
        self.etherlink.int1 = Parent.drivesys.realview.ethernet.interface
    elif hasattr(testSystem, 'tsunami'):
        self.etherlink.int0 = Parent.testsys.tsunami.ethernet.interface
        self.etherlink.int1 = Parent.drivesys.tsunami.ethernet.interface
    else:
        fatal("Don't know how to connect these system together")

    if dumpfile:
        self.etherdump = EtherDump(file=dumpfile)
        self.etherlink.dump = Parent.etherdump

    return self
