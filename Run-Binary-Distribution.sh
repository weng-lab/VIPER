#!/bin/bash

id=$1
type=$2
g1=$3
g2=$4
mode=$5
regions=$6
pmid=$7

dirControl=~/Lab/ENCODE/Encyclopedia/V5/GWAS/$id/Controls
dirGWAS=~/Lab/ENCODE/Encyclopedia/V5/GWAS/$id
scriptDir=~/Projects/GWAS/VIPER

mkdir -p /tmp/moorej3/$SLURM_JOBID
cd /tmp/moorej3/$SLURM_JOBID

dir=~/Lab/ENCODE/Encyclopedia/V5/GWAS/$id
scriptDir=/home/moorej3/Projects/GWAS/Updated-VIPER
i=$SLURM_ARRAY_TASK_ID

echo "Processing GWAS ..."
if [[ $mode == "NoHLA" ]]
then
awk '{if ($1 != "chr6") print $0}' $dir/$pmid.bed > bed
overlapLD=$(~/bin/bedtools2/bin/bedtools intersect -wo -a bed -b $regions | \
    awk '{print $7}' | sort -u | wc -l | awk '{print $1}')
else
overlapLD=$(~/bin/bedtools2/bin/bedtools intersect -wo -a $dir/$pmid.bed -b $regions | \
    awk '{print $7}' | sort -u | wc -l | awk '{print $1}')
fi

totalLD=$(awk '{print $NF}' $dir/$pmid.bed | sort -u | wc -l)
echo -e $overlapLD "\t" $totalLD > $dir/Overlap.$id.$type.$g1.$g2.$mode.txt

echo "Processing controls ..."
for i in `seq 1 1 500`
do
    echo "..."$i
    if [[ $mode == "NoHLA" ]]
    then
        awk '{if ($1 != "chr6") print $0}' $dir/Controls/Control.$i.$id.bed > bed
        overlapLD=$(~/bin/bedtools2/bin/bedtools intersect -wo -a bed -b $regions | \
            awk '{print $7}' | sort -u | wc -l | awk '{print $1}')
    else
        overlapLD=$(~/bin/bedtools2/bin/bedtools intersect -wo -a $dir/Controls/Control.$i.$id.bed -b $regions | \
            awk '{print $7}' | sort -u | wc -l | awk '{print $1}')
    fi
    totalLD=$(awk '{print $NF}' $dir/Controls/Control.$i.$id.bed | sort -u | wc -l)
    echo -e $overlapLD "\t" $totalLD >> tmp.control
done
mv tmp.control $dir/Controls/Overlap.$type.$g1.$g2.$mode.txt

echo "Calculating significance ..."
python $scriptDir/t.test.binary.py $dir/Overlap.$id.$type.$g1.$g2.$mode.txt \
    $dir/Controls/Overlap.$type.$g1.$g2.$mode.txt | awk '{print "'$id'" "\t" $0}' > tmp

mv tmp $dir/Enrichment.$id.$type.$g1.$g2.$mode.Zscore.txt
rm -r /tmp/moorej3/$SLURM_JOBID/
