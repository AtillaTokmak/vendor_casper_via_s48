#!/usr/bin/env bash
#
# Copyright (C) 2026 The LineageOS / AxionOS Project
#
# Proprietary blob extraction script for Casper VIA S48 (MT8168)
# Supports extracting from local firmware dump directory or live ADB device.
#

set -euo pipefail

VENDOR_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROPRIETARY_LIST="${VENDOR_ROOT}/proprietary-files.txt"
PROPRIETARY_DIR="${VENDOR_ROOT}/proprietary"
SRC_DUMP="${1:-}"

if [[ ! -f "${PROPRIETARY_LIST}" ]]; then
    echo "[-] Error: ${PROPRIETARY_LIST} not found!" >&2
    exit 1
fi

echo "============================================================"
echo "    Casper VIA S48 (MT8168) Proprietary Blob Extractor"
echo "============================================================"

mkdir -p "${PROPRIETARY_DIR}"

SUCCESS_COUNT=0
MISSING_COUNT=0
TOTAL_COUNT=0

extract_from_dump() {
    local src_root="$1"
    echo "[*] Extracting proprietary blobs from dump: ${src_root}"

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Trim leading/trailing whitespace
        line="$(echo "${line}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        TOTAL_COUNT=$((TOTAL_COUNT + 1))
        local target_file="${line}"
        local dest="${PROPRIETARY_DIR}/${target_file}"
        mkdir -p "$(dirname "${dest}")"

        # Search candidates in dump root
        local src=""
        if [[ -e "${src_root}/${target_file}" || -L "${src_root}/${target_file}" ]]; then
            src="${src_root}/${target_file}"
        elif [[ -e "${src_root}/vendor/${target_file}" || -L "${src_root}/vendor/${target_file}" ]]; then
            src="${src_root}/vendor/${target_file}"
        fi

        if [[ -n "${src}" && ( -e "${src}" || -L "${src}" ) ]]; then
            if [[ -L "${src}" ]]; then
                local link_target
                link_target="$(readlink "${src}")"
                # If target is absolute or points to dump dir, make it a clean relative target
                if [[ "${link_target}" =~ egl/libGLES_mali.so$ ]]; then
                    ln -sf "../egl/libGLES_mali.so" "${dest}"
                elif [[ "${link_target}" =~ libSoftGatekeeper.so$ ]]; then
                    ln -sf "libSoftGatekeeper.so" "${dest}"
                else
                    cp -a "${src}" "${dest}"
                fi
            else
                cp -f "${src}" "${dest}"
            fi
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            echo "[-] Warning: Missing blob in dump: ${target_file}"
            MISSING_COUNT=$((MISSING_COUNT + 1))
        fi
    done < "${PROPRIETARY_LIST}"
}

extract_from_adb() {
    echo "[*] No local dump provided. Attempting extraction via ADB..."
    if ! command -v adb >/dev/null 2>&1; then
        echo "[-] Error: 'adb' command not found in PATH." >&2
        exit 1
    fi

    adb wait-for-device

    while IFS= read -r line || [[ -n "$line" ]]; do
        line="$(echo "${line}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        TOTAL_COUNT=$((TOTAL_COUNT + 1))
        local target_file="${line}"
        local dest="${PROPRIETARY_DIR}/${target_file}"
        mkdir -p "$(dirname "${dest}")"

        if adb pull "/vendor/${target_file}" "${dest}" >/dev/null 2>&1; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            echo "[-] Warning: Failed to pull /vendor/${target_file}"
            MISSING_COUNT=$((MISSING_COUNT + 1))
        fi
    done < "${PROPRIETARY_LIST}"
}

if [[ -n "${SRC_DUMP}" ]]; then
    if [[ ! -d "${SRC_DUMP}" ]]; then
        echo "[-] Error: Specified directory '${SRC_DUMP}' does not exist." >&2
        exit 1
    fi
    extract_from_dump "${SRC_DUMP}"
else
    extract_from_adb
fi

echo "------------------------------------------------------------"
echo "[*] Extraction complete:"
echo "    - Successfully extracted: ${SUCCESS_COUNT} / ${TOTAL_COUNT}"
echo "    - Missing blobs:          ${MISSING_COUNT}"
echo "------------------------------------------------------------"

echo "[*] Generating Android build makefiles..."
"${VENDOR_ROOT}/setup-makefiles.sh"

echo "[+] Done. Vendor tree ready for build integration."
