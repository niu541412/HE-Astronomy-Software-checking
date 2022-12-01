#!/bin/bash
PATH="/usr/local/bin/":$PATH
LftpDir="${HOME}/Desktop/lftp"
cd $LftpDir

#heasoft
lftp -e "
open 'https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/release/'
lcd $LftpDir/heasoft
mirror -enr --include-glob heasoft*src.tar.gz --exclude-glob *xspec*
bye
"

#chandra
if [ $(uname -s) == Darwin ] ; then
  #SYS_VER=$(cat chandra/tmp/ciao-install|grep -A15 '${macver}'|tail -15|grep -B15 unsupport_sys|grep RSYS|tail -1|sed s/.*RSYS=\"//g|sed s/\"//g)
  SYS_VER=macOS
else
  SYS_VER=Linux
fi
CXC_URL="https://cxc.harvard.edu"
ciao_install_url=$(curl -sX GET $CXC_URL/ciao/download/ciao_install.html|grep -e "/cgi-gen/ciao/ciao[0-9]*_install.cgi?standard=true"|egrep -o "href=\".*\" "|sed s/href=//g|sed s/\"//g)
cd $LftpDir/chandra
wget -O ciao_install $CXC_URL/$ciao_install_url
CONTROL_FILE=$(cat ciao_install |grep ^CONTROL_FILE|egrep -o \".*\"|sed s/\"//g)
CONTROL_LOCATION=$(cat ciao_install |grep ^CONTROL_LOCATION|egrep -o \".*\"|sed s/\"//g)
rm ciao_install
wget -N $CONTROL_LOCATION/$CONTROL_FILE
FILE_NAME=$(cat ciao-control |grep -A 30 "SYS $SYS_VER"|grep -m 2 -B 30 "SYS"|grep FILE|egrep -o ciao.*tar.gz; cat ciao-control |grep -A 1 "SEG CALDB_main"|grep FILE|egrep -o caldb.*tar.gz;cat ciao-control |grep -A 1 "SEG contrib"|grep FILE|egrep -o ciao.*tar.g)
cd ciao
for i in *; do
       if ! grep -qFe "$i" <<< $FILE_NAME; then
               echo "Deleting: $i"
               rm $i
       fi
done
FILE_LOCATION=$(cat ../ciao-control |grep -A 1 "SYS $SYS_VER"|grep DL|sed s/DL\ //g|sed s/\ .*//g)
CIAO_FILE=$(cat ../ciao-control |grep -A 30 "SYS $SYS_VER"|grep -m 2 -B 30 "SYS"|grep FILE|egrep -o ciao.*tar.gz)
for i in $CIAO_FILE; do
        echo $i
        wget -N $FILE_LOCATION/$i
done
FILE_LOCATION=$(cat ../ciao-control |grep -A 1 "# CALDB"|grep DL|sed s/DL\ //g|sed s/\ .*//g)
CALDB_FILE=$(cat ../ciao-control |grep -A 1 "SEG CALDB_main"|grep FILE|egrep -o caldb.*tar.gz)
wget -N $FILE_LOCATION/$CALDB_FILE
FILE_LOCATION=$(cat ../ciao-control |grep -A 1 "# Contr"|grep DL|sed s/DL\ //g|sed s/\ .*//g)
CONTR_FILE=$(cat ../ciao-control |grep -A 1 "SEG contrib"|grep FILE|egrep -o ciao.*tar.gz)
wget -N $FILE_LOCATION/$CONTR_FILE
cd ../..

#atomdb
lftp -e "
open 'http://hea-www.cfa.harvard.edu/AtomDB/releases/'
lcd $LftpDir/atomdb
mirror -enr --include-glob LATEST
bye
"
AtomVer=$(cat $LftpDir/atomdb/LATEST)
lftp -e "
open 'http://hea-www.cfa.harvard.edu/AtomDB/releases/'
lcd $LftpDir/atomdb
mirror -enr --include-glob *atomdb_v${AtomVer}*tar.bz2
bye
"

#xmm
if [ $(uname -s) == Darwin ] ; then
  SAS_VER=$(lftp -e "ls -t; bye" http://sasdev-xmm.esac.esa.int/pub/sas/latest/MacOSX 2> /dev/null |egrep -o Darwin[0-9.\-]* | head -1)
  SAS_VER=MacOSX/$SAS_VER
else  
  SAS_VER=$(lftp -e "ls -t; bye" http://sasdev-xmm.esac.esa.int/pub/sas/latest/Linux 2> /dev/null |egrep -o Ubuntu[0-9.\-]* | head -1)
  SAS_VER=Linux/$SAS_VER
fi

lftp -e "
open 'http://sasdev-xmm.esac.esa.int/pub/sas/latest/$SAS_VER'
lcd $LftpDir/xmm-newton/sas
mirror -enr --include-glob *tgz
open 'http://sasdev-xmm.esac.esa.int/pub/ccf/valid_constituents/'
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
if [ x$patch_current != x$(basename $xspatch) ] ;then
rm $patch_current
wget -N  "https://heasarc.gsfc.nasa.gov"$xspatch
fi
cd ..

tail -30 date.log > date2.log
mv date2.log date.log
date +"%Y-%m-%d %H:%M:%S %a" >> $LftpDir/date.log
find . -mindepth 2 -mtime -1 -not -type d -print >> $LftpDir/date.log
