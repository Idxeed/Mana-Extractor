#!/bin/bash

GREEN='\033[0;32m' # Green Color
RED='\033[0;31m' # Red Color
YELLOW='\033[1;33m' # Yellow Color
NC='\033[0m' # No Color

echo -e "${YELLOW}[*] Start script ${NC}"
read -p 'Enter full path to firmware: ' namefile

# Create report directory
REPORT_DIR="Firmware/Reports"
mkdir -p "$REPORT_DIR"

# Initialize JSON report
JSON_REPORT="$REPORT_DIR/analysis_report.json"
echo '{' > "$JSON_REPORT"
echo '  "firmware_file": "'"$namefile"'",' >> "$JSON_REPORT"
echo '  "analysis_date": "'$(date -Iseconds)'",' >> "$JSON_REPORT"
echo '  "findings": {' >> "$JSON_REPORT"

echo -e "${YELLOW}[*] Gathering information about system..${NC}"
mkdir Firmware
binwalk "$namefile" -B --log=Firmware/About_System &>/dev/null
echo -e "${YELLOW}[*] The report can found in Firmware/About_System.txt${NC}"

# ============================================
# FEATURE 1: Cryptographic Keys and Passwords Scan
# ============================================
echo -e "${YELLOW}[*] Scanning for cryptographic keys and passwords...${NC}"
CRYPTO_FINDINGS=()
PASSWORD_PATTERNS=("password" "passwd" "pwd" "secret" "api_key" "apikey" "token" "credential" "private_key")
CRYPTO_PATTERNS=("-----BEGIN.*PRIVATE KEY-----" "RSA" "AES" "DES" "MD5" "SHA1" "weak_crypto")

cd Firmware/Filesystem || exit

for pattern in "${PASSWORD_PATTERNS[@]}"; do
    output=$(sudo grep -ril "$pattern" . 2>/dev/null | head -20)
    if [ -n "$output" ]; then
        CRYPTO_FINDINGS+=("Password-related: $pattern found")
        echo -e "${RED}[!] Potential password/credential file found: $pattern${NC}"
        echo "$output" >> "$REPORT_DIR/passwords_found.txt"
    fi
done

for pattern in "${CRYPTO_PATTERNS[@]}"; do
    output=$(sudo grep -ril "$pattern" . 2>/dev/null | head -20)
    if [ -n "$output" ]; then
        CRYPTO_FINDINGS+=("Crypto-related: $pattern found")
        echo -e "${YELLOW}[!] Potential cryptographic material: $pattern${NC}"
        echo "$output" >> "$REPORT_DIR/crypto_material.txt"
    fi
done

# Check for hardcoded credentials in config files
echo -e "${YELLOW}[*] Checking configuration files for hardcoded credentials...${NC}"
config_files=$(sudo find . -iname "*.conf" -o -iname "*.cfg" -o -iname "*.ini" -o -iname "*.config" 2>/dev/null)
if [ -n "$config_files" ]; then
    echo "$config_files" > "$REPORT_DIR/config_files.txt"
    echo -e "${GREEN}[+] Found $(echo "$config_files" | wc -l) configuration files${NC}"
fi

# ============================================
# FEATURE 2: Network Services and Ports Detection
# ============================================
echo -e "${YELLOW}[*] Detecting network services and ports...${NC}"
NETWORK_FINDINGS=()

# Search for network configuration files
net_configs=$(sudo find . -iname "*network*" -o -iname "*interface*" -o -iname "*socket*" -o -iname "*port*" 2>/dev/null)
if [ -n "$net_configs" ]; then
    echo "$net_configs" > "$REPORT_DIR/network_configs.txt"
    NETWORK_FINDINGS+=("Network configuration files found")
    echo -e "${GREEN}[+] Network configuration files found${NC}"
fi

# Search for common network service binaries
network_services=("sshd" "telnetd" "ftpd" "httpd" "nginx" "apache" "lighttpd" "busybox" "dropbear" "nc" "netcat" "socat")
for service in "${network_services[@]}"; do
    output=$(sudo find . -iname "*$service*" 2>/dev/null)
    if [ -n "$output" ]; then
        NETWORK_FINDINGS+=("Network service: $service")
        echo -e "${YELLOW}[!] Network service detected: $service${NC}"
        echo "$output" >> "$REPORT_DIR/network_services.txt"
    fi
done

# Search for port configurations in files
echo -e "${YELLOW}[*] Scanning for port configurations...${NC}"
port_patterns=("listen" "bind" "port" ":80" ":443" ":22" ":23" ":21" ":8080" ":8443")
for pattern in "${port_patterns[@]}"; do
    output=$(sudo grep -ril "$pattern" . 2>/dev/null | head -10)
    if [ -n "$output" ]; then
        echo "$output" >> "$REPORT_DIR/port_configs.txt"
    fi
done

# ============================================
# FEATURE 3: Enhanced Web Interface Analysis
# ============================================
echo -e "${YELLOW}[*] Enhanced web interface analysis...${NC}"
WEB_FINDINGS=()

