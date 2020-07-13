#!/bin/sh
# source ~/.bash_profile
# C4.1
mac=`pwd | sed 's/\// /g' | awk '{print $2}'`
# Dataset_name="SECAN"
Dataset_name="MAD_dataset_summary"
Title="Madagascar"

# This is the GMT Plotting script for the relative to absolute arrival time tool
# Developed by Alistair Boyce (alistair.boyce10@imperial.ac.uk)
# Last updated on 26-07-2020

# Programs required: GMT5, sactosac, sac2xy, saclst

# All 9 Output files required from calc_arr_times.sh.

# Script is set to plot results of:
# histogram of absolute arrival time residuals for dataset
# Absolute arrival time pick comparison with ISC for dataset Rel-Arr vs ISC
# SNR testing
# Trace stack XC
# Autocorrelation errors

gmt set FONT 					= Helvetica
gmt set FONT_TITLE				= 12p
gmt set FONT_LABEL				= 10p
gmt set FONT_ANNOT_PRIMARY		= 10p
gmt set FONT_ANNOT_SECONDARY	= 10p
gmt set PS_MEDIA 				= 600x1000
gmt set PS_PAGE_ORIENTATION 	= LANDSCAPE
gmt set PS_LINE_CAP 			= round
gmt set FORMAT_DATE_IN 			= yyyymmdd


PSFILE=$Dataset_name".ps"

rm $Dataset_name".ps"
# C4.2 ################## Dataset residual distribution ###########################

cat ./??????????????/d.txt > All_d.out

bin_width=0.5
y_plot_ticks="a500f100"
RANGE1="-R-6/6/0/2000"

gmt psbasemap $RANGE1 -JX9c/6c -Bpxa2f$bin_width+l"Absolute arrival-time residual" -Bpy$y_plot_ticks+l"Frequency" -BWSne+t"Absolute arrival-time residual distribution" -K > $PSFILE
gmt pshistogram All_d.out $RANGE1 -JX -W$bin_width -Z0 -F -L0.5p -P -Ggrey -O -K >> $PSFILE

# Do dataset residual distribution summary - All_d.out

THRESHOLD=3
gmt gmtmath -T All_d.out ABS $THRESHOLD LE SUM -S UPPER = prop.out # number of values less than $THRESHOLD
wc -l All_d.out | awk '{print $1}' > total.out # total number of values.
gmt gmtmath prop.out total.out DIV 100 MUL = perc.out # Precentage less than 0.5

TOTAL=`awk '{print $1}' total.out`
PERC=`awk '{printf "%2.3f\n", $1}' perc.out`
# echo "Percentage of "$TOTAL" absolute PICKS <"$THRESHOLD"s is "$PERC

gmt gmtmath -S All_d.out MEAN = mean.out
gmt gmtmath -S All_d.out STD = sd.out
mean=`awk '{printf "%2.3f\n", $1}' mean.out`
sd=`awk '{printf "%2.3f\n", $1}' sd.out`

echo "-4.5 1800 mean = "$mean > stats.out
echo "-4.5 1600 s.d. =  "$sd >> stats.out
echo "-4.5 1400 "$TOTAL" traces" >> stats.out
echo "-4.5 1200 "$PERC"% < +/-"$THRESHOLD"s" >> stats.out

gmt pstext stats.out -JX $RANGE1 -F+f8,Helvetica,black,bold+jLB -N -O -K >> $PSFILE

echo "D" | gmt pstext -J -R -O -K -Gwhite -N -W1 -C0.1 -D-0.2/0.2 -F+f10,Helvetica,black+jRB+cRB >> $PSFILE

rm prop.out total.out perc.out mean.out stats.out sd.out

# C4.3 ################## Autocorrelation error estimates ###########################

cat ./??????????????/auto_corr_errors2.txt | awk '{print $2}' > All_auto_corr_errors.out

bin_width=0.05
y_plot_ticks="a1000f100"
RANGE2="-R-0/0.5/0/4000"

# Do dataset autocorrelation pick error estimate distribution - All_auto_corr_errors.out

