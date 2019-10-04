#!/bin/sh

# C1.1
source ~/.bash_profile
mac=`echo $USER`
if [ -f bad_files.txt ]; then
	mv bad_files.txt old_bad_files.txt
fi

rm All_auto_corr_errors.txt All_d.txt Conv_vs_ISC_pick_errors.txt
rm *_event_SUMMARY.txt *_phase_SUMMARY.txt

reference_file="/Users/$mac/Dropbox/ADAPTIVE_STACKING/ISC_arrival_checks/ISC_reference_picks.txt"
# reference_file="/Users/$mac/Dropbox/ADAPTIVE_STACKING/SHARE_PACKAGE/ISC_FILES/ISC_reference_picks.txt"

# Use file "TT_calculator_ISC.sh" to convert ISC csv download to readable form:
# JWeed reference time, ISC date, ISC time, JWeed_time - ISC-time = EQ source error (can be opposite if loop is used), station, station lat, station lon, phase, absolute travel time

# Qaulity control parameters
ISC_CUTOFF=1.0
SNR_CUTOFF=0.5
XC_CUTOFF=0.25
AUTO_CUTOFF=1.0

PLOTTING=$2

# Assumed sac file format YYYMMDDHHMMSS_NETWORK_STATION.00.EHZ

# For reference sac data headers are assumed as follows.
# Predicted arrivals - T1
# Rel-Arr alignment - T0

