#!/usr/bin/python
#this script will read DGem5 config from argv[1] and start the framework
import sys, os, thread, commands
import socket
import time
import threading
import signal
import subprocess
import fcntl
import struct
#exitFlag = threading.Lock()
#exitFlag.acquire()
# Default config file (a sample is included)
configFile = sys.argv[1]
# A dictionary of parameters
params = {}
dict = {}
machines ={}
this = socket.gethostname()
#alias to machine name map
a_to_m ={} 

#all threads
t_sw = None
t_barrier = None
t_gem5 = {}
t_socat = {}
run_dir= ""
submit_script = ""
this_ip = ''
barrier_proc =None

def add_to_condor_script(rundir):
	global submit_script
	submit_script+="""
executable = /bin/sh 
arguments = %s
initialdir = %s
output = %s
error = %s
log = %s
Rank=TARGET.Mips
Requirements = ((Machine != "bert.ece.wisc.edu") && (Machine != "oct-6.ece.wisc.edu") && (Machine != "sameagle.ece.wisc.edu") && (Machine != "fozzy.ece.wisc.edu") && (Machine != "iris-33.ece.wisc.edu") && (Machine != "iris-21.ece.wisc.edu") && (Machine != "iris-16.ece.wisc.edu") && (Machine != "iris-31.ece.wisc.edu"))
universe = vanilla
getenv = true
queue
    """ % (rundir + "/job.sh",
           rundir,
           rundir + "/gem5sim.out",
           rundir + "/gem5sim.err",
           rundir + "/gem5sim.log")

def kill_simulation():
        global run_dir
        os.system(run_dir + '/pid.txt')
def kill_condor():
	os.system('condor_q > tmp.txt')
        with open('tmp.txt', 'r') as f:
			line = f.readline()
                	if "alian" in line:
                        	os.system('condor_rm ' + line.split(' ')[0])
def get_ip_address(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
    )[20:24])

this_ip = get_ip_address('eth0')
if this_ip == "192.168.2.18":
	this_ip = get_ip_address('eth1')

sync_host_ip = this_ip

def signal_handler(signal, frame):
        print('You pressed Ctrl+C!')
	print 'Do you want to kill this simulation or leave it running?'
	print 'yes: I want to kill it \n no: I want to continue simulation'
	while True:
		data = raw_input()
		if(data=='yes') or (data == 'Yes') or (data == 'YES'):
			kill_simulation()
			#kill_condor()
        		sys.exit(0)
		elif(data=='no') or (data == 'No') or (data == 'NO'):
			sys.exit(0)
		else:
			print 'please enter yes/no'

signal.signal(signal.SIGINT, signal_handler)
def start_barrier(rundir):
    global barrier_proc
    #more than 2 nodes
    if int(params['num_nodes']) > 2:
	cmd = '\'' + params['barrier_binary'] + ' ' + params['sync_port'] + ' '\
                + sync_host_ip + ' ' + str(int(params['num_nodes'])+1) + '\''
	cmd = params['barrier_bash_script'] + ' ' + cmd + ' ' + rundir
	print cmd
        barrier_proc = subprocess.Popen([cmd],shell = True)

    #run locally, 2 nodes
    else:
	cmd = params['barrier_binary_2nodes']+' ' + params['sync_port'] + ' '\
                + sync_host_ip + ' ' + params['num_nodes']
	barrier_proc = subprocess.Popen([cmd],shell = True)

def start_switch(run_dir,cmd_sw):
	rundir = run_dir + '/switch'
        f0 = open(rundir + '/job.sh','w')
        f0.write('#!/bin/sh\n')
        f0.write(cmd_sw)
        f0.close()
        add_to_condor_script(rundir)
 
def start_gem5(m,run_dir,a,cmd):
	rundir = run_dir + '/' + a
	f0 = open(rundir + '/job.sh','w')
	f0.write('#!/bin/sh\n')
	f0.write(cmd)
	f0.close()
	add_to_condor_script(rundir)

def start_socat(sw_tap_port,ip,gem5_tap_port):

    if int(params['num_nodes']) == 2:
	cmd = params['socat_binary'] + ' tcp:' + a_to_m['tux0'] + ':' + sw_tap_port + ',nodelay,priority=6'\
		+ ' tcp:' +a_to_m['tux1'] + ':' + gem5_tap_port + ',nodelay,priority=6'
	os.system(cmd)

    else:
	cmd = params['socat_binary'] + ' tcp:' + params['sw_host'] + ':' + sw_tap_port + ',nodelay,priority=6'\
                + ' tcp:' + ip + ':' + gem5_tap_port + ',nodelay,priority=6'
	os.system(cmd)

