
################################ feature importance #############################
load('/state2/hyangl/TF_co/feature_importance/co_H_fi.RData')
del_fi=mat_fi[,colSums(mat_fi)!=0]#delete 0 colmns

###########  3M & delta 3M
library(data.table)
library(scales)

mean=del_fi[437:451,]
delta_mean=del_fi[452:466,]
max=del_fi[467:481,]
min=del_fi[482:496,]
delta_max=del_fi[497:511,]
delta_min=del_fi[512:526,]

del_fi=mat_fi[,colSums(mat_fi)!=0]#delete 0 colmns
mean=del_fi[437:451,]
max=del_fi[467:481,]
min=del_fi[482:496,]
pal<-colorRampPalette(c("white",'#8491B4FF','#F39B7FFF',"#E64B35FF"))(256)

ord_max=max[c(14,12,10,8,6,4,2,1,3,5,7,9,11,13,15),]#order to -650bp to 650bp
ord_mean=mean[c(14,12,10,8,6,4,2,1,3,5,7,9,11,13,15),]
ord_min=min[c(14,12,10,8,6,4,2,1,3,5,7,9,11,13,15),]
pheatmap(t(ord_max), cutree_rows = 5,cluster_cols=F,color = pal)
pheatmap(t(ord_min), cutree_rows = 5,cluster_cols=F,color = pal)
pheatmap(t(ord_mean), cutree_rows = 5,cluster_cols=F,color = pal)
