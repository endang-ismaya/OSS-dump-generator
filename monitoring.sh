#!/bin/sh

TOP=`cat enodeblist | wc -l`
NUM=0
	
	while [ $NUM -lt $TOP ]; do
	NUM=`ls dumpfolder/ | wc -l`
	sleep 10
	let "M = $TOP - $NUM"
	clear
	echo $NUM to $TOP "-> ("$M" left)" 
	done

echo "Finish"