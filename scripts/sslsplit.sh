#!/bin/sh
# 2015 - Original: Whistle Master
# 2019 - Modified by: Andreas Nilsen <adde88@gmail.com>

MYTIME=`date +%s`

killall sslsplit

if [ "$1" = "start" ]; then

	echo '1' > /proc/sys/net/ipv4/ip_forward
	iptables-save > /pineapple/modules/SSLsplitNG/rules/saved
	iptables -X
	iptables -F
	iptables -t nat -F
	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT ACCEPT

	sh /pineapple/modules/SSLsplitNG/rules/iptables

	iptables -t nat -A POSTROUTING -j MASQUERADE

	sslsplit -D -l /pineapple/modules/SSLsplitNG/connections.log -L /pineapple/modules/SSLsplitNG/log/output_${MYTIME}.log -k /pineapple/modules/SSLsplitNG/cert/certificate.key -c /pineapple/modules/SSLsplitNG/cert/certificate.crt ssl 0.0.0.0 8443 tcp 0.0.0.0 8080

elif [ "$1" = "stop" ]; then

	rm -rf /pineapple/modules/SSLsplitNG/connections.log

	iptables -F
	iptables -X
	iptables -t nat -F
	iptables -t nat -X
	iptables -t mangle -F
	iptables -t mangle -X
	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT ACCEPT
	
	iptables-restore < /pineapple/modules/SSLsplitNG/rules/saved
fi
