#!/bin/bash

#Jill Moore
#October 2018
#Weng Lab
#VIPER-1.1


#Step 1 of VIPER Pipeline
#This step of the pipeline requires slurm

#Usage: ./1_Generate-Control-SNPs.sh Master-GWAS-List.txt

###

list=$1
scriptDir=~/Projects/GWAS/VIPER

q=$(wc -l $list | awk '{print $1}')
for j in `seq 1 1 $q`
do
    id=$(awk -F "\t" '{if (NR == '$j') print $3"-"$2"-"$4}' $list)
    pop=$(awk -F "\t" '{if (NR == '$j') print $5}' $list)
    file=/home/moorej3/Lab/ENCODE/Encyclopedia/V5/GWAS/$id/*.MAF.TSS.bed

    sbatch --nodes 1 --array=1-500%25 --mem=1G --time=00:30:00 \
	--output=/home/moorej3/Job-Logs/jobid_%A_%a.output \
    	--error=/home/moorej3/Job-Logs/jobid_%A_%a.error \
    	$scriptDir/Match-MAF-TSS.sh $file $id $pop
done    
