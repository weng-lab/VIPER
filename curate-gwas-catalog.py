import sys

def Create_Pop_Dict():
    popDict={"European":"eur", "Finnish":"eur", "British":"eur", 
             "Chinese":"asn", "Japanese":"asn", "Asian":"asn", 
             "Indian":"asn", "Filipino":"asn", "African":"afr", 
             "Latin":"amr", "Latino": "amr", "Hispanic":"amr",
             "Swedish":"eur", "Icelandic":"eur", "Irish":"eur",
             "Danish":"eur", "Scottish":"eur", "Dutch":"eur",
             "Korean":"asn", "Taiwanese":"asn", "Kenyan":"afr",
             "Thai":"asn", "Austrian":"eur", "Mexican":"amr",
             "Hispanic/Latino":"amr", "German":"eur", "Polish":"eur",
             "Italian":"eur","Norwegian":"eur", "Thai-Chinese":"asn",
             "HIspanic/Latino":"amr"} #typo here is intentional
    return popDict

def Determine_Pop(data, out, unsure, okay):    
    if "African American" in line[8] or "Jewish" in line[8]:
        print >> out, line[7]+"\t"+line[1]+"\t"+"_".join(line[2].split())+"\t"+\
            "_".join(line[7].split())+"\t"+"NA"+"\t"+"new"+"\t"+line[8]
        pop="unsure"
    else:
        pop=line[8].split()
        popArray=[]
        for word in pop:
            if word in popDict:
                popArray.append(popDict[word])
        popArray=list(set(popArray))
        if len(popArray) == 1:
            print >> okay, line[7]+"\t"+line[1]+"\t"+"_".join(line[2].split())+"\t"+\
                "_".join(line[7].split())+"\t"+popArray[0]+"\t"+"new"+"\t"+line[8]
            pop=popArray[0]
        elif len(popArray) == 0:
            print >> unsure, line[7]+"\t"+line[1]+"\t"+"_".join(line[2].split())+"\t"+\
                "_".join(line[7].split())+"\t"+"NA"+"\t"+"new"+"\t"+line[8]
            pop="unsure"
        elif len(popArray) > 1:
            print >> out, line[7]+"\t"+line[1]+"\t"+"_".join(line[2].split())+"\t"+\
                "_".join(line[7].split())+"\t"+"NA"+"\t"+"new"+"\t"+line[8]
            pop="mixed"
    return pop
                    
                    
newCatalog=open(sys.argv[1])
runningList=[]

popDict=Create_Pop_Dict()

out=open("out.txt","w+")
unsure=open("unsure.txt","w+")
okay=open("okay.txt","w+")

for line in newCatalog:
    line=line.rstrip().split("\t")
    key=line[7]+"***"+line[1]
    if key not in runningList:
        pop=Determine_Pop(line[8], out, unsure, okay)
        if pop != "mixed" and pop != "unsure":
            print line[7]+"\t"+line[1]+"\t"+"_".join(line[2].split())+"\t"+\
                "_".join(line[7].split()).replace("/","_")+"\t"+pop
        runningList.append(key)
        
out.close()
unsure.close()
okay.close()
