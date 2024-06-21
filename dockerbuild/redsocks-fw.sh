#!/bin/sh

fw_setup() {
  iptables-legacy -t nat -N REDSOCKS

  for item in $(echo ${RS_WHITELIST} | sed "s/,/ /g")
  do
      iptables-legacy -t nat -A REDSOCKS -d $item -j RETURN
  done

  iptables-legacy -t nat -A REDSOCKS -p tcp --dport ${RS_LISTEN_PORT_HTTP} -s ${RS_LISTEN_HOST} -j RETURN
  iptables-legacy -t nat -A REDSOCKS -p tcp --dport ${RS_LISTEN_PORT_HTTPS} -s ${RS_LISTEN_HOST} -j RETURN

  for item in $(echo ${RS_PORTS_HTTP} | sed "s/,/ /g")
  do
      iptables-legacy -t nat -A REDSOCKS -p tcp --dport $item -j DNAT --to-destination ${RS_LISTEN_HOST}:${RS_LISTEN_PORT_HTTP}

      if [ -z "${RS_TARGET_NET}" ]
      then
        iptables-legacy -t nat -A PREROUTING -p tcp --dport $item -j REDSOCKS
        iptables-legacy -t nat -A OUTPUT -p tcp --dport $item -j REDSOCKS
      else
        iptables-legacy -t nat -A PREROUTING -i ${RS_TARGET_NET} -p tcp --dport $item -j REDSOCKS
        iptables-legacy -t nat -A OUTPUT -i ${RS_TARGET_NET} -p tcp --dport $item -j REDSOCKS
      fi
  done

  for item in $(echo ${RS_PORTS_HTTPS} | sed "s/,/ /g")
  do
      iptables-legacy -t nat -A REDSOCKS -p tcp --dport $item -j DNAT --to-destination ${RS_LISTEN_HOST}:${RS_LISTEN_PORT_HTTPS}

      if [ -z "${RS_TARGET_NET}" ]
      then
        iptables-legacy -t nat -A PREROUTING -p tcp --dport $item -j REDSOCKS
        iptables-legacy -t nat -A OUTPUT -p tcp --dport $item -j REDSOCKS
      else
        iptables-legacy -t nat -A PREROUTING -i ${RS_TARGET_NET} -p tcp --dport $item -j REDSOCKS
        iptables-legacy -t nat -A OUTPUT -i ${RS_TARGET_NET} -p tcp --dport $item -j REDSOCKS
      fi
  done
}

fw_clear() {
  iptables-legacy-save | grep -v REDSOCKS | iptables-legacy-restore
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

