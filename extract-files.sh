#!/usr/bin/env bash
#
# extract-files.sh - Extract Proprietary Blobs for Casper VIA S48
# Usage: ./extract-files.sh [path_to_dump]
#

set -euo pipefail

SRC="${1:-}"
VENDOR_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROPRIETARY_LIST="${VENDOR_ROOT}/proprietary-files.txt"

if [[ ! -f "${PROPRIETARY_LIST}" ]]; then
    echo "ERROR: proprietary-files.txt not found." >&2
    exit 1
fi

echo "=========================================================="
echo " Extracting Proprietary Blobs: Casper VIA S48"
echo " Destination: ${VENDOR_ROOT}/proprietary"
echo "=========================================================="

mkdir -p "${VENDOR_ROOT}/proprietary"

while IFS= read -r line || [[ -n "${line}" ]]; do
    # Skip comments and empty lines
    [[ "${line}" =~ ^#.*$ ]] && continue
    [[ -z "${line}" ]] && continue
    
    FILE_PATH="${line}"
    TARGET_FILE="${VENDOR_ROOT}/proprietary/${FILE_PATH#vendor/}"
    mkdir -p "$(dirname "${TARGET_FILE}")"
    
    if [[ -n "${SRC}" ]] && [[ -d "${SRC}" ]]; then
        # Extract from local directory dump
        SRC_FILE="${SRC}/${FILE_PATH}"
        if [[ -f "${SRC_FILE}" ]]; then
            cp "${SRC_FILE}" "${TARGET_FILE}"
            echo "[FILE] ${FILE_PATH}"
        else
            echo "[-] Missing in dump: ${FILE_PATH}"
        fi
    else
        # Extract from connected ADB device
        if adb pull "/${FILE_PATH}" "${TARGET_FILE}" >/dev/null 2>&1; then
            echo "[ADB] ${FILE_PATH}"
        else
            echo "[-] Failed pulling: /${FILE_PATH}"
        fi
    fi
done < "${PROPRIETARY_LIST}"

echo "Extraction completed."
"${VENDOR_ROOT}/setup-makefiles.sh"