THRESHOLD=0.15
gmt gmtmath -T All_auto_corr_errors.out ABS $THRESHOLD LE SUM -S UPPER = prop.out # number of values less than $THRESHOLD
wc -l All_auto_corr_errors.out | awk '{print $1}' > total.out # total number of values.
gmt gmtmath prop.out total.out DIV 100 MUL = perc.out # Precentage less than 0.5

TOTAL=`awk '{print $1}' total.out`
PERC=`awk '{printf "%2.3f\n", $1}' perc.out`
# echo "Percentage of "$TOTAL" picks with errors <"$THRESHOLD"s is "$PERC


gmt psbasemap $RANGE2 -JX9c/6c -Y10c -Bpxa0.25f$bin_width+l"Pick error estimate" -Bpy$y_plot_ticks+l"Frequency" -BWSne+t"Autocorrelation error estimate" -K -O >> $PSFILE
gmt pshistogram All_auto_corr_errors.out $RANGE2 -JX -W$bin_width -Z0 -F -L0.5p -P -Ggrey -O -K >> $PSFILE

gmt gmtmath -S All_auto_corr_errors.out MEAN = mean.out
gmt gmtmath -S All_auto_corr_errors.out STD = sd.out
mean=`awk '{printf "%2.3f\n", $1}' mean.out`
sd=`awk '{printf "%2.3f\n", $1}' sd.out`

echo "0.35 3600 mean = "$mean > stats.out
echo "0.35 3200 s.d. =  "$sd >> stats.out
echo "0.35 2800 "$PERC"% < +/-"$THRESHOLD"s" >> stats.out
gmt pstext stats.out -JX $RANGE2 -F+f8,Helvetica,black,bold+jLB -N -O -K >> $PSFILE

echo "A" | gmt pstext -J -R -O -K -Gwhite -N -W1 -C0.1 -D-0.2/0.2 -F+f10,Helvetica,black+jRB+cRB >> $PSFILE

rm prop.out total.out perc.out mean.out stats.out sd.out



# C4.5 ######################### Average Autocorrelation pick error vs SNR ############################

cat ./??????????????/SNR_pick_error.txt > SNR_pick_error_all.out

RANGE4="-R1/1000/0/0.5"
gmt psbasemap $RANGE4 -JX9cl/6c -X11.5c -Bpxa2f1+l"Mean trace SNR" -Bpya0.5f0.1+l"Mean Pick error" -BWeSn+t"Mean Autocorrelation pick error vs SNR" -K -O >> $PSFILE
gmt psxy SNR_pick_error_all.out $RANGE4 -JX -Sc0.3c -W1 -Ggrey -O -K >> $PSFILE

echo "B" | gmt pstext -J -R -O -K -Gwhite -N -W1 -C0.1 -D-0.2/0.2 -F+f10,Helvetica,black+jRB+cRB >> $PSFILE


# C4.6 ######################### TRACE - STACK XC vs SNR ############################

cat ./??????????????/XC_means2.txt > XC_means2_all.out

RANGE5="-R1/1000/0/1"
gmt psbasemap $RANGE5 -JX9cl/6c -Y-10c  -Bpxa2f1+l"Mean trace SNR" -Bpya0.5f0.1+l"Mean Trace XC with stack" -BWeSn+t"Trace-stack cross-correlation vs SNR" -K -O >> $PSFILE
gmt psxy XC_means2_all.out $RANGE5 -JX -Sc0.3c -W1 -Ggrey -O -K >> $PSFILE

echo "E" | gmt pstext -J -R -O -K -Gwhite -N -W1 -C0.1 -D-0.2/0.2 -F+f10,Helvetica,black+jRB+cRB >> $PSFILE


# C4.7 ######################### STACK2 SNR vs Ave trace SNR ############################

cat ./??????????????/stack2_SNR.txt | awk '{print $2}' > stack_SNR.out
awk '{print $1}' SNR_pick_error_all.out > ave_trace_SNR.out
paste ave_trace_SNR.out stack_SNR.out > stack_v_trace.out

RANGE6="-R1/1000/5/500000"
gmt psbasemap $RANGE6 -JX9cl/6cl -X11.5c -Y10c -Bpxa2f1+l"Mean trace SNR" -Bpya2f1+l"Stack SNR" -BWeSn+t"Stack vs average trace SNR" -K -O >> $PSFILE
gmt psxy stack_v_trace.out $RANGE6 -JX -Sc0.3c -W1 -Ggrey -O -K >> $PSFILE

