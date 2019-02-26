#!/bin/sh
source ~/.bash_profile
mac=`pwd | sed 's/\// /g' | awk '{print $2}'`
SCHEME=`pwd | sed 's/\// /g' | awk '{print $NF}' | sed 's/\_/ /g' | awk '{print $1}'`

# Programs required: TauP Toolkit

# # INPUT SUMMARY FILE SECAN
# Dataset_name="SECAN_"$SCHEME
# SUMMARY_FILE="/Users/"$mac"/Dropbox/ADAPTIVE_STACKING/DATASETS/SECAN/CLEAN_DATA/P-SUMMARY-ALL.txt"
# STATION_LIST="/Users/"$mac"/Dropbox/ADAPTIVE_STACKING/DATASETS/SECAN/CLEAN_DATA/XC_PROCESSED/stations_list.txt"
# JWEED_EVT_FILE="/Users/"$mac"/Dropbox/ADAPTIVE_STACKING/SHARE_PACKAGE/ISC_FILES/correct_evts_304.txt"
# EVT_NUM_FILE="/Users/"$mac"/Dropbox/ADAPTIVE_STACKING/SHARE_PACKAGE/ISC_FILES/06-15_reference_JW_style.txt"
# EVT_NUM_FILE_2="/Users/"$mac"/Dropbox/ADAPTIVE_STACKING/DATASETS/SECAN/CLEAN_DATA/XC_PROCESSED/OUTFILES/DUMMY_FILE.txt"
# EVNR_START="476482"


# INPUT SUMMARY FILE WEST_SUP IRIS
# Dataset_name="WEST_SUP_"$SCHEME
# SUMMARY_FILE="/Users/"$mac"/Dropbox/ADAPTIVE_STACKING/DATASETS/WEST_SUP_JWEED_1996-2016/P/MCCC_COMPLETE/P_SUMMARY-ALL.txt"
# STATION_LIST="/Users/"$mac"/Dropbox/ADAPTIVE_STACKING/DATASETS/WEST_SUP_JWEED_1996-2016/CLEAN_DATA/XC_PROCESSED/stations_list.txt"
# JWEED_EVT_FILE="/Users/"$mac"/Dropbox/ADAPTIVE_STACKING/DATASETS/WEST_SUP_JWEED_1996-2016/West_Sup_1994-2016.events"
# EVT_NUM_FILE="/Users/"$mac"/Dropbox/ADAPTIVE_STACKING/DATASETS/WEST_SUP_JWEED_1996-2016/All_reference_JW_style.txt"
# EVT_NUM_FILE_2="/Users/"$mac"/Dropbox/ADAPTIVE_STACKING/DATASETS/SECAN/CLEAN_DATA/XC_PROCESSED/OUTFILES/MAY17/TXT_FILES/SECAN_extra_event_SORT.txt"
# EVNR_START="476501"


# INPUT SUMMARY FILE QMIII IRIS
# Combine the extra event files from SECAN, WSUP QMIII so that no changes to code required.
Dataset_name="SAF_"$SCHEME
SUMMARY_FILE="/Users/ab4810/AFRICA/AARM/SAF_DATA/P/SUMMARY.txt"
STATION_LIST="/Users/ab4810/AFRICA/AARM/SAF_DATA/P/XC_PROCESSED/TEXT_INFO_FILES/SAF_stations_list.txt"
JWEED_EVT_FILE="/Users/ab4810/AFRICA/JWEED_EVENTS_FILES/SAF_1990-2017_5.5_25-180.events"
EVT_NUM_FILE="/Users/ab4810/AFRICA/ISC_DATA/All_reference_JW_style.txt"
EVT_NUM_FILE_2="/Users/ab4810/AFRICA/AARM/SAF_DATA/P/XC_PROCESSED/TEXT_INFO_FILES/COMB_extra_event.txt" # COMBINE all extra events previous here.
EVNR_START="476779" ##### CHANGE THIS!!!!!!!!!!
# for EAR 476621
# for ETH 476707
# for MAD 476760
# for SAF 476779

# SUMMARY file in following form from Vandecar Processing:
# directoryname, KSTNM, STEL, GCARC, BAZ, AZ, EVDP, IASP91 TT, Pick time with elev correction, delay time, relative delay time, evla, evlo, stla, stlo, relative delay time.

# OUTPUT files to files of following form:

