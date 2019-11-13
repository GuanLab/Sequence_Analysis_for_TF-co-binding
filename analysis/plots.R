############ run this part every time before plotting
library('ggplot2')
library('ggpubr')
library('ggsci')
theme_Publication <- function(base_size=14, base_family="helvetica") {
      library(grid)
      library(ggthemes)
      (theme_foundation(base_size=base_size, base_family=base_family)
       + theme(plot.title = element_text(size = rel(1.2), hjust = 0.5),
               text = element_text(),
               panel.background = element_rect(colour = NA),
               plot.background = element_rect(colour = NA),
               panel.border = element_rect(colour = NA),
               axis.title = element_text(size = rel(1)),
               axis.title.y = element_text(angle=90,vjust =2),
               axis.title.x = element_text(vjust = -0.2),
               axis.text = element_text(), 
               axis.line = element_line(colour = "black"),
               axis.ticks = element_line(),
               panel.grid.major = element_line(colour="#f0f0f0"),
               panel.grid.minor = element_blank(),
               legend.key = element_rect(colour = NA),
               legend.position = "bottom",
               legend.direction = "horizontal",
               legend.key.size= unit(0.2, "cm"),
               #legend.margin = unit(0, "cm"),
               legend.title = element_text(face="italic"),
               plot.margin=unit(c(10,5,5,5),"mm"),
               strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
               strip.text = element_text()
          ))
      
}

scale_fill_Publication <- function(...){
      library(scales)
      discrete_scale("fill","Publication",manual_pal(values = c("#386cb0","#fdb462","#7fc97f","#ef3b2c","#662506","#a6cee3","#fb9a99","#984ea3","#ffff33")), ...)

}

scale_colour_Publication <- function(...){
      library(scales)
      discrete_scale("colour","Publication",manual_pal(values = c("#386cb0","#fdb462","#7fc97f","#ef3b2c","#662506","#a6cee3","#fb9a99","#984ea3","#ffff33")), ...)

}

#### figure 1
#### data split
#### xgboost
#### signal plot
#### auroc
#### auprc
#### cases
#### p-value


###############################

#################################  AUROC&AUPRC  ################
load('/state2/mqzhou/TF_co/evaluation/auc_auprc_all.RData')
mean=apply(array_auc, c(2,3), mean)
auroc=as.numeric(mean[,1])
auprc=as.numeric(mean[,2])
tfs=c()
tf1=c()
tf2=c()
cell=c()
for (i in 1:56){
  ind=which(charToRaw(tf_cell[i]) == charToRaw('_'))
  l=length(unlist(strsplit(tf_cell[i],'')))
  TF=substr(tf_cell[i],1,ind[2]-1)
  TF1=substr(tf_cell[i],1,ind[1]-1)
  TF2=substr(tf_cell[i],ind[1]+1,ind[2]-1)
  Cell=substr(tf_cell[i],ind[2]+1,l)
  tfs=c(tfs,TF)
  tf1=c(tf1,TF1)
  tf2=c(tf2,TF2)
  cell=c(cell,Cell)
}
auc=data.frame(tf1=tf1,tf2=tf2,tfs=tfs,cell=cell,auroc=as.numeric(mean[,1]),auprc=as.numeric(mean[,2]))

##########violin plot#########
plot_violin_roc <- function(data){  
	plot <- ggplot(data, aes(y = auroc, group = cell))+     
	geom_violin(aes(x = cell, fill = cell))+     
	geom_boxplot(aes(x = cell), width = 0.1, outlier.size = 0.1)+
	theme_Publication()+     
	stat_summary(fun.y = mean, geom = "point", shape = 10, size = 1, color = "red", aes(x = cell))+     
	facet_wrap(~cell, scales = "free_x", ncol =10)+     
	theme(legend.position = "none", axis.title.x = element_blank(),           
		axis.text.x = element_text(angle = -45, hjust = 0),           
		plot.title = element_text(),           
		strip.background = element_blank(),           
		strip.text = element_blank())+     
	scale_fill_npg()+scale_colour_npg()   
	ggsave(filename='/home/mqzhou/plot/AUROC_violin.png',plot=plot,dpi=320,width=4,height=4)
}
plot_violin_roc(auc)

plot_violin_prc <- function(data){  
	plot <- ggplot(data, aes(y = auprc, group = cell))+     
	geom_violin(aes(x = cell, fill = cell))+     
	geom_boxplot(aes(x = cell), width = 0.1, outlier.size = 0.1)+
	theme_Publication()+     
	stat_summary(fun.y = mean, geom = "point", shape = 10, size = 1, color = "red", aes(x = cell))+     
	facet_wrap(~cell, scales = "free_x", ncol =10)+   
	theme(legend.position = "none", axis.title.x = element_blank(),           
		axis.text.x = element_text(angle = -45, hjust = 0),           
		plot.title = element_blank(),           
		strip.background = element_blank(),           
		strip.text = element_blank())+     
	scale_fill_npg()+scale_colour_npg()   
	ggsave(filename='/home/mqzhou/plot/AUPRC_violin.png',plot=plot,dpi=320,width=4,height=4)
}
plot_violin_prc(
	)

###########scatter plot#############
plot_point_roc=function(data){
  plot=ggplot(data=data,aes(x = tfs, y = auroc,color=cell))+
  geom_point(size=2)+
  xlab('TF pairs')+ggtitle('AUROC in Different TF-TF pairs')+
  theme_Publication()+
  theme(panel.grid =element_blank())+
  theme(axis.title.x=element_text(size=12),
        axis.title.y=element_text(size=12),
        axis.text.y = element_text(size = 12),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank())+
  scale_fill_npg()+scale_colour_npg()
  ggsave(filename='/home/mqzhou/plot/AUROC_point2.png',plot=plot,dpi=320,width=6,height=4)
}
plot_point_roc(auc)

