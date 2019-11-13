F=list.files('/state2/mqzhou/TF_co/data/chipseq_co_complete/')#co-bind data
p_value=c()
rownames=c()
set.seed(123)
for (f in F){
	TF_pair=paste(unlist(strsplit(f,''))[1:(which(unlist(strsplit(f,''))=='.'))[1]-1],collapse='')
	if (TF_pair=='counts'){p_value=p_value}
    else{
    	tf1=unlist(strsplit(TF_pair,'_'))[1]
	    tf2=unlist(strsplit(TF_pair,'_'))[2]
	    co_path=paste('/state2/mqzhou/TF_co/data/chipseq_co_complete/',f,sep='')
	    tf1_path=paste('/state2/hyangl/TF_co/data/chipseq/',tf1,'.train.labels.tsv',sep='')
	    tf2_path=paste('/state2/hyangl/TF_co/data/chipseq/',tf2,'.train.labels.tsv',sep='')
    	co_first =unlist(strsplit(readLines(co_path, n=1),'\t'))
		tf1_first=unlist(strsplit(readLines(tf1_path, n=1),'\t'))
		tf2_first=unlist(strsplit(readLines(tf2_path, n=1),'\t'))
		num_cell=length(co_first)-3
		true=c();product=c()
		ind=sample(1:5100000,size=100) # sample intervals
		for (i in 1:100){	
			co_chunk=read.table(co_path,skip = ind[i], nrow = 1000000,sep='\t')
	    	tf1_chunk=read.table(tf1_path,skip = ind[i], nrow = 1000000,sep='\t')
	    	tf2_chunk=read.table(tf2_path,skip = ind[i], nrow = 1000000,sep='\t')
	    	for (j in 1:num_cell){
	    		cell=co_first[j+3]
		   		true=c(true,sum(co_chunk[,j+3]=='B')/1000000)
            	tf1_pr=sum(tf1_chunk[,which(tf1_first==cell)]=='B')/1000000
            	tf2_pr=sum(tf2_chunk[,which(tf2_first==cell)]=='B')/1000000
            	product=c(product,tf1_pr*tf2_pr) #product of two single ratios
			}	
  		}
  		write.table(cbind(true,product),file=paste('/state2/mqzhou/TF_co/data/wilcox_test/',TF_pair,'_wilcox_data.txt',sep=''),row.names=FALSE)
   		wilcox=wilcox.test(true,product,paired=T,alternative='greater')#wilcoxon test
   		p=wilcox$p.value
   		p_value=c(p_value,p)
   		rownames=c(rownames,TF_pair)
	}
	print(paste(TF_pair,'complete!'))	
   
}
write.table(p_value,file='/state2/mqzhou/TF_co/data/wilcox_test/p_value.txt',row.names=rownames,col.names=FALSE)