configCont = open(configFile,'r').readlines()

for i in configCont:
    if len(i)>1 and not i.strip()[0] == '#':
        iSplit = map(lambda x:x.strip(), i.split('=')[1:])
        params[i.split('=')[0]] = '='.join(iSplit)

print "\n\n>>> Start simulatig system with configuration  " + params['config'] + " <<<\n"\
        "              >>>>> That will work with host " + this + ":" + params['sync_port'] + " <<<<<\n"

machines = params['machine_names'].split(' ')
#make run directories:
run_dir= params['run_dir'] + '/'+ params['config']

# Clean up the old files
os.system("rm -rf %s" % (run_dir))
os.system("mkdir %s > /dev/null" %(params['run_dir']))
os.system("mkdir %s > /dev/null" %(run_dir))
os.system("mkdir %s/switch > /dev/null" %(run_dir))
os.system("mkdir %s > /dev/null" %(params['cpt_dir']))
os.system("mkdir %s/switch > /dev/null" %(params['cpt_dir']))

#copy config file
os.system("cp %s %s"%(configFile,run_dir))

for machine in machines:
    (m,a) = machine.split(':')
    os.system("mkdir %s/%s > /dev/null" %(run_dir,a))
    os.system("mkdir %s/%s > /dev/null" %(params['cpt_dir'],a))

cmd_debug = params['gem5_binary'] + ' ' + \
        '--debug-flags=' + params['debug_flags'] + ' '
if params['debug_start'] !='0':
        cmd_debug += '--debug-start=' + params['debug_start'] + ' '
cmd_nodebug = params['gem5_binary'] + ' '
cmd = params['gem5_dir']+'/configs/example/' + params['fs_script'] + ' '
#cmd = params['fs_script'] + ' '
if params['num_cpu'] != '1' and params['ISA'] == 'x86':
    cmd +='--kernel=' + params['gem5_dir'] + '/binaries/x86_64-vmlinux-2.6.22.9.smp' + ' '
elif params['ISA'] == 'x86':
    cmd +='--kernel=' + params['gem5_dir'] + '/binaries/x86_64-vmlinux-2.6.22.9' + ' '
elif params['ISA'] == 'arm':
    cmd +='--machine-type=' + params['machine_type'] + ' '\
    '--dtb-filename=' + params['dtb_filename'] + ' '\
    '--kernel=' + params['kernel'] + ' '
#cmd += '--script=' + params['script'] + ' '

cmd_no_sync_stub = params['sw_binary'] + ' ' +\
        params['gem5_dir']+'/configs/example/fs.py' + ' '\
        '--kernel=' + params['gem5_dir'] + '/binaries/x86_64-vmlinux-2.6.22.9' + ' '
cmd_no_sync = cmd
cmd += '--sync=' + params['sync_period'] + '000000' + ' ' \
        '--sync-port=' + params['sync_port'] + ' '

if params['ruby'] == '1':
	cmd += '--ruby '
cmd +=  '--mem-size=' + params['mem_size'] + ' ' \
        '--link-delay=' + params['link_delay'] + ' ' \
        '--switch-link-delay=' + params['switch_link_delay'] + ' ' \
        '--link-delay-var=' + params['link_delay_var'] + ' ' \
        '--link-speed=' + params['link_speed'] + ' ' \
        '--tcp-speed=' + params['tcp_speed'] + ' ' \
        '--udp-speed=' + params['udp_speed'] + ' ' \
        '--no-ip-speed=' + params['no_ip_speed'] + ' ' \
        '--link-rate-scale=' + params['link_rate_scale'] + ' ' \
        '--link-delay-opt=' + params['link_delay_opt'] + ' ' \
        '--link-delay-queue=' + params['link_delay_queue'] + ' ' \
        '--link-retry-time=' + params['link_retryTime'] + ' ' \
        '--nic-queue-th=' + params['nic_queue_th'] + ' ' \
	'--sys-clock=' + params['sys_clock'] + ' ' \
	'--cpu-clock=' + params['cpu_clock'] + ' ' \
	'--num-cpus=' + params['num_cpu'] + ' ' \
	'--tcp-retry-speed=' + params['tcp_retry_speed'] + ' ' \
	'--tcp-process-speed=' + params['tcp_process_speed'] + ' ' \
	'--udp-retry-speed=' + params['udp_retry_speed'] + ' ' \
	'--no-ip-retry-speed=' + params['no_ip_retry_speed'] + ' ' \
	'--tcp-jmp-delay0=' + params['tcp_jmp_delay0'] + ' ' \
	'--tcp-jmp-delay1=' + params['tcp_jmp_delay1'] + ' ' \
	'--tcp-jmp-size0=' + params['tcp_jmp_size0'] + ' ' \
	'--tcp-jmp-size1=' + params['tcp_jmp_size1'] + ' ' \
	'--tap-first-delay=' + params['tap_first_delay'] + ' '


