#!/bin/bash

# open file with paths to HiC-Pro and BART3d
# We can add other programs for more functionality or visualizations


bartout=bart3d_output

sub_help(){
	echo ""
	echo "Usage: computational pipeline for analyzing tumor Hi-C data incorporating existing and novel computational methods (HiC-Pro and BART3D) to predict putative oncogenic transcriptional regulators"
	echo "This tool requires HiC-Pro 3.0.0 and BART3D"
	echo ""
	echo -e "usage: hic3d -T TREATMENT -C CONTROL -t TREATMENT OUTPUT -c CONTROL OUTPUT -F TREATMENT CONFIG FILE -f CONTROL CONFIG FILE -s SPECIES [-b] [-h]"
	echo ""
	echo "OPTIONS INPUTS"
	echo ""
	echo "  -T|--treatment TREATMENT INPUT : input data folder; Must contain a folder per sample with input files"
	echo "  -C|--control  CONTROL INPUT : input data folder; Must contain a folder per sample with input files"
	echo "  -t|--tout TREATMENT OUTPUT : output folder for treatment results"
	echo "  -c|--cout CONTROL OUTPUT : output folder for control results"
	echo "  -F|--tconfig TREATMENT CONFIG FILE : configuration file for HiC-Pro for treatment files"
	echo "  -f|--cconfig CONTROL CONFIG FILE : configuration file for HiC-Pro for control files"
	echo "  -s|--species SPECIES : specify species for BART3D. Please choose from  hg38 or mm10"
	echo "  [-b|--bout]: BART3D output folder. Default bart3d_output"
	echo "  [-h|--help]: help"
	echo ""	
	exit
}

if [ $# -lt 1 ]; then
	sub_help
fi

for arg in "$@"; do
    shift
    case "$arg" in
        "--treatment") set -- "$@" "-T" ;;
        "--control") set -- "$@" "-C" ;;
        "--tout") set -- "$@" "-t" ;;
        "--cout") set -- "$@" "-c" ;;
        "--tconfig") set -- "$@" "-F" ;;
        "--cconfig") set -- "$@" "-f" ;;
        "--species") set -- "$@" "-s" ;;
        "--help") set -- "$@" "-h" ;;
        "--bout") set -- "$@" "-b" ;;
        *) set -- "$@" "$arg"
    esac
done

while getopts ":T:C:t:c:F:f:s:b:h" flag
do 
	case "${flag}" in
		T) treatmentdir=${OPTARG};;
		C) controldir=${OPTARG};;
		t) treatmentoutput=${OPTARG};;
		c) controloutput=${OPTARG};;
		F) tconfigfile=${OPTARG};;
		f) cconfigfile=${OPTARG};;
		s) species=${OPTARG};;
		b) bartout=${OTPARG};;
		h) sub_help ;;
		\?)
		    echo "Invalid option: -$OPTARG" >&2
		    sub_help
		    exit 1
		    ;;
		:)
		    echo "Option -$OPTARG requires an argument." >&2
		    sub_help
		    exit 1
		    ;;
	esac
done

filename='programs.txt'



hicproPath=`awk 'NR == 1' $filename | cut -d'=' -f 2`
bart3dPath=`awk 'NR == 2' $filename | cut -d'=' -f 2`
pythonPath=`awk 'NR == 3' $filename | cut -d'=' -f 2`


if [ ! -d $treatmentdir ]; then
	echo "Treatment Folder Does Not Exist"
	exit
fi
if [ ! -d $controldir ]; then
        echo "Control Folder Does Not Exist"
        exit
fi
if [ ! -f $tconfigfile ]; then
        echo "Treatment Config File Does Not Exist"
        exit
fi
if [ ! -f $cconfigfile ]; then
        echo "Control Config File Does Not Exist"
        exit
fi
if [ "$species" != hg38 ] && [ "$species" != mm10 ]; then
	echo "Invalid species. Please use either hg38 or mm10 as species input  (-s)"
	exit
fi

echo ""
echo "Running HiC-Pro for Treatment Condition"
echo ""

$hicproPath -i $treatmentdir -o $treatmentoutput -c $tconfigfile

echo ""
echo "Running HiC-Pro for Control Condition"
echo ""


$hicproPath -i $controldir -o $controloutput -c $cconfigfile

echo ""
echo "Runnning BART3D"
echo ""

if [ -d $bartout ]; then
    rm -rf $bartout
fi

treatmentMatrix="$treatmentoutput/hic_results/matrix/*/raw/10000/*_10000.matrix"
controlMatrix="$controloutput/hic_results/matrix/*/raw/10000/*_10000.matrix"
bedFile="$treatmentoutput/hic_results/matrix/*/raw/10000/*_10000_abs.bed"

$bart3dPath -t $treatmentMatrix -c $controlMatrix -f hicpro --bedFileHicpro $bedFile -s $species



for entry in $bartout/*results.txt
do
	$pythonPath make_table.py -i $entry
done

mkdir $bartout/raw_data
mv $bartout/*.txt bart3d_output/raw_data
mv $bartout/*.bed bart3d_output/raw_data


exit


