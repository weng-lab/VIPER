#!/bin/bash

id=$1
signal=$2
regions=$3
mode=$4
pmid=$5
dataPath=$6

file=$dataPath/$signal"-List.txt"
dir=~/Lab/ENCODE/Encyclopedia/V5/GWAS/$id/Controls
scriptDir=/home/moorej3/Projects/GWAS/Updated-VIPER
sigDir=$dataPath/signal-output
i=$SLURM_ARRAY_TASK_ID
regionShort=$(echo $regions | awk -F "/" '{print $NF}' | awk -F "." '{print $1}')

mkdir -p /tmp/moorej3/$SLURM_JOBID"-"$SLURM_ARRAY_TASK_ID
cd /tmp/moorej3/$SLURM_JOBID"-"$SLURM_ARRAY_TASK_ID

if [[ $mode == "NoHLA" ]]
then
    awk '{if ($1 != "chr6") print $0}' $dir/Control.$i.$id.bed > bed
    ~/bin/bedtools2/bin/bedtools intersect -wo -a bed -b $regions \
        | awk '{print $4 "\t" $5 "\t" $7 "\t" $11}' > MP.txt
else
    ~/bin/bedtools2/bin/bedtools intersect -wo -a $dir/Control.$i.$id.bed -b $regions \
        | awk '{print $4 "\t" $5 "\t" $7 "\t" $11}' > MP.txt
fi

total=$(awk '{print $3}' MP.txt | sort -u | wc -l | awk '{print $1}')

rm -f Overlap.$i.$signal.$genome.txt
l=$(wc -l $file | awk '{print $1}')
for j in $(seq $l)
do
    echo $j
    columns=$(head -n 1 $file | awk '{print NF}')

    if [ "$columns" -eq 2 ]
    then
        sigFile=$(awk -F "\t" '{if (NR == '$j') print $1".txt"}' $file)
    else
        sigFile=$(awk -F "\t" '{if (NR == '$j') print $1"-"$2".txt"}' $file)
    fi
    awk 'FNR==NR {x[$4];next} ($1 in x)' MP.txt $sigDir/$sigFile > sig.txt
    python $scriptDir/count.overlap.py MP.txt sig.txt $total $signal \
        >> Overlap.$i.$signal.$regionShort.$mode.txt
done 

mv Overlap.$i.$signal.$regionShort.$mode.txt $dir/

rm -r /tmp/moorej3/$SLURM_JOBID"-"$SLURM_ARRAY_TASK_ID
