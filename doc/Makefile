TOP_SRCDIR:=..
include $(TOP_SRCDIR)/common.mk

EXAMPLES = \
	tcp-port-80.md \
	icmp-or-tcp-or-udp.md \
	portrange-0-6000.md \
	host-127.0.0.1.md \
	net-127.0.0.0-8.md \
	host-ipv6-localhost.md \
	net-ipv6-0-mask-16.md \
	net-ipv6-ee.cc.9954.0-mask-111.md \
	src-net-ffff.ffff.eeee.eeee.1.0.0.0-82.md \
	src-net-ffff.ffff.eeee.eeee.0.0.0.0-72.md \
	src-port-80.md \
	dst-portrange-80-90.md \
	ether-multicast.md \
	ether-broadcast.md \
	ether-proto-decnet.md \
	ether-proto-1500.md \
	ether-proto-1501.md \
	ether-proto-255.md \
	dst-portrange-80-90.md \
	src-host-192.68.1.1-and-less-100.md \
	dst-host-192.68.1.1-and-greater-100.md \
	ip-multicast.md \
	ip-proto-ah.md \
	ip-proto-47.md \
	ip6-multicast.md \
	ip6-proto-ah.md \
	ip6-proto-47.md \
	iso-proto-clnp.md \
	iso-proto-47.md \
	ip-proto-sctp.md \
	proto-47.md \
	decnet-src-10.15.md \
	decnet-host-10.15.md \
	l1.md \
	icmp6.md \
	sctp.md \
	packet-access-igmp.md \
	packet-access-pim.md \
	packet-access-igrp.md \
	packet-access-vrrp.md \
	packet-access-sctp.md \
	icmp6-or-ip.md \
	tcp-address.md \
	fail-fail.md

PFLUA = \
	../src/pf.lua \
	../src/pf/bpf.lua \
	../src/pf/parse.lua \
	../src/pf/expand.lua \
	../src/pf/optimize.lua \
	../src/pf/anf.lua \
	../src/pf/ssa.lua \
	../src/pf/backend.lua

all: $(EXAMPLES)

maintainer-clean:
	rm -f $(EXAMPLES)

tcp-port-80.md: $(PFLUA)
	../tools/dump-markdown "tcp port 80" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

icmp-or-tcp-or-udp.md: $(PFLUA)
	../tools/dump-markdown "icmp or tcp or udp" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

portrange-0-6000.md: $(PFLUA)
	../tools/dump-markdown "portrange 0-6000" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

host-127.0.0.1.md: $(PFLUA)
	../tools/dump-markdown "host 127.0.0.1" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

net-127.0.0.0-8.md: $(PFLUA)
	../tools/dump-markdown "net 127.0.0.0/8" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

host-ipv6-localhost.md: $(PFLUA)
	../tools/dump-markdown "host ::1" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

net-ipv6-0-mask-16.md: $(PFLUA)
	../tools/dump-markdown "net ::0/16" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

net-ipv6-ee.cc.9954.0-mask-111.md: $(PFLUA)
	../tools/dump-markdown "net ee:cc::9954:0/111" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

src-net-ffff.ffff.eeee.eeee.1.0.0.0-82.md: $(PFLUA)
	../tools/dump-markdown "src net ffff:ffff:eeee:eeee:1:0:0:0/82" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

src-net-ffff.ffff.eeee.eeee.0.0.0.0-72.md: $(PFLUA)
	../tools/dump-markdown "src net ffff:ffff:eeee:eeee:0:0:0:0/72" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

src-port-80.md: $(PFLUA)
	../tools/dump-markdown "src port 80" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

dst-portrange-80-90.md: $(PFLUA)
	../tools/dump-markdown "dst portrange 80-90" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

ether-multicast.md: $(PFLUA)
	../tools/dump-markdown "ether multicast" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

ether-broadcast.md: $(PFLUA)
	../tools/dump-markdown "ether broadcast" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

ether-proto-decnet.md: $(PFLUA)
	../tools/dump-markdown "ether proto \decnet" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

# The frame should be treated as an Ethernet frame.
ether-proto-1501.md: $(PFLUA)
	../tools/dump-markdown "ether proto 1501" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

# The frame should be treated as an 802.3 frame.
ether-proto-1500.md: $(PFLUA)
	../tools/dump-markdown "ether proto 1500" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

# The frame should be treated as an 802.3 frame and check SAP (Service Access
# Point) at byte 14.
ether-proto-255.md: $(PFLUA)
	../tools/dump-markdown "ether proto 255" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

src-host-192.68.1.1-and-less-100.md: $(PFLUA)
	../tools/dump-markdown "src host 192.68.1.1 and less 100" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

dst-host-192.68.1.1-and-greater-100.md: $(PFLUA)
	../tools/dump-markdown "dst host 192.68.1.1 and greater 100" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

ip-multicast.md: $(PFLUA)
	../tools/dump-markdown "ip multicast" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

ip-proto-ah.md: $(PFLUA)
	../tools/dump-markdown "ip proto \ah" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

ip-proto-47.md: $(PFLUA)
	../tools/dump-markdown "ip proto 47" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

ip6-multicast.md: $(PFLUA)
	../tools/dump-markdown "ip6 multicast" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

ip6-proto-ah.md: $(PFLUA)
	../tools/dump-markdown "ip6 proto \ah" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

ip6-proto-47.md: $(PFLUA)
	../tools/dump-markdown "ip6 proto 47" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

iso-proto-clnp.md: $(PFLUA)
	../tools/dump-markdown "iso proto \clnp" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

iso-proto-47.md: $(PFLUA)
	../tools/dump-markdown "iso proto 47" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

ip-proto-sctp.md: $(PFLUA)
	../tools/dump-markdown "ip proto \sctp" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

proto-47.md: $(PFLUA)
	../tools/dump-markdown "proto 47" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

decnet-src-10.15.md: $(PFLUA)
	../tools/dump-markdown "decnet src 10.15" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

decnet-host-10.15.md: $(PFLUA)
	../tools/dump-markdown "decnet host 10.15" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

l1.md: $(PFLUA)
	../tools/dump-markdown "l1" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

icmp6.md: $(PFLUA)
	../tools/dump-markdown "icmp6" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

sctp.md: $(PFLUA)
	../tools/dump-markdown "sctp" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

packet-access-igmp.md: $(PFLUA)
	../tools/dump-markdown "igmp[8] < 8" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

packet-access-pim.md: $(PFLUA)
	../tools/dump-markdown "pim[8] < 8" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

packet-access-igrp.md : $(PFLUA)
	../tools/dump-markdown "igrp[8] < 8" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

packet-access-vrrp.md: $(PFLUA)
	../tools/dump-markdown "vrrp[8] < 8" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

packet-access-sctp.md: $(PFLUA)
	../tools/dump-markdown "sctp[8] < 8" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

icmp6-or-ip.md: $(PFLUA)
	../tools/dump-markdown "icmp6 or ip" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

tcp-address.md: $(PFLUA)
	../tools/dump-markdown "ether[&tcp[0]] = tcp[0]" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}

fail-fail.md: $(PFLUA)
	../tools/dump-markdown "tcp and tcp[100] == 1" > $@.tmp1 2> $@.tmp2 && cat $@.{tmp1,tmp2} > $@ && rm $@.{tmp1,tmp2}
