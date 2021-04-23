#!/bin/sh
# C3.1
# source ~/.bash_profile
mac=`pwd | sed 's/\// /g' | awk '{print $2}'`

# This is the GMT Plotting script for the relative to absolute arrival time tool
# Developed by Alistair Boyce (alistair.boyce10@imperial.ac.uk)
# Last updated on 06-01-2017

# Programs required: GMT5, sactosac, sac2xy, saclst

# All 9 Output files required from calc_arr_times.sh.

# Script is set to plot results of:
# weighting mapping function
# stack1 and stack2 with pick marker
# histogram of absolute arrival time residuals
# Absolute arrival time resiudals v.s. Great circle arc
# Absolute arrival time pick comparison with ISC

gmt set FONT 					= Helvetica
gmt set FONT_TITLE				= 12p
gmt set FONT_LABEL				= 10p
gmt set FONT_ANNOT_PRIMARY		= 10p
gmt set FONT_ANNOT_SECONDARY	= 10p
gmt set PS_MEDIA 				= 1000x600
gmt set PS_PAGE_ORIENTATION 	= LANDSCAPE
gmt set PS_LINE_CAP 			= round

event=`pwd | sed 's/\// /g' | awk '{print $NF}'`
# TO BE UPDATED TO NOT SAY ADAPTIVE STACKING!

PSFILE="AARM_"$event".ps"

# C3.2 ################# For weighting function: ##################

RANGE1="-R0/1/0/1"
awk '{print $(NF-1), $NF}' *_weightings.txt > weighting_function.out

THRESHOLD=0.6

echo "0.0 "$THRESHOLD > thres_line.out
echo "1.0 "$THRESHOLD >> thres_line.out
awk '{print $NF}' *_weightings.txt > weights.out

gmt gmtmath -T weights.out ABS $THRESHOLD GE SUM -S UPPER = prop.out # number of values less than $THRESHOLD
wc -l weights.out | awk '{print $1}' > total.out # total number of values.
gmt gmtmath prop.out total.out DIV 100 MUL = perc.out # Precentage less than 0.5

TOTAL=`awk '{print $1}' total.out`
PERC=`awk '{printf "%2.3f\n", $1}' perc.out`
# echo "Percentage of "$TOTAL" traces with weighting >"$THRESHOLD" is "$PERC


echo "0.55 0.65 HIGH stack contribution" > label.out
echo "0.05 0.65 "$PERC"% traces" >> label.out
echo "0.7 0.05 "$TOTAL" total traces" >> label.out

gmt psbasemap $RANGE1 -JX9c/6c -Bpxa0.2f0.1+l"Input normalized points" -Bpya0.2f0.1+l"Output weighting" -BWSne+t"Weightings mapping" -K -P > $PSFILE
gmt psxy weighting_function.out $RANGE1 -JX -Sc0.3c -Gblue -W1 -O -K >> $PSFILE
gmt psxy thres_line.out $RANGE1 -JX -Wthin,- -O -K >> $PSFILE
gmt pstext label.out $RANGE1 -JX -F+f10,Helvetica,black,bold+jLB -N -O -K >> $PSFILE
rm *out

# C3.3 ################## For plot of stacks ########################

sactosac -f stack*.sac
saclst a f stack2.sac > pick_time.out
amarker=`grep stack2.sac pick_time.out | awk '{print $2}'`
# Generate XY files
sac2xy stack.sac stack.xy
sac2xy stack2.sac stack2.xy
sactosac -m stack*.sac
STK_SNR=`awk '{printf "%2.3f\n", $2}' stack2_SNR.txt`

RANGE2="-R-10/10/-1/1"
echo $amarker "1" > pick_corr.out
echo $amarker "-1" >> pick_corr.out
echo $amarker "-0.9" "Tcorr" > label.out
echo "-5 0.8 stack.sac - blue" >> label.out
echo "-5 0.6 stack2.sac - red" >> label.out
echo "-5 0.4 SNR = "$STK_SNR >> label.out


# Plot stacks and picked arrival mark
gmt psbasemap $RANGE2 -Y10c -JX9c/6c -Bpxa2f1+l"Time (s)" -Bpya0.5f0.1+l"Normalized ampl." -BWSne+t"Stacked traces" -K -O >> $PSFILE

