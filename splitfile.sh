#!/bin/sh
## opt/ericsson/ddc/util/bin/listme egrep 'ERBS' | grep -iv 'ipAddress' | cut -f 3 -d '=' | nawk '{gsub("@.*","");print }' | egrep "CVL|CCL" > enodeblist

split enodeblist -100 > sitelist
for file in sitelist*; do
	mobatch -p 20 -t 120 $file cmdpci2 PCITest
	wait 1
done