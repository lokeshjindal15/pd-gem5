/*
 * Copyright (c) 2002-2005 The Regents of The University of Michigan
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
 *          Ron Dreslinski
 */

/* @file
 * Device module for modelling a fixed bandwidth full duplex ethernet link
 */

#include <cmath>
#include <deque>
#include <string>
#include <vector>

#include "base/random.hh"
#include "base/trace.hh"
#include "debug/Ethernet.hh"
#include "debug/EthernetData.hh"
#include "debug/EthernetTimingViolation.hh"
#include "debug/EthernetTiming.hh"
#include "debug/EthernetTimingMonitor.hh"
#include "dev/etherdump.hh"
#include "dev/etherint.hh"
#include "dev/etherlink.hh"
#include "dev/etherpkt.hh"
#include "params/EtherLink.hh"
#include "sim/core.hh"
#include "sim/serialize.hh"
#include "sim/system.hh"
#include "dev/i8254xGBe_defs.hh"
#include "base/inet.hh"
#include <string>
#include <stdio.h>
#include <string.h>


using namespace std;
using namespace Net;
uint64_t getTick(EthPacketPtr pkt);
void setTick(uint64_t tick,EthPacketPtr pkt);

uint64_t getTick(EthPacketPtr pkt) {
    Tick sTick;
    DPRINTF(Ethernet, "get packet time stamp\n");

    char SenderTick[TickDigits+1];
    memmove(SenderTick,pkt->data + pkt->length - TickDigits,TickDigits);
    int k = 0;
    for (k=0;k<TickDigits;k++)
        if(SenderTick[k]!='0')
            break;
    memmove(SenderTick,SenderTick+k,TickDigits-k);
    SenderTick[TickDigits-k] = '\0';
    sTick = atol(SenderTick) + curTick() - curTick()%1000000000000;
    if (sTick > curTick() + 500000000000)
        sTick = sTick - 1000000000000;
    if (sTick < curTick() - 500000000000)
        sTick = sTick + 1000000000000;
    return sTick;
}

void setTick(uint64_t tick,EthPacketPtr pkt){

    DPRINTF(Ethernet, "set packet time stamp\n");

    char tick_cstr[TickDigits+1];
    char zero_pad[TickDigits+1] = "000000000000";
    //convert tick to c_string
    sprintf(tick_cstr,"%lu",tick % 1000000000000);
    //put new tick into the pad
    memmove(zero_pad+strlen(zero_pad)-strlen(tick_cstr),tick_cstr,strlen(tick_cstr));
    //replace zero padded tick with the current time stamp
    memmove(pkt->data + pkt->length - TickDigits, zero_pad,TickDigits);
}

EtherLink::EtherLink(const Params *p)
    : EtherObject(p)
{
    link[0] = new Link(name() + ".link0", this, 0,
                       p->delay, p->delay_var, p->dump,
                       p->tcp_speed, p->udp_speed, p->no_ip_speed,
                       p->tcp_retry_speed, p->udp_retry_speed, p->no_ip_retry_speed, p->tcp_process_speed,
                       p->tcp_jmp_delay0, p->tcp_jmp_delay1, p->tcp_jmp_size0, p->tcp_jmp_size1, p->no_delay,
                       p->ns_connector, p->queue_size
                        );
    link[1] = new Link(name() + ".link1", this, 1,
                       p->delay, p->delay_var, p->dump,
                       p->tcp_speed, p->udp_speed, p->no_ip_speed,
                       p->tcp_retry_speed, p->udp_retry_speed, p->no_ip_retry_speed, p->tcp_process_speed,
                       p->tcp_jmp_delay0, p->tcp_jmp_delay1, p->tcp_jmp_size0, p->tcp_jmp_size1, p->no_delay,
                       p->ns_connector, p->queue_size
                        );

    interface[0] = new Interface(name() + ".int0", link[0], link[1]);
    interface[1] = new Interface(name() + ".int1", link[1], link[0]);
}


