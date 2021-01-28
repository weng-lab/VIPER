import sys, urllib2

def Process_SNPs(snps):
    snpDict={}
    for line in snps:
	line=line.rstrip().split("\t")
	if len(line) > 3:
	    snpDict[line[3]]=["Lead","*"]
    return snpDict

def Retrieve_LD_Partners(ld, snpDict):
    for line in ld:
        line=line.rstrip().split("\t")
	try:
            snps=line[1].split(";")
	except:
	    snp=[]
        for snp in snps:
        	snp=snp.split(",")
                if float(snp[1]) >= 0.7:
		    if snp[0] not in snpDict:
		        snpDict[snp[0]]=[line[0],snp[1]]
		    else:
			snpDict[snp[0]][0] = snpDict[snp[0]][0]+","+line[0]
			snpDict[snp[0]][1] = snpDict[snp[0]][1]+","+snp[1]
    for entry in snpDict:
	print entry+"\t"+"\t".join(snpDict[entry])

snps=open(sys.argv[1])
snpDict=Process_SNPs(snps)
snps.close()

ld=open(sys.argv[2])
ldDict=Retrieve_LD_Partners(ld, snpDict)
ld.close()