plot_point_prc=function(data){
  plot=ggplot(data=data,aes(x = tfs, y = auprc,color=cell))+ 
  geom_point(size=2)+  
  xlab('TF pairs')+ggtitle('AUPRC in Different TF-TF pairs')+
  theme_Publication()+
  theme(panel.grid =element_blank())+
  theme(axis.title.x=element_text(size=12),
        axis.title.y=element_text(size=12),
        axis.text.y = element_text(size = 12),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank())+
 scale_fill_npg()+scale_colour_npg()
  ggsave(filename='/home/mqzhou/plot/AUPRC_point.png',plot=plot,dpi=320,width=4,height=4)
}
plot_point_prc(auc)

##############typical ROC&PR line plot##############
#roc
load("/state2/mqzhou/TF_co/evaluation/auc_auprc_all.RData")
roc12_dat=as.data.frame(list_plot[[1]]$roc12$curve)#first column recall, second col precision
roc21_dat=as.data.frame(list_plot[[1]]$roc21$curve)

plot=ggplot()+
	geom_line(data=roc12_dat,aes(x=V1,y=V2),color='#2E4075')+
	geom_line(data=roc21_dat,aes(x=V1,y=V2),color='#2E4075')
for (i in 2:56){
	roc12_dat=as.data.frame(list_plot[[i]]$roc12$curve)#first column recall, second col precision
    roc21_dat=as.data.frame(list_plot[[i]]$roc21$curve)
    plot=plot+
    geom_line(data=roc12_dat,aes(x=V1,y=V2),color='#2E4075')+
	geom_line(data=roc21_dat,aes(x=V1,y=V2),color='#2E4075')
}

plot=plot+
	geom_abline(intercept = 0, slope = 1, linetype="dashed")+
	#geom_text(aes(0.65,0.45,label ='baseline:', vjust = -1),size=6)+
	#geom_text(aes(0.6,0.4,label ='0.5', vjust = -1),size=6)+
	xlab('FPR')+ylab('Sensitivity')+ggtitle('ROC Curve')+
	theme_Publication()+
    #theme(panel.grid =element_blank())+
    theme(axis.title.x=element_text(size=12),
        axis.title.y=element_text(size=12),
        axis.text = element_text(size = 12),
        legend.position = 'none') 
ggsave(filename='/home/mqzhou/plot/ROC_curve.png',plot=plot,dpi=320,width=4,height=4)


#pr
load("/state2/mqzhou/TF_co/evaluation/auc_auprc.RData")#####reload data
pr12_dat=as.data.frame(list_plot[[1]]$pr12$curve)#first column recall, second col precision
pr21_dat=as.data.frame(list_plot[[1]]$pr21$curve)
#pr12_dat=pr12_dat[pr12_dat$V1>0.01,]
#pr21_dat=pr21_dat[pr21_dat$V1>0.01,]

plot=ggplot()+
	geom_line(data=pr12_dat,aes(x=V1,y=V2),color='#129174',size=0.3,alpha=0.7)+
	geom_line(data=pr21_dat,aes(x=V1,y=V2),color='#129174',size=0.3,alpha=0.7)

for (i in 2:56){
	pr12_dat=as.data.frame(list_plot[[i]]$pr12$curve)#first column recall, second col precision
    pr21_dat=as.data.frame(list_plot[[i]]$pr21$curve)
    #pr12_dat=pr12_dat[pr12_dat$V1>0.0001,]
    #pr21_dat=pr21_dat[pr21_dat$V1>0.0001,]
    print(min(pr12_dat$V1))
    print(min(pr21_dat$V1))
    plot=plot+
    geom_line(data=pr12_dat,aes(x=V1,y=V2),color='#129174',size=0.3,alpha=0.7)+
	geom_line(data=pr21_dat,aes(x=V1,y=V2),color='#129174',size=0.3,alpha=0.7)
}

plot=plot+
	geom_hline(yintercept=0.0003067435, linetype="dashed")+
	xlab('Recall')+ylab('Precision')+ggtitle('PR Curve')+
	theme_Publication()+
    theme(axis.title.x=element_text(size=12),
        axis.title.y=element_text(size=12),
        axis.text = element_text(size = 12),
        legend.position = 'none')  
ggsave(filename='/home/mqzhou/plot/PR_curve_0.png',plot=plot,dpi=320,width=4,height=4)


##################### traget VS prediction signal plot##################

signal_plot=function(t1,p11,p21,cut1){
  star1=summary(which(t1>0.9))[2]
  end1=summary(which(t1>0.9))[3]
  w1=c(rep(0.2,end1-star1+1))
  w1[which(t1[star1:end1]>cut1)]=0.8
  ind1=sample(star1:end1,1000,prob=w1,replace=F)#sample index
  t1_s=t1[ind1]
  p21_s=p21[ind1]
  p11_s=p11[ind1]

  p1=ggplot()+
  	geom_segment(aes(x=ind1,xend=ind1,y=0,yend=(p11_s+p21_s)/2),color='#3C5488FF')+
  	#geom_segment(aes(x=ind1,xend=ind1,y=0,yend=p21_s),color='#3C5488FF')+
  	xlab('position')+ylab('prediction')+ggtitle('')+
  	theme_Publication()+
  	theme(panel.grid =element_blank())+
  	theme(axis.title.x=element_text(size=12),
        axis.title.y=element_text(size=12),
        axis.text.y = element_text(size = 12),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank())

  p2=ggplot()+
      geom_segment(aes(x=ind1,xend=ind1,y=0,yend=t1_s),color='#DC0000FF')+
      xlab('position')+ylab('prediction')+ggtitle('Target vs Prediction of JUND-MAX')+
  	theme_Publication()+
  	theme(panel.grid =element_blank())+
  	theme(axis.title.x=element_text(size=12),
        axis.title.y=element_text(size=12),
        axis.text.y = element_text(size = 12),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank())

  ggsave(filename='/home/mqzhou/plot/pred_signal.png',plot=p1,dpi=320,width=6,height=3)
  ggsave(filename='/home/mqzhou/plot/true_signal.png',plot=p2,dpi=320,width=6,height=3)

}

