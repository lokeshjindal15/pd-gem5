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

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((TCP_IP, int(TCP_PORT)))
s.listen(3)
for i in range(0,NumOfNodes):
    conn, addr = s.accept()
    c_list.append(conn)
    print "gem5 " + str(i) + "connected."

print "Sync Started ..."
time.sleep(30)

while 1:
    if int(x) == 0:
        print "Writing checkpoint ..."
        print "Please set config file back to 1 in 30 seconds ..."
        for i in range(0,NumOfNodes):
            c_list[i].recv(BUFFER_SIZE)
        for i in range (0,NumOfNodes):
            c_list[i].send('C')  #tack chackpoint
    else:
        for i in range(0,NumOfNodes):
            c_list[i].recv(BUFFER_SIZE)
        for i in range (0,NumOfNodes):
            c_list[i].send('R')  # echo

conn.close()
