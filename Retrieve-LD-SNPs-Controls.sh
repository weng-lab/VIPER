#!/bin/bash
#Jill E Moore
#Weng Lab
#UMass Medical School

#Script will take a file of control snps and return a bed file with all snps in LD

source ~/.bashrc

round=$1
pop=$2
g=$3
data=$SLURM_ARRAY_TASK_ID

dir=~/Lab/ENCODE/Encyclopedia/V5/GWAS/$round/Controls/Lead
output=~/Lab/ENCODE/Encyclopedia/V5/GWAS/$round/Controls
scriptDir=~/Projects/GWAS/VIPER

mkdir -p /tmp/moorej3/$SLURM_JOBID"-"$SLURM_ARRAY_TASK_ID
cd /tmp/moorej3/$SLURM_JOBID"-"$SLURM_ARRAY_TASK_ID

d=$dir/Final.$data.out

num=$(wc -l $d | awk '{print int($1/100)}')
rm -f h-$data

for j in `seq 1 1 $num`
do
    echo > h-$data.mini
    i=0
    while [ $i -lt 1 ]
    do
        count=$(awk 'BEGIN{print '$j'*100}')
        head -n $count $d | tail -n 100 > mini
        query=$(awk '{print $4}' mini | sort -u | sed ':a;N;$!ba;s/\n/,/g')
        wget "https://api.wenglab.org/gwasws/"$pop"/snp_ld/"$query -O h-$data.mini
        cat h-$data.mini >> h-$data
        i=$(wc -l h-$data.mini | awk '{print $1}')
    done
done

echo > h-$data.mini
i=0

remainder=$(wc -l $d | awk '{print $1-'$num'*100}')
if [ "$remainder" -gt 0 ]
then
    while [ $i -lt 1 ]
    do
        remainder=$(wc -l $d | awk '{print $1-'$num'*100}')
    	tail -n $remainder $d > mini
    	query=$(awk '{print $4}' mini | sort -u | sed ':a;N;$!ba;s/\n/,/g')
    	wget "https://api.wenglab.org/gwasws/"$pop"/snp_ld/"$query -O h-$data.mini
    	echo "" >> h-$data.mini
    	cat h-$data.mini >> h-$data
    	i=$(wc -l h-$data.mini | awk '{print $1}')
    done
fi

python $scriptDir/process.ld.py $d h-$data > output-$data

num=$(wc -l output-$data | awk '{print int($1/100)}')
rm -f bed

for j in `seq 1 1 $num`
do
    echo > bed1
    i=0
    while [ $i -lt 1 ]
    do
        count=$(awk 'BEGIN{print '$j'*100}')
        head -n $count output-$data | tail -n 100 > mini
        query=$(awk '{print $1}' mini | sort -u | sed ':a;N;$!ba;s/\n/,/g')
        wget "https://api.wenglab.org/gwasws/snp_coord/"$g"/"$query -O bed1
        awk '{if ($1 !~ /_/) print $0}' bed1 >> bed
        i=$(wc -l bed1 | awk '{print $1}')
    done
done

i=0
remainder=$(wc -l output-$data | awk '{print $1-'$num'*100}')
if [ "$remainder" -gt 0 ]
then
    while [ $i -eq 0 ]
    do
    	tail -n $remainder output-$data > mini
    	query=$(awk '{print $1}' mini | sort -u | sed ':a;N;$!ba;s/\n/,/g')
    	wget "https://api.wenglab.org/gwasws/snp_coord/"$g"/"$query -O bed1
    	echo "" >> bed1
    	awk '{if ($1 !~ /_/) print $0}' bed1 >> bed
    	i=$(wc -l bed1 | awk '{print $1}')
    done
fi

awk 'FNR==NR {x[$1];next} ($4 in x)' output-$data bed | sort -k4,4 | \
    awk '{if ($1 !~ /_/) print $0}' > sort1
awk 'FNR==NR {x[$4];next} ($1 in x)' bed output-$data |  sort -k1,1 > sort2
paste sort1 sort2 | awk '{if ($5 == $4) print $1 "\t" $2 "\t" $3 "\t" $4 \
    "\t" $6 "\t" $7}' > output-$data

echo "Creating ld groups ..."
python $scriptDir/make.ld.groups.py output-$data $round"-"$data"-" > test-$data


awk 'FNR==NR {x[$1];next} ($4 in x)' test-$data output-$data | sort -k4,4 > \
    tmp1-$data
awk 'FNR==NR {x[$4];next} ($1 in x)' output-$data test-$data | sort -k1,1 > \
    tmp2-$data

paste tmp1-$data tmp2-$data | awk '{if ($7 != $4) print "ERROR! Lines do \
    not match, rep-""'$data'"}' >> Log-$data
paste tmp1-$data tmp2-$data | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 \
    "\t" $6 "\t" $8}' > Control.$data.$round.bed

mv Control.$data.$round.bed $output
rm -r /tmp/moorej3/$SLURM_JOBID"-"$SLURM_ARRAY_TASK_ID
