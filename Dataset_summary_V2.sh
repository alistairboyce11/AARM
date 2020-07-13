#!/bin/sh
source ~/.bash_profile
SCHEME=XC
home=`pwd`
DATA_TRANCHE=SEP19

DEP_ERROR=2
LOC_ERROR=2
TIME_ERROR=8

# Programs required: TauP Toolkit

# INPUT SUMMARY FILE QMIII IRIS
# Combine the extra event files from SECAN, WSUP QMIII so that no changes to code required.
# After QMIII just adding unique event numbers for each event for African datasets, actual times dont matter, just phase association.

region_list="ATS CAM EAR ETH MAD SAF"

EVNR="476530" 
# # for ATS 476530
# # for CAM 477135
# # for EAR 477455
# # for ETH 478427
# # for MAD 479957
# # for SAF 480289
# # for next 481192

for region in $region_list; do
	
	echo " "
	echo "Starting the "$region" dataset............."
	echo " "
	
	region_dir=$region"_DATA"
	
	########################## Set all the necessary input and output files. #################################################
	ERROR_FILE=$home"/"$region"_summary_errors.txt"
	SUMMARY_FILE=$home"/"$region_dir"/P/SUMMARY.txt"
	STATION_LIST=$home"/TEXT_INFO_FILES/"$region"_station_list.txt"
	ObspyDMT_EVT_FILE=$home"/ObspyDMT_EQ_catalog/IRIS_catalog_5.2Mb/EVENTS-INFO/catalog.txt"
	#number,event_id,datetime,latitude,longitude,depth,magnitude,magnitude_type,author,flynn_region,mrr,mtt,mpp,mrt,mrp,mtp,stf_func,stf_duration,t1,t2
	
	# SUMMARY file in following form from Vandecar Processing:
	# directoryname, KSTNM, STEL, GCARC, BAZ, AZ, EVDP, IASP91 TT, Pick time with elev correction, delay time, relative delay time, evla, evlo, stla, stlo, relative delay time.

	# OUTPUT files to files of following form:

	EVENT_OUT=$region"_"$SCHEME"_event_SUMMARY.txt"
	EVENT_OUT_LOC=$home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/$DATA_TRANCHE/TXT_FILES/EVENTS" # AFRICA
	# year month day hour minute second envr evlat_d evlon_d evdepth evmb evms evnr

	# year, month, day, hour, minute, second
	# event number, event lat. (deg), event lon. (deg), event depth (km),
	# event body-wave magnitude, event surface-wave magnitude, event number in complete dataset.

	PHASE_OUT=$region"_"$SCHEME"_phase_SUMMARY.txt"
	PHASE_OUT_LOC=$home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/SEP19/TXT_FILES/PHASE" # AFRICA

	# envr evlat_d evlon_d evdepth stlat_d stlon_d sth stnr azim arc p prett d prec evnr

	# event number, event lat. (deg), event lon. (deg), event depth (km)
	# station lat. (deg), station lon. (deg), station elev (m), station number
	# backazimuth (), great circle arc (), ray parameter (s/radian), predicted TT (s),
	# travel-time residual (s), precision (s), event number in complete dataset.


	if [[ ! -d $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES" ]]; then
		echo "Making new directory..."
		mkdir $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES"
	fi
	
	if [[ ! -d $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE ]]; then
		echo "Making new directory..."
		mkdir $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE
	fi	
	
	if [[ ! -d $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/TXT_FILES/" ]]; then
		echo "Making new directory..."
		mkdir $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/TXT_FILES/"
	fi

	if [[ ! -d $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/BIN_FILES/" ]]; then
		echo "Making new directory..."
		mkdir $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/BIN_FILES/"
	fi
	
	if [[ ! -d $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/BIN_FILES/EVENTS" ]]; then
		echo "Making new directory..."
		mkdir $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/BIN_FILES/EVENTS"
	fi
	
	if [[ ! -d $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/BIN_FILES/PHASE" ]]; then
		echo "Making new directory..."
		mkdir $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/BIN_FILES/PHASE"
	fi
	
	
	if [[ ! -d $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/TXT_FILES/EVENTS" ]]; then
		echo "Making new directory..."
		mkdir $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/TXT_FILES/EVENTS"
	fi
	
	if [[ ! -d $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/TXT_FILES/PHASE" ]]; then
		echo "Making new directory..."
		mkdir $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/TXT_FILES/PHASE"
	fi

	################################# Begin looping thorugh events in each dir. ####################################
	
	cd $home"/"$region_dir"/P/"$SCHEME"_PROCESSED/"
	
	rm $EVENT_OUT $PHASE_OUT
	rm $PHASE_OUT_LOC/*txt
	rm $EVENT_OUT_LOC/*txt
	rm *.out
	
	event_list="??????????????"
	num_events=`echo $event_list | wc -w`
	
	echo " "
	echo ".... Beginning events loop, there are "$num_events" events :)"
	echo " "
	
	
	for event in $event_list; do
		echo "Working on event: "$event" ..... "
		
		year=`echo $event | awk '{print substr($0,1,4)}'`
		month=`echo $event | awk '{print substr($0,5,2)}'`
		day=`echo $event | awk '{print substr($0,7,2)}'`
		hour=`echo $event | awk '{print substr($0,9,2)}'`
		minute=`echo $event | awk '{print substr($0,11,2)}'`
		second=`echo $event | awk '{print substr($0,13,2)}'`

		# echo "searching for event" $year"-"$month"-"$day" "$hour":"$minute":"$second
		grep $year"-"$month"-"$day"T"$hour":"$minute":"$second $ObspyDMT_EVT_FILE  | sed 's/\,/ /g' | awk 'NR==1' > ObspyDMT_event_details.out
		grep $event $SUMMARY_FILE | awk '{print $1, $7, $12, $13}'  > VDC_SUM_event_details.out # directoryname, EVDP, evla, evlo,
		
		len_matching_events_1=`wc -l ObspyDMT_event_details.out | awk '{print $1}'`
		
		if [[ $len_matching_events_1 == 0 ]]; then
			# echo "We need to widen the search to include differences in the seconds...."
			grep $year"-"$month"-"$day"T"$hour":"$minute":" $ObspyDMT_EVT_FILE  | sed 's/\,/ /g' | awk 'NR==1' > ObspyDMT_event_details.out
			len_matching_events_2=`wc -l ObspyDMT_event_details.out | awk '{print $1}'`
			
			if [[ $len_matching_events_2 == 0 ]]; then
				# echo "We need to widen the search to include differences in the minutes...."
				grep $year"-"$month"-"$day"T"$hour":" $ObspyDMT_EVT_FILE  | sed 's/\,/ /g' | awk 'NR==1' > ObspyDMT_event_details.out
				len_matching_events_3=`wc -l ObspyDMT_event_details.out | awk '{print $1}'`
				if [[ $len_matching_events_3 == 0 ]]; then
					echo "No similar event found.... "
					echo "No idea how this happens..."
					echo "Exiting...."
					exit
				fi
			fi

		fi
		
		
		# Now just check that the times and locs are similar.
		
		# Take the median of the dep/lat/lon incase there are differences...
				
		awk '{print $2}' VDC_SUM_event_details.out > VDC_EV_DEP.out
		awk '{print $3}' VDC_SUM_event_details.out > VDC_EV_LAT.out
		awk '{print $4}' VDC_SUM_event_details.out > VDC_EV_LON.out
		
		VDC_EV_DEP=`gmt gmtmath -S VDC_EV_DEP.out MEDIAN = `
		VDC_EV_LAT=`gmt gmtmath -S VDC_EV_LAT.out MEDIAN = `
		VDC_EV_LON=`gmt gmtmath -S VDC_EV_LON.out MEDIAN = `
		
		DMT_EV_DEP=`awk '{print $6}' ObspyDMT_event_details.out`
		DMT_EV_LAT=`awk '{print $4}' ObspyDMT_event_details.out`
		DMT_EV_LON=`awk '{print $5}' ObspyDMT_event_details.out`
		DMT_EV_MMW=`awk '{print $7}' ObspyDMT_event_details.out`
		DMT_EV_MS="999.0"
		DMT_EVNRORG=`awk '{print $1}' ObspyDMT_event_details.out` # This makes the evnrorg number the one from the ObspyDMT list.
		
		DMT_EV_datetime=`awk '{print $3}' ObspyDMT_event_details.out | sed 's/\-/ /g' | sed 's/\:/ /g' | sed 's/\T/ /g' | sed 's/\000Z/ /g'`
		
		DMT_EV_YEAR=`echo $DMT_EV_datetime | awk '{print $1}'`
		DMT_EV_MONTH=`echo $DMT_EV_datetime | awk '{print $2}'`
		DMT_EV_DAY=`echo $DMT_EV_datetime | awk '{print $3}'`
		DMT_EV_HOUR=`echo $DMT_EV_datetime | awk '{print $4}'`
		DMT_EV_MIN=`echo $DMT_EV_datetime | awk '{print $5}'`
		DMT_EV_SEC=`echo $DMT_EV_datetime | awk '{print $6}'`
		
		
		TIME_MATCH=`python $home/SCRIPTS/eq_time_diff.py $TIME_ERROR $year $month $day $hour $minute $second $DMT_EV_YEAR $DMT_EV_MONTH $DMT_EV_DAY $DMT_EV_HOUR $DMT_EV_MIN $DMT_EV_SEC`
		
		if [[ $TIME_MATCH == 0 ]]; then
			echo "Picked event is outside time error "
			echo "Reporting to errors file..."
			echo $region $event $TIME_ERROR $year $month $day $hour $minute $second $DMT_EV_YEAR $DMT_EV_MONTH $DMT_EV_DAY $DMT_EV_HOUR $DMT_EV_MIN $DMT_EV_SEC >> $ERROR_FILE
			echo "Just using ObspyDMT times for everything.. I don't think it matters."
		fi
		
		LOC_MATCH=`python $home/SCRIPTS/eq_loc_diff.py $DEP_ERROR $LOC_ERROR $VDC_EV_DEP $VDC_EV_LAT $VDC_EV_LON $DMT_EV_DEP $DMT_EV_LAT $DMT_EV_LON`
		
		if [[ $LOC_MATCH == 0 ]]; then
			echo "Picked event is outside loc error "
			echo "Reporting to errors file..."
			echo $region $event $DEP_ERROR $LOC_ERROR $VDC_EV_DEP $VDC_EV_LAT $VDC_EV_LON $DMT_EV_DEP $DMT_EV_LAT $DMT_EV_LON >> $ERROR_FILE
			DMT_EV_LAT=$VDC_EV_LAT
			DMT_EV_LON=$VDC_EV_LON
			DMT_EV_DEP=$VDC_EV_DEP
				
		fi		
		
		
		echo $DMT_EV_YEAR $DMT_EV_MONTH $DMT_EV_DAY $DMT_EV_HOUR $DMT_EV_MIN $DMT_EV_SEC $DMT_EVNRORG $DMT_EV_LAT $DMT_EV_LON $DMT_EV_DEP $DMT_EV_MMW $DMT_EV_MS $EVNR
		echo " "
		echo $DMT_EV_YEAR $DMT_EV_MONTH $DMT_EV_DAY $DMT_EV_HOUR $DMT_EV_MIN $DMT_EV_SEC $DMT_EVNRORG $DMT_EV_LAT $DMT_EV_LON $DMT_EV_DEP $DMT_EV_MMW $DMT_EV_MS $EVNR >> $EVENT_OUT

		echo $DMT_EV_YEAR >> $EVENT_OUT_LOC/year.txt
		echo $DMT_EV_MONTH >> $EVENT_OUT_LOC/month.txt
		echo $DMT_EV_DAY >> $EVENT_OUT_LOC/day.txt
		echo $DMT_EV_HOUR >> $EVENT_OUT_LOC/hour.txt
		echo $DMT_EV_MIN >> $EVENT_OUT_LOC/minute.txt
		echo $DMT_EV_SEC >> $EVENT_OUT_LOC/sec.txt
		echo $DMT_EVNRORG >> $EVENT_OUT_LOC/evnrorg.txt
		echo $DMT_EV_LAT >> $EVENT_OUT_LOC/evlat_d.txt
		echo $DMT_EV_LON >> $EVENT_OUT_LOC/evlon_d.txt
		echo $DMT_EV_DEP >> $EVENT_OUT_LOC/evdepth.txt
		echo $DMT_EV_MMW >> $EVENT_OUT_LOC/evmb.txt
		echo $DMT_EV_MS >> $EVENT_OUT_LOC/evms.txt
		echo $EVNR >> $EVENT_OUT_LOC/evnr.txt

		# Catch errors with parameter finding for event.
		Num_var_event=`awk 'END{print}' $EVENT_OUT | wc -w`
		if [[ $Num_var_event -ne 13 ]]; then
			echo "Parameter missing for event..."
			echo $region $event" - "$DMT_EV_YEAR $DMT_EV_MONTH $DMT_EV_DAY $DMT_EV_HOUR $DMT_EV_MIN $DMT_EV_SEC $DMT_EVNRORG $DMT_EV_LAT $DMT_EV_LON $DMT_EV_DEP $DMT_EV_MMW $DMT_EV_MS $EVNR >> $ERROR_FILE
		fi

		# ############# REPORT PHASE INFO ######################
		# envr evlat_d evlon_d evdepth stlat_d stlon_d sth stnr azim arc p prett d prec
		grep $event $SUMMARY_FILE > phase_details.out

		station_list=`awk '{print $1}' $event/TT_calc_results.txt | awk -F_ '{print $3}' | awk -F. '{print $1}'`
		for station in $station_list; do
			grep " "$station" " phase_details.out | awk 'NR==1' > station_details.out
			stlat_d=`awk '{print $14}' station_details.out | awk 'NR==1'`
			stlon_d=`awk '{print $15}' station_details.out | awk 'NR==1'`
			sth=`awk '{print $3*1000}' station_details.out | awk 'NR==1'` # Meters
			azim_d=`awk '{print $6}' station_details.out | awk 'NR==1'` # This was found to be $5 in previous script.
			arc_d=`awk '{print $4}' station_details.out | awk 'NR==1'`
		
			stnr=`grep -n $station $STATION_LIST | sed 's/\:/ /g' | awk '{print $1}' | awk 'NR==1'`
		
			prett=`grep $station $event/TT_calc_results.txt | awk '{print $6}' | awk 'NR==1'`
			d=`grep $station $event/TT_calc_results.txt | awk '{print $7}' | awk 'NR==1'`
			prec=`grep $station $event/auto_corr_errors2.txt | awk '{print $2}' | awk 'NR==1'`

			p=`taup_time -mod ak135 -h $DMT_EV_DEP --rayp -ph P -deg $arc_d | awk 'NR==1' | awk '{print $1}'`
		
			echo $DMT_EVNRORG $DMT_EV_LAT $DMT_EV_LON $DMT_EV_DEP $stlat_d $stlon_d $sth $stnr $azim_d $arc_d $p $prett $d $prec $EVNR
			echo " "
			echo $DMT_EVNRORG $DMT_EV_LAT $DMT_EV_LON $DMT_EV_DEP $stlat_d $stlon_d $sth $stnr $azim_d $arc_d $p $prett $d $prec $EVNR >> $PHASE_OUT

			echo $DMT_EVNRORG >> $PHASE_OUT_LOC/evnrorg.txt
			echo $DMT_EV_LAT >> $PHASE_OUT_LOC/evlat_d.txt
			echo $DMT_EV_LON >> $PHASE_OUT_LOC/evlon_d.txt
			echo $DMT_EV_DEP >> $PHASE_OUT_LOC/evdepth.txt
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
			echo $EVNR >> $PHASE_OUT_LOC/evnr.txt
			
			# Catch errors with parameter finding for phase.
			Num_var_phase=`awk 'END{print}' $PHASE_OUT | wc -w`
			if [[ $Num_var_phase -ne 15 ]]; then
				echo "Parameter missing for phase..."
				echo $region $event" - "$DMT_EVNRORG $DMT_EV_LAT $DMT_EV_LON $DMT_EV_DEP $stlat_d $stlon_d $sth $stnr $azim_d $arc_d $p $prett $d $prec $EVNR >> $ERROR_FILE
			fi
			
		done

		rm *.out
		EVNR=$((EVNR+1)) 
		
	done
	
	
	echo " "
	echo "Finished the "$region" dataset, moving on....."
	echo " "
	
	cd $home
done


echo " "
echo "Check these: "
echo " First event numbers in EVENTS:"
head -1 $home"/???_DATA/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/TXT_FILES/EVENTS/evnr.txt"
echo " "
echo " "
echo " First event numbers in PHASE:"
head -1 $home"/???_DATA/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/TXT_FILES/PHASE/evnr.txt"

echo " "
echo " Final event numbers in EVENTS:"
tail -1 $home"/???_DATA/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/TXT_FILES/EVENTS/evnr.txt"
echo " "
echo " "
echo " Final event numbers in PHASE:"
tail -1 $home"/???_DATA/P/"$SCHEME"_PROCESSED/OUTFILES/"$DATA_TRANCHE"/TXT_FILES/PHASE/evnr.txt"

grep -v -n '\S' $home/???_DATA/P/XC_PROCESSED/OUTFILES/SEP19/TXT_FILES/PHASE/*.txt
grep -v -n '\S' $home/???_DATA/P/XC_PROCESSED/OUTFILES/SEP19/TXT_FILES/EVENTS/*.txt


echo " "
echo "Check the above ^^^^^^^ : "
echo " "