# Find all web-related files
web_extensions=("*.html" "*.htm" "*.js" "*.jsx" "*.ts" "*.tsx" "*.css" "*.scss" "*.php" "*.asp" "*.aspx" "*.jsp" "*.vue" "*.svelte")
for ext in "${web_extensions[@]}"; do
    count=$(sudo find . -iname "$ext" 2>/dev/null | wc -l)
    if [ "$count" -gt 0 ]; then
        WEB_FINDINGS+=("$ext: $count files")
        echo -e "${GREEN}[+] Found $count $ext files${NC}"
        sudo find . -iname "$ext" 2>/dev/null >> "$REPORT_DIR/web_files.txt"
    fi
done

# Check for sensitive web files
sensitive_web=(".env" ".git" ".htaccess" "wp-config.php" "config.php" "settings.py" ".aws" "credentials")
for file in "${sensitive_web[@]}"; do
    output=$(sudo find . -iname "$file" 2>/dev/null)
    if [ -n "$output" ]; then
        WEB_FINDINGS+=("Sensitive web file: $file")
        echo -e "${RED}[!] SENSITIVE web file found: $file${NC}"
        echo "$output" >> "$REPORT_DIR/sensitive_web_files.txt"
    fi
done

# ============================================
# FEATURE 4: Vulnerability Signature Matching
# ============================================
echo -e "${YELLOW}[*] Scanning for known vulnerability signatures...${NC}"
VULN_FINDINGS=()

# Common vulnerable patterns
vuln_patterns=("CVE-" "buffer overflow" "sql injection" "xss" "command injection" "path traversal" "use after free" "double free")
for pattern in "${vuln_patterns[@]}"; do
    output=$(sudo grep -ril "$pattern" . 2>/dev/null | head -5)
    if [ -n "$output" ]; then
        VULN_FINDINGS+=("Vulnerability pattern: $pattern")
        echo -e "${RED}[!] Potential vulnerability pattern: $pattern${NC}"
        echo "$output" >> "$REPORT_DIR/vulnerability_signatures.txt"
    fi
done

# Check for outdated/known vulnerable software versions
vulnerable_versions=("openssl 0." "openssl 1.0" "bash 3." "curl 7.0" "python 2.")
for version in "${vulnerable_versions[@]}"; do
    output=$(sudo grep -ril "$version" . 2>/dev/null | head -5)
    if [ -n "$output" ]; then
        VULN_FINDINGS+=("Potentially vulnerable version: $version")
        echo -e "${YELLOW}[!] Potentially outdated version detected: $version${NC}"
    fi
done

# ============================================
# Continue with original functionality
# ============================================
read -p ''
echo -e "${YELLOW}[*] Start extracting filesystem..${NC}"
mkdir -p Firmware/Filesystem
cp "$namefile" Firmware/Filesystem/
cd Firmware/Filesystem || exit
sudo binwalk "$namefile" -Me --run-as=root &>/dev/null
echo -e "${YELLOW}[*] Attempting to find init files:${NC}"
output1=$(sudo find . -iname "inittab")
if [ -z "$output1" ]
then echo -e "${RED}[!] inittab not found ${NC}"
else grep sysinit: "$output1"
fi
echo -e "${YELLOW}[*] Attempting to find libs for launcher: ${NC}"
outputall=$(sudo find -iname "*.so")
echo -e "${GREEN}All libs-path can be found in Firmware/Libs.txt"; echo "$outputall" > ../Libs.txt 
output1=$(sudo find . -iname "libcrypto*.so")
if [ -z "$output1" ]
then echo -e "${RED}[!] libcrypto not found${NC}"
else echo -e "${GREEN}[+] libcrypto was found:${NC} \n$output1"
fi
output1=$(sudo find . -iname "libstdc++*")
if [ -z "$output1" ]
then echo -e "${RED}[!] libstdc++ not found${NC}"
else echo -e "${GREEN}[+] libstdc++ was found: ${NC} \n$output1 "
fi
output1=$(sudo find . -iname "libssl.so")
if [ -z "$output1" ] 
then echo -e "${RED}[!] libssl not found ${NC}"
else echo -e "${GREEN}[+] libssl was found: ${NC} \n$output1 "
fi

echo -e "${YELLOW}[*] Attempting to find Cron: ${NC}"
output1=$(sudo find . -iname "crontab")
if [ -z "$output1" ] 
then echo -e "${RED}[!] crontab not found ${NC}"
else echo -e "${GREEN}[+] crontab was found: ${NC} \n$output1 "
fi                                                 
echo -e "${YELLOW}[*] Attempting to find curl and wget: ${NC}"
output1=$(sudo find . -iname "curl")
if [ -z "$output1" ] 
then echo -e "${RED}[!] Curl not found ${NC}"
else echo -e "${GREEN}[+] Curl was found:${NC} \n$output1 "
fi
output1=$(sudo find . -iname "wget")
if [ -z "$output1" ] 
then echo -e "${RED}[!] Wget not found ${NC}"
else echo -e "${GREEN}[+] Wget was found: ${NC} \n$output1 "
fi

