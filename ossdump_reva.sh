#!/bin/sh
###################################
## OSS DUMP
## created   : Apr 20, 2015
## update	   : Apr 20, 2015
## revion    : rev.A
## Author	   : Endang.Ismaya
## Assistant : Herry.Hanwari
## History   :
## * new parameters
## * 33 mobatch session
## * 1 session consist of 100 sites
## * 1 session run paralel 30 sites
####################################
## Data to be collected:
## cellId
## earfcndl
## earfcnul
## physicalLayerCellIdGroup
## physicalLayerSubCellId
## PCI
## tac
## rachRootSequence
## dlChannelBandwidth
## ulChannelBandwidth
## SW.Level
## DU.Type
## RRU.Type
###################################
####################
## Date Variable
TDAY=`date +%Y%m%d`
NODE=enodeblist.txt
####################
## removing files
rm enodeblist.txt
rm dumpfolder/file*
rm dumpfolder/*.log
rm dumpfolder/*.txt
rm dumpfolder/*.csv
################################
## collect sitelist with listme
/opt/ericsson/ddc/util/bin/listme egrep 'ERBS' | grep -iv 'ipAddress' | cut -f 3 -d '=' | nawk '{gsub("@.*","");print }' | egrep "CVL|CCL" | egrep -v 'CCL03729' > enodeblist
wait 2
################################
## split sitelist to 100 each
split enodeblist -100 sitelist
wait 2
################################
## Looping through file
for file in sitelist*; do
				echo "processing ${file}"
        nohup /opt/ericsson/amos/moshell/mobatch -p 30 -t 120 $file cmddump dumpfolder
        wait 60
        cat dumpfolder/mobatch_result.txt | grep 'contact.*m.*s' | nawk -v OFS="," '$1=$1' >> PCI_NO_CONTACT_$TDAY.csv
        cat dumpfolder/mobatch_result.txt | grep '^OK' | nawk -v OFS="," '$1=$1' >> PCI_OK_CONTACT_$TDAY.csv
done
wait 5
############################################
## log into dumpfolder and do egrep command
echo "compiling the logs files"
cd dumpfolder
## RRUType (file1a)
egrep "BXP.*" *.log | egrep -v "," | nawk '{gsub(".log:","");print $(NF-1), $5, $1}' | egrep -v '-' | sort | uniq > file1
egrep "BXP.*" *.log | egrep -v "," | nawk '{gsub(".log:","");print $(NF), $5, $1}' | egrep -v "\(" | sort | uniq >> file1
cat file1 | sort | uniq > file1a
## SW.Lvel (file2)
egrep 'Executing:' *.log | nawk '{gsub(".log"," ");print $1, $(NF-1)"_"$NF}' > file2
## V-lookup file1a & file2 > (file12)
nawk 'NR==FNR{a[$1]=$2;next} {print $1, $2, $3, a[$3]?a[$3]:"NA"}' file2 file1a > file12
## DU.Type (file3)
egrep '^01' *.log | nawk '{gsub(".log"," ");print $1, $3}' > file3
## V-lookup file12 & file3 > (file123)
nawk 'NR==FNR{a[$1]=$2;next} {print $1, $2, $3, $4, a[$3]?a[$3]:"NA"}' file3 file12 > file123
## EutranCellFDD parameters > (file4)
egrep '^EUtranCellFDD.*;' *.log | nawk '{gsub(".log:EUtranCellFDD="," ");gsub(";"," ");print}' > file4
## V-lookup file123 & file4 RRUType > (file5a)
nawk 'NR==FNR{a[$1]=$2;next} {print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, a[$2]?a[$2]:"NA"}' file123 file4 > file5a
## create sitename as reference > (file123a)
cat file123 | nawk '{print $3, $1, $2, $4, $5 }' > file123a
## V-lookup file123a & file5a SW.Level > (file5b)
nawk 'NR==FNR{a[$1]=$4;next} {print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, a[$1]?a[$1]:"NA"}' file123a file5a > file5b
## V-lookup file123a & file5b > (file5c)
nawk 'NR==FNR{a[$1]=$5;next} {print $1, $2, $3, $4, $5, $6, $7, $8, ($7*3) + $8, $9, $10, $11, $12, $13, a[$1]?a[$1]:"NA"}' file123a file5b > file5c
## field design
echo "eNodeBName EUtranCellFDD cellId earfcndl earfcnul physicalLayerCellIdGroup physicalLayerSubCellId PCI tac rachRootSequence dlChannelBandwidth ulChannelBandwidth SW.Level DU.Type RRU.Type" | nawk -v OFS="," '$1=$1' > PCI_DUMP.csv
## filled data to .csv
nawk '{printf "%s %15s %8s %10s %10s %8s %8s %10s %10s %10s %10s %10s %15s %10s %10s\n", $1, $2, $3, $5, $6, $7, $8, $9, $11, $10, $4, $12, $14, $15, $13}' file5c | nawk -v OFS="," '$1=$1' >> PCI_DUMP.csv
echo "mission completed!"