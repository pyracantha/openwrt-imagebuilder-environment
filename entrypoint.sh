#!/usr/bin/env bash

set -e
set -u
set -o pipefail
set -x

if [ "${1:-}" = 'imagebuilder' ]; then
    exec /openwrt-imagebuilder-wrapper.sh ${@:2}
fi

exec "$@"
