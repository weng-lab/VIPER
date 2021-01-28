import sys
import networkx 
from networkx.algorithms.components.connected import connected_components

def to_graph(l):
    G = networkx.Graph()
    for part in l:
        # each sublist is a bunch of nodes
        G.add_nodes_from(part)
        # it also imlies a number of edges:
        G.add_edges_from(to_edges(part))
    return G

def to_edges(l):
    """ 
        treat `l` as a Graph and returns it's edges 
        to_edges(['a','b','c','d']) -> [(a,b), (b,c),(c,d)]
    """
    it = iter(l)
    last = next(it)

    for current in it:
        yield last, current
        last = current  


snpDict={}
ldDict={}
title=sys.argv[2]

for line in open(sys.argv[1]):
	line=line.rstrip().split("\t")
	lds=line[4].split(",")
	if lds == ["Lead"] and line[3] not in ldDict:
	    ldDict[line[3]]=[]
	else:
	    for ld in lds:
		if ld == "Lead":
			pass
		else:
			if line[3] in snpDict:
				snpDict[line[3]].append(ld)
			else:
				snpDict[line[3]]=[ld]
			if ld in ldDict:
				ldDict[ld].append(line[3])
			else:
				ldDict[ld]=[line[3]]
i=1
k=[]

for entry in ldDict:
	name=title+str(i)
	m=ldDict[entry]+[entry]
	k.append(m)


G = to_graph(k)
g=connected_components(G)
for entry in g:
	name=title+str(i)
	for x in entry:
		print x, "\t", name
	i+=1