p21=scan("/state2/hyangl/TF_co/evaluation/prediction/JUND_MAX_K562_set2_model_set1_test.txt")
p11=scan("/state2/hyangl/TF_co/evaluation/prediction/JUND_MAX_K562_set1_model_set1_test.txt")
t1=scan("/state2/hyangl/TF_co/evaluation/target/JUND_MAX_K562_set1.txt")
p12=scan("/state2/hyangl/TF_co/evaluation/prediction/JUND_MAX_K562_set1_model_set2_test.txt")
p22=scan("/state2/hyangl/TF_co/evaluation/prediction/JUND_MAX_K562_set2_model_set2_test.txt")
t2=scan("/state2/hyangl/TF_co/evaluation/target/JUND_MAX_K562_set2.txt")

signal_plot(t1,p11,p21,0.9963)


signal_plot(t2,p12,p22,'JUND_MAX_K562',2,0.9963,0.9937)

############### tf B ratio heatmap
counts=read.table('/home/mqzhou/data/counts.tsv',sep='\t',header=T)
cell=levels(counts$Cell)
tfs=c("ATF3",levels(counts$TF2))
tfs=sort(tfs)
h=counts[,c(1,2,4)]
tf_heatmap=data.frame(TF1=c(),TF2=c(),ratio=c())
for (i in 1:12){
  for (j in (i+1):13){
    tf1=tfs[i];tf2=tfs[j]
    b=mean(h[(h$TF1==tf1&h$TF2==tf2)|(h$TF1==tf2&h$TF2==tf1),3])
    if (is.na(b)==FALSE){
      tf_heatmap=rbind(tf_heatmap,data.frame(TF1=as.character(tf1),TF2=as.character(tf2),ratio=as.numeric(b/51676736)))
    }
    else{ tf_heatmap= tf_heatmap}
  }
}
dat_rep=data.frame(TF1=tfs,TF2=tfs,ratio=rep(NA,13))
tf_heatmap=rbind(tf_heatmap,dat_rep)
tf_heatmap$TF1=factor(tf_heatmap$TF1,levels=tfs)
tf_heatmap$TF2=factor(tf_heatmap$TF2,levels=tfs)

library(wesanderson)
pal <- wes_palette("Zissou1", 100, type = "continuous")
p=ggplot(tf_heatmap, aes(x = TF1, y = TF2, fill = ratio)) +
  geom_tile() + 
  ggtitle('Co-Bound Ratio in TF-TF pairs')+
  theme_Publication()+  
  theme(axis.text.x =element_text(angle = -45, hjust = 0),
        legend.title=element_text('Ratio',size=10),
        legend.position='right',
        legend.direction = "vertical",
        legend.key.height= unit(0.6, "cm"),
        panel.grid =element_blank())+  
  scale_fill_gradientn(colours =pal,na.value = "#FFFFFF" ) + 
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) + 
  coord_equal() 
ggsave(filename='/home/mqzhou/plot/tf_heatmap.png',plot=p,dpi=320,width=5,height=5)

############### cell B ratio histogramt
cell_b=data.frame(cell=character(),label=character(),counts=numeric())
for (i in 1:10){
  b=colMeans(counts[counts$Cell==cell[i],4:6])
  cell_b=rbind(cell_b,
               data.frame(cell=cell[i],label='B',counts=(as.numeric(b[1]))) )
  #cell_b=rbind(cell_b,
               #data.frame(cell=cell[i],label='A',counts=(as.numeric(b[2]))) )
  cell_b=rbind(cell_b,
               data.frame(cell=cell[i],label='U',counts=(as.numeric(b[3]))) )
}

#cell_b=data.frame(x=cell,y=cell_b)
plot1=ggplot(cell_b,aes(x=cell,y=log2(counts)))+
  geom_bar(aes(fill=label),stat='identity')+
  xlab('Cell lines')+ylab('Counts')+ggtitle('log(count) in Different Cell Lines')+
  theme_Publication()+
  theme(axis.text.x =element_text(angle = -45, hjust = 0),
  	    legend.position='right',
        legend.direction = "vertical",
        legend.title=element_text('Label',size=10),
        legend.key.height= unit(0.4, "cm"),
        legend.key.width= unit(0.4, "cm"))+
  scale_fill_manual(values=c('#4DBBD5FF','#00A087FF'))
ggsave(filename='/home/mqzhou/plot/cell_counts.png',plot=plot1,dpi=320,width=5,height=5)


########################### p-value scatter plot 
pv=read.csv('/state2/mqzhou/TF_co/data/wilcox_test/p_value.txt',sep=' ',header=FALSE)
p1=ggplot(pv,aes(x=V1,y=log10(V2)))+
   xlab('TF-TF pair')+ylab('log10(p-value)')+ggtitle('log(P vallue) of Wilcoxon Test')+
	geom_point(color='#3C5488FF')+
	theme_Publication()+
	theme(panel.grid =element_blank())+
	theme(axis.text.x=element_blank(),
		axis.ticks.x=element_blank())

ggsave(filename='/home/mqzhou/plot/wil_pv.png',plot=p1,dpi=320,width=4,height=4)