#cmd_no_sync is just for switch usage, because we don't add --num-cpu option to it
#in addition, mem-size is hardwired to 4GB
if params['ruby'] == '1':
        cmd_no_sync += '--ruby '

cmd_no_sync += '--mem-size=' + '4096MB' + ' ' \
        '--link-delay=' + params['link_delay'] + ' ' \
        '--switch-link-delay=' + params['switch_link_delay'] + ' ' \
        '--link-delay-var=' + params['link_delay_var'] + ' ' \
        '--link-speed=' + params['link_speed'] + ' ' \
        '--tcp-speed=' + params['tcp_speed'] + ' ' \
        '--udp-speed=' + params['udp_speed'] + ' ' \
	'--tcp-process-speed=' + params['tcp_process_speed'] + ' ' \
        '--no-ip-speed=' + params['no_ip_speed'] + ' ' \
        '--link-rate-scale=' + params['link_rate_scale'] + ' ' \
        '--link-delay-opt=' + params['link_delay_opt'] + ' ' \
        '--link-delay-queue=' + params['link_delay_queue'] + ' ' \
        '--link-retry-time=' + params['link_retryTime'] + ' ' \
        '--nic-queue-th=' + params['nic_queue_th'] + ' ' \
        '--sys-clock=' + params['sys_clock'] + ' ' \
        '--cpu-clock=' + params['cpu_clock'] + ' ' \
        '--tcp-retry-speed=' + params['tcp_retry_speed'] + ' ' \
        '--udp-retry-speed=' + params['udp_retry_speed'] + ' ' \
        '--no-ip-retry-speed=' + params['no_ip_retry_speed'] + ' ' \
        '--tcp-jmp-delay0=' + params['tcp_jmp_delay0'] + ' ' \
        '--tcp-jmp-delay1=' + params['tcp_jmp_delay1'] + ' ' \
        '--tcp-jmp-size0=' + params['tcp_jmp_size0'] + ' ' \
        '--tcp-jmp-size1=' + params['tcp_jmp_size1'] + ' ' \
        '--tap-first-delay=' + params['tap_first_delay'] + ' '

#decoupled switch
cmd_sw = cmd + '--switch' + ' ' \
        '--disk-image=' + params['disk_image_sw'] + ' '\
        '--num-nodes=' + params['num_nodes'] + ' ' \
        '--checkpoint-dir=' + params['cpt_dir'] + '/switch/' + ' '
        #'--workload-disk-image=' + params['workload_disk_image'] + ' '\
if params['cpt_num_sw'] != '0':
        cmd_sw += '--checkpoint-restore=' + params['cpt_num_sw'] + ' '

if params['cpt_num'] != '0':
        cmd += '--checkpoint-restore=' + params['cpt_num'] + ' '

#switch will always run on iris-15
cmd_sw += '--sync-host=' + sync_host_ip + ' '
if params['trace_on_sw'] == '0':
	cmd_sw = cmd_nodebug + cmd_sw
else:
	cmd_sw = cmd_debug + cmd_sw
print cmd_sw
cmd += '--eth' + ' ' \
        '--cpu-type=' + params['cpu_type'] + ' '
        #'--disk-image=' + params['disk_image_tux'] + ' ' \
        #'--workload-disk-image=' + params['workload_disk_image'] + ' ' \
if params['max_inst'] !='0':
	cmd += '--maxinsts=' + params['max_inst'] + ' '

if params['caches'] == '1':
        cmd += '--caches' + ' '

