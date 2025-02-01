#!/bin/bash
# Volatility Automation Script
# This script searches for a provided search term in files located in
# <name>.mem_vol_results and <name>.mem_strings, then outputs the results
# to the terminal and saves each to its own file in a directory called grep_results.

# Usage check: requires exactly 2 arguments:
#   $1 : The search criteria (word, IP, URL, etc.)
#   $2 : The memory dump "name" (used as the prefix for the directories)
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <Search Criteria> <Memory Dump Name>"
    exit 1
fi

SEARCH_TERM="$1"
NAME="$2"

# Define directories based on the provided memory dump name.
VOL_RESULTS_DIR="${NAME}.mem_vol_results"
STRINGS_DIR="${NAME}.mem_strings"

# Check that at least one of the expected directories exists.
if [ ! -d "$VOL_RESULTS_DIR" ] && [ ! -d "$STRINGS_DIR" ]; then
    echo "Error: Neither directory '$VOL_RESULTS_DIR' nor '$STRINGS_DIR' exists!"
    exit 1
fi

# Create an output directory for grep results.
OUTPUT_DIR="grep_results"
mkdir -p "$OUTPUT_DIR"

# Sanitize the search term for safe usage in filenames:
# Replace any non-alphanumeric character with an underscore.
SANITIZED_TERM=$(echo "$SEARCH_TERM" | sed 's/[^a-zA-Z0-9]/_/g')

##############################
# Search in mem_vol_results  #
##############################
if [ -d "$VOL_RESULTS_DIR" ]; then
    echo "Searching in ${VOL_RESULTS_DIR}/NetScan.txt for '$SEARCH_TERM'..."
    grep --color=always "$SEARCH_TERM" "${VOL_RESULTS_DIR}/NetScan.txt" \
        | tee "${OUTPUT_DIR}/NetScan_${SANITIZED_TERM}.txt"

    echo "Searching in ${VOL_RESULTS_DIR}/PsTree.txt for '$SEARCH_TERM' (with 3 lines of context)..."
    grep -C 3 --color=always "$SEARCH_TERM" "${VOL_RESULTS_DIR}/PsTree.txt" \
        | tee "${OUTPUT_DIR}/PsTree_${SANITIZED_TERM}.txt"

    echo "Searching in ${VOL_RESULTS_DIR}/FileScan.txt for '$SEARCH_TERM'..."
    grep --color=always "$SEARCH_TERM" "${VOL_RESULTS_DIR}/FileScan.txt" \
        | tee "${OUTPUT_DIR}/FileScan_${SANITIZED_TERM}.txt"

    echo "Searching in ${VOL_RESULTS_DIR}/DllList.txt for '$SEARCH_TERM' (with 5 lines of context)..."
    grep -C 5 --color=always "$SEARCH_TERM" "${VOL_RESULTS_DIR}/DllList.txt" \
        | tee "${OUTPUT_DIR}/DllList_${SANITIZED_TERM}.txt"

    echo "Searching in ${VOL_RESULTS_DIR}/CmdLine.txt for '$SEARCH_TERM' (with 5 lines of context)..."
    grep -C 5 --color=always "$SEARCH_TERM" "${VOL_RESULTS_DIR}/CmdLine.txt" \
        | tee "${OUTPUT_DIR}/CmdLine_${SANITIZED_TERM}.txt"
else
    echo "Directory '$VOL_RESULTS_DIR' not found. Skipping volatility result searches."
fi

##############################
# Search in mem_strings      #
##############################
if [ -d "$STRINGS_DIR" ]; then
    # Adjust the filename below if your mem_strings directory contains a different file.
    STRINGS_FILE="${STRINGS_DIR}/strings.txt"
    if [ -f "$STRINGS_FILE" ]; then
        echo "Searching in ${STRINGS_FILE} for '$SEARCH_TERM'..."
        grep --color=always "$SEARCH_TERM" "$STRINGS_FILE" \
            | tee "${OUTPUT_DIR}/strings_${SANITIZED_TERM}.txt"
    else
        echo "File '$STRINGS_FILE' not found in directory '$STRINGS_DIR'. Skipping string searches."
    fi
else
    echo "Directory '$STRINGS_DIR' not found. Skipping mem_strings searches."
fi

echo "Search complete. Results have been saved in the '$OUTPUT_DIR' directory."