gmt psxy stack.xy $RANGE2 -JX9c/6c -Wthin,blue -K -O -N >> $PSFILE
gmt psxy stack2.xy $RANGE2 -JX -Wthin,red -K -O -N >> $PSFILE
gmt psxy pick_corr.out $RANGE2 -JX -Wthin,black -N -O -K >> $PSFILE
gmt pstext label.out $RANGE2 -JX -X-0.5 -F+f10,Helvetica,black,bold+jCB -N -O -K >> $PSFILE

rm pick_time.out pick_corr.out label.out stack.xy stack2.xy

# C3.4 ################### Residual Histogram ###############

gmt gmtmath -S d.txt UPPER CEIL = MAX.out
high=`awk '{print $1}' MAX.out`
gmt gmtmath -S d.txt LOWER FLOOR = MIN.out
low=`awk '{print $1}' MIN.out`
gmt gmtmath MAX.out MIN.out SUB 10 DIV = BW.out
bin_width=`awk '{print $1}' BW.out`

wc -l d.txt | awk '{print $1}' > sample_size.out
gmt gmtmath sample_size.out 10 DIV CEIL 10 MUL = ylim.out
ylim=`awk '{print $1}' ylim.out`
y_plot_ticks1=`awk '{print $1/5}' ylim.out`
y_plot_ticks2=`awk '{print $1/10}' ylim.out`
y_plot_ticks=`echo "a"$y_plot_ticks1"f"$y_plot_ticks2`
RANGE3="-R$low/$high/0/$ylim"

gmt psbasemap $RANGE3 -X11.5c -JX9c/6c -Bpxa1f$bin_width+l"Residual (s)" -Bpy$y_plot_ticks+l"Frequency" -BWSne+t"Residual Histogram" -K -O >> $PSFILE
gmt pshistogram d.txt $RANGE3 -JX9c/6c -W$bin_width -Z0 -F -L0.5p -Ggrey -O -K >> $PSFILE

rm MAX.out MIN.out BW.out sample_size.out ylim.out

# C3.5 ################### Plot of Residual with Great circle arc ###############
CPT_1=CPT_1.cpt

list=`ls *.?HZ | sed 's/\_/ /g' | sed 's/\./ /g' | awk '{print $2"_"$3"."$4}'`

sactosac -f *HZ
saclst gcarc f *HZ > gcarc_headers.out
sactosac -m *HZ

for stat in $list; do
# KSTNM, GCARC
grep $stat gcarc_headers.out | awk '{print var, $2}' var=$stat >> gcarc.out
grep $stat TT_calc_results.txt | awk '{print $7}' >> d.out
done

# KSTNM, GCARC, absolute residual
paste gcarc.out d.out > gcarc_res.out
awk '{print $2,$3,$3}' gcarc_res.out > points.out

RANGE4=`gmt info points.out -I2/1`
MAX=`echo $RANGE4 | sed 's/\// /g' | awk '{print $4}'`
MIN=`echo $RANGE4 | sed 's/\// /g' | awk '{print $3}'`
MAX_P_1=`echo $MAX+0.7 | bc`
MAX_P_2=`echo $MAX+1.3 | bc`
MIN_P_1=`echo $MIN+0.2 | bc`

gmt makecpt -Z -Cseis -T$MIN/$MAX/0.01 -I > $CPT_1

awk '{print $2,VAR,$1}' VAR=$MIN_P_1 gcarc.out > station.id
awk '{print $1, $2-0.1}' station.id > stat_tri.out

gmt psbasemap $RANGE4 -Y-10c -JX9c/6c -Bpxa5f1+l"Epicentral Distance (deg)" -Bpya1f0.5+l"Absolute Arrival-Time Residual (s)" -BWSen+t"Abs-Arr-Residuals" -K -O >> $PSFILE
gmt psscale -C$CPT_1 -D9/5+jML+w2c/0.3c+e -Ba1f0.5g0.5::/:+/-s: -O -K  >> $PSFILE
# -D0/0+MC+w0.3c/2c+e
# -D9/+5/2c/0.3c -E
gmt psxy points.out $RANGE4 -JX -Sc0.3c -C$CPT_1 -W1 -K -O >> $PSFILE
gmt pstext station.id $RANGE4 -JX -D0.1 -N -K -O -F+a-45+f10,Helvetica,black,bold+jRB >> $PSFILE
gmt psxy stat_tri.out $RANGE4 -JX -Si0.3c -Gred -W1 -K -O >> $PSFILE

