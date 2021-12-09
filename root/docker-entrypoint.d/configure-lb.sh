#!/bin/sh

set -o nounset
set -o errexit
set -o pipefail

NGINX_CONF=/etc/nginx/nginx.conf

main() {
  # TODO support args
  LB_PORT=${LB_PORT:-80}
  LB_BACKENDS=${LB_BACKENDS:-example.com:80}

  complete_nginx_conf
}

complete_nginx_conf() {
  UPSTREAM_BACKENDS=""
  for i in $(echo $LB_BACKENDS | sed 's|;| |g') ; do
    UPSTREAM_BACKENDS="$UPSTREAM_BACKENDS   server $$i;\n"
  done

  sed -i "s|__LB_PORT__|${LB_PORT}|" "${NGINX_CONF}"
  sed -i "s|__UPSTREAM_BACKENDS__|${UPSTREAM_BACKENDS}|" "${NGINX_CONF}"

  cat "${NGINX_CONF}"
}

main

