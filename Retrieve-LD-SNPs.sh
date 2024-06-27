#Step 1 in Pipeline
#To Run:
#Process.List.sh Lead-Name

scriptDir=/home/moorej3/Projects/GWAS/VIPER/
data=$1
pop=$2
g=$3

echo "Extracting coordinates ..."

num=$(wc -l $data.Lead.List | awk '{print int($1/100)}')
rm -f $data.Lead.bed

for j in `seq 1 1 $num`
do
    count=$(awk 'BEGIN{print '$j'*100}')
    head -n $count $data.Lead.List | tail -n 100 > mini
    query=$(awk '{print $1}' mini | sort -u | sed ':a;N;$!ba;s/\n/,/g')
    wget "https://api.wenglab.org/gwasws/snp_coord/"$g"/"$query -O text
    awk '{if ($1 !~ /_/) print $1 "\t" $3 "\t" $3 "\t" $4}' text >> \
        $data.Lead.bed
done

remainder=$(wc -l $data.Lead.List | awk '{print $1-'$num'*100}')
if [ "$remainder" -gt 0 ]
then
    tail -n $remainder $data.Lead.List > mini
    query=$(awk '{print $1}' mini | sort -u | sed ':a;N;$!ba;s/\n/,/g')
    wget "https://api.wenglab.org/gwasws/snp_coord/"$g"/"$query -O text
    awk '{if ($1 !~ /_/) print $1 "\t" $3 "\t" $3 "\t" $4}' text >> \
        $data.Lead.bed
fi

sort -u $data.Lead.bed > tmp
mv tmp $data.Lead.bed 


echo "Extracting LD SNPs ..."

num=$(wc -l $data.Lead.bed | awk '{print int($1/100)}')
rm -f h-$data

for j in `seq 1 1 $num`
do
    count=$(awk 'BEGIN{print '$j'*100}')
    head -n $count $data.Lead.bed | tail -n 100 > mini
    query=$(awk '{print $4}' mini | sort -u | sed ':a;N;$!ba;s/\n/,/g')
    wget "https://api.wenglab.org/gwasws/"$pop"/snp_ld/"$query -O h-$data.mini
    cat h-$data.mini >> h-$data
done

remainder=$(wc -l $data.Lead.bed | awk '{print $1-'$num'*100}')
if [ "$remainder" -gt 0 ]
then
    tail -n $remainder $data.Lead.bed > mini
    query=$(awk '{print $4}' mini | sort -u | sed ':a;N;$!ba;s/\n/,/g')
    wget "https://api.wenglab.org/gwasws/"$pop"/snp_ld/"$query -O h-$data.mini
    cat h-$data.mini >> h-$data
fi

python $scriptDir/process.ld.py $data.Lead.bed h-$data > output-$data

num=$(wc -l output-$data | awk '{print int($1/100)}')
rm -f bed

for j in `seq 1 1 $num`
do
    count=$(awk 'BEGIN{print '$j'*100}')
    head -n $count output-$data | tail -n 100 > mini
    query=$(awk '{print $1}' mini | sort -u | sed ':a;N;$!ba;s/\n/,/g')
    wget "https://api.wenglab.org/gwasws/snp_coord/"$g"/"$query -O bed1
    awk '{if ($1 !~ /_/) print $0}' bed1 >> bed
done

remainder=$(wc -l output-$data | awk '{print $1-'$num'*100}')
if [ "$remainder" -gt 0 ]
then
    tail -n $remainder output-$data > mini
    query=$(awk '{print $1}' mini | sort -u | sed ':a;N;$!ba;s/\n/,/g')
    wget "https://api.wenglab.org/gwasws/snp_coord/"$g"/"$query -O bed1
    awk '{if ($1 !~ /_/) print $0}' bed1 >> bed
fi

awk 'FNR==NR {x[$1];next} ($4 in x)' output-$data bed | sort -u | \
    sort -k4,4 | awk '{if ($1 !~ /_/) print $0}' > sort1
awk 'FNR==NR {x[$4];next} ($1 in x)' bed output-$data |  sort -u | \
    sort -k1,1 > sort2
paste sort1 sort2 | awk '{if ($5 == $4) print $1 "\t" $2 "\t" $3 "\t" $4 \
    "\t" $6 "\t" $7}' > output-$data

echo "Creating ld groups ..."
python $scriptDir/make.ld.groups.py output-$data $data"-" > test

sort -k1,1 test > tmp2
sort -k4,4 output-$data > tmp1

paste tmp1 tmp2 | awk '{if ($7 != $4) print "ERROR! Lines do not match"}'
paste tmp1 tmp2 | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" \
    $8}' > $data.bed

rm bed bed1 h-$data h-$data.mini mini output-$data sort* tmp* test text
