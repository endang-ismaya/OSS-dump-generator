## RRUType (file1a)
egrep "BXP.*" *.log | egrep -v "," | awk '{gsub(".log:","");print $(NF-1), $5, $1}' | egrep -v '-' | sort | uniq > file1
egrep "BXP.*" *.log | egrep -v "," | awk '{gsub(".log:","");print $(NF), $5, $1}' | egrep -v "\(" | sort | uniq >> file1
cat file1 | sort | uniq > file1a
## SW.Lvel (file2)
##egrep 'Executing:' *.log | awk '{gsub(".log"," ");print $1, $(NF-1)"_"$NF}' > file2
egrep 'Executing:' *.log | awk '{gsub(".log"," ");print $1, $(NF-2), $(NF-1)"_"$NF}' > file2
## V-lookup file1a & file2 > (file12)
awk 'NR==FNR{a[$1]=$2;next} {print $1, $2, $3, a[$3]?a[$3]:"NA"}' file2 file1a > file12
## DU.Type (file3)
egrep '^01' *.log | awk '{gsub(".log"," ");print $1, $3}' > file3
## V-lookup file12 & file3 > (file123)
awk 'NR==FNR{a[$1]=$2;next} {print $1, $2, $3, $4, a[$3]?a[$3]:"NA"}' file3 file12 > file123
## EutranCellFDD parameters > (file4)
egrep '^EUtranCellFDD.*;' *.log | awk '{gsub(".log:EUtranCellFDD="," ");gsub(";"," ");print}' > file4
## V-lookup file123 & file4 RRUType > (file5a)
awk 'NR==FNR{a[$1]=$2;next} {print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, a[$2]?a[$2]:"NA"}' file123 file4 > file5a
## create sitename as reference > (file123a)
cat file123 | awk '{print $3, $1, $2, $4, $5 }' > file123a
## V-lookup file123a & file5a SW.Level > (file5b)
awk 'NR==FNR{a[$1]=$4;next} {print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, a[$1]?a[$1]:"NA"}' file123a file5a > file5b
## V-lookup file123a & file5b > (file5c)
awk 'NR==FNR{a[$1]=$5;next} {print $1, $2, $3, $4, $5, $6, $7, $8, ($7*3) + $8, $9, $10, $11, $12, $13, a[$1]?a[$1]:"NA"}' file123a file5b > file5c
## V-lookup again with SWLevel > (file5d)
awk 'NR==FNR{a[$1]=$2;next} {print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, a[$1]?a[$1]:"NA", $15}' file2 file5c > file5d
## SW.Package
awk 'NR==FNR{a[$1]=$3;next} {print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, a[$1]?a[$1]:"NA", $15}' file2 file5d > file5e
## v-lookup again DUL > filefinal
awk 'NR==FNR{a[$1]=$2;next} {print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14,$15, a[$1]?a[$1]:"NA"}' file3 file5e > filefinal
## field design
echo "eNodeBName EUtranCellFDD cellId earfcndl earfcnul physicalLayerCellIdGroup physicalLayerSubCellId PCI tac rachRootSequence dlChannelBandwidth ulChannelBandwidth SW.Package SW.Level DU.Type RRU.Type" | awk -v OFS="," '$1=$1' > PCI_DUMP.csv
## filled data to .csv
awk '{ print $1, $2, $3, $5, $6, $7, $8, $9, $11, $10, $4, $12, $14, $15, $16, $13 }' filefinal | awk -v OFS="," '$1=$1' >> PCI_DUMP.csv
echo "mission completed!"