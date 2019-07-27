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

#chandra
CIAO_VER=$(lftp -e "ls -t; bye" ftp://cxc.harvard.edu/pub 2> /dev/null |egrep -o ciao[0-9.]* | head -1)
lftp -e "
open 'ftp://cda.harvard.edu/pub/arcftp/caldb/'
lcd $LftpDir/chandra/caldb
mirror -enr --include-glob caldb_*_main.tar.gz
lcd $LftpDir/chandra/tmp
open 'ftp://cxc.harvard.edu/pub/$CIAO_VER/all'
mirror -enr --include-glob ciao-install
bye
"
if [ $(uname -s) == Darwin ] ; then
  SYS_VER=$(cat chandra/tmp/ciao-install|grep -A15 '${macver}'|tail -15|grep -B15 unsupport_sys|grep RSYS|tail -1|sed s/.*RSYS=\"//g|sed s/\"//g)
else
  SYS_VER=LinuxU
fi

lftp -e "
open 'ftp://cxc.harvard.edu/pub/$CIAO_VER/$SYS_VER'
lcd $LftpDir/chandra/ciao
mirror -enr --include-glob *
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

#xmm
if [ $(uname -s) == Darwin ] ; then
  SAS_VER=$(lftp -e "ls -t; bye" ftp://xmm.esac.esa.int/pub/sas/latest/MacOSX 2> /dev/null |egrep -o Darwin[0-9.\-]* | head -1)
  SAS_VER=MacOSX/$SAS_VER
else
  SAS_VER=$(lftp -e "ls -t; bye" ftp://xmm.esac.esa.int/pub/sas/latest/Linux 2> /dev/null |egrep -o Ubuntu[0-9.\-]* | head -1)
  SAS_VER=Linux/$SAS_VER
fi

lftp -e "
open 'ftp://xmm.esac.esa.int/pub/sas/latest/$SAS_VER'
lcd $LftpDir/xmm-newton/sas
mirror -enr --include-glob *tgz
open 'ftp://xmm.esac.esa.int/pub/ccf/valid_constituents/'
lcd $LftpDir/xmm-newton/valid_constituents
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
