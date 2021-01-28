import sys

def Create_LD_Dict(masterPeaks):
    ldDict={}
    for line in masterPeaks:
        line=line.rstrip().split("\t")
        if line[3] not in ldDict:
            ldDict[line[3]]=[line[2]]
        else:
            ldDict[line[3]].append(line[2])
    for entry in ldDict:
        ldDict[entry]=list(set(ldDict[entry]))
    return ldDict

def Process_Signal(ldDict, signal, sigType):
    ldArray=[]
    for line in signal:
        line=line.rstrip().split("\t")
        if sigType == "RAMPAGE":
            score = float(line[2])/float(line[3])*1000000
            threshold = 1
        else:
            score = float(line[1])
            threshold = 1.64
        for entry in ldDict[line[0]]:
            if entry not in ldArray and score > threshold:
                ldArray.append(entry)
    return ldArray

masterPeaks=open(sys.argv[1])
signal=open(sys.argv[2])
total=sys.argv[3]
sigType=sys.argv[4]

ldDict=Create_LD_Dict(masterPeaks)
print len(Process_Signal(ldDict, signal, sigType)), "\t", total


masterPeaks.close()
signal.close()
