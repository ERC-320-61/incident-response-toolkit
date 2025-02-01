# Set vars and mkdir
```bash
memdump=dumpName.<mem or raw>
mkdir $memdump.strings
```

#ASCII
```bash
strings $memdump > $memdump.strings/asc.txt
```

# Little endian
```bash
strings -e l $memdump > $memdump.strings/unile.txt
```

# big endian
```bash
strings -e b $memdump > $memdump.strings/unibe.txt
```