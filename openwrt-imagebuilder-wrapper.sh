#!/usr/bin/env bash

set -e
set -u
set -o pipefail

RELEASE="${1:-}"
TARGET="${2:-}"
SUBTARGET="${3:-}"
MAKE_ARGUMENTS="${@:4}"

WORK_DIRECTORY="/tmp"
IMAGEBUILDER_DIRECTORY="/openwrt/imagebuilder"

if [ -z "${RELEASE}" ] || [ -z "${TARGET}" ] || [ -z "${SUBTARGET}" ]; then
    echo "Provides an Openwrt Imagebuilder environment for the given release/target/subtarget"
    echo ""
    echo "Usage: imagebuilder <release> <target> <subtarget> [imagebuilder arguments]"
    echo ""
    echo "Example: imagebuilder snapshot x86 64 info"
    echo "Example: imagebuilder 19.07.5 x86 64 info"
    echo ""
    echo "Generated images are located under '${IMAGEBUILDER_DIRECTORY}/bin'"
    exit 1
fi

IMAGEBUILDER_CHECKSUM="sha256sums"
if [ "${RELEASE}" == "snapshot" ]; then
    IMAGEBUILDER_BASE_URL="https://downloads.openwrt.org/snapshots/targets/${TARGET}/${SUBTARGET}"
    IMAGEBUILDER_ARCHIVE="openwrt-imagebuilder-${TARGET}-${SUBTARGET}.Linux-x86_64.tar.xz"
else
    IMAGEBUILDER_BASE_URL="https://downloads.openwrt.org/releases/${RELEASE}/targets/${TARGET}/${SUBTARGET}"
    IMAGEBUILDER_ARCHIVE="openwrt-imagebuilder-${RELEASE}-${TARGET}-${SUBTARGET}.Linux-x86_64.tar.xz"
fi
IMAGEBUILDER_ARCHIVE_URL="${IMAGEBUILDER_BASE_URL}/${IMAGEBUILDER_ARCHIVE}"
IMAGEBUILDER_CHECKSUM_URL="${IMAGEBUILDER_BASE_URL}/${IMAGEBUILDER_CHECKSUM}"

echo "Download sha256sums"
echo "${IMAGEBUILDER_CHECKSUM_URL}"
curl -o "${WORK_DIRECTORY}/${IMAGEBUILDER_CHECKSUM}" "${IMAGEBUILDER_CHECKSUM_URL}"

echo "Download imagebuilder archive"
echo "${IMAGEBUILDER_ARCHIVE_URL}"
curl -o "${WORK_DIRECTORY}/${IMAGEBUILDER_ARCHIVE}" "${IMAGEBUILDER_ARCHIVE_URL}"

echo "Check imagebuilder archive integrity"
(cd "${WORK_DIRECTORY}"; cat "${IMAGEBUILDER_CHECKSUM}" | grep "${IMAGEBUILDER_ARCHIVE}" | sha256sum -c)

echo "Extract imagebuilder archive"
mkdir -p "${IMAGEBUILDER_DIRECTORY}"
tar -C "${IMAGEBUILDER_DIRECTORY}" -xf "${WORK_DIRECTORY}/${IMAGEBUILDER_ARCHIVE}" --strip 1

cd "${IMAGEBUILDER_DIRECTORY}"
make ${MAKE_ARGUMENTS}