EtherLink::~EtherLink()
{
    delete link[0];
    delete link[1];

    delete interface[0];
    delete interface[1];
}

EtherInt*
EtherLink::getEthPort(const std::string &if_name, int idx)
{
    Interface *i;
    if (if_name == "int0")
        i = interface[0];
    else if (if_name == "int1")
        i = interface[1];
    else
        return NULL;
    fatal_if(i->getPeer(), "interface already connected to\n");

    return i;
}


EtherLink::Interface::Interface(const string &name, Link *tx, Link *rx)
    : EtherInt(name), txlink(tx)
{
    tx->setTxInt(this);
    rx->setRxInt(this);
}

EtherLink::Link::Link(const string &name, EtherObject *p, int num,
                      Tick delay, Tick delay_var, EtherDump *d,
                      double rateTCP, double rateUDP, double rateNoIP,
                      double rateRetryTCP, double rateRetryUDP,
                      double rateRetryNoIP, double rateProcessTCP,
                      Tick DelayJmp0, Tick DelayJmp1, int SizeJmp0, int SizeJmp1,bool no_delay,
                      bool ns_connector, int queue_size)
    : objName(name), parent(p), number(num), txint(NULL), rxint(NULL),
      ticksPerByteTCP(rateTCP),ticksPerByteUDP(rateUDP),ticksPerByteNoIP(rateNoIP),
      ticksPerByteRetryTCP(rateRetryTCP),ticksPerByteRetryUDP(rateRetryUDP),
      ticksPerByteRetryNoIP(rateRetryNoIP),ticksPerByteProcessTCP(rateProcessTCP),
      linkDelay(delay), delayVar(delay_var), dump(d),
      linkDelayJmp0(DelayJmp0),linkDelayJmp1(DelayJmp1),preScheduleTick(0),retryTick(0),
      releaseTick(0),DelayJmpPoint0(SizeJmp0),DelayJmpPoint1(SizeJmp1),noDelay(no_delay),
      nsConnector(ns_connector),queueSize(queue_size), ts(0), rt(0), qs(0),
      doneEvent(this)
{ }

void
EtherLink::serialize(ostream &os)
{
    link[0]->serialize("link0", os);
    link[1]->serialize("link1", os);
}

void
EtherLink::unserialize(Checkpoint *cp, const string &section)
{
    link[0]->unserialize("link0", cp, section);
    link[1]->unserialize("link1", cp, section);
}

void
EtherLink::Link::txComplete(EthPacketPtr packet)
{
    DPRINTF(Ethernet, "packet received: len=%d\n", packet->length);
    DDUMP(EthernetData, packet->data, packet->length);
    rxint->sendPacket(packet);
}

class LinkDelayEvent : public Event
{
  protected:
    EtherLink::Link *link;
    EthPacketPtr packet;

  public:
    // non-scheduling version for createForUnserialize()
    LinkDelayEvent();
    LinkDelayEvent(EtherLink::Link *link, EthPacketPtr pkt);

    void process();

    virtual void serialize(ostream &os);
    void unserialize(Checkpoint *cp, const string &section) {}
    void unserialize(Checkpoint *cp, const string &section,
                     EventQueue *eventq);
    static Serializable *createForUnserialize(Checkpoint *cp,
                                              const string &section);
};

class OrderingEvent : public Event
{
  protected:
    EtherLink::Link *link;
    EthPacketPtr packet;
    Tick stick;

  public:
    OrderingEvent(EtherLink::Link *link, EthPacketPtr pkt,Tick stick);

    void process();

    virtual void serialize(ostream &os);
    void unserialize(Checkpoint *cp, const string &section) {}
    void unserialize(Checkpoint *cp, const string &section,
                     EventQueue *eventq);
};


class QueueSizeDecEvent : public Event
{
  protected:
    EtherLink::Link *link;

  public:
    QueueSizeDecEvent(EtherLink::Link *link);

