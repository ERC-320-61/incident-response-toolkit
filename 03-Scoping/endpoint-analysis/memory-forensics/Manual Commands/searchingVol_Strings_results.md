# Search for connections involving the specific IP in NetScan.txt
```bash
grep $IP $memdump.vol_results/NetScan.txt 
```
# Search for the process name in NetScan.txt to see all connections associated with it
```bash
grep $nameEXE $memdump.vol_results/NetScan.txt 
```

# Search for the process in PsTree.txt and show 3 lines of context for better visibility
```bash
grep -C 3 $nameEXE $memdump.vol_results/PsTree.txt 
```

# Search for occurrences of the process in FileScan.txt (to locate file presence)
```bash
grep $nameEXE $memdump.vol_results/FileScan.txt 
```

# Search for the process in DllList.txt with 5 lines of context to capture associated DLLs
```bash
grep -C 5 $nameEXE $memdump.vol_results/DllList.txt 
```

# Search for the process in CmdLine.txt with 5 lines of context to capture its command-line usage
```bash
grep -C 5 $nameEXE $memdump.vol_results/CmdLine.txt 
```
# Looking for unique values in strings 
```bash
grep -i -h $nameEXE $memdump.strings/*.txt | sort -u
```

# Looking for unique values in strings that are shown to in system32
```bash
grep -i -h 'windows\\system32\\{word}' $memdump.strings/*.txt | sort -u
```