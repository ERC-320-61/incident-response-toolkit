#!/bin/bash

# Memory Strings Extraction Script
# Automates the extraction of ASCII and Unicode strings from memory dumps
# Usage: ./memdump_strings_extractor.sh <memory_dump.mem>

# Check if `strings` is installed
if ! command -v strings &> /dev/null; then
    echo "Error: 'strings' command is not installed. Install binutils package."
    exit 1
fi

# Check if memory dump filename is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <memory_dump.mem>"
    exit 1
fi

# Define input memory dump file
MEMDUMP=$1

# Check if the file exists
if [ ! -f "$MEMDUMP" ]; then
    echo "Error: File '$MEMDUMP' not found!"
    exit 1
fi

# Create output directory based on filename
# Changed the directory naming to have a dot between 'mem' and 'strings'
OUTPUT_DIR="${MEMDUMP%.*}.mem.strings"
FILTER_DIR="$OUTPUT_DIR/filterings"
mkdir -p "$OUTPUT_DIR" "$FILTER_DIR"

echo "🔍 Extracting strings from memory dump: $MEMDUMP"
echo "Results will be saved in: $OUTPUT_DIR"

# Extract ASCII strings
echo "[*] Extracting ASCII strings..."
strings "$MEMDUMP" > "$OUTPUT_DIR/${MEMDUMP%.*}_strings-asc.txt"
echo "[+] ASCII strings saved."

# Extract Unicode (Little-endian) strings
echo "[*] Extracting Unicode (Little-endian) strings..."
strings -e l "$MEMDUMP" > "$OUTPUT_DIR/${MEMDUMP%.*}_strings-unile.txt"
echo "[+] Unicode (Little-endian) strings saved."

# Extract Unicode (Big-endian) strings
echo "[*] Extracting Unicode (Big-endian) strings..."
strings -e b "$MEMDUMP" > "$OUTPUT_DIR/${MEMDUMP%.*}_strings-unibe.txt"
echo "[+] Unicode (Big-endian) strings saved."

# Ensure all results belong to the user
sudo chown -R "$USER:$USER" "$OUTPUT_DIR"
echo "[+] File ownership adjusted to user: $USER"

# Start Filtering
echo "[*] Filtering potential key artifacts into separate files..."

# Define filters
declare -A FILTERS
FILTERS["passwords"]="password|pwd|passcode|login"
FILTERS["urls"]="http[s]?://[a-zA-Z0-9./?=_-]+"
FILTERS["emails"]="[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"
FILTERS["ips"]="\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b"
FILTERS["registry_keys"]="HKEY_[A-Z]+\\[^\s]+"  # Common Windows registry keys
FILTERS["shell_commands"]="cmd.exe|powershell|bash|sh|zsh"

# Run each filter on ASCII strings file
for category in "${!FILTERS[@]}"; do
    grep -E "${FILTERS[$category]}" "$OUTPUT_DIR/${MEMDUMP%.*}_strings-asc.txt" > "$FILTER_DIR/${category}.txt"
    echo "[+] Saved ${category} results to: $FILTER_DIR/${category}.txt"
done

echo "✅ Memory strings extraction complete!"
echo "📂 All results saved in: $OUTPUT_DIR"
