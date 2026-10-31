# Vendor Configuration: Casper VIA S48 (MT8168)

This directory provides the proprietary blob extraction tooling and vendor makefile generation for the **Casper VIA S48** tablet.

## Usage

To extract blobs from a connected tablet running stock or compatible firmware:
```bash
./extract-files.sh
```

To extract from a local dump directory:
```bash
./extract-files.sh /path/to/extracted/vendor
```

Note: Do not commit proprietary binaries to public git repositories without authorization.
