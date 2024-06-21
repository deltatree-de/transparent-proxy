echo "Creating redsocks configuration file using proxy ${RS_PROXY_HOST}:${RS_PROXY_PORT}, listening ${RS_LISTEN_HOST}:${RS_LISTEN_PORT_HTTP} and ${RS_LISTEN_HOST}:${RS_LISTEN_PORT_HTTPS}..."
sed -e "s|\${RS_PROXY_HOST}|${RS_PROXY_HOST}|" \
    -e "s|\${RS_PROXY_PORT}|${RS_PROXY_PORT}|" \
    -e "s|\${RS_LISTEN_PORT_HTTP}|${RS_LISTEN_PORT_HTTP}|" \
    -e "s|\${RS_LISTEN_PORT_HTTPS}|${RS_LISTEN_PORT_HTTPS}|" \
    -e "s|\${RS_LISTEN_HOST}|${RS_LISTEN_HOST}|" \
    -e "s|\${RS_DAEMON}|${RS_DAEMON}|" \
    -e "s|\${RS_LOG_DEBUG}|${RS_LOG_DEBUG}|" \
    -e "s|\${RS_LOG_INFO}|${RS_LOG_INFO}|" \
    ${RS_TEMPLATE} > ${RS_CONF}
echo "Generated configuration:"
cat ${RS_CONF}
