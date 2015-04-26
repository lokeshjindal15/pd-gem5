#!/usr/bin/env python
#this barrier is designed for condor simulation
import socket
import sys
import time
import threading
import os
c_list=[]
TCP_IP = sys.argv[2]#'128.104.189.129'
TCP_PORT = sys.argv[1]
BUFFER_SIZE = 1
NumOfNodes = int(sys.argv[3])
os.system('echo 0 > ' + sys.argv[4])

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((TCP_IP, int(TCP_PORT)))
s.listen(3)
for i in range(0,NumOfNodes):
    conn, addr = s.accept()
    c_list.append(conn)
    print "gem5 " + str(i) + "connected."

os.system('echo 1 > ' + sys.argv[4])
time.sleep(100)
print "Sync Started ...!"


checkpoint = 0

while 1:
	checkpoint = 0
	for i in range (0,NumOfNodes):
		if(c_list[i].recv(BUFFER_SIZE) == "C"):
			checkpoint = 1
        for i in range (0,NumOfNodes):
		if checkpoint == 1:
                	c_list[i].send('C')
		else:
                	c_list[i].send('R')

conn.close()
