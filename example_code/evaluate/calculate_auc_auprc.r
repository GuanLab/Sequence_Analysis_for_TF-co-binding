## name: calculate_auc_auprc.r
## date: 03/29/2019

## Here I calculate auc & auprc for different models
## The plot points are subsampled and saved in list list_plot

# real    103m40.589s

library(PRROC)
set.seed(3.14)

path0="evaluation/target/"
path1="evaluation/prediction/"

tf_cell = list.files(path=path0,pattern="*set1.txt")
tf_cell = sub("_set1.txt","",tf_cell)

array_auc=array(NA,dim=c(2,length(tf_cell),2))
dimnames(array_auc)[1]=list(c("12","21"))
dimnames(array_auc)[2]=list(tf_cell)
dimnames(array_auc)[3]=list(c("auroc","auprc"))

l=1000

list_plot=list()
for(i in tf_cell){
    print(i)
    target1=scan(paste0(path0, i, "_set1.txt"))
    target2=scan(paste0(path0, i, "_set2.txt"))
    # a - anchor_FGHI
    pred12=scan(paste0(path1, i, "_set1_model_set2_test.txt"))
    pred21=scan(paste0(path1, i, "_set2_model_set1_test.txt"))
    pr12=pr.curve(scores.class0=pred12, weights.class0=target2, curve=T)
    pr21=pr.curve(scores.class0=pred21, weights.class0=target1, curve=T)
    roc12=roc.curve(scores.class0=pred12, weights.class0=target2, curve=T)
    roc21=roc.curve(scores.class0=pred21, weights.class0=target1, curve=T)
    # save
    array_auc[,i,"auroc"]=c(roc12$auc,roc21$auc)
    array_auc[,i,"auprc"]=c(pr12$auc.integral,pr21$auc.integral)

    # subsampling for plot
    roc12$curve=roc12$curve[c(seq(dim(roc12$curve)[1],1,-l),1),]
    roc21$curve=roc21$curve[c(seq(dim(roc21$curve)[1],1,-l),1),]
    pr12$curve=pr12$curve[c(seq(dim(pr12$curve)[1]-l,1,-l),1),] # skip the first 1000 otherwise the first hundrads of calls have low precision
    pr21$curve=pr21$curve[c(seq(dim(pr21$curve)[1]-l,1,-l),1),] # sample every 1000 points otherwise too many points!

    tmp=list(roc12=roc12,pr12=pr12,roc21=roc21,pr21=pr21)
    list_plot=c(list_plot,list(tmp))
    gc() # release memory
}
names(list_plot)=tf_cell

save(tf_cell,array_auc,list_plot,
	file="auc_auprc.RData")

apply(array_auc,c(2,3),mean)