    void process(){
        DPRINTF(Ethernet, "Decrement qs, qs=%d\n",link->qs);
        link->qs --;
    }

    virtual void serialize(ostream &os);
    void unserialize(Checkpoint *cp, const string &section) {}
    void unserialize(Checkpoint *cp, const string &section,
                     EventQueue *eventq);
};

void
EtherLink::Link::txDone(){
    txDone(packet,0);
}

void
EtherLink::Link::txDone(EthPacketPtr pkt, Tick stick)
{
    packet = pkt;
    ts = stick;
    if (dump)
        dump->dump(packet);
    if (noDelay || (!nsConnector && ts==0)){
        DPRINTF(EthernetTimingMonitor, "length_ct,%d,%lu\n",packet->length,curTick());
        txComplete(packet);

        packet = 0;
        assert(!busy());

        txint->sendDone();
    }
    else if (nsConnector){
        /*
         parameters & variables:

         ct = current tick
         ts = time stamp
         td = transport delay
         pd = propagation delay
         rt = release tick
         dt = delivery tick
         qs = queue size
         ticksPerByteTCP
         linkDelay
        */
        ct = curTick();
        ts = getTick(packet);
        td = (Tick)ceil(((double)packet->length * ticksPerByteTCP) + 1.0);
        pd = linkDelay;
        DPRINTF(Ethernet, "rt = %lu, ts=%lu, td=%lu, pd=%lu, qs=%d \n", rt,ts,td,pd,qs);
        DPRINTF(EthernetTimingMonitor, "rt = %lu, ts=%lu, td=%lu, pd=%lu, qs=%d \n", rt,ts,td,pd,qs);
        /*
          ----------------------------------------------------------
             ^      ^                ^       ^              ^
             |      |                |       |              |
             rt   ct,ts     OR      ct,ts   rt     OR    ct,ts,rt
                (1)                     (2)                 (3)
        */
        if (ts == ct){
            /*
                (1) , (3)
                queue is empty or one packet is there, no drop
            */
            if(rt <= ct){
                DPRINTF(EthernetTimingMonitor, "rt<=ts==ct\n");
                dt = ts + td + pd;
                rt = ts + td;
                qs ++;
                //schedule a queue size decrement event on rt
                Event *event = new QueueSizeDecEvent(this);
                parent->schedule(event, rt);
            }

            /*
                (2)
                there is something in the queue, possibility for drop
            */
            else {
                DPRINTF(EthernetTimingMonitor, "ts==ct<rt\n");
                if (queueSize <= qs){
                    //drop packet
                    DPRINTF(EthernetTimingMonitor, "Queue full, drop packet\n");
                    packet = 0;
                    assert(!busy());
                    ts = 0;
                    return;
                }
                dt = rt + td + pd;
                rt = rt + td;
                qs ++;
                //schedule a queue size decrement event on rt
                Event *event = new QueueSizeDecEvent(this);
                parent->schedule(event, rt);
            }
        }
        /*
          --------------------------------------------
             ^      ^                ^       ^     ^
             |      |                |       |     |
             ts   ct,rt     OR      ts      ct     rt
                (4)                     (5)
        */
        else if(ts < ct && ct <= rt){
            /*
                (4) , (5)
                there is something in the queue, possibility for drop
                possibility of inaccuracy, maybe something has been violated!
            */
            DPRINTF(EthernetTimingMonitor, "ts<ct<=rt\n");
            if (queueSize <= qs){
                //drop packet
                DPRINTF(EthernetTimingMonitor, "Queue full, drop packet\n");
                packet = 0;
                assert(!busy());
                ts = 0;
                return;
            }
            dt = rt + td + pd;
            rt = rt + td;
            qs ++;
            //schedule a queue size decrement event on rt
            Event *event = new QueueSizeDecEvent(this);
            parent->schedule(event, rt);

        }
        /*
          --------------------------------------------
             ^      ^     ^           ^       ^
             |      |     |           |       |
             rt    ts    ct     OR  ts,rt     ct
                (6)                   (7)
        */
        else if(rt <= ts && ts < ct){
            /*
                (6) , (7)
                queue is empty, no possibility for drop
                possibility of inaccuracy, maybe something has been violated!
            */
            dt = ts + td + pd;
            rt = ts + td;
            DPRINTF(EthernetTimingMonitor, "rt<=ts<ct\n");
        }
        /*
          ---------------------
             ^      ^     ^
             |      |     |
             ts    rt    ct
                (8)
        */
        else if(ts < rt && rt < ct){
            /*
                (8)
                queue is empty, no possibility for drop
                possibility of inaccuracy, maybe something has been violated!
            */
            DPRINTF(EthernetTimingMonitor, "ts<rt<ct\n");
            dt = rt + td + pd;
            rt = rt + td;
        }
        else{
            printf("Error!!! Don't know what to do with packet! rt = %lu, ts=%lu, td=%lu, pd=%lu, qs=%d \n", rt,ts,td,pd,qs);
            DPRINTF(Ethernet, "Error!!! Don't know what to do with packet!\n");
            assert(0);
        }
        DPRINTF(Ethernet, "changing the ts to dt=%lu, dt - ct =%lu\n",dt,dt - ts);
        DPRINTF(EthernetTimingMonitor, "length_dt_delay,%d,%lu,%lu\n",packet->length,dt,dt - ts);
        DPRINTF(EthernetTiming, "length_dt_delay_qs,%d,%lu,%lu,%d\n",packet->length,dt,dt - ts,qs);
        setTick(dt,packet);
        txComplete(packet);

        packet = 0;
        ts = 0;
        assert(!busy());

        txint->sendDone();
    }
    else {
        ct = curTick();
        td = (Tick)ceil(((double)packet->length * ticksPerByteTCP) + 1.0);
        qd = (Tick)ceil(((double)packet->length * ticksPerByteProcessTCP) + 1.0); //queue delay
        pd = linkDelay;
        DPRINTF(EthernetTiming, "xyzz rt = %lu, ts=%lu, td=%lu, pd=%lu, qd=%lu, qs=%d \n", rt,ts,td,pd,qd,qs);
        /*
          ----------------------------------------------------------
             ^      ^                ^       ^              ^
             |      |                |       |              |
             rt   ct,ts     OR      ct,ts   rt     OR    ct,ts,rt
                (1)                     (2)                 (3)
        */
        if (ts == ct){
            /*
                (1) , (3)
                queue is empty or one packet is there, no drop
            */
            if(rt <= ct){
                DPRINTF(EthernetTiming, "xyz rt<=ct=ts\n");
                dt = ts + td + pd;
                rt = ts + td;
                qs ++;
                //schedule a queue size decrement event on rt
                DPRINTF(EthernetTimingMonitor, "rt<=ts==ct, schedule a queue size decrement on %lu, qs=%d \n", rt,qs);
                Event *event = new QueueSizeDecEvent(this);
                parent->schedule(event, rt);
            }

            /*
                (2)
                there is something in the queue, possibility for drop
            */
            else {
                DPRINTF(EthernetTiming, "xyz ct=ts<rt\n");
                if (queueSize <= qs){
                    //drop packet
                    DPRINTF(EthernetTiming, "length_dt_ts,qs,%d,0,%lu,%d\n",packet->length,ts,qs);
                    DPRINTF(EthernetTimingMonitor, "Queue full, drop packet\n");
                    packet = 0;
                    assert(!busy());
                    return;
                }
                dt = rt + td + pd;
                rt = rt + td;
                qs ++;
                //schedule a queue size decrement event on rt
                DPRINTF(EthernetTimingMonitor, "ts==ct<rt, schedule a queue size decrement on %lu, qs=%d \n", rt,qs);
                Event *event = new QueueSizeDecEvent(this);
                parent->schedule(event, rt);
            }
        }
        /*
          --------------------------------------------
             ^      ^                ^       ^     ^
             |      |                |       |     |
             ts   ct,rt     OR      ts      ct     rt
                (4)                     (5)
        */
        else if(ts < ct && ct <= rt){
            DPRINTF(EthernetTiming, "xyz ts<ct<=rt\n");
            /*
                (4) , (5)
                there is something in the queue, possibility for drop
                possibility of inaccuracy, maybe something has been violated!
            */
            if (queueSize <= qs){
                //drop packet
                DPRINTF(EthernetTiming, "length_dt_ts,qs,%d,0,%lu,%d\n",packet->length,ts,qs);
                DPRINTF(EthernetTimingMonitor, "Queue full, drop packet\n");
                packet = 0;
                assert(!busy());
                return;
            }
            dt = rt + td + pd;
            rt = rt + td;
            qs ++;
            //schedule a queue size decrement event on rt
            DPRINTF(EthernetTimingMonitor, "ts<ct<=rt ,schedule a queue size decrement on %lu, qs=%d \n", rt,qs);
            Event *event = new QueueSizeDecEvent(this);
            parent->schedule(event, rt);

        }
        /*
          --------------------------------------------
             ^      ^     ^           ^       ^
             |      |     |           |       |
             rt    ts    ct     OR  ts,rt     ct
                (6)                   (7)
        */
        else if(rt <= ts && ts < ct){
            /*
                (6) , (7)
                queue is empty, no possibility for drop
                possibility of inaccuracy, maybe something has been violated!
            */
            DPRINTF(EthernetTiming, "xyz rt<=ts<ct\n");
            dt = ts + td + pd;
            if ( dt < ct ){
                DPRINTF(EthernetTimingViolation,"Packet arrived late! late tick=%lu",ct-dt);
                DPRINTF(EthernetTimingMonitor,"Packet arrived late! late tick=%lu",ct-dt);
                dt = ct;
            }
            rt = ts + td;
        }
        /*
          ---------------------
             ^      ^     ^
             |      |     |
             ts    rt    ct
                (8)
        */
        else if(ts < rt && rt < ct){
            /*
                (8)
                queue is empty, no possibility for drop
                possibility of inaccuracy, maybe something has been violated!
            */
            DPRINTF(EthernetTiming, "xyz ts<rt<ct\n");
            dt = rt + td + pd;
            if ( dt < ct ){
                DPRINTF(EthernetTimingViolation,"Packet arrived late! late tick=%lu",ct-dt);
                DPRINTF(EthernetTimingMonitor,"Packet arrived late! late tick=%lu",ct-dt);
                dt = ct;
            }
            rt = rt + td;
        }
        else{
            printf("Error!!! Don't know what to do with packet! rt = %lu, ts=%lu, td=%lu, pd=%lu, qs=%d \n", rt,ts,td,pd,qs);
            DPRINTF(Ethernet, "Error!!! Don't know what to do with packet!\n");
            assert(0);
        }
        DPRINTF(Ethernet, "scheduling packet at dt=%lu, dt - ct =%lu\n",dt,dt - ts);
        DPRINTF(EthernetTimingMonitor, "length_dt_diff,%d,%lu,%lu\n",packet->length,dt,dt - ts);
        DPRINTF(EthernetTiming, "length_dt_diff,qs,%d,%lu,%lu,%d\n",packet->length,dt,dt - ts,qs);
        DPRINTF(EthernetTiming, "xyzzz rt,ts,td,pd,qs,dt,ct = ,%lu,%lu,%lu,%lu,%d,%lu,%lu \n", rt,ts,td,pd,qs,dt,ct);
        if (dt == ct)
            txComplete(packet);
        else{
            Event *event = new LinkDelayEvent(this, packet);
            parent->schedule(event, dt);
        }

        packet = 0;
        ts = 0;
        assert(!busy());

        txint->sendDone();
    }
}