EVENT_OUT=$Dataset_name"_event_SUMMARY.txt"
# EVENT_OUT_LOC="/Users/"$mac"/Dropbox/ADAPTIVE_STACKING/DATASETS/SECAN/CLEAN_DATA/"$SCHEME"_PROCESSED/OUTFILES/MAY17/TXT_FILES/EVENTS" # SECAN
# EVENT_OUT_LOC="/Users/"$mac"/Dropbox/ADAPTIVE_STACKING/DATASETS/WEST_SUP_JWEED_1996-2016/CLEAN_DATA/"$SCHEME"_PROCESSED/OUTFILES/MAY17/TXT_FILES/EVENTS" # WEST_SUP
EVENT_OUT_LOC="/Users/ab4810/AFRICA/AARM/SAF_DATA/P/XC_PROCESSED/OUTFILES/OCT17/TXT_FILES/EVENTS" # AFRICA
# year month day hour minute second envr evlat_d evlon_d evdepth evmb evms evnr

# year, month, day, hour, minute, second
# event number, event lat. (deg), event lon. (deg), event depth (km),
# event body-wave magnitude, event surface-wave magnitude, event number in complete dataset.

PHASE_OUT=$Dataset_name"_phase_SUMMARY.txt"
# PHASE_OUT_LOC="/Users/"$mac"/Dropbox/ADAPTIVE_STACKING/DATASETS/SECAN/CLEAN_DATA/"$SCHEME"_PROCESSED/OUTFILES/MAY17/TXT_FILES/PHASE" # SECAN
# PHASE_OUT_LOC="/Users/"$mac"/Dropbox/ADAPTIVE_STACKING/DATASETS/WEST_SUP_JWEED_1996-2016/CLEAN_DATA/"$SCHEME"_PROCESSED/OUTFILES/MAY17/TXT_FILES/PHASE" # WEST_SUP
PHASE_OUT_LOC="/Users/ab4810/AFRICA/AARM/SAF_DATA/P/XC_PROCESSED/OUTFILES/OCT17/TXT_FILES/PHASE" # AFRICA

# envr evlat_d evlon_d evdepth stlat_d stlon_d sth stnr azim arc p prett d prec evnr

# event number, event lat. (deg), event lon. (deg), event depth (km)
# station lat. (deg), station lon. (deg), station elev (m), station number
# backazimuth (), great circle arc (), ray parameter (s/radian), predicted TT (s),
# travel-time residual (s), precision (s), event number in complete dataset.


# PRIOR CLEAN UP