########################### p-value heatmap
p_value=read.csv('/state2/mqzhou/TF_co/data/wilcox_test/p_value.txt',sep=' ',header=FALSE)
tf1=c();tf2=c()
for (i in 1:56){
  t1=strsplit(as.character(p_value$V1[i]),"_")[[1]][1]
  t2=strsplit(as.character(p_value$V1[i]),"_")[[1]][2]
  tf1=c(tf1,t1)
  tf2=c(tf2,t2)
}
ph=data.frame(TF1=tf1,TF2=tf2,pv=p_value$V2)
#ph2=ph;ph2$TF1=ph$TF2;ph2$TF2=ph$TF1
#ph=rbind(ph,ph2)
counts=read.table('/home/mqzhou/data/counts.tsv',sep='\t',header=T)
cell=levels(counts$Cell)
tfs=c("ATF3",levels(counts$TF2))
for (i in 1:13){
  for (j in 1:13){
    t1=tfs[i];t2=tfs[j]
    b=ph[(ph$TF1==t1&ph$TF2==t2)|(ph$TF1==t2&ph$TF2==t1),3]
    if (identical(b,numeric(0))==FALSE){
      ph=ph
    }
    else{ ph= rbind(ph,data.frame(TF1=as.character(t1),TF2=as.character(t2),pv=NA))}
  }
}
le=c("ATF3",  "CTCF",  "E2F1" , "EGR1" , "FOXA1" ,"FOXA2" ,"GABPA" ,"HNF4A" ,"JUND", "MAX" ,  "NANOG" ,"REST" , "TAF1")
ph$TF1=factor(ph$TF1,levels=le)
ph$TF2=factor(ph$TF2,levels=le)
dat_rep=data.frame(TF1=le,TF2=le,pv=rep(NA,13))
ph=rbind(ph,dat_rep)
#ph$TF1=factor(ph$TF1,levels=sort(levels(ph$TF1)))
#ph$TF2=factor(ph$TF2,levels=sort(levels(ph$TF2)))
library(wesanderson)
pal <- wes_palette("Zissou1", 100, type = "continuous")
p=ggplot(ph, aes(x = TF1, y = TF2, fill = -log2(pv))) +
  geom_tile() + 
  ggtitle('-log2(p-value)')+
  theme_Publication()+  
  theme(axis.text.x =element_text(angle = -45, hjust = 0),
        legend.title=element_blank(),
        legend.position='right',
        legend.direction = "vertical",
        legend.key.height= unit(0.6, "cm"),
        panel.grid =element_blank())+  
  scale_fill_gradientn(colours =pal,na.value = "#FFFFFF" ) + 
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) + 
  coord_equal() 
ggsave(filename='/home/mqzhou/plot/pv_heatmap.png',plot=p,dpi=320,width=5,height=5)


######################## test box-plot

library(ggpubr)
plot_pv=function(pair){
 dat=read.csv(paste('/state2/mqzhou/TF_co/data/wilcox_test/',pair,'_wilcox_data.txt',sep=''),sep=' ')
 colnames(dat)=c('co_bind','single_product')
 plot_dat=as.data.frame(matrix(c(dat[,1],dat[,2]),ncol=1))
 plot_dat=cbind(plot_dat,c(rep(c('co-bind','single-product'),each=dim(dat)[1])))
 colnames(plot_dat)=c('value','group')
 plot=ggboxplot(plot_dat, x = "group", y = "value",
         color = "group",palette = c("#00A087FF","#4DBBD5FF"),add = "jitter")+
  xlab('')+ylab('')+ggtitle(pair)+
  stat_compare_means(paired = TRUE,label.x=1.2,label.y=max(plot_dat$value)*1.1,size=4)+
  theme_Publication()+
   theme(legend.position='none')

  ggsave(filename=paste('/home/mqzhou/plot/',pair,'_pvalue.png',sep=''),plot=plot,dpi=320,width=4,height=4)

}

plot_pv('ATF3_JUND')
plot_pv('FOXA2_HNF4A')
plot_pv('EGR1_MAX')
plot_pv('FOXA1_HNF4A')

#for (p in pair){plot_pv(p)}

################## figure 1 -- DNA sequence heatmap
library(reshape2)
library(RcppCNPy)
'cd /home/hyangl/TF_co/data/scan_motif/'
p=npyLoad('CTCF_chr21.npy')
f=p[39531500:39531700]
pl=matrix(f[-1],ncol=20)
m_pl=melt(pl)
library(wesanderson)
pal <- wes_palette("Zissou1", 100, type = "continuous")

plot=ggplot(data = m_pl, aes(x=Var1, y=Var2, fill=value)) + 
  geom_tile()+
  theme_Publication()+
  theme(panel.grid =element_blank())+
  theme(axis.ticks=element_blank(),
  	axis.text=element_blank(),
  	axis.title=element_blank(),
  	legend.position='none')+
  scale_fill_gradient(low = "white", high = "#00A087FF")+
  #scale_fill_gradientn(colours =c('#3C548819','#3C5488FF'),na.value = "#FFF" ) + 
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) 
  ggsave(file='/home/mqzhou/plot/f1f.png',plot=plot,dpi=320,width=5,height=3)


###################### train & test split scatterplot
#cd /home/mqzhou/data
TF_cell=read.csv('TF-cell.csv')
cobind=read.csv('cobind.csv')
rownames(TF_cell)=TF_cell[,1]
TF_cell=TF_cell[,-1]
TF_cell[is.na(TF_cell)] <- 0
rownames(cobind)=cobind[,1]
cobind=cobind[,-1]
TF_pairs=c()#Y
cellLines=c()#X
for (i in 1:nrow(cobind)){
  x=which(cobind[i,]==1)
  y=rep(i,length(x))
  cellLines=c(cellLines,x)
  TF_pairs=c(TF_pairs,y)
}

plot_data=data.frame('TF_TF'=TF_pairs,'Cell_Line'=cellLines)
rownames(plot_data)=NULL
attach(plot_data)
for (i in 1:56){
  for (j in 1:10){
    plot_data[which(plot_data[,1]==i),1]=rownames(cobind)[i]
    plot_data[which(plot_data[,2]==j),2]=colnames(cobind)[j]
  }
}
test=c(4,4,3,4,4,1,1,2,2,8,2,7,1,9,
       1,1,2,2,5,5,5,5,8,7,2,4,2,7,
       10,8,10,8,10,8,10,10,10,6,6,
       6,6,6,3,2,3,3,6,6,10,6,7,7,5,1,3,3)#test labels 