//This function gets called from EtherTap device
//So receiveing packets from outside world will go through this function
bool
EtherLink::Link::transmit(EthPacketPtr pkt, Tick sTick_)
{
    ts = sTick_;
    if (busy()) {
        DPRINTF(Ethernet, "packet not sent, link busy\n");
        return false;
    }
    DPRINTF(Ethernet, "packet sent: len=%d\n", pkt->length);
    DDUMP(EthernetData, pkt->data, pkt->length);

    packet = pkt;

    DPRINTF(Ethernet, "received packet from ethertap device: len=%d, ts=%lu\n"
                , packet->length,ts);
    if (curTick() < ts){
        // early packet, ordering point
        DPRINTF(Ethernet,"early packet, ordering point!, ts=%lu\n",ts);
        Event *event = new OrderingEvent(this,packet,ts);
        parent->schedule(event, ts);
        packet = 0;
        return true;
    }
    DPRINTF(Ethernet,"packet time stamp already expired! process it immediately!\n");
    // packet time stamp already expired! process it immediately
    packet = 0;
    txDone(pkt,ts);
    return true;
}

bool
EtherLink::Link::transmit(EthPacketPtr pkt)
{
    if (busy()) {
        DPRINTF(Ethernet, "packet not sent, link busy\n");
        return false;
    }

    DPRINTF(Ethernet, "received packet from !ethertap/ethertap device: len=%d\n"
                , pkt->length);
    DDUMP(EthernetData, pkt->data, pkt->length);

    packet = pkt;
    Tick delay = 0;

    if(noDelay){
        DPRINTF(Ethernet,"No Delay enabled!\n");
        parent->schedule(doneEvent, curTick() + 1000);
        return true;
    }

    if(nsConnector){
        DPRINTF(Ethernet,"NS Connector enabled!\n");

        if (curTick() < getTick(pkt)){
            // early packet, ordering point
            DPRINTF(Ethernet,"early packet, ordering point!, ts=%lu\n",getTick(packet));
            Event *event = new OrderingEvent(this,packet,getTick(packet));
            parent->schedule(event, getTick(packet));
            packet = 0;
            return true;
        }
        DPRINTF(Ethernet,"packet time stamp already expired! process it immediately!\n");
        // packet time stamp already expired! process it immediately
        txDone(pkt, getTick(packet));
        packet = 0;
        return true;
    }

    delay = (Tick)ceil(((double)pkt->length * ticksPerByteRetryTCP) + 1.0);
    if (delayVar != 0)
        delay += random_mt.random<Tick>(0, delayVar);

    DPRINTF(Ethernet, "scheduling packet: delay=%d, rate= %f\n",
            delay, ticksPerByteRetryTCP);
    parent->schedule(doneEvent, curTick() + delay);

    return true;
}

