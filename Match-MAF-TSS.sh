#!/bin/bash

#Jill Moore
#GWAS 2014
#This script creates 100 controls (1 round) for any candidate GWAS SNPs
#A list of each lead SNP with the corresponding SNP ChIP used is required
#as well as the minor allele frequency for each lead SNP in a bed file

#Use the following guide to create the ArrayList {"A": "Affymetrix500K", "B": "Affymetrix5", "C": "Affymetrix6", "D": "Illumina1M", "E": "Illumina300", "F": "Illumina550", "G": "Illumina610", "H": "All", "I": "Illumina"}

LeadBed=$1 #Lead.MAF.bed
id=$2
I=$SLURM_ARRAY_TASK_ID
pop=$3

scriptDir=/home/moorej3/Projects/GWAS/VIPER
outputDir=~/Lab/ENCODE/Encyclopedia/V5/GWAS/$id

mkdir -p /tmp/moorej3/$SLURM_JOBID"-"$SLURM_ARRAY_TASK_ID
cd /tmp/moorej3/$SLURM_JOBID"-"$SLURM_ARRAY_TASK_ID

python $scriptDir/create.controls.py $LeadBed $I $pop >> Output

mkdir -p $outputDir/Controls/Lead/
mv Final.$I.out $outputDir/Controls/Lead/

rm -r /tmp/moorej3/$SLURM_JOBID"-"$SLURM_ARRAY_TASK_ID
