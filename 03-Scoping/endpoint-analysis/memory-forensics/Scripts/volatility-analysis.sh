#!/bin/bash

# Volatility Automation Script
# Runs multiple Volatility plugins on an existing memory dump and saves results.

# Check if Volatility is installed
if ! command -v vol &> /dev/null; then
    echo "Error: Volatility is not installed. Install it and try again."
    exit 1
fi

# Check for input argument
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <memory_dump.mem> <os_type>"
    exit 1
fi

# Define input memory dump
MEMORY_DUMP=$1
OS_TYPE=$2

# Define results directory using a period before "vol_results"
OUTPUT_DIR="$(basename "$MEMORY_DUMP").vol_results"

# Ensure the directory is created with user ownership
mkdir -p "$OUTPUT_DIR"
chmod 755 "$OUTPUT_DIR"

echo "🔍 Starting Volatility analysis on: $MEMORY_DUMP"
echo "Results will be saved in: $OUTPUT_DIR"

# List of essential plugins (excluding procdump)
if [ "$OS_TYPE" == "windows" ]; then
    PLUGINS=(
        "windows.netscan.NetScan"   # Network connections
        "windows.pstree.PsTree"     # Process tree
        "windows.pslist.PsList"     # Process listing
        "windows.cmdline.CmdLine"   # Command-line arguments
        "windows.filescan.FileScan" # File handles
        "windows.dlllist.DllList"   # Loaded DLLs
        "windows.malfind.Malfind"   # Detect code injection
    )
elif [ "$OS_TYPE" == "linux" ]; then
    PLUGINS=(
        "linux.pslist.PsList"       # Process listing
        "linux.pstree.PsTree"       # Process tree
        "linux.netstat.Netstat"     # Network connections
        "linux.lsof.Lsof"           # Open file descriptors
        "linux.bash.Bash"           # Recover bash history
        "linux.proc.Malfind"        # Detect injected code
    )
else
    echo "Error: Unsupported OS type. Use 'windows' or 'linux'."
    exit 1
fi

# Run each plugin and save output
for plugin in "${PLUGINS[@]}"; do
    echo "[*] Running $plugin..."
    vol -f "$MEMORY_DUMP" $plugin > "$OUTPUT_DIR/$(basename "$plugin" | cut -d'.' -f3).txt"
    chmod 644 "$OUTPUT_DIR/$(basename "$plugin" | cut -d'.' -f3).txt"
    echo "[+] Saved output: $(basename "$MEMORY_DUMP").$plugin.txt"
done

# Ensure all results belong to the user
sudo chown -R "$USER:$USER" "$OUTPUT_DIR"

# Summary
echo "✅ Volatility analysis completed."
echo "Results saved in: $OUTPUT_DIR"
