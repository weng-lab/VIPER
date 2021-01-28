import numpy, sys, scipy
from scipy import stats


gwas=open(sys.argv[1])
controls=open(sys.argv[2])

for line in gwas:
    line=line.rstrip().split("\t")
    if float(line[1]) > 0:
        gwasFraction=int(line[0])/float(line[1])
    else:
        gwasFraction=0
    controlFractions=[float(i) for i in controls.next().rstrip().split("\t")]
    mean=numpy.mean(controlFractions)
    sd=numpy.std(controlFractions)
    z=(gwasFraction-mean)/sd
    p = stats.norm.sf(abs(z))*2
    print round(gwasFraction,4),"\t",round(mean,4),"\t",z,"\t",round(p,4)

gwas.close()
controls.close()
