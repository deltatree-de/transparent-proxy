#!/bin/bash

export RS_LISTEN_HOST=$(ip route get 8.8.8.8 |     awk '{gsub(".*src",""); print $1; exit}')
set -o allexport
source transparent-proxy.conf
set +o allexport

start() {
    chmod +x ${RS_FIREWALL_SH} ${RS_DNS_FW_SH}
    ${RS_FIREWALL_SH} start
    ${RS_DNS_FW_SH} start

}

stop() {
    chmod +x ${RS_FIREWALL_SH} ${RS_DNS_FW_SH}
    ${RS_FIREWALL_SH} stop
    ${RS_DNS_FW_SH} stop
}

conf() {
    chmod +x ${RS_CONF_SH}
    ${RS_CONF_SH}
}

case "$1" in
    start)
        echo -n "Starting transparent proxy..."
        start
        echo "done."
        ;;
    stop)
        echo -n "Stopping transparent proxy..."
        stop
        echo "done."
        ;;
    conf)
        echo -n "Replacing redsocks.conf..."
	conf
        echo "done."
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
exit 0