rm gcarc.out gcarc_headers.out CPT_1.cpt d.out gcarc_res.out points.out station.id stat_tri.out

# C3.6 ################################ Autocorrelation errors #####################

errors_est=`awk '{print $2}' auto_corr_errors2.txt`
awk '{print $2}' auto_corr_errors2.txt > errors_est.out

gmt gmtmath -S errors_est.out UPPER CEIL = MAX.out
high=`awk '{print $1}' MAX.out`
gmt gmtmath -S errors_est.out LOWER FLOOR = MIN.out
low=`awk '{print $1}' MIN.out`
gmt gmtmath MAX.out MIN.out SUB 20 DIV = BW.out
bin_width=`awk '{print $1}' BW.out`

RANGE5="-R$low/$high/0/$ylim"

gmt psbasemap $RANGE5 -X11.5c -Y10c -JX9c/6c -Bpxa0.2f$bin_width+l"Pick error estimate" -Bpy$y_plot_ticks+l"Frequency" -BWSne+t"Autocorrelation Pick error estimate" -K -O >> $PSFILE
gmt pshistogram errors_est.out $RANGE5 -JX -W$bin_width -Z0 -F -L0.5p -Ggrey -K -O >> $PSFILE

rm errors_est.out MAX.out MIN.out BW.out 

# C3.7 ################### ISC pick differential ###############

ISC_FILE="Conv_stack-ISC_picks.txt"

if [ -f $ISC_FILE ]; 
then
	echo "File '$ISC_FILE' Exists"

	gmt gmtmath -S Conv_stack-ISC_picks.txt UPPER CEIL = MAX.out
	high=`awk '{print $1}' MAX.out`
	gmt gmtmath -S Conv_stack-ISC_picks.txt LOWER FLOOR = MIN.out
	low=`awk '{print $1}' MIN.out`
	gmt gmtmath MAX.out MIN.out SUB 20 DIV = BW.out
	bin_width=`awk '{print $1}' BW.out`
	
	sample_size=`wc -l Conv_stack-ISC_picks.txt | awk '{print $1}'`
	y_plot_ticks1=`wc -l Conv_stack-ISC_picks.txt | awk '{print $1/5}'`
	y_plot_ticks2=`wc -l Conv_stack-ISC_picks.txt | awk '{print $1/10}'`
	yscale=`echo "a"$y_plot_ticks1"f"$y_plot_ticks2`
	RANGE6="-R$low/$high/0/$sample_size"
	
	gmt psbasemap $RANGE6 -Y-10c -JX9c/6c -Bpxa1f$bin_width+l"Residual (s)" -Bpy$yscale+l"Frequency" -BWSne+t"ISC Pick differential" -K -O >> $PSFILE
	gmt pshistogram Conv_stack-ISC_picks.txt -JX $RANGE6 -W$bin_width -F -Z0 -L0.5p -Ggrey -K -O >> $PSFILE

	rm MAX.out MIN.out BW.out
	######################### PLOT TITLE ####################

	echo "-0.8 2.9 EVENT "$event" SUMMARY" > title.out
	gmt pstext title.out $RANGE1 -JX9c/6c -F+f14,Helvetica,black,bold+jCB -N -O >> $PSFILE
	rm title.out gmt*
	
else
	echo "The File '$ISC_FILE' Does Not Exist - Skipping this plot"
	######################### PLOT TITLE ####################

	echo "-0.8 1.25 EVENT "$event" SUMMARY" > title.out
	gmt pstext title.out $RANGE1 -JX9c/6c -F+f14,Helvetica,black,bold+jCB -N -O >> $PSFILE
	rm title.out gmt*
fi

gmt psconvert -Tf $PSFILE
rm *out gmt* *ps

# gs "AARM_"$event".pdf"
# open "AARM_"$event".pdf"
