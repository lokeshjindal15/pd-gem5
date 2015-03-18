#!/usr/bin/env python
# ./barrier.py <tcp_port> <num_of_nodes>
# if barrier reads 0 form config.ini, it will pause synchronization
# till it reads 1 again
import socket
import sys
import time
c_list=[]
TCP_IP = sys.argv[2]#'128.104.189.129'
TCP_PORT = sys.argv[1]
#BUFFER_SIZE = 131
BUFFER_SIZE = 1
NumOfNodes = int(sys.argv[3])
ConfFileName = "/research/alian/Simulators/gem5/util/barrier/config1.ini"

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((TCP_IP, int(TCP_PORT)))
s.listen(3)
for i in range(0,NumOfNodes):
    conn, addr = s.accept()
    c_list.append(conn)
    print "gem5 " + str(i) + "connected."

print "Sync Started ..."
time.sleep(60)

#f0 = open("barrierTrace.txt",'w')
#ticks = time.time()

while 1:
    with open(ConfFileName, 'r') as f:
        x = f.readline()
        if x != '':
            if int(x) == 0:
                print "Writing checkpoint ..."
                print "Please set config file back to 1 in 30 seconds ..."
                for i in range(0,NumOfNodes):
                    c_list[i].recv(BUFFER_SIZE)
                for i in range (0,NumOfNodes):
                    c_list[i].send('C')  #tack chackpoint

                time.sleep(30)

            elif int(x) == 1:
                for i in range(0,5):
                    for i in range(0,NumOfNodes):
                        #f0.write(c_list[i].recv(BUFFER_SIZE))
                        c_list[i].recv(BUFFER_SIZE)
		    #f0.write(str(time.time() - ticks) + '\n')
                    for i in range (0,NumOfNodes):
                        c_list[i].send('R')  # echo
		    #ticks = time.time()
		    #time.sleep(0.1)
            else:
                print "Please attach ethertap and then set config file back to 1"
                time.sleep(30)

conn.close()
f0.close()
