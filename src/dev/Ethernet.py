# Copyright (c) 2005-2007 The Regents of The University of Michigan
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
# Authors: Nathan Binkert

from m5.SimObject import SimObject
from m5.params import *
from m5.proxy import *
from Pci import PciDevice

class EtherObject(SimObject):
    type = 'EtherObject'
    abstract = True
    cxx_header = "dev/etherobject.hh"

class EtherLink(EtherObject):
    type = 'EtherLink'
    cxx_header = "dev/etherlink.hh"
    int0 = SlavePort("interface 0")
    int1 = SlavePort("interface 1")
    delay = Param.Latency('0us', "packet transmit delay")
    delay_var = Param.Latency('0ns', "packet transmit delay variability")
    dump = Param.EtherDump(NULL, "dump object")
    tcp_speed = Param.NetworkBandwidth('1Gbps', "tcp traffic speed ")
    udp_speed = Param.NetworkBandwidth('1Gbps', "udp traffic speed ")
    no_ip_speed = Param.NetworkBandwidth('1Gbps', "no ip traffic speed ")
    tcp_retry_speed = Param.NetworkBandwidth('1Gbps', "tcp processing speed ")
    udp_retry_speed = Param.NetworkBandwidth('1Gbps', "udp processing speed ")
    no_ip_retry_speed = Param.NetworkBandwidth('1Gbps', "no ip processing speed ")
    tcp_process_speed = Param.NetworkBandwidth('1Gbps', "no ip processing speed ")
    tcp_jmp_delay0 = Param.Latency('0us', "packet transmit delay for tcp packets: tcp_jmp_size0< pkt_size <tcp_jmp_size1")
    tcp_jmp_delay1 = Param.Latency('0us', "packet transmit delay for tcp packets: tcp_jmp_size1< pkt_size")
    tcp_jmp_size0 = Param.Int(131,"latency jump point 0")
    tcp_jmp_size1 = Param.Int(323,"latency jump point 1")
    no_delay = Param.Bool(False,"If true, then we don't add/remove time stamp to out-going/in-going pkts")
    ns_connector = Param.Bool(False,"If true, it's a etherlink which connects two NS together")
    queue_size = Param.Int(100,"link queue size")


class EtherBus(EtherObject):
    type = 'EtherBus'
    cxx_header = "dev/etherbus.hh"
    loopback = Param.Bool(True, "send packet back to the sending interface")
    dump = Param.EtherDump(NULL, "dump object")
    speed = Param.NetworkBandwidth('100Mbps', "bus speed in bits per second")

class EtherSwitch(EtherObject):
    type = 'EtherSwitch'
    cxx_header = "dev/etherswitch.hh"
    dump = Param.EtherDump(NULL, "dump object")
    fabric_speed = Param.NetworkBandwidth('1Gbps', "fabric links speed in bits "
                                          "per second")
    interface = VectorMasterPort("Ethernet Interface")
    input_buffer_size = Param.MemorySize('1MB', "size of input port buffers")
    output_buffer_size = Param.MemorySize('1MB', "size of output port buffers")
    delay = Param.Latency('0us', "packet transmit delay")
    delay_var = Param.Latency('0ns', "packet transmit delay variability")
    port_count = Param.Int(3,"number of ports")

class EtherTap(EtherObject):
    type = 'EtherTap'
    cxx_header = "dev/ethertap.hh"
    bufsz = Param.Int(10000, "tap buffer size")
    dump = Param.EtherDump(NULL, "dump object")
    port = Param.UInt16(3500, "tap port")
    tap = MasterPort("EtherTap interface")
    no_delay = Param.Bool(False,"If true, then we don't add/remove time stamp to out-going/in-going pkts")
    delay = Param.Latency('0us', "packet transmit delay")

class EtherDump(SimObject):
    type = 'EtherDump'
    cxx_header = "dev/etherdump.hh"
    file = Param.String("dump file")
    maxlen = Param.Int(96, "max portion of packet data to dump")

class EtherDevice(PciDevice):
    type = 'EtherDevice'
    abstract = True
    cxx_header = "dev/etherdevice.hh"
    interface = MasterPort("Ethernet Interface")

class IGbE(EtherDevice):
    # Base class for two IGbE adapters listed above
    type = 'IGbE'
    cxx_header = "dev/i8254xGBe.hh"
    hardware_address = Param.EthernetAddr(NextEthernetAddr,
        "Ethernet Hardware Address")
    rx_fifo_size = Param.MemorySize('384kB', "Size of the rx FIFO")
    tx_fifo_size = Param.MemorySize('384kB', "Size of the tx FIFO")
    rx_desc_cache_size = Param.Int(64,
        "Number of enteries in the rx descriptor cache")
    tx_desc_cache_size = Param.Int(64,
        "Number of enteries in the rx descriptor cache")
    VendorID = 0x8086
    SubsystemID = 0x1008
    SubsystemVendorID = 0x8086
    Status = 0x0000
    SubClassCode = 0x00
    ClassCode = 0x02
    ProgIF = 0x00
    BAR0 = 0x00000000
    BAR1 = 0x00000000
    BAR2 = 0x00000000
    BAR3 = 0x00000000
    BAR4 = 0x00000000
    BAR5 = 0x00000000
    MaximumLatency = 0x00
    MinimumGrant = 0xff
    InterruptLine = 0x1e
    InterruptPin = 0x01
    BAR0Size = '128kB'
    wb_delay = Param.Latency('10ns', "delay before desc writeback occurs")
    fetch_delay = Param.Latency('10ns', "delay before desc fetch occurs")
    fetch_comp_delay = Param.Latency('10ns', "delay after desc fetch occurs")
    wb_comp_delay = Param.Latency('10ns', "delay after desc wb occurs")
    tx_read_delay = Param.Latency('0ns', "delay after tx dma read")
    rx_write_delay = Param.Latency('0ns', "delay after rx dma read")
    phy_pid = Param.UInt16("Phy PID that corresponds to device ID")
    phy_epid = Param.UInt16("Phy EPID that corresponds to device ID")
    nic_rate_th_freq = Param.UInt64(50000000,"threshold for nic arrival rate to boost freq")
    nic_rate_cal_interval = Param.Latency('200us', "Interval for calculating nic arrival rate")
    enable_rate_calc = Param.Bool(False, "Enable or disable rate calculator")
    disable_freq_change_interval = Param.Latency('5ms', "Disable changing frequency for a while after we change it once")
    nic_rate_th_low_freq = Param.UInt64(10000000,"low threshold for nic arrival rate to boost freq")
    rate_above_th = Param.UInt32(5,"change frequency when num of consequative intervals which arrival rate is above low_th is more than this")

