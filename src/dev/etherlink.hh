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
 */

/* @file
 * Device module for modelling a fixed bandwidth full duplex ethernet link
 */

#ifndef __DEV_ETHERLINK_HH__
#define __DEV_ETHERLINK_HH__

#include "base/types.hh"
#include "dev/etherint.hh"
#include "dev/etherobject.hh"
#include "dev/etherpkt.hh"
#include "params/EtherLink.hh"
#include "sim/eventq.hh"
#include "sim/sim_object.hh"

class EtherDump;
class Checkpoint;
/*
 * Model for a fixed bandwidth full duplex ethernet link
 */
class EtherLink : public EtherObject
{
  protected:
    class Interface;

    friend class LinkDelayEvent;

  public:
     /*
      * Model for a single uni-directional link
      */
    class Link
    {
      protected:
        std::string objName;

        EtherObject *parent;
        int number;

        EtherInt *txint;
        EtherInt *rxint;

        double ticksPerByteTCP;
        double ticksPerByteUDP;
        double ticksPerByteNoIP;
        double ticksPerByteRetryTCP;
        double ticksPerByteRetryUDP;
        double ticksPerByteRetryNoIP;
        double ticksPerByteProcessTCP;
        Tick linkDelay;
        Tick delayVar;
        EtherDump *dump;
        Tick linkDelayJmp0;
        Tick linkDelayJmp1;
        Tick preScheduleTick;
        Tick scheduleTick;
        Tick retryTick;
        Tick nextRetryTick;
        Tick releaseTick;
        int DelayJmpPoint0;
        int DelayJmpPoint1;
        bool noDelay;

      protected:
        /*
         * Transfer is complete
         */
        EthPacketPtr packet;
        void txDone();
        void txDone(Tick sTick); //for packets which we get from tap device
        typedef EventWrapper<Link, &Link::txDone> DoneEvent;
        friend void DoneEvent::process();
        DoneEvent doneEvent;

        friend class LinkDelayEvent;
        void txComplete(EthPacketPtr packet);

      public:
        Link(const std::string &name, EtherObject *p, int num,
             Tick delay, Tick delay_var, EtherDump *dump,
             double rateTCP, double rateUDP, double rateNoIP,
             double rateRetryTCP, double rateRetryUDP, double rateRetryNoIP, double rateProcessTCP,
             Tick DelayJmp0, Tick DelayJmp1, int SizeJmp0, int SizeJmp1, bool no_delay);
        ~Link() {}

        const std::string name() const { return objName; }

        bool busy() const { return (bool)packet; }
        bool transmit(EthPacketPtr packet);
        bool transmit(EthPacketPtr packet,Tick sTick);

        void setTxInt(EtherInt *i) { assert(!txint); txint = i; }
        void setRxInt(EtherInt *i) { assert(!rxint); rxint = i; }

        void serialize(const std::string &base, std::ostream &os);
        void unserialize(const std::string &base, Checkpoint *cp,
                                 const std::string &section);
    };

  protected:
    /*
     * Interface at each end of the link
     */
    class Interface : public EtherInt
    {
      private:
        Link *txlink;

      public:
        Interface(const std::string &name, Link *txlink, Link *rxlink);
        bool recvPacket(EthPacketPtr packet) { return txlink->transmit(packet); }
        bool recvPacket_(EthPacketPtr packet, Tick sTick)
            { return txlink->transmit(packet,sTick);}
        void sendDone() { peer->sendDone(); }
        bool isBusy() const { return txlink->busy(); }
    };

    Link *link[2];
    Interface *interface[2];

  public:
    typedef EtherLinkParams Params;
    EtherLink(const Params *p);
    virtual ~EtherLink();

    const Params *
    params() const
    {
        return dynamic_cast<const Params *>(_params);
    }

    virtual EtherInt *getEthPort(const std::string &if_name, int idx);

    virtual void serialize(std::ostream &os);
    virtual void unserialize(Checkpoint *cp, const std::string &section);

};

#endif // __ETHERLINK_HH__
