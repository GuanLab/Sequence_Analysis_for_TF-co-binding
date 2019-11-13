### run generate_cobind.py
#!/usr/bin/env python
from itertools import combinations, permutations
import os

TFs=['ATF3','CTCF','E2F1','EGR1','FOXA1', 'FOXA2', 'GABPA', 'HNF4A', 'JUND', 'MAX','NANOG', 'REST', 'TAF1']

combs=list(combinations(TFs, 2))#combinations of TFs
for i in combs:
    TF1=i[0]
    TF2=i[1]
    os.system("/state2/mqzhou/TF_co/code/generate_cobind.py %s %s " % (TF1,TF2))