class IGbE_e1000(IGbE):
    # Older Intel 8254x based gigabit ethernet adapter
    # Uses Intel e1000 driver
    DeviceID = 0x1075
    phy_pid = 0x02A8
    phy_epid = 0x0380

class IGbE_igb(IGbE):
    # Newer Intel 8257x based gigabit ethernet adapter
    # Uses Intel igb driver and in theory supports packet splitting and LRO
    DeviceID = 0x10C9
    phy_pid = 0x0141
    phy_epid = 0x0CC0

class EtherDevBase(EtherDevice):
    type = 'EtherDevBase'
    abstract = True
    cxx_header = "dev/etherdevice.hh"

    hardware_address = Param.EthernetAddr(NextEthernetAddr,
        "Ethernet Hardware Address")

    dma_read_delay = Param.Latency('0us', "fixed delay for dma reads")
    dma_read_factor = Param.Latency('0us', "multiplier for dma reads")
    dma_write_delay = Param.Latency('0us', "fixed delay for dma writes")
    dma_write_factor = Param.Latency('0us', "multiplier for dma writes")

    rx_delay = Param.Latency('1us', "Receive Delay")
    tx_delay = Param.Latency('1us', "Transmit Delay")
    rx_fifo_size = Param.MemorySize('512kB', "max size of rx fifo")
    tx_fifo_size = Param.MemorySize('512kB', "max size of tx fifo")

    rx_filter = Param.Bool(True, "Enable Receive Filter")
    intr_delay = Param.Latency('10us', "Interrupt propagation delay")
    rx_thread = Param.Bool(False, "dedicated kernel thread for transmit")
    tx_thread = Param.Bool(False, "dedicated kernel threads for receive")
    rss = Param.Bool(False, "Receive Side Scaling")

class NSGigE(EtherDevBase):
    type = 'NSGigE'
    cxx_header = "dev/ns_gige.hh"

    dma_data_free = Param.Bool(False, "DMA of Data is free")
    dma_desc_free = Param.Bool(False, "DMA of Descriptors is free")
    dma_no_allocate = Param.Bool(True, "Should we allocate cache on read")

    VendorID = 0x100B
    DeviceID = 0x0022
    Status = 0x0290
    SubClassCode = 0x00
    ClassCode = 0x02
    ProgIF = 0x00
    BAR0 = 0x00000001
    BAR1 = 0x00000000
    BAR2 = 0x00000000
    BAR3 = 0x00000000
    BAR4 = 0x00000000
    BAR5 = 0x00000000
    MaximumLatency = 0x34
    MinimumGrant = 0xb0
    InterruptLine = 0x1e
    InterruptPin = 0x01
    BAR0Size = '256B'
    BAR1Size = '4kB'



class Sinic(EtherDevBase):
    type = 'Sinic'
    cxx_class = 'Sinic::Device'
    cxx_header = "dev/sinic.hh"

    rx_max_copy = Param.MemorySize('1514B', "rx max copy")
    tx_max_copy = Param.MemorySize('16kB', "tx max copy")
    rx_max_intr = Param.UInt32(10, "max rx packets per interrupt")
    rx_fifo_threshold = Param.MemorySize('384kB', "rx fifo high threshold")
    rx_fifo_low_mark = Param.MemorySize('128kB', "rx fifo low threshold")
    tx_fifo_high_mark = Param.MemorySize('384kB', "tx fifo high threshold")
    tx_fifo_threshold = Param.MemorySize('128kB', "tx fifo low threshold")
    virtual_count = Param.UInt32(1, "Virtualized SINIC")
    zero_copy_size = Param.UInt32(64, "Bytes to copy if below threshold")
    zero_copy_threshold = Param.UInt32(256,
        "Only zero copy above this threshold")
    zero_copy = Param.Bool(False, "Zero copy receive")
    delay_copy = Param.Bool(False, "Delayed copy transmit")
    virtual_addr = Param.Bool(False, "Virtual addressing")

    VendorID = 0x1291
    DeviceID = 0x1293
    Status = 0x0290
    SubClassCode = 0x00
    ClassCode = 0x02
    ProgIF = 0x00
    BAR0 = 0x00000000
    BAR1 = 0x00000000
    BAR2 = 0x00000000
    BAR3 = 0x00000000
    BAR4 = 0x00000000
    BAR5 = 0x00000000
    MaximumLatency = 0x34
    MinimumGrant = 0xb0
    InterruptLine = 0x1e
    InterruptPin = 0x01
    BAR0Size = '64kB'