void
EtherLink::Link::serialize(const string &base, ostream &os)
{
    bool packet_exists = packet != nullptr;
    paramOut(os, base + ".packet_exists", packet_exists);
    if (packet_exists)
        packet->serialize(base + ".packet", os);

    bool event_scheduled = doneEvent.scheduled();
    paramOut(os, base + ".event_scheduled", event_scheduled);
    if (event_scheduled) {
        Tick event_time = doneEvent.when();
        paramOut(os, base + ".event_time", event_time);
    }

}

void
EtherLink::Link::unserialize(const string &base, Checkpoint *cp,
                             const string &section)
{
    bool packet_exists;
    paramIn(cp, section, base + ".packet_exists", packet_exists);
    if (packet_exists) {
        packet = make_shared<EthPacketData>(16384);
        packet->unserialize(base + ".packet", cp, section);
    }

    bool event_scheduled;
    paramIn(cp, section, base + ".event_scheduled", event_scheduled);
    if (event_scheduled) {
        Tick event_time;
        paramIn(cp, section, base + ".event_time", event_time);
        parent->schedule(doneEvent, event_time);
    }
}

LinkDelayEvent::LinkDelayEvent()
    : Event(Default_Pri, AutoSerialize | AutoDelete), link(NULL)
{
}

LinkDelayEvent::LinkDelayEvent(EtherLink::Link *l, EthPacketPtr p)
    : Event(Default_Pri, AutoSerialize | AutoDelete), link(l), packet(p)
{
}

