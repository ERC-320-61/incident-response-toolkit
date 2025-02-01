# For running most the nessecary modules
```bash
for plugin in "windows.netscan.NetScan" "windows.pstree.PsTree" "windows.pslist.PsList" "windows.cmdline.CmdLine" "windows.filescan.FileScan" "windows.dlllist.DllList" "windows.malfind.Malfind"; do
    vol -q -f "$memdump" "$plugin" > "${memdump}.vol_results/${plugin}.txt"
done

```