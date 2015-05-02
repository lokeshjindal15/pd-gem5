/*
 * Copyright (c) 2003-2005 The Regents of The University of Michigan
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met: redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer;
 * redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution;
 * neither the name of the copyright holders nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Authors: Nathan Binkert
 */

/* @file
 * Interface to connect a simulated ethernet device to the real world
 */

#if defined(__OpenBSD__) || defined(__APPLE__)
#include <sys/param.h>
#endif
#include <netinet/in.h>
#include <unistd.h>

#include <deque>
#include <string>

#include "base/misc.hh"
#include "base/pollevent.hh"
#include "base/socket.hh"
#include "base/trace.hh"
#include "debug/Ethernet.hh"
#include "debug/EthernetData.hh"
#include "dev/etherdump.hh"
#include "dev/etherint.hh"
#include "dev/etherpkt.hh"
#include "dev/ethertap.hh"
#include <sstream>
#include <stdlib.h>
#include <stdio.h>
#include <netinet/tcp.h>
#include <stdio.h>
#include <sys/types.h>
#include <ifaddrs.h>
#include <netinet/in.h>
#include <string.h>
#include <arpa/inet.h>
#include <fcntl.h>

std::string uint64_to_string( uint64_t value );
uint64_t extractTick(char*);
using namespace std;

// uint_64(Tick) to string
std::string uint64_to_string( uint64_t value ) {
    std::ostringstream os;
    os << value;
    return os.str();
}

// extract sender's tick from the packet
uint64_t extractTick(char* tick){
    int i=0;
    while(i<TickDigits){
        if(tick[i]!='0')
            break;
            i++;
    }
    return atol(tick+i);
}


/**
 */
class TapListener
{
  protected:
    /**
     */
    class Event : public PollEvent
    {
      protected:
        TapListener *listener;

      public:
        Event(TapListener *l, int fd, int e)
            : PollEvent(fd, e), listener(l) {}

        virtual void process(int revent) { listener->accept(); }
    };

    friend class Event;
    Event *event;

  protected:
    ListenSocket listener;
    EtherTap *tap;
    int port;

  public:
    TapListener(EtherTap *t, int p)
        : event(NULL), tap(t), port(p) {}
    ~TapListener() { if (event) delete event; }

    void accept();
    void listen();
};

void
TapListener::listen()
{
    while (!listener.listen(port, true)) {
        DPRINTF(Ethernet, "TapListener(listen): Can't bind port %d\n", port);
        port++;
    }

    FILE *f;
    struct ifaddrs * ifAddrStruct=NULL;
    struct ifaddrs * ifa=NULL;
    void * tmpAddrPtr=NULL;
    f = fopen("tap.conf", "w");
    getifaddrs(&ifAddrStruct);

    for (ifa = ifAddrStruct; ifa != NULL; ifa = ifa->ifa_next) {
        if (!ifa->ifa_addr) {
            continue;
        }
        if (ifa->ifa_addr->sa_family == AF_INET) { // check it is IP4
            // is a valid IP4 Address
            tmpAddrPtr=&((struct sockaddr_in *)ifa->ifa_addr)->sin_addr;
            char addressBuffer[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, tmpAddrPtr, addressBuffer, INET_ADDRSTRLEN);
            if (!strcmp(ifa->ifa_name,"eth0") || !strcmp(ifa->ifa_name,"eth1"))
                 fprintf(f,"%s= %s\n", ifa->ifa_name, addressBuffer);
                 printf("%s= %s\n", ifa->ifa_name, addressBuffer);
        }
    }
    if (ifAddrStruct!=NULL) freeifaddrs(ifAddrStruct);

    fprintf(f,"tapport= %d\n", port);
    printf("tapport= %d\n", port);
    fclose(f);
    ccprintf(cerr, "Listening for tap connection on port %d\n", port);
    event = new Event(this, listener.getfd(), POLLIN|POLLERR);
    pollQueue.schedule(event);
}

void
TapListener::accept()
{
    // As a consequence of being called from the PollQueue, we might
    // have been called from a different thread. Migrate to "our"
    // thread.
    EventQueue::ScopedMigration migrate(tap->eventQueue());

    if (!listener.islistening())
        panic("TapListener(accept): cannot accept if we're not listening!");

    int sfd = listener.accept(true);
    if (sfd != -1)
        tap->attach(sfd);
}

/**
 */

