#!/bin/bash

#Jill Moore
#January 2019
#Weng Lab
#VIPER-1.0


#Step 2 of VIPER Pipeline
#This step of the pipeline requires slurm

#Usage: ./2_Curate-Control-SNPs.sh Master-GWAS-List.txt genome

###

source ~/.bashrc
list=$1
genome=$2
scriptDir=~/Projects/GWAS/VIPER

q=$(wc -l $list | awk '{print $1}')
for j in `seq 1 1 $q`
do
    id=$(awk -F "\t" '{if (NR == '$j') print $3"-"$2"-"$4}' $list)
    pop=$(awk -F "\t" '{if (NR == '$j') print $5}' $list)
    sbatch --nodes 1 --array=380-500%10 --mem=1G --time=04:00:00 \
    	--output=/home/moorej3/Job-Logs/jobid_%A_%a.output \
    	--error=/home/moorej3/Job-Logs/jobid_%A_%a.error \
    	$scriptDir/Retrieve-LD-SNPs-Controls.sh $id $pop $genome
done    