gmt psxy <<END $RANGE6 -JX -W2 -Wblack -O -K >> $PSFILE
5 5
10 10
50 50
100 100
500 500
1000 1000 
END

echo "C" | gmt pstext -J -R -O -K -Gwhite -N -W1 -C0.1 -D-0.2/0.2 -F+f10,Helvetica,black+jRB+cRB >> $PSFILE


# C4.4 ####################### Rel-Arr conversion vs ISC Pick comparison

cat ./??????????????/Conv*picks.txt > Conv_vs_ISC_pick_errors.out

if [ -s Conv_vs_ISC_pick_errors.out ]; 
then
	bin_width=0.25
	y_plot_ticks="a100f50"
	RANGE3="-R-2/2/0/200"
	gmt psbasemap $RANGE3 -JX9c/6c -Y-10c -Bpxa1f$bin_width+l"Rel-Abs conversion pick vs ISC pick (s)" -Bpy$y_plot_ticks+l"Frequency" -BWSne+t"Rel-Abs conversion pick vs ISC pick" -K -O >> $PSFILE

	echo "Conv_vs_ISC_pick_errors.out has data."

	THRESHOLD=0.5
	gmt gmtmath -T Conv_vs_ISC_pick_errors.out ABS $THRESHOLD LE SUM -S UPPER = prop.out # number of values less than $THRESHOLD
	gmt gmtmath prop.out total.out DIV 100 MUL = perc.out # Precentage less than 0.5

	TOTAL=`awk '{print $1}' total.out`
	PERC=`awk '{printf "%2.3f\n", $1}' perc.out`
	# echo "Percentage of "$TOTAL" ISC PICKS with difference of <"$THRESHOLD"s is "$PERC

	gmt pshistogram Conv_vs_ISC_pick_errors.out $RANGE3 -JX -W$bin_width -Z0 -F -L0.5p -P -Ggrey -O -K >> $PSFILE


	gmt gmtmath -S Conv_vs_ISC_pick_errors.out MEAN = mean.out
	gmt gmtmath -S Conv_vs_ISC_pick_errors.out STD = sd.out
	mean=`awk '{printf "%2.3f\n", $1}' mean.out`
	sd=`awk '{printf "%2.3f\n", $1}' sd.out`

	echo "-1.8 180 mean = "$mean > stats.out
	echo "-1.8 160 s.d. =  "$sd >> stats.out
	echo "-1.8 140 "$TOTAL" ISC picks" >> stats.out
	echo "-1.8 120 "$PERC"% < +/-"$THRESHOLD"s" >> stats.out

	gmt pstext stats.out -JX $RANGE3 -F+f8,Helvetica,black,bold+jLB -N -O -K >> $PSFILE

	rm prop.out total.out perc.out mean.out stats.out sd.out

fi


# C4.8 ######################### Compute some statistics ##########################

cat ./??????????????/SNR.txt | awk '{print $2}' > All_SNR.out

THRESHOLD=1
gmt gmtmath -T All_SNR.out ABS $THRESHOLD LE SUM -S UPPER = prop.out # number of values less than $THRESHOLD
wc -l All_SNR.out | awk '{print $1}' > total.out # total number of values.
gmt gmtmath prop.out total.out DIV 100 MUL = perc.out # Precentage less than 0.5

TOTAL=`awk '{print $1}' total.out`
PERC=`awk '{printf "%2.3f\n", $1}' perc.out`
echo "Percentage of "$TOTAL" traces with SNR of <"$THRESHOLD" is "$PERC

rm prop.out total.out perc.out


######################### PLOT TITLE ####################

echo "0.0 0.0 "$Title > title.out
gmt pstext title.out $RANGE1 -Yf20.5 -Xf14 -JX9c/6c -F+f14,Helvetica,black,bold+jCB -N -O >> $PSFILE

ps2pdf $PSFILE
rm *out gmt* *ps

# gs $Dataset_name".pdf"
open $Dataset_name".pdf"