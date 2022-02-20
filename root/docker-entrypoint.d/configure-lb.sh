#!/bin/sh

set -o nounset
set -o errexit
# set -o pipefail

# NGINX_CONF=/etc/nginx/nginx.conf

main() {
  LB_PORT=${LB_PORT:-80}
  lb_backends=$(echo  ${LB_BACKENDS} | tr "," "\n") #split comma delimited string

  # Complete the nginx.conf template
  UPSTREAM_BACKENDS=""
  for i in $(echo $lb_backends | sed 's|;| |g') ; do
    UPSTREAM_BACKENDS="$UPSTREAM_BACKENDS   server $i;\n"
  done

  # echo $UPSTREAM_BACKENDS
  sed -i "s|__LB_PORT__|${LB_PORT}|" "${NGINX_CONF}"
  sed -i "s|__UPSTREAM_BACKENDS__|${UPSTREAM_BACKENDS}|" "${NGINX_CONF}"

  # Print the used nginx.conf for debugging
  cat "${NGINX_CONF}"
}

main