echo -e "${YELLOW}[*] Attempting to find webserver: ${NC}"

while IFS= read -r line
do
  output2=$(sudo find -iname "$line")
  if [ -z "$output2" ]
  then echo -e "${YELLOW} Check $line... ${NC}"
  else echo -e "${GREEN}[+] $line was found: ${NC} \n$output2 "; break
  fi 
done < ../../webservers.txt 

echo -e "${YELLOW}[*] Attempting to find Python: ${NC}"
output1=$(sudo find -iname "*.py")
if [ -z "$output1" ] 
then echo -e "${RED}[!] Python not found ${NC}"
else echo -e "${GREEN}[+] Python was found: Check the Firmware/PythonScripts.txt${NC}"; echo -e "$output1" > ../PythonScripts.txt
fi

echo -e "${YELLOW}[*] Attempting to find webui files: ${NC}"
output1=$(sudo find . -iname "*.html")
output2=$(sudo find . -iname "*.js*")
output3=$(sudo find . -iname "*.css")
output4=$(sudo find . -iname "*php*")
if [ -z "$output1" ] 
then echo -e "${RED}[!] HTML not found ${NC}"
else echo -e "${GREEN}[+] HTML was found:${NC} \n$output1 "
fi
if [ -z "$output2" ] 
then echo -e "${RED}[!] Javascript not found ${NC}"
else echo -e "${GREEN}[+] Javascript was found:${NC} \n$output2 "
fi
if [ -z "$output3" ] 
then echo -e "${RED}[!] CSS-style not found ${NC}"
else echo -e "${GREEN}[+] CSS-style was found:${NC} \n$output3 "
fi                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
if [ -z "$output4" ] 
then echo -e "${RED}[!] PHP not found ${NC}"
else echo -e "${GREEN}[+] PHP was found:${NC} \n$output4 "
fi
echo -e "${YELLOW} [*] Attempting to find drivers: ${NC}"
output1=$(sudo find -iname "*.ko")
if [ -z "$output1" ]
then echo -e "${RED}[-] Drivers not found${NC}"
else echo -e "${GREEN}[+] Drivers were found! Check Firmware/DriversList.txt ${NC}"; echo "$output1" > ../DriversList.txt
fi

echo -e "${YELLOW}[*] Attempting to find symbol table"
while IFS= read -r line
do
  output2=$(sudo find -iname "$line")
  if [ -z "$output2" ]
  then echo -e "${YELLOW} Check $line... ${NC}"
  else echo -e "${GREEN}[+] $line was found: ${NC} \n$output2"; break
  fi 
done < ../../SymbolTable.txt

# ============================================
# FEATURE 5: Generate JSON Report
# ============================================
echo -e "${YELLOW}[*] Generating JSON report...${NC}"

# Close JSON report
echo '  },' >> "$JSON_REPORT"
echo '  "summary": {' >> "$JSON_REPORT"
echo '    "crypto_findings_count": '${#CRYPTO_FINDINGS[@]}',' >> "$JSON_REPORT"
echo '    "network_findings_count": '${#NETWORK_FINDINGS[@]}',' >> "$JSON_REPORT"
echo '    "web_findings_count": '${#WEB_FINDINGS[@]}',' >> "$JSON_REPORT"
echo '    "vuln_findings_count": '${#VULN_FINDINGS[@]} >> "$JSON_REPORT"
echo '  }' >> "$JSON_REPORT"
echo '}' >> "$JSON_REPORT"

# Generate summary
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}         ANALYSIS COMPLETE${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}Summary:${NC}"
echo -e "  - Cryptographic findings: ${#CRYPTO_FINDINGS[@]}"
echo -e "  - Network service findings: ${#NETWORK_FINDINGS[@]}"
echo -e "  - Web interface findings: ${#WEB_FINDINGS[@]}"
echo -e "  - Vulnerability signatures: ${#VULN_FINDINGS[@]}"
echo -e "\n${GREEN}Reports saved to: $REPORT_DIR/${NC}"
echo -e "${YELLOW}  - JSON Report: $JSON_REPORT${NC}"
echo -e "${YELLOW}  - Passwords: $REPORT_DIR/passwords_found.txt${NC}"
echo -e "${YELLOW}  - Crypto material: $REPORT_DIR/crypto_material.txt${NC}"
echo -e "${YELLOW}  - Network services: $REPORT_DIR/network_services.txt${NC}"
echo -e "${YELLOW}  - Web files: $REPORT_DIR/web_files.txt${NC}"
echo -e "${YELLOW}  - Vulnerability signatures: $REPORT_DIR/vulnerability_signatures.txt${NC}"
echo -e "${GREEN}========================================${NC}\n"

exit
