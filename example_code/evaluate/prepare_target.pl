#!/usr/bin/perl

## prepare the complete target files

$path1="prediction/H/combined/"; # PARAMETER
$path2="evaluation/target/"; # PARAMETER

@all_chr=('chr10','chr11','chr12','chr13','chr14','chr15','chr16','chr17','chr18','chr19',
	'chr2','chr20','chr22','chr3','chr4','chr5','chr6','chr7','chr9','chrX');

open INDEX_SET1, "data/index/ind_chr_set1.txt" or die;
%chr_set1=();
while ($line=<INDEX_SET1>){
    chomp $line;
    $chr_set1{$line}=0;
}
close INDEX_SET1;
%chr_set2=(); # set 2; be careful not using if else cause there are other 3 chrs!
foreach $chr (@all_chr){
    if (exists $chr_set1{$chr}){
    }else{
        $chr_set2{$chr}=0;
    }
}

@all_target=glob "data/chipseq_co_test/*tsv";
foreach $target (@all_target){ # all 32 tf files; but we only predict 13 tf
    @tmp1=split '/',$target;
    $tmp2=pop @tmp1;
    @tmp3=split '\.', $tmp2;
    $tf=$tmp3[0];

    open TARGET, "$target" or die;
    $header=<TARGET>;
    chomp $header;
    @all_cell=split "\t", $header;
    shift @all_cell;
    shift @all_cell;
    shift @all_cell;
    $cell=@all_cell[0];

    if (-f "${path1}${tf}.${cell}_set1_model"){
    	$num=0;
    	foreach $cell (@all_cell){
       		print "$tf\t$cell\n";
        	$name1="SET1".$num;
        	$name2="SET2".$num;
        	open $name1, ">${path2}${tf}_${cell}_set1.txt" or die;
        	open $name2, ">${path2}${tf}_${cell}_set2.txt" or die;
		$num++;
    	}
        while ($line=<TARGET>){
            chomp $line;
            @table=split "\t", $line;
            $i=0;
            while($i<$num){
            	$j=$i+3;
            	if ($table[$j] eq "U"){
                	$table[$j] = 0;
            	}
            	if ($table[$j] eq "B"){
                	$table[$j] = 1;
            	}
            	if ($table[$j] eq "A"){
                	$table[$j] = 0.5;
            	}
            	if (($table[$j]==1)||($table[$j]==0)){
            		$name1="SET1".$i;
            		$name2="SET2".$i;
                	if (exists $chr_set1{$table[0]}){ # if set1
                    	print $name1 "$table[$j]\n";
                	}
                	if (exists $chr_set2{$table[0]}){ # if set2;
                    	print $name2 "$table[$j]\n";
                	}
            	}
            	$i++;
        	}
        }
        $i=0;
        while($i<$num){
        	$name1="SET1".$i;
        	$name2="SET2".$i;
        	close $name1;
        	close $name2;
		$i++;
        }
    } 
    close TARGET;
}


