import numpy, sys, scipy
from scipy import stats

def Process_Controls(controls):
    controlArray=[]
    for line in controls:
        line=line.rstrip().split("\t")
        controlArray.append(float(line[0])/float(line[1]))
    return controlArray

gwas=open(sys.argv[1])
controls=open(sys.argv[2])
controlArray=Process_Controls(controls)
controls.close()


for line in gwas:
    line=line.rstrip().split("\t")
    gwasFraction=int(line[0])/float(line[1])
    mean=numpy.mean(controlArray)
    sd=numpy.std(controlArray)
    z=(gwasFraction-mean)/sd
    p = stats.norm.sf(abs(z))*2
    print round(gwasFraction,4),"\t",round(mean,4),"\t",z,"\t",round(p,4)
gwas.close()
