FROM ubuntu:jammy

ENV RS_PROXY_HOST proxy.internal.local
ENV RS_PROXY_PORT 8080
ENV RS_LISTEN_PORT 12345
ENV RS_WHITELIST 10.0.0.0/8,127.0.0.0/8,172.16.0.0/12,192.168.0.0/16
ENV RS_PORTS 80,443
ENV RS_CONF /tmp/redsocks.conf
ENV RS_BIN /usr/sbin/redsocks
ENV RS_TEMPLATE /etc/redsocks.tmpl
ENV RS_FIREWALL_SH /usr/local/bin/redsocks-fw.sh
ENV RS_DNS_FW_SH /usr/local/bin/dns-fw.sh
ENV RS_CONF_SH /usr/local/bin/redsocks-create-conf.sh
ENV RS_SH /usr/local/bin/redsocks.sh
ENV RS_DAEMON off
ENV TP_DNS_PORT 53

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y redsocks iptables iproute2

COPY redsocks-fw.sh ${RS_FIREWALL_SH}
COPY redsocks.sh ${RS_SH}
COPY redsocks-create-conf.sh ${RS_CONF_SH}
COPY redsocks.tmpl ${RS_TEMPLATE}
COPY dns-fw.sh ${RS_DNS_FW_SH}

RUN chmod +x ${RS_SH} ${RS_CONF_SH} ${RS_FIREWALL_SH} ${RS_DNS_FW_SH}

ENTRYPOINT ${RS_SH}