test_labels=colnames(cobind)[test]
labels=c()
for (i in 1:length(TF_pairs)){
  tfs=plot_data[i,1]
  cell=plot_data[i,2]
  ind=which(rownames(cobind)==tfs)
  if (cell==test_labels[ind]){
    labels=c(labels,'Test')
  }
  else{ labels=c(labels,'Train')}
}
plot_data$Labels=labels

p <- ggplot(data=plot_data,mapping=aes(x=TF_TF,y=Cell_Line,col=Labels))+
  geom_point()+
  labs(x='TF-TF pairs',y='Cell Lines')+
  theme_Publication()+
  theme(plot.title=element_blank(),
        axis.text = element_blank(),
        axis.ticks=element_blank(),
        panel.background = element_blank(),
        legend.position = "right",
        legend.direction = "vertical",   
        legend.key = element_rect(fill="white", color = NA))+
  scale_colour_npg()
ggsave(filename='/home/mqzhou/plot/split.png',plot=p,dpi=320,width=4,height=4)

################# figure 1
cells=c('A549','GM12878','H1-hESC','HCT116','HeLa-S3','HepG2','K562','MCF-7','iPSC','liver')
test=c(6,8, 6,5,5,8,5,5,1,7)
train=c(9,20,23,5,16,32,30,10,0,27)
df=data.frame(cell=c(rep(cells,2)),counts=c(train,test),label=c(rep('train',10),rep('test',10)))

plot1=ggplot(df,aes(x=cell,y=counts))+
  geom_bar(aes(fill=label),stat='identity')+
  xlab('Cell lines')+ylab('')+ggtitle('')+
  theme_Publication()+
  theme(panel.grid =element_blank())+
  theme(axis.text.x =element_text(angle = -45, hjust = 0),
        legend.position='right',
        legend.direction = "vertical",
        legend.title=element_blank(),
        legend.key.height= unit(0.4, "cm"),
        legend.key.width= unit(0.4, "cm"))+
   scale_fill_manual("legend", values = c("train" = "#00A087FF", "test" = "#3C5488FF"))
ggsave(filename='/home/mqzhou/plot/cell_split.png',plot=plot1,dpi=320,width=4,height=4)

##################### f1 dna sequence heatmap
pwm2=matrix(c(0.174,  -0.04,  0.425,  -1.138,
  0.504,  -0.584, 0.206,  -0.584,
  -1.0, -0.016, 0.904,  -1.725,
  -2.484, 1.357,  -4.4, -3.903,
  1.313,  -3.573, -1.489, -3.573,
  -3.903, 1.187,  -0.958, -1.138,
  -1.022, -2.694, 1.263,  -3.325,
  -0.841, -0.737, -3.325, 1.117,
  -3.903, -3.573, 1.363,  -3.126,
  -0.584, -1.022, 0.917,  -0.543),ncol=4,byrow=T)

pwm1=matrix(c(  -0.059, -0.495, 0.534,  -0.299,
0.459 ,-0.412,  0.448,  -1.667,
-2.132, -3.809, -2.482, 1.329,
-3.226, -3.027, 1.329,  -1.994,
1.322,  -3.226, -2.292, -2.209,
-1.351, -4.313, 1.312,  -4.313,
-2.718, -2.718, -2.718, 1.336,
-2.209, 1.307,  -1.715, -4.313,
1.365,  -3.476, -3.226, -4.313,
-1.817, 0.426,  -0.524, 0.539,
-0.495, 0.497,  -0.386, 0.064),ncol=4,byrow=T)
#sample(c(1,2,3,4),size=20,replace = T)
dna=matrix(c(0,0,1,0,
0,0,1,0,
1,0,0,0,
1,0,0,0,
0,0,0,1,
1,0,0,0,
0,1,0,0,
1,0,0,0,
0,0,0,1,
0,0,0,1,
1,0,0,0,
0,0,1,0,
0,1,0,0,
0,1,0,0,
1,0,0,0,
0,0,1,0,
1,0,0,0,
0,1,0,0,
0,0,0,1,
0,0,0,1),nrow=4,byrow=F)

pd1=pwm1%*%dna
pd2=pwm2%*%dna
library(reshape2)
p=ggplot(melt(dna),aes(Var1,Var2, fill=value))+
  geom_raster()+
  theme_Publication()+
  theme_linedraw()+
  scale_fill_gradient(low = "white", high = "#F39B7FFF")+
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) 
ggsave(filename='/home/mqzhou/plot/dna_motif.png',plot=p,dpi=320,width=4,height=8)

############### feature importance--3 categories #################################
#cd /state2/hyangl/TF_co/feature_importance
load('co_H_fi.RData')
#### 三大类
distance=apply(mat_fi[1:20,],2,mean)
motif=apply(mat_fi[21:436,],2,mean)
dnase=apply(mat_fi[437:526,],2,mean)
feature=rep(NA,78*3)
for (i in 1:234){
  if (i%%3==1){feature[i]=as.numeric(distance[i%/%3+1])}
  else {
    if (i%%3==2){feature[i]=as.numeric(motif[i%/%3+1])}
    else{feature[i]=as.numeric(dnase[i%/%3])}
  }
}
label=c(rep(c('distance','motif','dnase'),78))
a=rbind(c(rep(colnames(mat_fi),each=3)),feature,label)
b=t(a);rownames(b)=NULL
mat=data.frame(TFs=b[,1],f_importance=as.numeric(b[,2]),label=b[,3])
dat=mat[mat[,2]!=0,];rownames(dat)=NULL

