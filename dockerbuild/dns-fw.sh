#!/bin/sh

fw_setup() {
  iptables -t nat -N TP_DNS
  iptables -t nat -A TP_DNS ! -d ${TP_DNS_ALLOW}/32 -p udp --dport 53 -j DNAT --to-destination ${TP_DNS_SERVER}:${TP_DNS_PORT}
  iptables -t nat -A TP_DNS ! -d ${TP_DNS_ALLOW}/32 -p tcp --dport 53 -j DNAT --to-destination ${TP_DNS_SERVER}:${TP_DNS_PORT}
  if [ -z "${TARGET_NET}" ]
  then
    iptables -t nat -A OUTPUT -p udp --dport 53 -j TP_DNS
    iptables -t nat -A OUTPUT -p tcp --dport 53 -j TP_DNS
    iptables -t nat -A PREROUTING -p udp --dport 53 -j TP_DNS
    iptables -t nat -A PREROUTING -p tcp --dport 53 -j TP_DNS
  else
    iptables -t nat -A OUTPUT -i $TARGET_NET -p udp --dport 53 -j TP_DNS
    iptables -t nat -A OUTPUT -i $TARGET_NET -p tcp --dport 53 -j TP_DNS
    iptables -t nat -A PREROUTING -i $TARGET_NET -p udp --dport 53 -j TP_DNS
    iptables -t nat -A PREROUTING -i $TARGET_NET -p tcp --dport 53 -j TP_DNS
  fi
  sysctl -w net.ipv4.ip_forward=1
  sysctl -w net.ipv4.conf.all.route_localnet=1
  iptables -t nat -A POSTROUTING -j MASQUERADE
}

fw_clear() {
  iptables-save | grep -v TP_DNS | iptables-restore
  iptables -t nat -D POSTROUTING -j MASQUERADE
}

case "$1" in
    start)
        if [ -n "${TP_DNS_ALLOW}" ]
        then
          echo -n "Setting DNS firewall rules..."
          fw_clear
          fw_setup
          echo "done."
	fi
        ;;
    stop)
        if [ -n "${TP_DNS_ALLOW}" ]
        then
          echo -n "Cleaning DNS firewall rules..."
          fw_clear
          echo "done."
	fi
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
exit 0

