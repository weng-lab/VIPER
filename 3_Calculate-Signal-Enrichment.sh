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
signal=$2
regions=$3
mode=$4
scriptDir=~/Projects/GWAS/Updated-VIPER
dataPath=~/Lab/ENCODE/RAMPAGE

q=$(wc -l $list | awk '{print $1}')
for j in `seq 1 1 $q`
do
    id=$(awk -F "\t" '{if (NR == '$j') print $3"-"$2"-"$4}' $list)
    pmid=$(awk -F "\t" '{if (NR == '$j') print $2}' $list)
    sbatch --nodes 1 --array=1-500%10 --mem=10G --time=04:00:00 \
        --output=/home/moorej3/Job-Logs/jobid_%A_%a.output \
        --error=/home/moorej3/Job-Logs/jobid_%A_%a.error \
        $scriptDir/Calculate-Control-Enrichment.sh $id $signal $regions $mode $pmid $dataPath

    sbatch --nodes 1 --mem=10G --time=04:00:00 \
        --output=/home/moorej3/Job-Logs/jobid_%A.output \
        --error=/home/moorej3/Job-Logs/jobid_%A.error \
        $scriptDir/Calculate-GWAS-Enrichment.sh $id $signal $regions $mode $pmid $dataPath
done

