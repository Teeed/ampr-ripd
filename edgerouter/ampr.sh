#!/bin/sh

MY_IP=`ip addr list dev tun44 | grep -w "inet" | awk '{print $2}'`

# wait for tunnel interface
while [ "$MY_IP" == "" ]; do
    sleep 1
    MY_IP=`ip addr list dev tun44 | grep -w "inet" | awk '{print $2}'`
done

# AMPR routes go to table 44
#
ip rule add from $MY_IP table 44
ip rule add to 44.0.0.0/9 table 44
ip rule add to 44.128.0.0/10 table 44
# temporary for ampr.de
ip rule add to 44.224.0.0/15 table 44

# default AMPR reply route is in table 45
#
ip route add default via 169.228.34.84 dev tun44 table 45 onlink

# mark incoming and route replies via table 45
#
iptables -t mangle -A PREROUTING -i tun44 -s 44.0.0.0/9 -j RETURN
iptables -t mangle -A PREROUTING -i tun44 -s 44.128.0.0/10 -j RETURN
# temporary for ampr.de
iptables -t mangle -A PREROUTING -i tun44 -s 44.224.0.0/15 -j RETURN

ip rule add fwmark 45 table 45
iptables -t mangle -A PREROUTING -i tun44 -j CONNMARK --set-mark 45
iptables -t mangle -A PREROUTING ! -i tun44 -m connmark --mark 45 -j CONNMARK --restore-mark
iptables -t mangle -A OUTPUT -m connmark --mark 45 -j CONNMARK --restore-mark

# start ampr-ripd (add your -a parameter if needed)
ampr-ripd -s -t 44 -i tun44 -m 90
