import random, sys, subprocess


mafDict={"eur": [0.06,0.18,0.33], "afr": [0.09,0.19,0.33], \
	 "amr": [0.07,0.19,0.33], "asn": [0.02,0.16,0.32]}
tssDict={"Any":[9553,39530,154279]}

masterDir="/home/moorej3/Lab/GWAS/SNP_Array/New-Lists/"

SNPs=open(sys.argv[1], "r")
FF=open("Final."+sys.argv[2]+".out","w+")
pop=sys.argv[3]


for line in SNPs:
    line=line.rstrip().split("\t")
    try:
        maf=float(line[4])
    except:
	maf=max([float(i) for i in line[4].split(",")])
    tss=float(line[5])
    
    T1=open("tmp1.txt","w+")
    T2=open("tmp2.txt","w+")
    T3=open("tmp3.txt","w+")
    T=open("tmp.txt","w+")

    num=mafDict[pop]
    if maf <= num[0]:
        Ext = 1
    elif maf > num[0] and maf <= num[1]:
        Ext=2
    elif maf > num[1] and maf <= num[2]:
        Ext=3
    elif maf > num[2]:
        Ext=4
    num2=tssDict["Any"]
    if tss <= num2[0]:
        Ext2 = 1
    elif tss > num2[0] and tss <= num2[1]:
        Ext2=2
    elif tss > num2[1] and tss <= num2[2]:
        Ext2=3
    elif tss > num2[2]:
        Ext2=4

    subprocess.call(['cat', masterDir+'/MAF-HaploReg/'+pop\
                     +'.'+str(Ext)+'.bed'], stdout=T1)
    print >> T1, "\n",
    subprocess.call(['cat', masterDir+'/TSS-Quartiles/Any'\
                     +'.'+str(Ext2)+'.bed'], stdout=T2)
    print >> T2, "\n",
    proc = subprocess.Popen(["awk 'FNR==NR {{x[$4];next}} ($4 in x)' \
                             tmp1.txt tmp2.txt"], stdout=T, shell=True)
    stdout = proc.communicate()[0]
    R=random.randint(1, 10000)
    
    subprocess.call(['/home/moorej3/bin/randomLines', 'tmp.txt', '1', \
                     '-seed='+str(R), 'Final.tmp'], stdout=T)
    subprocess.call(['cat', 'Final.tmp'], stdout=FF)
    

