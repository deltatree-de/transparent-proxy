#!/bin/bash

export RS_LISTEN_HOST=$(ip route get 8.8.8.8 |     awk '{gsub(".*src",""); print $1; exit}')
${RS_CONF_SH}

echo "Activating iptables rules..."
${RS_FIREWALL_SH} start

${RS_DNS_FW_SH} start

pid=0

# SIGUSR1 handler
usr_handler() {
  echo "usr_handler"
}

# SIGTERM-handler
term_handler() {
    if [ $pid -ne 0 ]; then
        echo "Term signal catched. Shutdown redsocks and disable iptables rules..."
        kill -SIGTERM "$pid"
        wait "$pid"
        ${RS_FIREWALL_SH} stop
	${RS_DNS_FW_SH} stop
    fi
    exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
trap 'kill ${!}; usr_handler' SIGUSR1
trap 'kill ${!}; term_handler' SIGTERM

echo "Starting redsocks..."
${RS_BIN} -c ${RS_CONF} &
pid="$!"

# wait indefinetely
while true
do
    tail -f /dev/null & wait ${!}
done
