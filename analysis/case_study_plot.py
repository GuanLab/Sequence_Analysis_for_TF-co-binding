##!/usr/bin/env python
#input: cell name, chromosome number, start coordinate, 
#plot features: original counts(g06); max/min/diff features(g07); motif features(g07)

import os
import sys
import numpy as np
import pandas as pd
import re
import rpy2.robjects as robjects
from rpy2.robjects import pandas2ri

test_label=sys.argv[1]#ATF3_CTCF.HCT116
pair=test_label.split('.')[0]#ATF3_CTCF
tf1=pair.split('_')[0]#ATF3
tf2=pair.split('_')[1]#CTCF
cell=test_label.split('.')[1]#'HCT116'

chro=sys.argv[2] #22
start=sys.argv[3] #start coordinate in chro, eg. 20378500
chro=int(chro)
start=int(start)

chr_num=[1,10,11,12,13,14,15,16,17,18,19,2,20,21,22,3,4,5,6,7,8,9,'X']

cut=[4980064, 7682534, 10354914, 13014293, 15317648, 17463410, 
	19513126, 21311247, 22933566, 24494680, 25659729, 30517477, 31775927,
 	32733786, 33759394, 37714840, 41527341, 45129591, 48548884, 51700030, 
 	54605117, 57422660, 60519746]#python chromosome cut coordinate

TFs=['ATF3','E2F1','FOXA1','GABPA','HNF4A','JUND','NANOG','TAF1',
'CTCF','EGR1','FOXA2','MAX','REST']


#DNase feature
path1='/state2/hyangl/TF_model/data/feature/'#DNase feature path,g07
ind=chr_num.index(chro)
path_cor='/home/mqzhou/data/prediction/coordinate/'#chr coordinate path
cor=np.load(path_cor+'chr'+str(chro)+'_start.npy')
if ind==0:#chr1
	start1=np.where(cor==start)
else:
	start1=cut[ind-1]+int(np.argwhere(cor==start))+1


order=[0,-1,1,-3,3,-5,5,-7,7,-9,9,-11,11,-13,13]
#15 mean
mean=os.popen("sed -n '%ip' %sanchor_bam_DNAse_largespace/%s "%(int(start1+1),path1,cell))
m=re.split('\t|\n',mean.read())
m.pop()
m=list(map(float,m))#mean
#30 max & min
max_min=os.popen("sed -n '%ip' %sanchor_bam_DNAse_max_min_largespace/%s "%(int(start1+1),path1,cell))
mm=re.split('\t|\n',max_min.read())
mm.pop()
mm=list(map(float,mm))
mmax=mm[:15]#max
mmin=mm[15:]#min

m_plot=[i for _,i in sorted(zip(order,m))]#ordered plot mean
mmax_plot=[i for _,i in sorted(zip(order,mmax))]#ordered plot max
mmin_plot=[i for _,i in sorted(zip(order,mmin))]#ordered plot min



#write r functions
robjects.r('''
plot_original=function(pair,cell,chro,start,filename){
	library('ggplot2')
	path0='/state1/gyuanfan/DNAse_track_avg/'#DNase-seq original path,g06
	f0=paste(path0,cell,'_chr',chro,'.txt',sep='')
	file0=read.table(f0)
	start0=which(file0[,1]==start)
	end0=start0+200
	plot_dat=data.frame(x=c(-100:100),y=file0[start0:end0,2])
	p=ggplot(plot_dat,aes(x=x,y=y))+
		geom_line()+
		labs(x = "", y = "Original read alignment coverage signals", title = "")+
		theme_bw() + 
    	theme(panel.grid =element_blank())
    ggsave(filename=paste('/state2/mqzhou/TF_co/plot/ob/',pair,'/',filename,'.png',sep=''), plot=p,width=7,height=4,dpi=320)
  
}

plot_dnase=function(pair,mean,max,min,filename){
	library('ggplot2')
	x=c(-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13)
	plot_dat=data.frame(X=c(rep(x,3)),Y=c(mean,max,min),labels=c(rep(c('mean','max','min'),each=15))) 
	p1=ggplot(plot_dat,aes(x=X,y=Y,color=labels))+
		geom_line()+geom_point()+
		labs(x = "", y = "DNase Feature", title = "")+
		scale_x_continuous(breaks=x, labels = x*50)+
		theme_bw() + 
   		theme(panel.grid =element_blank())+
    	theme(legend.title = element_blank())
   ggsave(filename=paste('/state2/mqzhou/TF_co/plot/ob/',pair,'/',filename,'.png',sep=''), plot=p1,width=7,height=4,dpi=320)
  
}

plot_motif=function(pair,motif,filename){
	library('ggplot2')
	x=c(0,1,3,5,7,9,11,13)
	plot_dat=data.frame(index=rep(x,13),
		value=as.numeric(c(motif[,1],motif[,2],motif[,3],motif[,4],motif[,5],motif[,6],motif[,7],
			motif[,8],motif[,9],motif[,10],motif[,11],motif[,12],motif[,13])),
		labels=c(rep(colnames(motif),each=8)))

	p2=ggplot(plot_dat,aes(x=index,y=value,color=labels))+
		geom_point(size=4,alpha=0.5)+
		labs(x = "", y = "Motif Feature", title = "")+
		scale_x_continuous(breaks=x, labels =x*50)+
		theme_bw() + 
    	theme(panel.grid =element_blank())+
    	theme(legend.title = element_blank())
	ggsave(filename=paste('/state2/mqzhou/TF_co/plot/ob/',pair,'/',filename,'.png',sep=''), plot=p2,width=7,height=4,dpi=320)
	
}
''')

#DNasee-seq original
robjects.r['plot_original'](pair,cell,chro,start,pair+'_'+'chr'+str(chro)+'_'+str(start)+'_original')


#DNase-seq features
mean_r=robjects.FloatVector(m_plot)
max_r=robjects.FloatVector(mmax_plot)
min_r=robjects.FloatVector(mmin_plot)
robjects.r['plot_dnase'](pair,mean_r,max_r,min_r,pair+'_'+'chr'+str(chro)+'_'+str(start)+'_dnase')

#motif top4 features
#motif feature
motif1 = pd.DataFrame()
motif2 = pd.DataFrame()
motif3 = pd.DataFrame()
motif4 = pd.DataFrame()
for tf in TFs:
	mo=os.popen("sed -n '%ip' %stf_ru_max_top4_rank_largespace/%s "%(int(start1+1),path1,tf))
	m=re.split('\t|\n',mo.read())
	m.pop()
	m=list(map(float,m))
	motif1[tf]=m[:8]
	motif2[tf]=m[8:16]
	motif3[tf]=m[16:24]
	motif4[tf]=m[24:]


motif1_r=pandas2ri.py2ri(motif1)
motif2_r=pandas2ri.py2ri(motif2)
motif3_r=pandas2ri.py2ri(motif3)
motif4_r=pandas2ri.py2ri(motif4)

robjects.r['plot_motif'](pair,motif1_r,pair+'_'+'chr'+str(chro)+'_'+str(start)+'_tf_top1')
robjects.r['plot_motif'](pair,motif2_r,pair+'_'+'chr'+str(chro)+'_'+str(start)+'_tf_top2')
robjects.r['plot_motif'](pair,motif3_r,pair+'_'+'chr'+str(chro)+'_'+str(start)+'_tf_top3')
robjects.r['plot_motif'](pair,motif4_r,pair+'_'+'chr'+str(chro)+'_'+str(start)+'_tf_top4')









