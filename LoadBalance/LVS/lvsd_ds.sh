#!/bin/bash
#
#LVS Script for DirectServer
#author: jerryxing98@gmail.com
#
. /etc/rc.d/init.d/functions

#
VIP=10.14.1.140
DIP=10.14.1.130
RIP1=10.14.1.131
RIP2=10.14.1.132
PORT=80
RSWEIGHT1=2
RSWEIGHT2=5

case "$1" in
start)
	
	#Since this the Director we must be able to forward packets
	echo 1 > /proc/sys/net/ipv4/ip_forword
	#Clear all iptables rules
	/sbin/iptables -F
	#Reset iptables counters
	/sbin/iptables -Z
	#Clear all ipvsadm rules/services
	/sbin/ipvsadm -C
	#Add an IP virtual service for VIP 10.14.1.140 port 80
	#We set the Schedul,Method
	
	/sbin/ipvsadm -A -t $VIP:$PORT -s wls	
	
	#Now directory packets for this VIP ROUTE TO SIP 
		
	/sbin/ipvsadm -a -t $VIP:$PORT -r $RIP1 -g -w $RSWEIGHT1
	/sbin/ipvsadm -a -t $VIP:$PORT -r $RIP2 -g -w $RSWEIGHT2	

;;
stop)	
	#Stop ip forword packets
	echo 0 > /proc/sys/net/ipv4/ip_forward
	
	#Clear all iptables rules
	/sbin/iptables -X	

	#Reset iptables counters
	/sbin/iptables -Z


	#Clean ipvsadm
	/sbin/ipvsadm -C

	#Bring down the VIP interfacce
	/sbin/ifconfig eth0:0 down
	/sbin/route del $VIP
	
	/bin/rm -f /var/lock/subsys/ipvsadm

	echo "ipvs is stopped..."

;;
status)
	if [ ! -e /var/lock/subsys/ipvsadm ];then
		echo "ipvs is stopped ... "
	else
		echo "ipvs is running... "
		/sbin/ipvsadm -L -n
	fi
;;
*)
	echo "Usage:$0 {start|stop|status}"
;;
esac