EtherTap::EtherTap(const Params *p)
    : EtherObject(p), socket(-1), buflen(p->bufsz), dump(p->dump),
      interface(NULL), noDelay(p->no_delay), delay(p->delay), txEvent(this), tapInEvent(this)
{
    if (ListenSocket::allDisabled())
        fatal("All listeners are disabled! EtherTap can't work!");

    buffer = new char[buflen];
    listener = new TapListener(this, p->port);
    listener->listen();
    interface = new EtherTapInt(name() + ".interface", this);
}

EtherTap::~EtherTap()
{
    if (buffer)
        delete [] buffer;

    delete interface;
    delete listener;
}

void
EtherTap::attach(int fd)
{
    if (socket != -1)
        close(fd);

    buffer_offset = 0;
    data_len = 0;
    socket = fd;
    DPRINTF(Ethernet, "EtherTap attached\n");
    int nonBlocking = 1;
    if ( fcntl( socket, F_SETFL, O_NONBLOCK, nonBlocking ) == -1 )
    {
            printf( "failed to set non-blocking socket\n" );
            return;
    }
    schedule(tapInEvent, curTick() + 10000000);
}

void
EtherTap::detach()
{
    DPRINTF(Ethernet, "EtherTap detached\n");
    close(socket);
    socket = -1;
}

bool
EtherTap::recvPacket(EthPacketPtr packet)
{
    if (dump)
        dump->dump(packet);

    DPRINTF(Ethernet, "EtherTap output len=%d\n", packet->length);
    DDUMP(EthernetData, packet->data, packet->length);
    if(!noDelay){
        DPRINTF(Ethernet, "Adding time stamp to out going packet\n");
        uint32_t len = htonl(packet->length+TickDigits);
        // send current tick to the peer at the end of packet
        // Just capture 1 sec of simulated time
        int j=0;
        Tick_int=0;
        char tick_cstr[TickDigits+1];
        Tick_int = (curTick() + delay) % 1000000000000;
        sprintf(tick_cstr,"%lu",Tick_int);
        for(j=0;j<packet->length;j++)
            buff[j]=packet->data[j];
        for(j=TickDigits-strlen(tick_cstr);j<TickDigits;j++)
            buff[j+packet->length] = tick_cstr[j-(TickDigits-strlen(tick_cstr))];

        for(j=0;j<TickDigits-strlen(tick_cstr);j++)
            buff[j+packet->length] = '0';
        buff[packet->length+TickDigits]='\0';
        ssize_t ret = write(socket, &len, sizeof(len));
        if (ret != sizeof(len))
            return false;

        ret = write(socket, buff, packet->length+TickDigits);
        if (ret != packet->length + TickDigits)
            return false;

        //interface->recvDone();

        return true;
    }
    uint32_t len = htonl(packet->length);
    ssize_t ret = write(socket, &len, sizeof(len));
    if (ret != sizeof(len))
        return false;
    ret = write(socket, packet->data, packet->length);
    if (ret != packet->length)
        return false;

    //interface->recvDone();

    return true;
}

void
EtherTap::sendDone()
{}

