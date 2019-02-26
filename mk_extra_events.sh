#!/bin/sh
source ~/.bash_profile
mac=`pwd | sed 's/\// /g' | awk '{print $2}'`
SCHEME=`pwd | sed 's/\// /g' | awk '{print $NF}' | sed 's/\_/ /g' | awk '{print $1}'`
Dataset_name="SAF_XC"

# rm $Dataset_name"_event_SORT.txt"

while read line; do
evnr=`echo $line | awk '{print $13}'`
if [ `echo "$evnr >= 476779" | bc` == 1 ]; then # 
echo $line >> $Dataset_name"_extra_event_SORT.txt"
fi
done<$Dataset_name"_event_SUMMARY.txt"