#!/usr/bin/env bash

set -e
set -u
set -o pipefail

RELEASE="${1:-}"
TARGET="${2:-}"
SUBTARGET="${3:-}"
COMMAND="${4:-}"
PROFILE="${5:-}"
PACKAGES="${6:-}"

WORK_DIRECTORY="/tmp"
IMAGEBUILDER_DIRECTORY="/openwrt/imagebuilder"

function usage() {
    echo "Provides an Openwrt Imagebuilder environment for the given release/target/subtarget"
    echo ""
    echo "Usage: imagebuilder <release> <target> <subtarget> <build|profiles|raw>"
    echo ""
    echo "Example: imagebuilder snapshot x86 64 build generic"
    echo "Example: imagebuilder 19.07.5 x86 64 profiles"
    echo ""
    echo "Generated images are located under '${IMAGEBUILDER_DIRECTORY}/bin'"
    exit 1
}

function prepare_environment() {
    local IMAGEBUILDER_CHECKSUM="sha256sums"
    if [ "${RELEASE}" == "snapshot" ]; then
        local IMAGEBUILDER_BASE_URL="https://downloads.openwrt.org/snapshots/targets/${TARGET}/${SUBTARGET}"
        local IMAGEBUILDER_ARCHIVE="openwrt-imagebuilder-${TARGET}-${SUBTARGET}.Linux-x86_64.tar.xz"
    else
        local IMAGEBUILDER_BASE_URL="https://downloads.openwrt.org/releases/${RELEASE}/targets/${TARGET}/${SUBTARGET}"
        local IMAGEBUILDER_ARCHIVE="openwrt-imagebuilder-${RELEASE}-${TARGET}-${SUBTARGET}.Linux-x86_64.tar.xz"
    fi
    local IMAGEBUILDER_ARCHIVE_URL="${IMAGEBUILDER_BASE_URL}/${IMAGEBUILDER_ARCHIVE}"
    local IMAGEBUILDER_CHECKSUM_URL="${IMAGEBUILDER_BASE_URL}/${IMAGEBUILDER_CHECKSUM}"

    echo "Download sha256sums"
    echo "${IMAGEBUILDER_CHECKSUM_URL}"
    curl -o "${WORK_DIRECTORY}/${IMAGEBUILDER_CHECKSUM}" "${IMAGEBUILDER_CHECKSUM_URL}"

    echo "Download imagebuilder archive"
    if [ -f "${WORK_DIRECTORY}/${IMAGEBUILDER_ARCHIVE}" ]; then
        echo "Skipped: Archive exists in filesystem"
    else 
        echo "${IMAGEBUILDER_ARCHIVE_URL}"
        curl -o "${WORK_DIRECTORY}/${IMAGEBUILDER_ARCHIVE}" "${IMAGEBUILDER_ARCHIVE_URL}"
    fi

    echo "Check imagebuilder archive integrity"
    (cd "${WORK_DIRECTORY}"; cat "${IMAGEBUILDER_CHECKSUM}" | grep "${IMAGEBUILDER_ARCHIVE}" | sha256sum -c)

    echo "Extract imagebuilder archive"
    mkdir -p "${IMAGEBUILDER_DIRECTORY}"
    tar -C "${IMAGEBUILDER_DIRECTORY}" -xf "${WORK_DIRECTORY}/${IMAGEBUILDER_ARCHIVE}" --strip 1

    cd "${IMAGEBUILDER_DIRECTORY}"
}

if [ -z "${RELEASE}" ] || [ -z "${TARGET}" ] || [ -z "${SUBTARGET}" ] || [ -z "${COMMAND}" ]; then
    usage
fi

case "${COMMAND}" in
  build)
    if [ -z "${PROFILE}"  ]; then
        echo "Build command parameters: <profile> [<packages>]"
        echo ""
        echo "Hint: Use profile command to get list of profiles"
        exit 1
    fi
    PACKAGES_WITH_SPACE="$(echo "${PACKAGES}" | tr ',' ' ')"
    prepare_environment
    make image PROFILE="${PROFILE}" PACKAGES="${PACKAGES_WITH_SPACE}"
    ;;
  profiles)
    prepare_environment
    make info
    ;;
  raw)
    prepare_environment
    make
    ;;
  *)
    usage
    ;;
esac
