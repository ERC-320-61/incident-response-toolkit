#!/bin/bash
# IP Investigation Script
# This script uses an IP address to locate related connections in a memory dump’s Volatility output,
# extracts the associated process name, and then uses that process name to search through various output files.
#
# Usage: ./IP_investigation.sh <IP> <Memory Dump Name>
# Example: ./IP_investigation.sh 167.172.201.123 FM-TETRIS.mem

# Function to print a divider line
print_divider() {
  echo "------------------------------------------------------------"
}

# Check for exactly 2 arguments.
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <IP> <Memory Dump Name>"
  exit 1
fi

# Assign arguments.
IP="$1"
NAME="$2"

# Define directories (assumes directories named: <NAME>.vol_results and <NAME>.strings)
VOL_RESULTS_DIR="${NAME}.vol_results"
STRINGS_DIR="${NAME}.strings"

if [ ! -d "$VOL_RESULTS_DIR" ] && [ ! -d "$STRINGS_DIR" ]; then
  echo "Error: Neither directory '$VOL_RESULTS_DIR' nor '$STRINGS_DIR' exists!"
  exit 1
fi

# Create an output directory for grep results.
OUTPUT_DIR="grep_results"
mkdir -p "$OUTPUT_DIR"

# Sanitize the IP for safe filename usage.
SANITIZED_IP=$(echo "$IP" | sed 's/[^a-zA-Z0-9]/_/g')

##############################
# Step 1: IP Search in NetScan.txt
##############################
print_divider
echo "Step 1: Searching for connections involving IP '$IP' in:"
echo "         ${VOL_RESULTS_DIR}/NetScan.txt"
print_divider
grep "$IP" "${VOL_RESULTS_DIR}/NetScan.txt" | tee "${OUTPUT_DIR}/NetScan_${SANITIZED_IP}.txt"

# Capture the results for later processing.
ip_results=$(grep "$IP" "${VOL_RESULTS_DIR}/NetScan.txt")
if [ -z "$ip_results" ]; then
  echo "No connections found for IP '$IP'. Exiting."
  exit 1
fi

##############################
# Step 2: Process Name Extraction
##############################
print_divider
# (Assumes the process name is the second-to-last field on the first matching line)
nameEXE=$(echo "$ip_results" | head -n 1 | awk '{print $(NF-1)}')
if [ -z "$nameEXE" ]; then
  echo "No process name found. Exiting."
  exit 1
fi
echo "Found running process: '$nameEXE' associated with IP '$IP'."
echo "Proceeding with further investigation using process name '$nameEXE'."
print_divider

# Prepare a sanitized version for filenames and one without the .exe extension (case-insensitive).
SANITIZED_NAMEEXE=$(echo "$nameEXE" | sed 's/[^a-zA-Z0-9]/_/g')
nameNoExt=$(echo "$nameEXE" | sed -E 's/\.exe$//I')

##############################
# Step 3: Further Investigation Using Process Name
##############################

# 3.1 Search for process name in NetScan.txt
echo "Step 3.1: Searching for process name '$nameEXE' in:"
echo "         ${VOL_RESULTS_DIR}/NetScan.txt"
print_divider
grep "$nameEXE" "${VOL_RESULTS_DIR}/NetScan.txt" | tee "${OUTPUT_DIR}/NetScan_${SANITIZED_NAMEEXE}.txt"
print_divider

# 3.2 Search in PsTree.txt (3 lines of context)
echo "Step 3.2: Searching in ${VOL_RESULTS_DIR}/PsTree.txt for '$nameEXE' (3 lines of context)"
print_divider
grep -C 3 "$nameEXE" "${VOL_RESULTS_DIR}/PsTree.txt" | tee "${OUTPUT_DIR}/PsTree_${SANITIZED_NAMEEXE}.txt"
print_divider

# 3.3 Search in FileScan.txt
echo "Step 3.3: Searching in ${VOL_RESULTS_DIR}/FileScan.txt for '$nameEXE'"
print_divider
grep "$nameEXE" "${VOL_RESULTS_DIR}/FileScan.txt" | tee "${OUTPUT_DIR}/FileScan_${SANITIZED_NAMEEXE}.txt"
print_divider

# 3.4 Search in DllList.txt (5 lines of context)
echo "Step 3.4: Searching in ${VOL_RESULTS_DIR}/DllList.txt for '$nameEXE' (5 lines of context)"
print_divider
grep -C 5 "$nameEXE" "${VOL_RESULTS_DIR}/DllList.txt" | tee "${OUTPUT_DIR}/DllList_${SANITIZED_NAMEEXE}.txt"
print_divider

# 3.5 Search in CmdLine.txt (5 lines of context)
echo "Step 3.5: Searching in ${VOL_RESULTS_DIR}/CmdLine.txt for '$nameEXE' (5 lines of context)"
print_divider
grep -C 5 "$nameEXE" "${VOL_RESULTS_DIR}/CmdLine.txt" | tee "${OUTPUT_DIR}/CmdLine_${SANITIZED_NAMEEXE}.txt"
print_divider

# 3.6 Look for unique values in strings files containing the process name.
echo "Step 3.6: Looking for unique values in strings for '$nameEXE' in:"
echo "         ${STRINGS_DIR}/*.txt"
print_divider
grep -i -h "$nameEXE" "${STRINGS_DIR}"/*.txt | sort -u | tee "${OUTPUT_DIR}/strings_${SANITIZED_NAMEEXE}.txt"
print_divider

# 3.7 Look for unique values in strings that contain "windows\system32\<process>" (without .exe)
echo "Step 3.7: Looking for unique values in strings containing 'windows\\system32\\\\${nameNoExt}' in:"
echo "         ${STRINGS_DIR}/*.txt"
print_divider
grep -i -h "windows\\\\system32\\\\${nameNoExt}" "${STRINGS_DIR}"/*.txt | sort -u | tee "${OUTPUT_DIR}/system32_${SANITIZED_NAMEEXE}.txt"
print_divider

echo "✅ IP investigation complete. Results have been saved in the '${OUTPUT_DIR}' directory."
