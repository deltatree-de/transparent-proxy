#!/bin/sh

fw_setup() {
  iptables-legacy -t nat -N TP_DNS
  iptables-legacy -t nat -A TP_DNS ! -d ${TP_DNS_ALLOW}/32 -p udp --dport 53 -j DNAT --to-destination ${TP_DNS_SERVER}:${TP_DNS_PORT}
  iptables-legacy -t nat -A TP_DNS ! -d ${TP_DNS_ALLOW}/32 -p tcp --dport 53 -j DNAT --to-destination ${TP_DNS_SERVER}:${TP_DNS_PORT}
  if [ -z "${TARGET_NET}" ]
  then
    iptables-legacy -t nat -A OUTPUT -p udp --dport 53 -j TP_DNS
    iptables-legacy -t nat -A OUTPUT -p tcp --dport 53 -j TP_DNS
    iptables-legacy -t nat -A PREROUTING -p udp --dport 53 -j TP_DNS
    iptables-legacy -t nat -A PREROUTING -p tcp --dport 53 -j TP_DNS
  else
    iptables-legacy -t nat -A OUTPUT -i $TARGET_NET -p udp --dport 53 -j TP_DNS
    iptables-legacy -t nat -A OUTPUT -i $TARGET_NET -p tcp --dport 53 -j TP_DNS
    iptables-legacy -t nat -A PREROUTING -i $TARGET_NET -p udp --dport 53 -j TP_DNS
    iptables-legacy -t nat -A PREROUTING -i $TARGET_NET -p tcp --dport 53 -j TP_DNS
  fi
  sysctl -w net.ipv4.ip_forward=1
  sysctl -w net.ipv4.conf.all.route_localnet=1
  iptables-legacy -t nat -A POSTROUTING -j MASQUERADE
}

fw_clear() {
  iptables-legacy-save | grep -v TP_DNS | iptables-legacy-restore
  iptables-legacy -t nat -D POSTROUTING -j MASQUERADE
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

