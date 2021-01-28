#!/bin/bash

#Jill Moore
#January 2019
#Weng Lab
#VIPER-1.0


#Step 0 of VIPER Pipeline
#This step of the pipeline does not require slurm

#Usage: ./0_Curate-GWAS-SNPs.sh Master-GWAS-List.txt genome

###

f2=$1
genome=$2

mainDir=~/Lab/ENCODE/Encyclopedia/V5/GWAS
scriptDir=~/Projects/GWAS/VIPER
gwas=$3

cd $mainDir
q=$(wc -l $f2 | awk '{print $1}')

for j in `seq 1 1 $q`
do

    pmid=$(awk -F "\t" '{if (NR == '$j') print $2}' $f2)
    pheno=$(awk -F "\t" '{if (NR == '$j') print $1}' $f2)
    author=$(awk -F "\t" '{if (NR == '$j') print $3}' $f2)
    nickname=$(awk -F "\t" '{if (NR == '$j') print $4}' $f2)
    pop=$(awk -F "\t" '{if (NR == '$j') print $5}' $f2)

    echo $author-$pmid-$nickname

    mkdir -p $author-$pmid-$nickname
    cd $author-$pmid-$nickname
    rm -f $mainDir/$author-$pmid-$nickname/*

    awk -v p="$pheno" -F "\t" '{if ($2 == '$pmid' && $8 == p) print $0}' $gwas | \
        awk -F "\t" '{print $22}' | awk '{gsub(/; /,"\n");print}' > $pmid.Lead.List

    $scriptDir/Retrieve-LD-SNPs.sh $pmid $pop $genome
    $scriptDir/Process-MAF-TSS.sh $pmid $pop $genome

    cd $mainDir

done