cmd_tux = {}
itr = 0
for machine in machines:
    (m,a) = machine.split(':')
    a_to_m[a] = m
   
    # remove tux4 below     
    if ( a == "tux0" and params['trace_on_tux0'] == '1' ) or ( a=="tux1" and params['trace_on_tux1'] == '1') or ( a=="tux2" and params['trace_on_tux2'] == '1') or (params['trace_on_all'] == '1') or ( a=="tux4" and params['trace_on_tux4'] == '1'):
        cmd_tux[a] = cmd_debug + cmd + '--checkpoint-dir=' + params['cpt_dir'] + '/' + a + ' ' \
        '--sync-host=' + sync_host_ip + ' ' \
        '--mac=00:90:00:00:00:0' + str(itr) + ' ' \
	'--tap-port=3500 '
        if (a == "tux0"):
            cmd_tux[a] += '--script=' + params['script_tux0'] + ' '
        else:
            cmd_tux[a] += '--script=' + params['script_dir'] + '/'+ a + '.sh' + ' '
    else:
        cmd_tux[a] = cmd_nodebug + cmd + '--checkpoint-dir=' + params['cpt_dir'] + '/' + a + ' ' \
        '--sync-host=' + sync_host_ip + ' ' \
        '--mac=00:90:00:00:00:0' + str(itr) + ' ' \
	'--tap-port=3500 '
	if (a == "tux0"):
	    cmd_tux[a] += '--script=' + params['script_tux0'] + ' '
	else:
	    cmd_tux[a] += '--script=' + params['script_dir'] + '/'+ a + '.sh' + ' '

    cmd_tux[a] += '--disk-image=' + params['disk_image_dir'] +'/' + a + '.img '
    if(params['udp'] == '1'):
	if ( a != "tux0" ):
	    cmd_tux[a] += '--server=False '
    itr +=1

start_barrier(run_dir)

#start switch
if int(params['num_nodes']) > 2:
    start_switch(run_dir,cmd_sw)


#start other nodes
itr = 0
for machine in machines:
        (m,a) = machine.split(':')
        start_gem5(m,run_dir,a,cmd_tux[a])

condor_scr = open(run_dir + '/submit_script.scr','w')
condor_scr.write(submit_script)
condor_scr.close()

submit_cmd = 'condor_submit ' + run_dir + '/submit_script.scr'

os.system(submit_cmd)

print 'waiting ',
sys.stdout.flush()
while True:
	with open(run_dir + '/handshake', 'r') as f:
		print '.',
		sys.stdout.flush()
		if f.readline().rstrip() == '1':
			break
		else:
			time.sleep(10)

time.sleep(60)
print ' \n'
f = file(run_dir+'/switch/gem5sim.out')

itr = 0
sw_tap_ports = {}
sw_ip = ''
for line in f:
    if 'eth0' in line:
	(x,sw_ip) = line.split(' ')
	sw_ip = sw_ip.rstrip()
    if 'tapport=' in line:
	print line
        mach_name = 'tux'+str(itr)
        (x,sw_tap_ports[mach_name]) = line.split(' ')
        (sw_tap_ports[mach_name],x) = sw_tap_ports[mach_name].split('\n')
        itr +=1

f.close()

tap_port = {}
tux_ip = {}
itr = 0
file_log = open(run_dir+ '/cluster.conf','w')
for machine in machines:
	print itr
        (m,a) = machine.split(':')
	g = open(run_dir+'/'+a+'/tap.conf')
        for line in g:
	    if 'eth0' in line:
            	(x,tux_ip[a]) = line.split(' ')
            	tux_ip[a] = tux_ip[a].rstrip()

            if 'tapport=' in line:
                (x,tap_port[a]) = line.split(' ')
                (tap_port[a],x) = tap_port[a].split('\n')
                g.close()
                break
	print tux_ip
	print tap_port
	print sw_tap_ports
	print sw_ip
        if int(params['num_nodes']) > 2 and itr < int(params['disconnected_node']):
		cmd_socat = params['socat_binary'] +' tcp:' + tux_ip[a] + ':' + tap_port[a] + ',nodelay,priority=6'\
                + ' tcp:' +sw_ip + ':' + sw_tap_ports[a] + ',nodelay,priority=6 &'
		os.system(cmd_socat)
	itr +=1
itr = 0
for ip in tux_ip:
	file_log.write('tux'+str(itr) + ' '+ tux_ip['tux'+str(itr)])
	itr +=1
file_log.close()

file_log.close()
if int(params['num_nodes']) == 2:
	cmd_socat = params['socat_binary'] + ' tcp:' + tux_ip['tux0'] + ':' + tap_port['tux0'] + ',nodelay,priority=6'\
                + ' tcp:' +tux_ip['tux1'] + ':' + tap_port['tux1'] + ',nodelay,priority=6 &'
        os.system(cmd_socat)

print ">>>>>>>>>>Cluster Simulation<<<<<<<<<<"
while True:
    time.sleep(1)

