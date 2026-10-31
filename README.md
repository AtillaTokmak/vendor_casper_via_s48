# Casper VIA S48 (MT8168) Proprietary Vendor Repository

This repository provides the extraction framework and build integration makefiles for the proprietary MediaTek MT8168 board support package (BSP) binaries, firmware, and hardware abstraction layer (HAL) libraries required to build Android 16 (AxionOS 2.9 / LineageOS) for the Casper VIA S48 tablet.

---

## 1. Subsystem Blob Coverage

A total of **570 proprietary files** have been extracted and verified against the stock Casper C1.03 firmware:

* **Graphics & Display:** Mali-G52 MP1 DDK user-space drivers (`libGLES_mali.so`), Gralloc 2.0 (`gralloc.mt8168.so`), Hardware Composer 2.1 (`hwcomposer.mt8168.so`, `android.hardware.graphics.composer@2.1-service`), and MediaTek GED/GPU libraries.
* **Audio:** MediaTek Audio HAL 5.0 (`audio.primary.mt8168.so`, `android.hardware.audio@5.0-service-mediatek`), TinyALSA interface, custom audio tuning parameter tables, and XML routing profiles.
* **Media & Codecs:** OpenMAX hardware video decoders and encoders (`libMtkOmxCore.so`, `libMtkOmxVdecEx.so`, `libMtkOmxVencOpvp.so`, `libvcodecdrv.so`).
* **Connectivity (Wi-Fi / BT / GPS):** MT6631 wireless stack (`wlan_drv_gen4m.ko`, `bt_drv.ko`, `wmt_drv.ko`), firmware microcode images (`soc1_0_ram_bt_1a_1_hdr.bin`, `soc1_0_ram_wifi_1a_1_hdr.bin`, `WIFI_RAM_CODE_soc1_0_1a_1.bin`), GNSS HAL (`android.hardware.gnss@2.0-service-mediatek`, `mnld`).
* **Sensors:** Silead touch interface integration and MediaTek sensor service (`sensors.mt8168.so`, `android.hardware.sensors@2.0-service-mediatek`).
* **Power, Health & Thermal:** MediaTek MT6357 PMIC gauge daemon (`fuelgauged`), thermal manager (`android.hardware.thermal@1.0-service`), battery health HAL (`android.hardware.health@2.0-service`), and performance profiles (`mtkpower`).
* **Security & TEE:** TrustKernel MTEE Keymaster 4.0 daemon (`android.hardware.keymaster@4.0-service.mtee`), Gatekeeper (`android.hardware.gatekeeper@1.0-service`), and DRM Widevine plugins.
* **USB:** MediaTek USB ConfigFS HAL (`android.hardware.usb@1.1-service-mediatek`).

---

## 2. Extraction Instructions

### Option A: Extract from Stock Firmware Dump
If you have extracted the stock firmware partitions (`vendor.img` or `super.raw.img`):
```bash
./extract-files.sh /path/to/extracted_vendor_folder
```

### Option B: Extract from Connected Device via ADB
With the tablet connected over USB with ADB debugging authorized:
```bash
./extract-files.sh
```

---

## 3. Makefile Generation

The extraction script automatically invokes `setup-makefiles.sh`, generating:
* `BoardConfigVendor.mk`: Injects vendor Soong namespaces and sepolicy directories into the Android build environment.
* `via_s48-vendor.mk`: Generates the complete `PRODUCT_COPY_FILES` mapping to install all proprietary binaries to `$(TARGET_COPY_OUT_VENDOR)`.

---

## 4. Legal & Licensing Notice

This repository contains only makefiles, extraction scripts, and dependency definitions.
Proprietary binaries are excluded from public Git tracking and must be legally dumped from authorized device firmware.