if [ $# == 0 ];
then
	echo " NO Weighting scheme given"
	echo "USEAGE:   calc_arr_times.sh <SCHEME> <PLOTTING> <RERUN>"
	echo "EXAMPLE:  calc_arr_times.sh XC NO"
	echo "EXAMPLE:  calc_arr_times.sh NOISE YES RERUN"
	echo
	exit
fi

if [ $1 == "XC" ];
then
	WEIGHTING_SCHEME=XC
else
	if [ $1 == "NOISE" ];
	then
		WEIGHTING_SCHEME=NOISE
	else
		echo "Incorrect Weighting scheme given"
		echo "USEAGE:   calc_arr_times.sh <SCHEME> <PLOTTING> <RERUN>"
		echo "EXAMPLE:  calc_arr_times.sh XC NO"
		echo "EXAMPLE:  calc_arr_times.sh NOISE YES RERUN"
		echo
		exit
	fi
fi

# Set up the loop parameters - helps save time for re-runs after zipping bad files.

if [ $3 == "RERUN" ];
then
	# echo $3
	file_list=`awk '{print $1}' bad_events.txt`
else
	# echo "use the normal for loop"
	rm bad_events.txt
	file_list="??????????????"
	# file_list=$3
	
 fi

# C1.2

echo "Starting the loop HERE"
for event in $file_list; do


	# Move events with less than 3 files to POOR.
	f_list=`echo $event/*HZ | grep -v *HZ |  wc -w `
	if [[ $f_list -lt 3 ]]; then
		echo "Less than 3 Files present"
		cd $event
		rm stack.sac stack2.sac stack2_auto.sac
		rm *out *stk *stk2 *corr *new gmt* *.m *.s *.cut *.cut2 *.sgf *.pdf *txt
		gunzip *gz
		cd ..
		echo "Moving "$event" to ./POOR/."
		mv $event ./POOR/
		continue
	fi

echo $event
cd $event

# |_|_|_|_|_|_|_|_|_|_|_|_|_| Method using SSS |_|_|_|_|_|_|_|_|_|_|_|_|_|


# rm stack.sac stack2.sac stack2_auto.sac
# rm *out *stk *stk2 *corr *corr2 *new gmt* *.m *.s *.cut
rm Conv_stack-ISC_picks.txt SNR.txt auto_corr_errors2.txt d.txt *.ps SNR_pick_error.txt
rm *_weightings.txt TT_calc_results.txt correlation_sort2.txt XC_means2.txt



sactosac -f *.bht
saclst o t1 t4 f *.bht > orig_headers.out 
sactosac -m *.bht

# C1.3
# Prepare files before stacking
# Normalize the traces using macro normalize.m (Files *stk are overwritten)
# Calculate weighting factors used in noise assessment
# Save a phaseweighted stack
# Calculate the XC between the stack and each trace to check the alignment.
# rtr int


sac << sacend

read *.bht
cuterr fillz
cut t1 -60 60
read
synchronize

interpolate delta 0.025

taper width 0.3
chnhdr b -60
write append .stk
cut off
quit
sacend

# sac macro seem to limit number of input files so must use for-loop. Put all files in one macro to save time.
rm norm_stk.m
for file in *bht.stk; do
echo "m normalize.m "$file >> norm_stk.m
done

echo "m norm_stk.m" | sac


# C1.4
sac << sacend

read *.stk
mtw -57 -2
rms noise off to USER0
mtw 0 55
rms noise off to USER5
write append .s

read *.stk
taper
sss
cs all sum on
timewindow -60 60
sumstack type phaseweight 4 normalization on
writestack stack.sac
quitsub

m normalize.m stack.sac
quit
sacend


# C1.5
sac << sacend
read stack.sac *stk
cut -10 10
r
write append .cut
cut off
quit
sacend

rm norm_cut.m
for file in *.cut; do
echo "m normalize.m "$file >> norm_cut.m
done

echo "m norm_cut.m" | sac


/usr/local/LINUX_sac/bin/sacinit.sh << sacend

read stack.sac.cut *stk.cut
correlate master stack.sac.cut normalized number 1 length 20 type rectangle
mtw -10 10
markptp length 20 to T8
write append .corr

quit
sacend
sactosac -m *.corr

# Grab estimate for SNR for each trace
sactosac -f *.bht.stk.s
saclst user0 user5 f *.bht.stk.s > rms_pre_arrival_signal.out # filename, rms of data in noise window, rms of data in signal window
sactosac -m *.bht.stk.s
awk '{print $1, ($3/$2)}' rms_pre_arrival_signal.out | sed 's/\.bht.stk.s /.bht /g' > SNR.txt

# C1.6 moved to after C1.10.1


# C1.7
# Grab correlation coefficients between stack and traces
sactosac -f *.corr
saclst depmax t9 f *.corr | grep bht > correlation.out # filename, correlation co-efficient, XC location (correction)
sactosac -m *.corr

# Calculate mean XC co-efficient between traces and stack to compare with 2nd stack.
grep .bht correlation.out | awk '{print $2}' > XC_coefficients.out # correlation co-efficients
gmt gmtmath -S XC_coefficients.out MEAN = XC_mean.out # mean correlation co-efficient


##### Do a second RMS or XC weighted stack here to penalise the worse quality data.
# Weight a second stack using the noise or using the XC peak (and shift the traces by the offset of the XC peak i.e. a measure of trace similarity to the stack)
# Parameter set at top of script!
# C1.8
if [ $WEIGHTING_SCHEME == "NOISE" ];
then
	echo " "
	echo "DO the NOISE scheme"
	echo " "
	
	max_weighting=`sort -n -k2 -r SNR.txt | awk 'NR==1' | awk '{print $2}'`
	awk -v var=$max_weighting '{print $2/var}' SNR.txt > SNR_norm.out
	# The extra 2 is a naming convention.
	
	### ADD the weighting function here....
	# Please note this functionality was removed at review as for our application it was found to offer little improvement of the final stack.
	# We leave the funcitonality to weight the stack non-linearly in future uses if required.
	/Users/$mac/Dropbox/File_Sharing/GITHUB_AB/AARM/AARM_weight_function.sh SNR_norm.out SNR_norm_weighted.out
	paste SNR.txt SNR_norm.out SNR_norm_weighted.out > Noise_weightings.txt # filename, SNR, normalized SNR, weighted normalized SNR
	awk '{print "addstack "$1".stk2 weight "$4}' Noise_weightings.txt > addstack.m
	# Make Macro to write unique filesnames these files
	echo "read *bht; write append .new" > mk_stk2.m
	echo "read *stk; write append 2" >> mk_stk2.m # Should already be normalized from .stk
# C1.9
else
	if [ $WEIGHTING_SCHEME == "XC" ];
	then
		echo " "
		echo "Do XC scheme"
		echo " "
		############### XC correlation weighting scheme #########################

		# Generate an alternative addstack macro that will stack (all stk2 files) using the XC weighting

		max_XC=`sort -g -r -k2 correlation.out | awk 'NR==1' | awk '{print $2}'`
		awk -v var=$max_XC '{print $2/var}' correlation.out > correlation_norm.out # normalized correlation co-efficients.
		# The extra 2 is a naming convention.
		
		#### ADD the weighting function here
		# Linear weighting function as above.
		/Users/$mac/Dropbox/File_Sharing/GITHUB_AB/AARM/AARM_weight_function.sh correlation_norm.out correlation_norm_weighted.out
		paste correlation.out correlation_norm.out correlation_norm_weighted.out > correlation_weightings.txt # filename, correlation co-efficient, XC location (correction), normalized correlation co-efficient, weighted norm correlation co-efficient

		awk '{print "addstack "$1" weight "$5}' correlation_weightings.txt | sed 's/\.stk.cut.corr /.new.stk2 /g' > addstack.m 
		############### XC correlation weighting scheme #########################

		# Make small adjustments to Rel-Arr alignment based on XC peak shift from 0 - should improve the stack....
		# Don't overwrite EHZ files with new corrected stack times, save a subset with append .new in sac macro
		# Use QC parameters to check applied XC peak shift is not greater than XC_CUTOFF, else, gzip in bad_files.txt
		# Cannot force to zero as this affects error analysis.
		
		echo $XC_CUTOFF > ADJ_HIGH.out
		echo "-"$XC_CUTOFF > ADJ_LOW.out
		
		for file in *.bht; do
			grep $file correlation.out | awk '{print $3}' > adjust.out # T0 adjustment
			
			IN_ADJ_RANGE=`gmt gmtmath adjust.out ADJ_LOW.out ADJ_HIGH.out INRANGE =`
			if [[ $IN_ADJ_RANGE != 1 ]]; then
				awk -v var=$XC_CUTOFF '{print "Suggested XC peak shift: "$1" not in range +/- "var}' adjust.out
				echo " Can gzip the file "$file" ...."
				echo "gzip "$event"/"$file >> ../bad_files.txt 
			fi
			grep $file orig_headers.out | awk '{print $3}' > old_T1.out  # old T1
			gmt gmtmath old_T1.out adjust.out ADD = new_T1.out
			new_T1=`awk '{print $1}' new_T1.out`
			echo "read "$file"; chnhdr t1 "$new_T1"; write append .new" >> correct_T1.m # Paste the new T1 header into *.bht.new
			echo "m normalize.m "$file".new.stk2" >> norm_stk2.m # will individually normalize the new.stk2 files later on.
		done
		
		rm ADJ_HIGH.out ADJ_LOW.out

		# Prepare files before stacking
		# Normalize the traces using macro normalize.m (Files *stk2 are overwritten)

		echo "m correct_T1.m" > mk_stk2.m
		echo "read *bht.new" >> mk_stk2.m
		echo "cuterr fillz" >> mk_stk2.m
		echo "cut t1 -60 60" >> mk_stk2.m
		echo "read" >> mk_stk2.m
		echo "synchronize" >> mk_stk2.m
		
		echo "interpolate delta 0.025" >> mk_stk2.m
		# echo "int" >> mk_stk2.m
		echo "taper width 0.3" >> mk_stk2.m
		echo "chnhdr b -60" >> mk_stk2.m
		echo "write append .stk2" >> mk_stk2.m
		echo "cut off" >> mk_stk2.m
		echo "m norm_stk2.m" >> mk_stk2.m # This isnt going to work properly so must do it on a file-by-file basis.
	else
		echo " get out of here "
		echo " NO WEIGHTING SCHEME SET...."
		echo " NO WEIGHTING SCHEME SET...."
		echo " Exiting......"
		rm *.corr *.stk *.out
		cd ..
		exit
	fi
fi

# m addstack.m takes care of the new weighting in stack2.sac either using the shifted XC weighted stack or RMS noise weighted stack.

# Restack using RMS-noise or XC co-efficient weighting scheme
# Pick the onset on stack2.sac
# taper width 0.3

# C 1.10
sac << sacend3
m mk_stk2.m
sss
m addstack.m
cs all sum on
timewindow -60 60
sumstack type phaseweight 4 normalization on
writestack stack2.sac
quitsub

m normalize.m stack2.sac

read stack2.sac
chnhdr kstnm STK
write over
bd x
qdp off
xlim -20 20
ylim -1 1
ppk perplot 1
wh stack2.sac
read stack2.sac
mtw a -57 -2
rms noise off to USER0
mtw a 0 55
rms noise off to USER5
write over
quit
sacend3
# rm addstack.m

# C1.10.1 
#  Inlcude a little cut that removes events that have poor stacks and thus no arrival time pick

if [[ "$(sachdrinfo stack2.sac a)" == *"UNDEFINED"* ]]; then
	echo "No pick present - Move event to POOR and continue"
	rm stack.sac stack2.sac stack2_auto.sac
	rm *out *stk *stk2 *corr *new gmt* *.m *.s *.cut *.cut2 *.sgf *.pdf *txt
	cd ..
	mv $event ./POOR/
	grep -v $event bad_files.txt > bad_files.temp
	mv bad_files.temp bad_files.txt
	continue
fi

# C1.6
########### Paste all files with Low SNR into Bad files or gzip straight away! ##############
# Had to be moved to here so that events moved to POOR are not included!

while read line; do
TRACE_SNR=`echo $line | awk '{print $2}'`
# SNR_CUTOFF=0.5
if (( $(echo "$TRACE_SNR $SNR_CUTOFF" | awk '{print ($1 < $2)}') ));
then
	STAT=`echo $line | sed 's/\_/ /g' | sed 's/\./ /g' | awk '{print $3}'`
	FILE=`echo $line | awk '{print $1}'`
		
	echo " SNR estimate for station "$STAT" is less than $SNR_CUTOFF...."
	echo " Can gzip the file "$FILE"...."
	echo "Check the file SNR.txt"
	echo "gzip "$event"/"$FILE >> ../bad_files.txt # " # SNR"
	
	# OR
	# Remove all low SNR traces before stacking..... : 
	# gzip ./*$STAT*
	
fi
done<SNR.txt


# C1.11
# Calculate the XC between the stack2 and each stacked trace to check the alignment.
sac << sacend
read stack2.sac *stk2
cut -10 10
r
write append .cut2
cut off
quit
sacend

rm norm_cut2.m
for file in *.cut2; do
echo "m normalize.m "$file >> norm_cut2.m
done

echo "m norm_cut2.m" | sac


/usr/local/LINUX_sac/bin/sacinit.sh << sacend4

read stack2.sac.cut2 *stk2.cut2
correlate master stack2.sac.cut2 normalized number 1 length 20 type rectangle
mtw -10 10
markptp length 20 to T8
write append .corr2
quit
sacend4

sactosac -m *.corr2
cp stack2.sac.cut2.corr2 stack2_auto.sac

sactosac -f *.corr2
saclst depmax t9 f *.corr2 > correlation2.out  # filename, correlation co-efficient, XC location (correction)
sactosac -m *.corr2

grep .bht correlation2.out | sort -k3 -n > correlation_sort2.txt # Sorted by third column.


# C1.12
############# Check whether XC function maximum is still offset from zero -> paste to bad files ###############

while read line; do
XC_ERR=`echo $line | awk '{print $3}'`
# XC_CUTOFF=0.25
if (( $(echo "$XC_ERR $XC_CUTOFF" | awk '{print ($1 > $2)}') )) || (( $(echo "$XC_ERR -$XC_CUTOFF" | awk '{print ($1 < $2)}') ));
then
	STAT=`echo $line | sed 's/\_/ /g' | sed 's/\./ /g' | awk '{print $3}'`
	FILE=`echo $line | awk '{print $1}'`
	ORIG_FILE=`echo $FILE | sed 's/\.stk2.cut.corr2/ /g' | sed 's/\.new/ /g'` # will remove all file suffixes from either NOISE or XC regime.
		
	echo " Max correlation offset for "$STAT" is greater than $XC_CUTOFF/-$XC_CUTOFF...."
	echo " Can gzip the file "$ORIG_FILE"...."
	echo "Check the file correlation_sort2.txt"
	echo "gzip "$event"/"$ORIG_FILE >> ../bad_files.txt # " # XC_ERR"
fi
done<correlation_sort2.txt

########### Calculate parameters required for Autocorrelation errors. ################

# C1.13
list=`sort -k1 correlation_sort2.txt | sed 's/\_/ /g' | awk '{print $2}'`
# echo $list

for station in $list; do

# echo $station
corr=`grep $station correlation_sort2.txt | awk '{print $2}'`
# echo $corr
sac << sacend
read stack2_auto.sac
ch kstnm $station
markvalue GE $corr to T5
write stack2_auto_$station.sac
quit
sacend
done

sactosac -f stack2_auto_*.sac
saclst t5 f stack2_auto_*.sac >> auto_corr_errors.txt
sactosac -m stack2_auto_*.sac

awk '{print $1, $2/-1}' auto_corr_errors.txt > auto_corr_errors2.txt
rm stack2_auto_*.sac auto_corr_errors.txt

# Paste files with Autocorr errors over threshold to bad files.

while read line; do
AUTO_ERR=`echo $line | awk '{print $2}'`
# AUTO_CUTOFF=0.5
if (( $(echo "$AUTO_ERR $AUTO_CUTOFF" | awk '{print ($1 > $2)}') ));
then
	STAT=`echo $line | sed 's/\_/ /g' | sed 's/\./ /g' | awk '{print $3}'`
	FILE=`ls *bht | grep $STAT | awk 'NR==1'`
		
	echo " Autocorrelation error estimate for "$STAT" is greater than $AUTO_CUTOFF...."
	echo " Can gzip the file "$FILE"...."
	echo "Check the file auto_corr_errors2.txt"
	echo "gzip "$event"/"$FILE >> ../bad_files.txt # " # AUTO_ERR"
fi
done<auto_corr_errors2.txt

awk '{print $2}' SNR.txt > SNR.out
awk '{print $2}' auto_corr_errors2.txt > auto_corr_errors2.out

gmt gmtmath -S SNR.out MEAN = SNR_mean.out # mean SNR for event
gmt gmtmath -S auto_corr_errors2.out MEAN = error_mean.out # mean pick error for event
paste SNR_mean.out error_mean.out > SNR_pick_error.txt # mean SNR, mean pick error


# C1.14
############# Compute absolute arrival-times and residuals ################## -> should be a later process.

sactosac -f stack2.sac
saclst a f stack2.sac > correction.out  # filename, manual onset pick.
saclst user0 user5 f stack2.sac > rms_noise_signal_stack2.out # filename, noise RMS, signal RMS
sactosac -m stack2.sac

# stack signal to noise calcs.
awk -v var=$event"/" '{print var$1, ($3/$2)}' rms_noise_signal_stack2.out > stack2_SNR.txt

sactosac -f *.bht.new
saclst o t1 t4 f *.bht.new > final_headers.out # filename, omarker, mccc alignment, Predicted arrival
sactosac -m *.bht.new

# Calculate correction to subtract from T1 (Rel-Arr) - (T4 - P from ak135) - correction is already negative when Rel-Arr is after first break

TTC=`grep stack2.sac correction.out | awk '{print $2}'`
awk -v var=$TTC '{print (-1*$2)+$3+var }' final_headers.out > TT.out  # absolute (Rel-Arr derived) traveltime
awk '{print (-1*$2)+$4}' final_headers.out > ak135.out  # predicted traveltime
paste final_headers.out TT.out ak135.out > TT_calcs.out  # filename, omarker, Rel-Arr alignment, Predicted arrival, absolute (Rel-Arr derived) traveltime, absolute predicted traveltime

# Using sign convention Rel-Arr - ak135 prediction (respective travel times) When Rel-Arr is before prediction (i.e. early) it is a negative number.
awk '{print $5-$6}' TT_calcs.out > residual.out  # absolute traveltime residual
paste TT_calcs.out residual.out > TT_calc_results.txt  # filename, omarker, Rel-Arr alignment, Predicted arrival, (Rel-Arr derived) traveltime, predicted traveltime, absolute traveltime residual
awk '{print $7}'  TT_calc_results.txt > d.txt # absolute traveltime residual

# C1.15
# Checking the difference to ISC picks here

# day=`echo $event | awk '{print substr($0,1,4)"-"substr($0,5,2)"-"substr($0,7,2)}'`
# time=`echo $event | awk '{print substr($0,9,2)":"substr($0,11,2)":"substr($0,13,2)}'`
#
# grep $day $reference_file | grep $time | sed 's/\,/ /g' > ISC_picks.out
# station_list=`awk '{print $6}' ISC_picks.out | sort -u`
# echo "ISC Stations available include : "$station_list
#
# for station in $station_list; do
# 	stat_info=`grep $station ISC_picks.out | awk 'NR==1'`
# 	EQ_source_error=`echo $stat_info | awk '{print $5}'`
# 	ISC_TT=`echo $stat_info | awk '{print $10}'`
# 	if [ $EQ_source_error != "0.00" ]; then
# 		# echo "there is a problem skip this station"
# 		continue
# 	else
# 		Conv_stack_TT=`grep $station TT_calc_results.txt | awk '{print $5}'`
# 		if [ -z "$Conv_stack_TT" ]; then
# 			# echo "do nothing here"
# 			continue
# 		else
# 			echo $Conv_stack_TT" - "$ISC_TT | bc >> Conv_stack-ISC_picks.txt
# 			ISC_ERR=`echo $Conv_stack_TT" - "$ISC_TT | bc`
# 			FILE=`ls *EHZ | grep $station | awk 'NR==1'`
# 			if (( $(echo "$ISC_ERR $ISC_CUTOFF" | awk '{print ($1 > $2)}') )) || (( $(echo "$ISC_ERR -$ISC_CUTOFF" | awk '{print ($1 < $2)}') ));
# 			then
# 				echo " difference between converted pick and ISC pick for "$station" is greater than $ISC_CUTOFF/-$ISC_CUTOFF...."
# 				echo " Could reject the station "$station"...."
# 				echo " Can gzip the file "$FILE"...."
# 				echo "Check the file Conv_stack-ISC_picks.txt"
# 				echo "gzip "$event"/"$FILE >> ../bad_files.txt # " # ISC_ERR"
# 			fi
# 		fi
# 	fi
# done


######## Calculate parameters for the XC mean analysis ############### Not sure what this means......
# C1.16
sort -k1 correlation_sort2.txt | awk '{print $2}' > XC_coefficients2.out # correlation co-efficients
gmt gmtmath -S XC_coefficients2.out MEAN = XC_mean2.out # mean cross correlation co-efficients
awk '{print $NF}' *_weightings.txt > weightings.out
awk '{print $2}' SNR.txt > SNR.out
gmt gmtmath -S SNR.out MEAN = SNR_MEAN.out
SNR_MEAN=`awk '{print $1}' SNR_MEAN.out`

awk -v var=$SNR_MEAN '{print var, $1}' XC_mean2.out > XC_means2.txt # Mean SNR, mean XC co-efficient.

#############################################
# C1.17
rm *out *.stk *.stk2 *.corr *.corr2 *.new *.m gmt* *.bht.s *.bht.stk.s *.cut *.cut2

if [ $PLOTTING == "YES" ];
then
	/Users/$mac/Dropbox/File_Sharing/GITHUB_AB/AARM/AARM_Make_plots_Event.sh
else
	echo "Skipping Event plotting routine...."
fi

cd ..
done

if [ $PLOTTING == "YES" ];
then
	/Users/$mac/Dropbox/File_Sharing/GITHUB_AB/AARM/AARM_Make_plots_Dataset.sh
	# echo "yes"
else
	echo "Skipping Dataset plotting routine...."
fi

# C1.18

if [[ -s bad_files.txt ]] ; then
echo " "
echo "bad_files.txt has data."


sort -u bad_files.txt > bad_files.temp # Remove any duplication in the file.
mv bad_files.temp bad_files.txt

sed 's/\// /g' bad_files.txt | awk '{print $2}' | sort -u > bad_events.txt
echo " "
echo "Please use file bad_files.txt to zip bad files and repeat for the events below"
echo " The COMMAND : while read line; do echo line; done<bad_files.txt       should work"

more bad_events.txt
while read line; do
	echo $line
done < bad_files.txt
echo " "


else
echo " "
echo "bad_files.txt is empty - analysis complete!"
fi ;


