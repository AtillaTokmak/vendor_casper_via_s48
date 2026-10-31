#!/usr/bin/env bash
#
# setup-makefiles.sh - Generate Vendor Makefiles for Casper VIA S48
#

set -euo pipefail

VENDOR_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_MK="${VENDOR_ROOT}/via_s48-vendor.mk"
BOARD_MK="${VENDOR_ROOT}/BoardConfigVendor.mk"

cat << 'EOF' > "${BOARD_MK}"
#
# Generated BoardConfigVendor.mk for Casper VIA S48
#
EOF

cat << 'EOF' > "${OUTPUT_MK}"
#
# Generated via_s48-vendor.mk for Casper VIA S48
#

PRODUCT_COPY_FILES += \
EOF

if [[ -d "${VENDOR_ROOT}/proprietary" ]]; then
    find "${VENDOR_ROOT}/proprietary" -type f | sort | while read -r f; do
        REL_PATH="${f#${VENDOR_ROOT}/proprietary/}"
        echo "    vendor/casper/via_s48/proprietary/${REL_PATH}:\$(TARGET_COPY_OUT_VENDOR)/${REL_PATH} \\" >> "${OUTPUT_MK}"
    done
fi

# Close copy files declaration
echo "    # End of blobs" >> "${OUTPUT_MK}"

echo "Makefiles generated successfully."