rm $Dataset_name"_event_SUMMARY.txt" $Dataset_name"_phase_SUMMARY.txt"
rm $PHASE_OUT_LOC/*txt
rm $EVENT_OUT_LOC/*txt
rm *bad_*txt


file_list="??????????????"
# file_list="20080109082648"
# file_list="2008*"


echo "Starting the loop HERE"
for event in $file_list; do

cd $event
echo $event

######### START WITH EVENT #####################

year=`echo $event | awk '{print substr($0,1,4)}'`
month=`echo $event | awk '{print substr($0,5,2)}'`
day=`echo $event | awk '{print substr($0,7,2)}'`
hour=`echo $event | awk '{print substr($0,9,2)}'`
minute=`echo $event | awk '{print substr($0,11,2)}'`
second=`echo $event | awk '{print substr($0,13,2)}'`

echo "searching for event" $year"-"$month"-"$day" "$hour":"$minute":"$second

grep $year"-"$month"-"$day" "$hour":"$minute":"$second $JWEED_EVT_FILE | sed 's/\,/ /g' | awk 'NR==1' > event_details.out

grep $year"-"$month"-"$day" "$hour":" $EVT_NUM_FILE | sed 's/\,/ /g' > ev_num.out
# Also look in SECAN extra events file.
grep $year" "$month" "$day" "$hour" "$minute $EVT_NUM_FILE_2 > ev_num_2.out


if [ -f ../$EVENT_OUT ];
then
evnrorg=`awk '{print $7}' ../$EVENT_OUT | sort -n | tail -1 | awk '{print $0+1}'`
else
evnrorg=1
fi

lines=`wc -l ev_num.out | awk '{print $1}'`

lines_2=`wc -l ev_num_2.out | awk '{print $1}'`
echo $lines $lines_2


if [ $lines == "1" ] && [ $lines_2 == "0" ]; # Exact match found so number can be taken straight from ev_num.out
then
echo "Do 1-0"
evnr=`awk '{print $1}' ev_num.out`
sec=`sed 's/\:/ /g' event_details.out | awk '{print $5}'`
fi

if [ $lines == "0" ] && [ $lines_2 == "1" ];
then
echo "Do 0-1"
evnr=`awk '{print $13}' ev_num_2.out`
sec=`awk '{print $6}' ev_num_2.out`
fi

if [ $lines == "0" ] && [ $lines_2 == "0" ]; # No match found so number must be increased starting from $EVNR_START - new events. THis was for TA + SECAN - now need TA+SECAN+WEST_SUP
then
echo "Do 0-0"
if [ -f $EVENT_OUT_LOC/evnr.txt ]; # File is present so check for largest value.
then
high_ev_num=`sort -n -r $EVENT_OUT_LOC/evnr.txt | awk 'NR==1'`
value=`echo "$high_ev_num >= $EVNR_START" | bc`

if [ $value == 1 ];
then
evnr=`echo "$high_ev_num + 1" | bc` # evnr is above the new EQ threshold so just add one.
else
evnr=$EVNR_START 
fi

else
# This will catch the $EVNR_START increment when no other events have been read before. for Secan dataset
# echo "need to start at $EVNR_START"
# evnr=$EVNR_START
# as there was 19 extar events for the secan dataset, for the west sup dataset we need to start at $EVNR_START
echo "need to start at $EVNR_START"
evnr=$EVNR_START
fi
fi


sec=`sed 's/\:/ /g' event_details.out | awk '{print $5}'`

if [ $lines -ge "2" ]; # More than one match found for that hour so manually copy and pick the whole line.
then
echo "Do >=2"

# Try with minutes
echo "Checking with minutes for single match"
grep $year"-"$month"-"$day" "$hour":"$minute ev_num.out | sed 's/\,/ /g' > ev_num_3.out

lines_3=`wc -l ev_num_3.out | awk '{print $1}'`

if [ $lines_3 == "1" ]; # Exact match found so number can be taken straight from ev_num.out
then
echo "Do 1-0"
evnr=`awk '{print $1}' ev_num_3.out`
sec=`sed 's/\:/ /g' event_details.out | awk '{print $5}'`
echo $evnr $hour":"$minute":"$sec
else

head -20 ev_num.out
if [ $lines_2 -ge "1" ];
then
head -10 ev_num_2.out
fi
echo "pick which line is correct event:"
read line




if [ `echo $line | awk '{print $1}'` == "0" ];
then
echo "No matching line so make new"

if [ -f $EVENT_OUT_LOC/evnr.txt ]; # File is present so check for largest value.
then
high_ev_num=`sort -n -r $EVENT_OUT_LOC/evnr.txt | awk 'NR==1'`
value=`echo "$high_ev_num >= $EVNR_START" | bc`

if [ $value == 1 ];
then
evnr=`echo "$high_ev_num + 1" | bc` # evnr is above the new EQ threshold so just add one.
else
evnr=$EVNR_START 
fi

else
echo "need to start at $EVNR_START"
evnr=$EVNR_START
fi

sec=`sed 's/\:/ /g' event_details.out | awk '{print $5}'`
echo $evnr $hour":"$minute":"$sec
else

# line=`awk NR==1 ev_num.out`
evnr=`echo $line | sed 's/\,/ /g' | awk '{print $1}'`
hour=`echo $line | awk '{print $3}' | sed 's/\:/ /g'| awk '{print $1}'`
minute=`echo $line | awk '{print $3}' | sed 's/\:/ /g'| awk '{print $2}'`
sec=`echo $line | awk '{print $3}' | sed 's/\:/ /g'| awk '{print $3}'`
echo $evnr $hour":"$minute":"$sec


fi


fi

fi

evlat_d=`awk '{print $4}' event_details.out`
evlon_d=`awk '{print $5}' event_details.out`
evdepth=`awk '{print $6}' event_details.out`
evmb=`awk '{print $10}' event_details.out`
evms="999.0"

# echo $year $month $day $hour $minute $sec $evnrorg $evlat_d $evlon_d $evdepth $evmb $evms $evnr
echo " "
echo $year $month $day $hour $minute $sec $evnrorg $evlat_d $evlon_d $evdepth $evmb $evms $evnr >> ../$EVENT_OUT

echo $year >> $EVENT_OUT_LOC/year.txt
echo $month >> $EVENT_OUT_LOC/month.txt
echo $day >> $EVENT_OUT_LOC/day.txt
echo $hour >> $EVENT_OUT_LOC/hour.txt
echo $minute >> $EVENT_OUT_LOC/minute.txt
echo $sec >> $EVENT_OUT_LOC/sec.txt
echo $evnrorg >> $EVENT_OUT_LOC/evnrorg.txt
echo $evlat_d >> $EVENT_OUT_LOC/evlat_d.txt
echo $evlon_d >> $EVENT_OUT_LOC/evlon_d.txt
echo $evdepth >> $EVENT_OUT_LOC/evdepth.txt
echo $evmb >> $EVENT_OUT_LOC/evmb.txt
echo $evms >> $EVENT_OUT_LOC/evms.txt
echo $evnr >> $EVENT_OUT_LOC/evnr.txt

############# REPORT PHASE INFO ######################
# envr evlat_d evlon_d evdepth stlat_d stlon_d sth stnr azim arc p prett d prec

grep $event $SUMMARY_FILE > phase_details.out

# Loop over remaining files that have not been zipped: *.?HZ

station_list=`ls *.?HZ | sed 's/\_/ /g' | sed 's/\./ /g' | awk '{print $3}' | uniq | sort -n`
for station in $station_list; do


grep " "$station" " phase_details.out | awk 'NR==1' > station_details.out
stlat_d=`awk '{print $14}' station_details.out | awk 'NR==1'`
stlon_d=`awk '{print $15}' station_details.out | awk 'NR==1'`
sth=`awk '{print $3*1000}' station_details.out | awk 'NR==1'` # Meters
azim_d=`awk '{print $5}' station_details.out | awk 'NR==1'`
arc_d=`awk '{print $4}' station_details.out | awk 'NR==1'`
# echo $event" "$station
# echo $azim_d
# echo $arc_d
# echo " "

stnr=`grep -n $station $STATION_LIST | sed 's/\:/ /g' | awk '{print $1}' | awk 'NR==1'`

prett=`grep $station TT_calc_results.txt | awk '{print $6}' | awk 'NR==1'`
d=`grep $station TT_calc_results.txt | awk '{print $7}' | awk 'NR==1'`
prec=`grep $station auto_corr_errors2.txt | awk '{print $2}' | awk 'NR==1'`

p=`taup_time -mod ak135 -h $evdepth --rayp -ph P -deg $arc_d | awk 'NR==1' | awk '{print $1}'`

# echo $evnrorg $evlat_d $evlon_d $evdepth $stlat_d $stlon_d $sth $stnr $azim_d $arc_d $p $prett $d $prec $evnr
# echo " "
echo $evnrorg $evlat_d $evlon_d $evdepth $stlat_d $stlon_d $sth $stnr $azim_d $arc_d $p $prett $d $prec $evnr >> ../$PHASE_OUT

echo $evnrorg >> $PHASE_OUT_LOC/evnrorg.txt
echo $evlat_d >> $PHASE_OUT_LOC/evlat_d.txt
echo $evlon_d >> $PHASE_OUT_LOC/evlon_d.txt
echo $evdepth >> $PHASE_OUT_LOC/evdepth.txt
echo $stlat_d >> $PHASE_OUT_LOC/stlat_d.txt
echo $stlon_d >> $PHASE_OUT_LOC/stlon_d.txt
echo $sth >> $PHASE_OUT_LOC/sth.txt
echo $stnr >> $PHASE_OUT_LOC/stnr.txt
echo $azim_d >> $PHASE_OUT_LOC/azim_d.txt
echo $arc_d >> $PHASE_OUT_LOC/arc_d.txt
echo $p >> $PHASE_OUT_LOC/p.txt
echo $prett >> $PHASE_OUT_LOC/prett.txt
echo $d >> $PHASE_OUT_LOC/d.txt
echo $prec >> $PHASE_OUT_LOC/prec.txt
echo $evnr >> $PHASE_OUT_LOC/evnr.txt

done

rm event_details.out phase_details.out station_details.out ev_num.out ev_num_2.out ev_num_3.out



cd ..
done