plot1=ggplot(dat,aes(x=TFs,y=f_importance))+
  geom_bar(aes(fill=label),stat='identity')+
  xlab('TF-TF pairs')+ylab('Feature importance')+ggtitle('Feature Importance')+
  theme_Publication()+
  theme(axis.text.x =element_blank(),
        axis.ticks.x=element_blank(),
        legend.position='right',
        legend.direction = "vertical",
        legend.title=element_text('Label',size=10),
        legend.key.height= unit(0.4, "cm"),
        legend.key.width= unit(0.4, "cm"))+
  scale_fill_manual(values=c('#91D1C2FF','#00A087FF','#3C5488FF'))
ggsave(filename='/home/mqzhou/plot/f_importance.png',plot=plot1,dpi=320,width=6,height=4)

########################### pie chart #############################
library(wesanderson)
cells=c('A549','GM12878','H1-hESC','HCT116','HeLa-S3','HepG2','K562','MCF-7','iPSC','liver')
num=c(6,8,9,5,7,10,9,6,2,9)
df=data.frame(Cell=cells,ChIPseq=num)
pie_plot= ggplot(df, aes(x="", y=ChIPseq, fill=Cell))+
  geom_bar(width = 1,stat="identity")+
  coord_polar("y")+
  theme_Publication()+
  scale_color_manual(values=wes_palette(n=10, name="Zissou1"))+
  theme(axis.text=element_blank(),
        axis.ticks=element_blank(),
        panel.border=element_blank(),
        panel.grid=element_blank(),
        legend.position = "right",
        legend.direction = "vertical")
ggsave(filename='/home/mqzhou/plot/pie.png',plot=pie_plot,dpi=320,width=4,height=4)


################################# feature importance #############################
#cd /state2/hyangl/TF_co/feature_importance
#load('co_H_fi.RData')
del_fi=mat_fi[,colSums(mat_fi)!=0]#delete 0 colmns

###########  3M & delta 3M
library(data.table)
library(scales)
plot_3m=function(dat,color,name){
  m_mat=dat[c(14,12,10,8,6,4,2,1,3,5,7,9,11,13,15),]#reorder
  m_mat=apply(m_mat,2,rescale) #rescale 
  org_label=rownames(m_mat)
 p=ggplot(melt(m_mat),aes(Var1,Var2, fill=value))+
  geom_raster()+
  ggtitle(name)+
  theme_Publication()+
  theme_linedraw()+
  theme(
  	    axis.text.y =element_text(size=9),
        axis.text.x =element_text(angle = -45, hjust = 0),
        axis.ticks.y=element_blank(),
        axis.title = element_blank(),
        legend.position='right',
        legend.direction = "vertical",
        legend.title=element_blank())+
  scale_fill_gradient(low = "white", high = color)+
  scale_x_discrete(name=org_label,labels =c(-650,-550,-450,-350,-250,-150,-50,0,50,150,250,350,450,550,650) )
ggsave(filename=paste('/home/mqzhou/plot/',name,'_fi.png',sep=''),plot=p,dpi=320,width=4,height=3)

}

mean=del_fi[437:451,]
delta_mean=del_fi[452:466,]
max=del_fi[467:481,]
min=del_fi[482:496,]
delta_max=del_fi[497:511,]
delta_min=del_fi[512:526,]

plot_3m(mean,'#8491B4FF','mean')
plot_3m(max,'#3C5488FF','max')
plot_3m(min,'#91D1C2FF','min')
#plot_3m(delta_max,'#E64B35FF','delta_max')
#plot_3m(delta_min,'#fdb462','delta_min')
#plot_3m(delta_mean,'#3C5488FF','delta_mean')

#########  distance
dist=del_fi[1:20,]

p=ggplot(melt(dist),aes(Var1,Var2, fill=value))+
  geom_raster()+
  ggtitle('distance')+
  theme_Publication()+
  theme_linedraw()+
  theme(
  	    axis.text.y =element_blank(),
        axis.text.x =element_text(angle = -45, hjust = 0),
        axis.ticks.y=element_blank(),
        axis.title = element_blank(),
        legend.position='right',
        legend.direction = "vertical",
        legend.title=element_blank())+
  scale_fill_gradient(low = "white", high = 'blue')+
  scale_x_discrete(name=rownames(dist),labels =1:20 )
ggsave(filename=paste('/home/mqzhou/plot/','distance','_fi.png',sep=''),plot=p,dpi=320,width=4,height=3)

############### pair motif
library(scales)
motif_fi=del_fi[21:436,]
motif_fi_avg=data.frame(t(rep(NA,56)))
for (i in 1:13){
  tf=rescale(apply(motif_fi[((i-1)*32+1):(i*32),],2,mean))#rescale row
  #tf=apply(motif_fi[((i-1)*32+1):(i*32),],2,mean)#non-rescale
  motif_fi_avg=rbind(motif_fi_avg,tf)
}
colnames(motif_fi_avg)=colnames(motif_fi)
motif_fi_avg=motif_fi_avg[-1,]
motif_fi_avg=as.data.frame(cbind(TF=sort(c( "ATF3",  "CTCF" , "EGR1",  "GABPA", "JUND" ,"MAX",
                               "REST","TAF1","E2F1","FOXA1","NANOG","FOXA2","HNF4A")),motif_fi_avg))

p=ggplot(melt(motif_fi_avg,id.vars='TF'),aes(TF, variable, fill=value))+
  geom_raster()+
  ggtitle('TF motif')+
  theme_Publication()+
  theme_linedraw()+
  theme(
    axis.text.y =element_text(size=4),
    axis.text.x =element_text(angle = -45, hjust = 0),
    axis.ticks.y=element_blank(),
    axis.title = element_blank(),
    legend.position='right',
    legend.direction = "vertical",
    legend.title=element_blank())+
  scale_fill_gradient(low = "white", high = '#DC0000FF')
