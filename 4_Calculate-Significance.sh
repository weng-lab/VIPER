#!/bin/bash

#Jill Moore
#January 2018
#Weng Lab
#VIPER-1.0


#Step 4 of VIPER Pipeline
#This step of the pipeline requires slurm

#Usage: ./4_Calculate-Significance.sh Master-GWAS-List.txt [H3K27ac , DNase, H3K4me3, CTCF] [hg38, hg19] [hg38, hg19, mm10] [All, noHLA]

###

source /home/moorej3/.bashrc

list=$1
signal=$2
regionShort=$3
mode=$4
genome=hg38
scriptDir=~/Projects/GWAS/Updated-VIPER

q=$(wc -l $list | awk '{print $1}')
for j in `seq 1 1 $q`
do
    id=$(awk -F "\t" '{if (NR == '$j') print $3"-"$2"-"$4}' $list)
    pmid=$(awk -F "\t" '{if (NR == '$j') print $2}' $list)
    sbatch --nodes 1 --mem=1G --time=00:30:00 \
        --output=/home/moorej3/Job-Logs/jobid_%A.output \
        --error=/home/moorej3/Job-Logs/jobid_%A.error \
        $scriptDir/Run-Distribution.sh $id $signal $regionShort $mode $genome
/bin/sleep 1
done

