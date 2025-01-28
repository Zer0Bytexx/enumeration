#!/bin/bash

# Variables
TARGET_DOMAIN=$1
OUTPUT_DIR="enum_results"
WORDLIST="/usr/share/wordlists/dirb/common.txt"

# Create output directory
mkdir -p $OUTPUT_DIR

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
REQUIRED_TOOLS=("nmap" "dnsenum" "dirb" "gobuster" "sublist3r" "curl" "wget")
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command_exists $tool; then
        echo "Error: $tool is not installed."
        exit 1
    fi
done

# Step 1: Find subdomains using Sublist3r
echo "[*] Finding subdomains using Sublist3r..."
sublist3r -d $TARGET_DOMAIN -o $OUTPUT_DIR/subdomains.txt

# Step 2: Check if subdomains are still running
echo "[*] Checking if subdomains are still running..."
LIVE_SUBDOMAINS="$OUTPUT_DIR/live_subdomains.txt"
> $LIVE_SUBDOMAINS
for subdomain in $(cat $OUTPUT_DIR/subdomains.txt); do
    if curl -s -o /dev/null -w "%{http_code}" "http://$subdomain" | grep -q "200"; then
        echo "$subdomain" >> $LIVE_SUBDOMAINS
    fi
done

# Step 3: Enumerate DNS records
echo "[*] Enumerating DNS records..."
dnsenum $TARGET_DOMAIN --output $OUTPUT_DIR/dns_records.xml

# Step 4: Scan open ports and services using Nmap
echo "[*] Scanning open ports and services using Nmap..."
nmap -sV -oA $OUTPUT_DIR/nmap_scan -iL $LIVE_SUBDOMAINS

# Step 5: Fuzz directories on live subdomains
echo "[*] Fuzzing directories on live subdomains..."
for subdomain in $(cat $LIVE_SUBDOMAINS); do
    echo "[*] Fuzzing $subdomain..."
    gobuster dir -u "http://$subdomain" -w $WORDLIST -o $OUTPUT_DIR/gobuster_$subdomain.txt
done

echo "[*] Enumeration complete. Results saved in $OUTPUT_DIR."