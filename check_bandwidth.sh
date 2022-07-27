#!/bin/bash
# script created by nsc
# usage ./bw_watch bw_warning bw_critical pkt_warning pkt_critical
# bw usage is in kbits/s
 
if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]]
then
	echo "VARIABLES ARE NOT SET!!!"
	echo "usage $0 bw_warning bw_critical pkt_warning pkt_critical"
	echo "bw usage is in kbits/s"
	exit 2
fi
 
bw_warn=$1
bw_crit=$2
packets_warn=$3
packets_crit=$4
 
bw_output=$(vnstat -tr 5 -s )
rx_value=$(echo $bw_output | grep -o "rx [[:digit:]]*\.*[[:digit:]]* .bit/s" | cut -f2 -d' ' )
rx_unit=$(echo $bw_output | grep -o "rx [[:digit:]]*\.*[[:digit:]]* .bit/s" | cut -f3 -d' ' )
rx_packets=$(echo $bw_output | grep -o "rx [[:digit:]]*\.*[[:digit:]]* .bit/s [[:digit:]]* packets/s" | cut -f4 -d' ' )
tx_value=$(echo $bw_output | grep -o "tx [[:digit:]]*\.*[[:digit:]]* .bit/s" | cut -f2 -d' ' )
tx_unit=$(echo $bw_output | grep -o "tx [[:digit:]]*\.*[[:digit:]]* .bit/s" | cut -f3 -d' ' )
tx_packets=$(echo $bw_output | grep -o "tx [[:digit:]]*\.*[[:digit:]]* .bit/s [[:digit:]]* packets/s" | cut -f4 -d' ' )
 
#convert rx to kbits/s
if [ $rx_unit == "Mbit/s" ]
then rx_value=`echo "$rx_value * 1024" | bc`
fi
 
#convert tx to kbits/s
if [ $tx_unit == "Mbit/s" ]
then tx_value=`echo "$tx_value * 1024" | bc`
fi
 
#convert to integer
rx_value=${rx_value/.*}
tx_value=${tx_value/.*}
 
 
if [ $bw_crit -lt $rx_value ] || [ $bw_crit -lt $tx_value ] || [ $packets_crit -lt $rx_packets ] || [ $packets_crit -lt $tx_packets ]
then
	echo "CRITICAL: RX/TX: $rx_value/$tx_value kbits/s. PKT: RX/TX: $rx_packets/$tx_packets"
	exit 2
elif [ $bw_warn -lt $rx_value ] || [ $bw_warn -lt $tx_value ] || [ $packets_warn -lt $rx_packets ] || [ $packets_warn -lt $tx_packets ]
then
	echo "WARNING: RX/TX: $rx_value/$tx_value kbits/s. PKT: RX/TX: $rx_packets/$tx_packets"
	exit 1
else
	echo "OK: RX/TX: $rx_value/$tx_value kbits/s. PKT: RX/TX: $rx_packets/$tx_packets"
	exit 0
fi
