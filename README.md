Need lftp, curl, wget

modify the **LftpDir** environment variable in the lftp.sh

Use crontab -e to set a periodic checking, for example:
```crontab
00 03 * * * /home/whoami/Desktop/lftp/lftp.sh
```

1. currently, tracking list:
2. heasoft & Xspec latest patch
3. chandra ciao & caldb
3. xmm-newton SAS & valid CCF
4. ATOMDB
5. sixte
