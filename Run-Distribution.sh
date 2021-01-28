#!/bin/bash

data=$1
signal=$2
regionShort=$3
mode=$4
genome=$5

header=~/Lab/ENCODE/Encyclopedia/V5/GWAS/$signal-Header-$genome.txt
dirControl=~/Lab/ENCODE/Encyclopedia/V5/GWAS/$data/Controls
dirGWAS=~/Lab/ENCODE/Encyclopedia/V5/GWAS/$data
scriptDir=~/Projects/GWAS/Updated-VIPER

mkdir -p /tmp/moorej3/$SLURM_JOBID
cd /tmp/moorej3/$SLURM_JOBID

paste $dirControl/Overlap*.$signal.$regionShort.$mode.txt | awk '{for(i=1;i<=NF;i+=2) \
    {if ($(i+1) != 0) printf "%s\t",$i/$(i+1); else printf "%s\t", 0}; print ""}' > Control.Overlap.$signal.$regionShort.$mode.txt

python $scriptDir/t.test.py $dirGWAS/Overlap.$data.$signal.$regionShort.$mode.txt \
    Control.Overlap.$signal.$regionShort.$mode.txt > tmp

paste $header tmp > test

awk '{print $5}' test > p
Rscript ~/Projects/ENCODE/Encyclopedia/Version4/GWAS-Analysis/fdr.R
paste test results.txt > Enrichment.$data.$signal.$regionShort.$mode.Zscore.txt

mv Enrichment.$data.$signal.$regionShort.$mode.Zscore.txt $dirGWAS

rm -r /tmp/moorej3/$SLURM_JOBID/