ggsave(filename=paste('/home/mqzhou/plot/','motif','_fi.png',sep=''),plot=p,dpi=320,width=4,height=3)

###########  heatmap of clustered 3M features
#cd /state2/hyangl/TF_co/feature_importance
#load('co_H_fi.RData')
del_fi=mat_fi[,colSums(mat_fi)!=0]#delete 0 colmns
mean=del_fi[437:451,]
max=del_fi[467:481,]
min=del_fi[482:496,]
pal<-colorRampPalette(c("white",'#8491B4FF','#F39B7FFF',"#E64B35FF"))(256)

ord_max=max[c(14,12,10,8,6,4,2,1,3,5,7,9,11,13,15),]
ord_mean=mean[c(14,12,10,8,6,4,2,1,3,5,7,9,11,13,15),]
ord_min=min[c(14,12,10,8,6,4,2,1,3,5,7,9,11,13,15),]
pheatmap(t(ord_max), cutree_rows = 5,cluster_cols=F,color = pal)
pheatmap(t(ord_min), cutree_rows = 5,cluster_cols=F,color = pal)
pheatmap(t(ord_mean), cutree_rows = 5,cluster_cols=F,color = pal)


suppressPackageStartupMessages(library(dendextend))
hclust_avg <- hclust(dist(t(mean)))
avg_dend_obj <- as.dendrogram(hclust_avg,lwd=3,edgePar=(lwd=3))
avg_dend_obj %>% set("branches_lwd", 3) %>% color_branches(k=5,col=rev(c('#704191','#4DBBD5FF','#00A087FF','#7E6148FF','#91D1C2FF')))%>%plot #get dendrogram tree

##############################  f6 figure

hclust_avg <- hclust(dist(t(mean)))

clu=hclust_avg$labels[hclust_avg$order]
# clust1=clu[50:56]#GABPA
# clust2=clu[c(2,4,6,7,9,10,13,15,17)]#FOXA
# clust3=clu[c(22:24,26:28,30:34,39,46,48)]#CTCF JUND
# clust4=clu[c(2,4,6,7,9,10,13,15,17,22:24,26:28,30:34,39,46,48,50:56)]
clust1=clu[50:56]#GABPA
clust2=clu[2:17]#FOXA
clust3=clu[c(1,18:49)]#CTCF JUND


c1_fi=ord_mean[,match(clust1,colnames(ord_mean))]
c2_fi=ord_mean[,match(clust2,colnames(ord_mean))]
c3_fi=ord_mean[,match(clust3,colnames(ord_mean))]
#c4_fi=ord_mean[,match(clust4,colnames(ord_mean))]

#library(scales)
#c1_re=apply(c1_fi,1,rescale)
#c2_re=apply(c2_fi,1,rescale)
#c3_re=apply(c3_fi,1,rescale)
#c4_re=apply(c4_fi,1,rescale)
#re_mean=apply(ord_mean,1,rescale)

c_sum=data.frame(sum1=rowMeans(c1_fi),sum2=rowMeans(c2_fi),sum3=rowMeans(c3_fi),sum4=rowMeans(ord_mean)
	#,sum5=rowMeans(c4_re)
	)
plot1=ggplot(c_sum,aes(x=rownames(c_sum),y=sum1))+
  geom_bar(stat='identity',fill='#704191',alpha=0.8)+
  xlab('position')+ylab('Feature importance')+
  #ylim(0,0.0045)+
  theme_Publication()+
  theme(axis.text.x =element_text(angle = -45, hjust = 0),
        axis.title = element_blank())+
  theme(panel.grid =element_blank())+
  scale_x_discrete(name=rownames(c_sum),labels =c(-650,-550,-450,-350,-250,-150,-50,0,50,150,250,350,450,550,650) )
ggsave(filename='/home/mqzhou/plot/f6-2.png',plot=plot1,dpi=320,width=4,height=2)

plot2=ggplot(c_sum,aes(x=rownames(c_sum),y=sum2))+
  geom_bar(stat='identity',fill='#836F2C')+
  xlab('position')+ylab('Feature importance')+
  #ylim(0,0.0045)+
  theme_Publication()+
  theme(axis.text.x =element_text(angle = -45, hjust = 0),
        axis.title = element_blank(),
        axis.text = element_text(size = 12))+
  theme(panel.grid =element_blank())+
  scale_x_discrete(name=rownames(c_sum),labels =c(-650,-550,-450,-350,-250,-150,-50,0,50,150,250,350,450,550,650) )
ggsave(filename='/home/mqzhou/plot/f6-3.png',plot=plot2,dpi=320,width=4,height=2)

plot3=ggplot(c_sum,aes(x=rownames(c_sum),y=sum3))+
  geom_bar(stat='identity',fill='#25998A')+
  xlab('position')+ylab('Feature importance')+
  #ylim(0,0.0045)+
  theme_Publication()+
  theme(panel.grid =element_blank())+
  theme(axis.text.x =element_text(angle = -45, hjust = 0),
        axis.title = element_blank(),
        axis.text = element_text(size = 12))+
  scale_x_discrete(name=rownames(c_sum),labels =c(-650,-550,-450,-350,-250,-150,-50,0,50,150,250,350,450,550,650) )
ggsave(filename='/home/mqzhou/plot/f6-4.png',plot=plot3,dpi=320,width=4,height=2)


plot5=ggplot(c_sum,aes(x=rownames(c_sum),y=sum4))+
  geom_bar(stat='identity',fill='#3C5488FF')+
  xlab('position')+ylab('Feature importance')+
  #ylim(0,0.0045)+
  theme_Publication()+
  theme(panel.grid =element_blank())+
  theme(axis.text.x =element_text(angle = -45, hjust = 0),
        axis.title = element_blank(),
        axis.text = element_text(size = 12))+
  scale_x_discrete(name=rownames(c_sum),labels =c(-650,-550,-450,-350,-250,-150,-50,0,50,150,250,350,450,550,650) )