void
LinkDelayEvent::process()
{
    link->txComplete(packet);
}

void
LinkDelayEvent::serialize(ostream &os)
{
    paramOut(os, "type", string("LinkDelayEvent"));
    Event::serialize(os);

    EtherLink *parent = static_cast<EtherLink*>(link->parent);
    bool number = link->number;
    SERIALIZE_OBJPTR(parent);
    SERIALIZE_SCALAR(number);

    packet->serialize("packet", os);
}


void
LinkDelayEvent::unserialize(Checkpoint *cp, const string &section,
                            EventQueue *eventq)
{
    Event::unserialize(cp, section, eventq);

    EtherLink *parent;
    bool number;
    UNSERIALIZE_OBJPTR(parent);
    UNSERIALIZE_SCALAR(number);

    link = static_cast<EtherLink*>(parent)->link[number];

    packet = make_shared<EthPacketData>(16384);
    packet->unserialize("packet", cp, section);
}


Serializable *
LinkDelayEvent::createForUnserialize(Checkpoint *cp, const string &section)
{
    return new LinkDelayEvent();
}

REGISTER_SERIALIZEABLE("LinkDelayEvent", LinkDelayEvent)

EtherLink *
EtherLinkParams::create()
{
    return new EtherLink(this);
}




QueueSizeDecEvent::QueueSizeDecEvent(EtherLink::Link *l)
    : Event(Default_Pri, AutoSerialize | AutoDelete), link(l)
{
}

