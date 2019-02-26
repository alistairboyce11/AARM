#!/bin/sh

# C2.1
# source ~/.profile
# mac=`pwd | sed 's/\// /g' | awk '{print $2}'`
event=`pwd | sed 's/\// /g' | awk '{print $NF}'`

# max_XC=`sort -g -r -k2 *_sort2.txt | grep EHZ | awk 'NR==1' | awk '{print $2}'`
# awk -v var=$max_XC '{print $1, $2/var}' *_sort2.txt | grep EHZ > correlation_norm.out # filename, normalized weighting factors.
# # The extra 2 is a naming convention.
#
# awk '{print $2}' correlation_norm.out > norm_correlation.out

if [ "$#" -lt 2 ]; then
	echo " Must give normalized input file, output file, plotting instruction"
	echo "USEAGE:   weight_function.sh <INPUT FILE> <OUTPUT FILE> "
	echo "EXAMPLE:  weight_function.sh norm_correlation.out weighting.out "
	echo
	exit
fi


INFILE=$1
OUTFILE=$2
echo "Applying weighting function to normalized file : "$INFILE
echo "Output file is : "$OUTFILE
################# PICK WEIGHTING FUNCTION #########
# C2.2
FUNC_NUM=1 # Default is 1

if [ $FUNC_NUM == 1 ]; then
	paste $INFILE > $OUTFILE # y = x This is the Default
elif [ $FUNC_NUM == 2 ]; then
	gmt gmtmath $INFILE PI MUL PI 2 DIV SUB SIN 1 ADD 2 DIV = $OUTFILE # y2 = (sin((pi*x)-pi/2)+1)/2;
elif [ $FUNC_NUM == 3 ]; then
	gmt gmtmath $INFILE LOG 2 POW NEG 0.5 MUL EXP = $OUTFILE # y3 = exp(-0.5*log(x).^2);
elif [ $FUNC_NUM == 4 ]; then
	gmt gmtmath $INFILE LOG 2 POW NEG EXP = $OUTFILE # y4 = exp(-log(x).^2);
elif [ $FUNC_NUM == 5 ]; then
	gmt gmtmath $INFILE LOG 2 POW NEG 2 MUL EXP = $OUTFILE # y5 = exp(-2*log(x).^2);
elif [ $FUNC_NUM == 6 ]; then
	gmt gmtmath $INFILE LOG 3 POW 0.5 MUL EXP = $OUTFILE # y6 = exp(0.5*log(x).^3);
elif [ $FUNC_NUM == 7 ]; then
	gmt gmtmath $INFILE LOG 3 POW EXP = $OUTFILE # y7 = exp((log(x)).^3); 
elif [ $FUNC_NUM == 8 ]; then
	gmt gmtmath $INFILE LOG 3 POW 2 MUL EXP = $OUTFILE # y8 = exp(2*log(x).^3);
elif [ $FUNC_NUM == 9 ]; then
	gmt gmtmath $INFILE 1 SUB 4 POW NEG 1 ADD = $OUTFILE # y9 = -((x-1).^4)+1;
fi



