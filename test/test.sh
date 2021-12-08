#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

LB_PORT=9090
LB_BACKEND=example.com:80
DOCKER_CONTAINER_NAME=nginx-lb-test
DOCKER_IMAGE_NAME=nginx-lb:test
root_path=$(realpath $(dirname $0))

cleanup() {
  original_exitcode=$?
  log "Cleaning up test infrastructure..."
  docker stop "${DOCKER_CONTAINER_NAME}" 2>/dev/null || true
  docker rm "${DOCKER_CONTAINER_NAME}" 2>/dev/null || true
  if [ ${original_exitcode} == 0 ] ; then
    log "All tests passed!"
  else
    log "Tests failed!"
  fi
  exit ${original_exitcode}
}

log() {
  echo "[info] $@"
}

main() {
  # Check prerequisites
  log "Checking prerequisites..."
  which curl >/dev/null || (echo "error: missing required command 'curl'" && exit 1)
  which docker >/dev/null || (echo "error: missing required command 'docker'" && exit 1)

  # Build the image to test
  log "Building the load-balancer image..."
  docker build --tag=${DOCKER_IMAGE_NAME} ${root_path}/..

  # Run the load-balancer
  log "Setting up test infrastructure..."
  trap cleanup EXIT
  docker run --rm --name "${DOCKER_CONTAINER_NAME}" \
    -d \
    -p ${LB_PORT}:${LB_PORT} \
    -e LB_PORT=${LB_PORT} \
    -e LB_BACKENDS=${LB_BACKEND} \
    "${DOCKER_IMAGE_NAME}"

  # Hacky way to ensure that the load-balancer is functional
  log "Waiting for test infrastructure to be ready..."
  sleep 5

  # Run a test request
  log "Executing test request..."
  curl --fail -v -H "Host: ${LB_BACKEND}" http://localhost:${LB_PORT}
}

main
