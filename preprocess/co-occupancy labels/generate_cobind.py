#!/usr/bin/env python
from __future__ import division
import sys

tf1='/state2/hyangl/TF_co/data/chipseq/'+sys.argv[1]+'.train.labels.tsv'
tf2='/state2/hyangl/TF_co/data/chipseq/'+sys.argv[2]+'.train.labels.tsv'

f1=open(tf1,'r')
f2=open(tf2,'r')

line1=f1.readline()
line1=line1.rstrip()
line2=f2.readline()
line2=line2.rstrip()
seg1=line1.split('\t')
seg2=line2.split('\t')

cells=list()#commom cell lines
ind1=list()#index of common cell lines in tf1
ind2=list()#index of common cell lines in tf2
for i in seg1[3:]:
    for j in range(3,len(seg2)):
        if (seg2[j]==i):
            cells.append(i)
            ind1.append(seg1.index(i))
            ind2.append(j)
        else:
            cells=cells;ind1=ind1;ind2=ind2

if (len(cells)<2):
    f1.close()
    f2.close()
    sys.exit()
else:
    compare='/state2/mqzhou/TF_co/data/chipseq_co/'+sys.argv[1]+'_'+sys.argv[2]+'.train.labels.tsv'
    counts='/state2/mqzhou/TF_co/data/chipseq_co/counts.tsv'

    f3=open(compare,'w')
    f4=open(counts,'a')
   
    b=[0]*len(cells)
    a=[0]*len(cells)
    u=[0]*len(cells)

    c='\t'.join([ "%s" % i for i in cells])
    f3.write('chr\tstart\tend\t%s\n' % c)

    for line1 in f1:
        line1=line1.rstrip()
        line2=f2.readline()
        line2=line2.rstrip()
        the_chr,start,end=line1.split('\t')[0:3]
        new_labels=list()
        for i in range(0,len(cells)):
            label1=line1.split('\t')[ind1[i]]
            label2=line2.split('\t')[ind2[i]]
            if (label1=="U") | (label2=="U"):
                label3="U";u[i]=u[i]+1
            elif (label1=="A") | (label2=="A"):
                label3="A";a[i]=a[i]+1
            else:
                label3="B";b[i]=b[i]+1
            new_labels.append(label3)
        labels='\t'.join([ "%s" % k for k in new_labels])
        f3.write('%s\t%s\t%s\t%s\n' % (the_chr,start,end,labels))

    for i in range(0,len(cells)):
        f4.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\n' % (sys.argv[1],sys.argv[2],cells[i],b[i],a[i],u[i],b[i]/a[i]))

    f1.close()
    f2.close()
    f3.close()
    f4.close()



