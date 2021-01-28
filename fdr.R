p=read.table("p")

p=p.adjust(p$V1, method="fdr")

write(p, file="results.txt", ncolumns=1)

