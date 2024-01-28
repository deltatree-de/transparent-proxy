#!/bin/sh

fw_setup() {
  iptables -t nat -N REDSOCKS

  for item in $(echo ${RS_WHITELIST} | sed "s/,/ /g")
  do
      iptables -t nat -A REDSOCKS -d $item -j RETURN
  done

  for item in $(echo ${RS_PORTS} | sed "s/,/ /g")
  do
      iptables -t nat -A REDSOCKS -p tcp --dport $item -j DNAT --to-destination ${RS_LISTEN_HOST}:${RS_LISTEN_PORT}

      if [ -z "${RS_TARGET_NET}" ]
      then
        iptables -t nat -A PREROUTING -p tcp --dport $item -j REDSOCKS
        iptables -t nat -A OUTPUT -p tcp --dport $item -j REDSOCKS
      else
        iptables -t nat -A PREROUTING -i ${RS_TARGET_NET} -p tcp --dport $item -j REDSOCKS
        iptables -t nat -A OUTPUT -i ${RS_TARGET_NET} -p tcp --dport $item -j REDSOCKS
      fi
  done
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

