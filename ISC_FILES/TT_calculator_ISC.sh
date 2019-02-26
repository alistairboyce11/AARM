#!/bin/sh
source ~/.bash_profile
mac=`pwd | sed 's/\// /g' | awk '{print $2}'`

rm ISC_reference_picks.txt *out

while read JWEED_line; do
	
	# JWEED_line="xxxxx,2012-05-20 02:03:52.0000,44.89,11.23,6.3,xxxx,yyyyy,MW,6.0,"
	# echo $JWEED_line | sed 's/\,/ /g'
	echo "Looking for event : "$JWEED_line

	JWEED_date_time=`echo $JWEED_line | sed 's/\,/ /g' | awk '{print $2","$3}' | sed 's/\./ /g' | sed 's/\:/ /g'| awk '{print $1":"$2}'`

	grep $JWEED_date_time ISC_picks_2007-2014.txt > ISC_picks.out

	JWEED_ref_time=`echo $JWEED_line | sed 's/\,/ /g' | awk '{print $2","$3}'`

	JW_year=`echo $JWEED_ref_time | sed 's/\-/ /g' | awk '{print $1}'`
	JW_month=`echo $JWEED_ref_time | sed 's/\-/ /g' | awk '{print $2}'`
	JW_day=`echo $JWEED_ref_time | sed 's/\-/ /g' | sed 's/\,/ /g' | awk '{print $3}'`

	JW_hour=`echo $JWEED_ref_time | sed 's/\-/ /g' | sed 's/\,/ /g' | sed 's/\:/ /g' | awk '{print $4}'`
	JW_min=`echo $JWEED_ref_time | sed 's/\-/ /g' | sed 's/\,/ /g' | sed 's/\:/ /g' | awk '{print $5}'`
	JW_sec=`echo $JWEED_ref_time | sed 's/\-/ /g' | sed 's/\,/ /g' | sed 's/\:/ /g' | sed 's/\./ /g' | awk '{print $6}'`
	JW_msec=`echo $JWEED_ref_time | sed 's/\-/ /g' | sed 's/\,/ /g' | sed 's/\:/ /g' | sed 's/\./ /g' | awk '{printf $7"00"}'`

	num_ISC_picks=`wc -l ISC_picks.out | awk '{print $1}'`


	if [ $num_ISC_picks == 0 ];
	then
		dummy=1
		continue
	else


		echo "Stations available are: "
		awk -F"," '{print $3}' ISC_picks.out
		echo " "

		while read line; do
			# echo $line
			# rm *out




			station=`echo $line | awk -F',' '{print $3}'`
			stla=`echo $line | awk -F',' '{print $4}'`
			stlo=`echo $line | awk -F',' '{print $5}'`
			stel=`echo $line | awk -F',' '{print $6}'`
			dist=`echo $line | awk -F',' '{print $8}'`
			iscphase=`echo $line | awk -F',' '{print $10}'`
			st_arr_date=`echo $line | awk -F',' '{print $12}'`
			st_arr_time=`echo $line | awk -F',' '{print $13}'`
			ev_date=`echo $line | awk -F',' '{print $19}'`
			ev_time=`echo $line | awk -F',' '{print $20}'`
			evla=`echo $line | awk -F',' '{print $21}'`
			evlo=`echo $line | awk -F',' '{print $22}'`
			evdp=`echo $line | awk -F',' '{print $23}'`
			
			# echo $station $stla $stlo $stel $dist $iscphase $st_arr_date $st_arr_time $ev_date $ev_time $evla $evlo $evdp

			# Add Station time to Event time

			ev_year=`echo $ev_date | sed 's/\-/ /g' | awk '{print $1}'`
			ev_month=`echo $ev_date | sed 's/\-/ /g' | awk '{print $2}'`
			ev_day=`echo $ev_date | sed 's/\-/ /g' | awk '{print $3}'`

			ev_hour=`echo $ev_time | sed 's/\:/ /g' | awk '{print $1}'`
			ev_min=`echo $ev_time | sed 's/\:/ /g' | awk '{print $2}'`
			ev_sec=`echo $ev_time | sed 's/\:/ /g' | sed 's/\./ /g' | awk '{print $3}'`
			ev_msec=`echo $ev_time | sed 's/\:/ /g' | sed 's/\./ /g' | awk '{printf $4"0000"}'`

			st_year=`echo $st_arr_date | sed 's/\-/ /g' | awk '{print $1}'`
			st_month=`echo $st_arr_date | sed 's/\-/ /g' | awk '{print $2}'`
			st_day=`echo $st_arr_date | sed 's/\-/ /g' | awk '{print $3}'`

			st_hour=`echo $st_arr_time | sed 's/\:/ /g' | awk '{print $1}'`
			st_min=`echo $st_arr_time | sed 's/\:/ /g' | awk '{print $2}'`
			st_sec=`echo $st_arr_time | sed 's/\:/ /g' | sed 's/\./ /g' | awk '{print $3}'`
			st_msec=`echo $st_arr_time | sed 's/\:/ /g' | sed 's/\./ /g' | awk '{printf $4"0000"}'`

			# Use python to calculate time difference.
			rm time_diff.out
			python ./time_diff.py $ev_year $ev_month $ev_day $ev_hour $ev_min $ev_sec $ev_msec $st_year $st_month $st_day $st_hour $st_min $st_sec $st_msec

			TT_time=`awk '{print $1}' time_diff.out`
			# echo $TT_time

			TT_time_hours=`echo $TT_time | sed 's/\:/ /g' | awk '{print $1}'`
			TT_time_min=`echo $TT_time | sed 's/\:/ /g' | awk '{print $2}'`
			TT_time_sec=`echo $TT_time | sed 's/\:/ /g' | sed 's/\./ /g' | awk '{print $3}'`
			TT_time_msec=`echo $TT_time | sed 's/\:/ /g' | sed 's/\./ /g' | awk '{print $4}'`
			TT_time_total=`echo $TT_time_hours" * 3600 + "$TT_time_min" * 60 + "$TT_time_sec" + 0."$TT_time_msec | bc | awk '{printf "%.2f\n", $0}'`

			# echo "Travel time at station "$station" for phase "$iscphase" is "$TT_time_total

			rm time_diff.out
			# Source timing errors travel time errors - have to have the thw right way round or ewsle you get -1day errors so run if loop to switch if necessary
			# echo $ev_year $ev_month $ev_day $ev_hour $ev_min $ev_sec $ev_msec $JW_year $JW_month $JW_day $JW_hour $JW_min $JW_sec $JW_msec
			python ./time_diff.py $ev_year $ev_month $ev_day $ev_hour $ev_min $ev_sec $ev_msec $JW_year $JW_month $JW_day $JW_hour $JW_min $JW_sec $JW_msec
			mv time_diff.out source_time_error.out
			EQ_time_error=`awk '{print $1}' source_time_error.out`
			# echo $EQ_time_error
			
			if [ $EQ_time_error == "-1" ]; 
			then
				python ./time_diff.py $JW_year $JW_month $JW_day $JW_hour $JW_min $JW_sec $JW_msec $ev_year $ev_month $ev_day $ev_hour $ev_min $ev_sec $ev_msec
				mv time_diff.out source_time_error.out
				EQ_time_error=`awk '{print $1}' source_time_error.out`
				# echo $EQ_time_error
			fi
			

			EQ_time_error_hours=`echo $EQ_time_error | sed 's/\:/ /g' | awk '{print $1}'`
			EQ_time_error_min=`echo $EQ_time_error | sed 's/\:/ /g' | awk '{print $2}'`
			EQ_time_error_sec=`echo $EQ_time_error | sed 's/\:/ /g' | sed 's/\./ /g' | awk '{print $3}'`
			EQ_time_error_msec=`echo $EQ_time_error | sed 's/\:/ /g' | sed 's/\./ /g' | awk '{print $4}'`
			EQ_time_error_total=`echo $EQ_time_error_hours" * 3600 + "$EQ_time_error_min" * 60 + "$EQ_time_error_sec" + 0."$EQ_time_error_msec | bc | awk '{printf "%.2f\n", $0}'`
			
			
			
			# JWeed reference time, ISC date, ISC time, JWeed_time - ISC-time = EQ source error (can be opposite if loop is used), station, station lat, station lon, phase, absolute travel time
			echo $JWEED_ref_time", "$ev_date", "$ev_time", "$EQ_time_error_total", "$station", "$stla", "$stlo", "$iscphase", "$TT_time_total >> ISC_reference_picks.txt
			# echo " "


		done<ISC_picks.out
	fi

	echo " "
	rm *out
done<correct_evts_304.txt


rm *out


# line=`awk 'NR==1244' ISC_picks_2007-2014.txt`