ggsave(filename='/home/mqzhou/plot/f6-5.png',plot=plot5,dpi=320,width=4,height=2)

# plot6=ggplot(c_sum,aes(x=rownames(c_sum),y=sum5))+
#   geom_bar(stat='identity',fill='yellow')+
#   xlab('position')+ylab('Feature importance')+ylim(0,0.0045)+
#   theme_Publication()+
#   theme(panel.grid =element_blank())+
#   theme(
#         axis.text.x =element_text(angle = -45, hjust = 0),
#         axis.title = element_blank())+
#   scale_x_discrete(name=rownames(c_sum),labels =c(-650,-550,-450,-350,-250,-150,-50,0,50,150,250,350,450,550,650) )
# ggsave(filename='/home/mqzhou/plot/f6-6.png',plot=plot6,dpi=320,width=6,height=4)


plot7=ggplot(c_sum,aes(x=rownames(c_sum)))+
      geom_line(aes(y=sum1),group=1,color='#704191',alpha=0.5,size=1.2)+
      geom_line(aes(y=sum2),group=1,color='#836F2C',size=1.2,alpha=0.7)+
      geom_line(aes(y=sum3),group=1,color='#25998A',size=1.2,alpha=0.7)+
      geom_line(aes(y=sum4),group=1,color='#3C5488FF',size=1.2,alpha=0.7)+
      theme_Publication()+
      theme(axis.text.x =element_text(angle = -45, hjust = 0),
            axis.title = element_blank(),
            axis.text = element_text(size = 12))+
      scale_x_discrete(name=rownames(c_sum),labels =c(-650,-550,-450,-350,-250,-150,-50,0,50,150,250,350,450,550,650) )
ggsave(filename='/home/mqzhou/plot/f6-7.png',plot=plot7,dpi=320,width=4,height=2)

############################################## supp   ##################

######## barplot B/A/U counts in all pairs
#cd data
library(data.table)
counts=read.table(file='counts.tsv',sep='\t',header=T)
rownames(counts)=NULL

TFs=unique(cbind(as.character(counts$TF1),as.character(counts$TF2)))
H=data.frame(B=0,A=0,U=0)
pair=c()
  for (i in 1:56){
    tf1=TFs[i,1]
    tf2=TFs[i,2]
    h=colSums(counts[which(counts$TF1==tf1 & counts$TF2==tf2),4:6])
    h=log(h)#log counts
    H=rbind(H,h)
    pair=c(pair,paste(tf1,'_',tf2,sep=''))
  }
H=H[-1,]
H$pair=pair
plot=ggplot(melt(H),group=pair,aes(fill=variable))+
  geom_bar(stat='identity',aes(x=variable,y=value))+
  ylab('log(B/A/U) counts')+xlab('')+ggtitle('log(B/A/U) counts in TF-TF pairs')+
  facet_wrap(~pair, scales = "free_x", ncol =7)+
  scale_fill_manual(values=c('#4DBBD5FF','#91D1C2FF','#00A087FF'))+
  theme_Publication()+
  theme(strip.background = element_rect(fill='white',colour = NA))
ggsave(file='/home/mqzhou/plot/BAU_tfs.png',plot,width = 10,height = 11)


######## barplot B/A/U counts in cells
H=data.frame(B=0,A=0,U=0)
cells=c()
for (i in 1:10){
  cell=unique(as.character(counts$Cell))[i]
  h=(counts[which(counts$Cell==cell),4])
  h=log(h)
  H=rbind(H,h)
  cells=c(cells,cell)
 }
H=H[-1,]
H$cells=cells
plot=ggplot(melt(H),group=cells,aes(fill=variable))+
  geom_bar(stat='identity',aes(x=variable,y=value))+
  ylab('log(B/A/U) counts')+xlab('')+ggtitle('log(B/A/U) counts in cell lines')+
  facet_wrap(~cells, scales = "free_x", ncol =5)+
  scale_fill_manual(values=c('#4DBBD5FF','#91D1C2FF','#00A087FF'))+
  theme_Publication()+
  theme(strip.background = element_rect(fill='white',colour = NA))
ggsave(file='/home/mqzhou/plot/BAU_cell.png',plot,width = 8,height = 4)


##################### barplot B ratio in cell lines
Bratio=data.frame(cell='cell',pair='TF',ratio=0)
for (i in 1:10){
  cell=unique(as.character(counts$Cell))[i]
  h=(counts[which(counts$Cell==cell),4:6])
  tfs=counts[which(counts$Cell==cell),1:2]
  ratio=h[1]/rowSums(h)
  labels=c()
  for (i in 1:dim(tfs)[1]){
    l=paste(tfs[i,1],tfs[i,2],sep='-')
    labels=c(labels,l)
  }
  Bratio=rbind(Bratio,
  	data.frame(cell=c(rep(cell,length(labels))),pair=labels,ratio=ratio$B))
}
Bratio=Bratio[-1,]
plot=ggplot(melt(Bratio),group=cell)+
  geom_bar(stat='identity',aes(x=pair,y=value),fill='#8491B4FF')+
  ylab('B ratio')+xlab('TF-TF pairs')+ggtitle('B ratio in cell lines')+
  facet_wrap(~cell, scales = "free_x", ncol =2)+
  theme_Publication()+
  theme(strip.background = element_rect(fill='white',colour = NA),
  	axis.text.x =element_text(angle = -45, hjust = 0),
  	plot.title = element_text(size = rel(2)),
  	axis.title=element_text(size=rel(1.5)))
ggsave(file='/home/mqzhou/plot/Bratio_cell.png',plot,width = 14,height = 15)






