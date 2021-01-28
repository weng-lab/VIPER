#!/bin/bash

#Jill Moore
#January 2018
#Weng Lab
#VIPER-1.0


#Step 3 of VIPER Pipeline
#This step of the pipeline requires slurm

#Usage: ./3_Calculate-Signal-Enrichment.sh Master-GWAS-List.txt [H3K27ac , DNase, H3K4me3, CTCF] genome1 genome2 HLA-mode

###

source /home/moorej3/.bashrc

list=$1
#name=$2
name=ctsPLS
#regions=$3
regions=/data/zusers/fankaili/ccre/encode_v2_ubi-rDHSs/non-ubi-PLS.bed
#mode=$4
mode=Normal
scriptDir=~/Projects/GWAS/Updated-VIPER
g1=hg38
g2=hg38

q=$(wc -l $list | awk '{print $1}')
for j in `seq 1 1 $q`
do
    id=$(awk -F "\t" '{if (NR == '$j') print $3"-"$2"-"$4}' $list)
    pmid=$(awk -F "\t" '{if (NR == '$j') print $2}' $list)

    sbatch --nodes 1 --mem=10G --time=04:00:00 \
        --output=/home/moorej3/Job-Logs/jobid_%A.output \
        --error=/home/moorej3/Job-Logs/jobid_%A.error \
        $scriptDir/Run-Binary-Distribution.sh $id $name $g1 $g2 $mode $regions $pmid

/bin/sleep 2

done

