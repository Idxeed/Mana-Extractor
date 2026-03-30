# FirmwareAnalyzer

This is a simple bash script that extracts and scans the firmware file of IoT devices. Its main purpose is to facilitate initial preparation and data collection. It is based on binwalk and find.

## Features

### Original Features:
- **System Information Gathering**: Extracts basic information about the firmware using binwalk
- **Filesystem Extraction**: Automatically extracts filesystem from firmware
- **Init Files Detection**: Searches for inittab and other initialization files
- **Library Detection**: Finds crypto libraries (libcrypto, libssl), C++ runtime (libstdc++)
- **Service Detection**: Detects curl, wget, cron, web servers
- **Web UI Analysis**: Finds HTML, JavaScript, CSS, PHP files
- **Driver Detection**: Locates kernel modules (.ko files)
- **Symbol Table Search**: Checks for symbol tables and encoding schemes

### New Enhanced Features:

#### 1. Cryptographic Keys and Passwords Scan
- Scans for hardcoded passwords, credentials, API keys, tokens
- Detects cryptographic material (RSA, AES, DES, private keys)
- Analyzes configuration files for sensitive data
- Results saved to `Firmware/Reports/passwords_found.txt` and `crypto_material.txt`

#### 2. Network Services and Ports Detection
- Identifies network service binaries (sshd, telnetd, ftpd, httpd, etc.)
- Searches for network configuration files
- Scans for port configurations and bindings
- Results saved to `Firmware/Reports/network_services.txt` and `port_configs.txt`

#### 3. Enhanced Web Interface Analysis
- Extended support for modern web frameworks (TypeScript, Vue, Svelte, etc.)
- Detects sensitive web files (.env, .git, .htaccess, config files)
- Comprehensive web asset inventory
- Results saved to `Firmware/Reports/web_files.txt` and `sensitive_web_files.txt`

#### 4. Vulnerability Signature Matching
- Scans for known vulnerability patterns (CVE references, injection types)
- Detects potentially outdated/vulnerable software versions
- Identifies common security issues (buffer overflow, XSS, command injection)
- Results saved to `Firmware/Reports/vulnerability_signatures.txt`

#### 5. JSON Report Generation
- Generates structured JSON report with all findings
- Includes summary statistics for each category
- Machine-readable format for automation and integration
- Report saved to `Firmware/Reports/analysis_report.json`

## Usage

To successfully execute the script, you need to create an empty folder, place the firmware file, the script and support files (.txt) there.

```bash
sudo ./analyze-firmware.sh
```

### Output

The script will create a `Firmware/Reports/` directory containing:
- `analysis_report.json` - Main JSON report with all findings
- `passwords_found.txt` - Potential password/credential files
- `crypto_material.txt` - Cryptographic material locations
- `config_files.txt` - Configuration files found
- `network_services.txt` - Network services detected
- `port_configs.txt` - Port configuration files
- `web_files.txt` - Web interface files
- `sensitive_web_files.txt` - Sensitive web files
- `vulnerability_signatures.txt` - Vulnerability patterns found

## Example of work


![изображение](https://github.com/Idxeed/Mana-Extractor/assets/117141740/255f1739-de0d-4cc6-b251-a7a865d7f6cf)
