#!/bin/sh

fw_setup() {
  iptables -t nat -N REDSOCKS

  for item in $(echo ${RS_WHITELIST} | sed "s/,/ /g")
  do
      iptables -t nat -A REDSOCKS -d $item -j RETURN
  done

  for item in $(echo ${RS_PORTS_HTTP} | sed "s/,/ /g")
  do
      iptables -t nat -A REDSOCKS -p tcp --dport $item -j DNAT --to-destination ${RS_LISTEN_HOST}:${RS_LISTEN_PORT_HTTP}
  done

  for item in $(echo ${RS_PORTS_HTTPS} | sed "s/,/ /g")
  do
      iptables -t nat -A REDSOCKS -p tcp --dport $item -j DNAT --to-destination ${RS_LISTEN_HOST}:${RS_LISTEN_PORT_HTTPS}
  done

  iptables -t nat -A OUTPUT -p tcp -j REDSOCKS

  iptables ! -o lo -t nat -A POSTROUTING -j MASQUERADE
}

fw_clear() {
  iptables-save | grep -v REDSOCKS | iptables-restore
}

case "$1" in
    start)
        echo -n "Setting REDSOCKS firewall rules..."
        fw_clear
        fw_setup
        echo "done."
        ;;
    stop)
        echo -n "Cleaning REDSOCKS firewall rules..."
        fw_clear
        echo "done."
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
exit 0