void
QueueSizeDecEvent::serialize(ostream &os)
{
    paramOut(os, "type", string("QueueSizeDecEvent"));
    Event::serialize(os);

    EtherLink *parent = static_cast<EtherLink*>(link->parent);
    bool number = link->number;
    SERIALIZE_OBJPTR(parent);
    SERIALIZE_SCALAR(number);

}


void
QueueSizeDecEvent::unserialize(Checkpoint *cp, const string &section,
                            EventQueue *eventq)
{
    Event::unserialize(cp, section, eventq);

    EtherLink *parent;
    bool number;
    UNSERIALIZE_OBJPTR(parent);
    UNSERIALIZE_SCALAR(number);

    link = static_cast<EtherLink*>(parent)->link[number];
}

OrderingEvent::OrderingEvent(EtherLink::Link *l, EthPacketPtr p, Tick ts)
    : Event(Default_Pri, AutoSerialize | AutoDelete), link(l), stick(ts)
{
    packet = make_shared<EthPacketData>(p->length);
    packet->length = p->length;
    memcpy(packet->data, p->data, p->length);
}

void
OrderingEvent::process()
{
    link->txDone(packet,stick);
}

void
OrderingEvent::serialize(ostream &os)
{
    paramOut(os, "type", string("OrderingEvent"));
    Event::serialize(os);

    EtherLink *parent = static_cast<EtherLink*>(link->parent);
    bool number = link->number;
    SERIALIZE_OBJPTR(parent);
    SERIALIZE_SCALAR(number);
    SERIALIZE_SCALAR(stick);

    packet->serialize("packet", os);
}

void
OrderingEvent::unserialize(Checkpoint *cp, const string &section,
                            EventQueue *eventq)
{
    Event::unserialize(cp, section, eventq);

    EtherLink *parent;
    bool number;
    UNSERIALIZE_OBJPTR(parent);
    UNSERIALIZE_SCALAR(number);
    UNSERIALIZE_SCALAR(stick);

    link = static_cast<EtherLink*>(parent)->link[number];

    packet = make_shared<EthPacketData>(16384);
    packet->unserialize("packet", cp, section);
}