void
EtherTap::process()
{
    char *data = buffer + sizeof(uint32_t);

    if (buffer_offset < data_len + sizeof(uint32_t)) {
        int len = read(socket, buffer + buffer_offset, buflen - buffer_offset);
        if (len <= 0) {
            schedule(tapInEvent, curTick() + 1000000);
            return;
        }

        buffer_offset += len;

        if (data_len == 0)
            data_len = ntohl(*(uint32_t *)buffer);

        DPRINTF(Ethernet, "Received data from peer: len=%d buffer_offset=%d "
                "data_len=%d\n", len, buffer_offset, data_len);
    }

    if(!noDelay){
        int k=0;
        while (data_len != 0 && buffer_offset >= data_len + sizeof(uint32_t)) {
            buffer_offset -= TickDigits;
            memmove(SenderTick,buffer+sizeof(uint32_t)+data_len-TickDigits,TickDigits);
            data_len -= TickDigits;
            for (k=0;k<TickDigits;k++)
                if(SenderTick[k]!='0')
                    break;
            memmove(SenderTick,SenderTick+k,TickDigits-k);
            SenderTick[TickDigits-k] = '\0';
            uint64_t sTick = extractTick(SenderTick) + curTick() - curTick()%1000000000000;
            //sanity check
            //if we had a transition to next second of simulation while packet was in flight!
            if (sTick > (curTick() + 500000000000))
                sTick = sTick - 1000000000000;
            if (sTick < curTick() - 500000000000)
                sTick = sTick + 1000000000000;
            EthPacketPtr packet;
            packet = make_shared<EthPacketData>(data_len);
            packet->length = data_len;
            memcpy(packet->data, data, data_len);

            buffer_offset -= data_len + sizeof(uint32_t);
            assert(buffer_offset >= 0);
            if (buffer_offset > 0) {
                memmove(buffer, data + data_len + TickDigits, buffer_offset);
                data_len = ntohl(*(uint32_t *)buffer);
            } else
                data_len = 0;

            DPRINTF(Ethernet, "EtherTap input len=%d,STick=%lu\n", packet->length,sTick);
            DDUMP(EthernetData, packet->data, packet->length);
            if (!interface->sendPacket_(packet,sTick)) {
                DPRINTF(Ethernet, "bus busy...buffer for retransmission\n");
                tickBuffer.push(sTick);
                packetBuffer.push(packet);
                if (!txEvent.scheduled())
                    schedule(txEvent, curTick() + retryTime);
            } else if (dump) {
                dump->dump(packet);
            }
        }
        schedule(tapInEvent, curTick() + 1000000);
        return;
    }
    while (data_len != 0 && buffer_offset >= data_len + sizeof(uint32_t)) {
        EthPacketPtr packet;
        packet = make_shared<EthPacketData>(data_len);
        packet->length = data_len;
        memcpy(packet->data, data, data_len);

        buffer_offset -= data_len + sizeof(uint32_t);
        assert(buffer_offset >= 0);
        if (buffer_offset > 0) {
            memmove(buffer, data + data_len, buffer_offset);
            data_len = ntohl(*(uint32_t *)buffer);
        } else
            data_len = 0;

        DPRINTF(Ethernet, "EtherTap input len=%d\n", packet->length);
        DDUMP(EthernetData, packet->data, packet->length);
        if (!interface->sendPacket(packet)) {
            DPRINTF(Ethernet, "bus busy...buffer for retransmission\n");
            packetBuffer.push(packet);
            if (!txEvent.scheduled())
                schedule(txEvent, curTick() + retryTime);
        } else if (dump) {
            dump->dump(packet);
        }
    }
    schedule(tapInEvent, curTick() + 1000000);
}

void
EtherTap::retransmit()
{
    if (packetBuffer.empty())
        return;

    EthPacketPtr packet = packetBuffer.front();
    if (interface->sendPacket(packet) && (noDelay)) {
        if (dump)
            dump->dump(packet);
        DPRINTF(Ethernet, "EtherTap retransmit\n");
        packetBuffer.front() = NULL;
        packetBuffer.pop();
    }
    else if (interface->sendPacket_(packet,tickBuffer.front()) && (!noDelay)) {
        if (dump)
            dump->dump(packet);
        DPRINTF(Ethernet, "EtherTap retransmit\n");
        packetBuffer.front() = NULL;
        packetBuffer.pop();
        tickBuffer.pop();
    }

    if (!packetBuffer.empty() && !txEvent.scheduled())
        schedule(txEvent, curTick() + retryTime);
}

EtherInt*
EtherTap::getEthPort(const std::string &if_name, int idx)
{
    if (if_name == "tap") {
        if (interface->getPeer())
            panic("Interface already connected to\n");
        return interface;
    }
    return NULL;
}


//=====================================================================

void
EtherTap::serialize(ostream &os)
{
    SERIALIZE_SCALAR(socket);
    SERIALIZE_SCALAR(buflen);
    uint8_t *buffer = (uint8_t *)this->buffer;
    SERIALIZE_ARRAY(buffer, buflen);
    SERIALIZE_SCALAR(buffer_offset);
    SERIALIZE_SCALAR(data_len);

}

void
EtherTap::unserialize(Checkpoint *cp, const std::string &section)
{
    //UNSERIALIZE_SCALAR(socket);
    UNSERIALIZE_SCALAR(buflen);
    uint8_t *buffer = (uint8_t *)this->buffer;
    UNSERIALIZE_ARRAY(buffer, buflen);
    UNSERIALIZE_SCALAR(buffer_offset);
    UNSERIALIZE_SCALAR(data_len);

}

//=====================================================================

EtherTap *
EtherTapParams::create()
{
    return new EtherTap(this);
}
