#!/bin/bash

d=$1.Lead.bed
pop=$2
g=$3


if [[ $g == "hg38" ]]
then
tss=~/Lab/Reference/Human/$g/GENCODE24/TSS.Filtered.4K.bed
elif [[ $g == "hg19" ]]
then
tss=~/Lab/Reference/Human/$g/Gencode19/TSS.Filtered.4K.bed
fi

num=$(wc -l $d | awk '{print int($1/100)}')
rm -f maf-mini
for j in `seq 1 1 $num`
do
    count=$(awk 'BEGIN{print '$j'*100}')
    head -n $count $d | tail -n 100 > mini
    query=$(awk '{print $4}' mini | sort -u | sed ':a;N;$!ba;s/\n/,/g')
    wget "http://api.wenglab.org/gwasws/"$pop"/snp_maf/"$query -O maf-mini
    cat maf-mini >> maf
done

remainder=$(wc -l $d | awk '{print $1-'$num'*100}')
if [ "$remainder" -gt 0 ]
then
    tail -n $remainder $d > mini
    query=$(awk '{print $4}' mini | sort -u | sed ':a;N;$!ba;s/\n/,/g')
    wget "http://api.wenglab.org/gwasws/"$pop"/snp_maf/"$query -O maf-mini
    cat maf-mini >> maf
fi

sort -k1,1 maf | awk '{if ($4 > 0.5) print $1 "\t" $2 "\t" $3 "\t" 1-$4; \
    else print $1 "\t" $2 "\t" $3 "\t" $4}' > TMP1

sort -k1,1 -k2,2n $d > sorted

bedtools closest -d -a sorted -b $tss | awk '{print $4 "\t" $11 "\t" $12}' | \
    sort -u | sort -k1,1 | awk 'BEGIN{a=0}{if ($1 != a) print $0; a=$1}' > TMP2

awk 'FNR==NR {x[$1];next} ($1 in x)' TMP2 TMP1 | sort -u > B
awk 'FNR==NR {x[$1];next} ($1 in x)' TMP1 TMP2 | sort -u  > A

paste B A | awk '{if ($1 != $1) print "ERROR"}'
paste B A | awk '{print $1 "\t" $4 "\t" $7}' > l

awk 'FNR==NR {x[$1];next} ($4 in x)' l $d | sort -k4,4 > bed
awk 'FNR==NR {x[$4];next} ($1 in x)' $d l | sort -k1,1 > stats

paste bed stats | awk '{if ($4 != $5) print "ERROR"}'
paste bed stats | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $6 "\t" $7}' \
    > $1.MAF.TSS.bed

rm -f TMP* sorted A B bed stats l maf  maf-mini  mini
