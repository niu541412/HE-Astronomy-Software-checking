#!/bin/bash
PATH="/usr/local/bin/":$PATH
LftpDir='/home/${whoami}/Desktop/lftp'
cd $LftpDir

#heasoft
lftp -e "
open 'https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/release'
lcd $LftpDir/heasoft
mirror -enr --include-glob heasoft*src.tar.gz --exclude-glob *xspec*
bye
"

#chandra caldb
lftp -e "
open 'ftp://cda.harvard.edu/pub/arcftp/caldb/'
lcd $LftpDir/ciao
mirror -enr --include-glob caldb_*_main.tar.gz
bye
"

#atomdb
lftp -e "
open 'ftp://sao-ftp.harvard.edu/AtomDB/releases/'
lcd $LftpDir/atomdb
mirror -enr --include-glob LATEST
bye
"
AtomVer=$(cat $LftpDir/atomdb/LATEST)
lftp -e "
open 'ftp://sao-ftp.harvard.edu/AtomDB/releases/'
lcd $LftpDir/atomdb
mirror -enr --include-glob *atomdb_v${AtomVer}*tar.bz2
bye
"

#xmm caldb
lftp -e "
open 'ftp://xmm.esac.esa.int/pub/ccf/valid_constituents/'
lcd $LftpDir/sas/valid_constituents
mirror -enr --include-glob *
bye
"
#sixte
lftp -e "
open 'http://www.sternwarte.uni-erlangen.de/research/sixte/downloads/sixte/instruments/'
lcd $LftpDir/sixte/instruments
mirror -enr --include-glob instruments_*.tar.gz
bye
"
#Xspec patch
xspatch=$(curl -sX GET https://heasarc.gsfc.nasa.gov/docs/xanadu/xspec/issues/issues.html|grep latest\ patchfile|egrep -o "\/docs.*gz")
cd $LftpDir/heasoft
patch_current=$(ls Xspatch_*gz)
if [ $patch_current != $(basename $xspatch) ] ;then
rm $patch_current
wget -N  "https://heasarc.gsfc.nasa.gov"$xspatch
fi
cd ..

tail -30 date.log > date2.log
mv date2.log date.log
date +"%Y-%m-%d %H:%M:%S %a" >> $LftpDir/date.log
find . -mindepth 2 -mtime -1 -not -type d -print >> $LftpDir/date.log
