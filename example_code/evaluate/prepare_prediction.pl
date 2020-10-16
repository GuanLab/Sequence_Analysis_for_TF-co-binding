#!/usr/bin/perl

## prepare the complete prediction files

$path1="prediction/H/combined/"; # PARAMETER F_G_H_I, F_G, H_I
$path2="evaluation/prediction/"; # PARAMETER

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
    close TARGET;

    $i=3;
    foreach $cell (@all_cell) {
        print "$tf\t$cell\n";
        if (-f "${path1}${tf}.${cell}_set1_model") {
            %chr_to_id=();
            %start_to_id=();
            $chr_id=0;
            $start_id=0;
            @pred1=();
            @pred2=();
            open PRED1, "${path1}${tf}.${cell}_set1_model" or die;
            open PRED2, "${path1}${tf}.${cell}_set2_model" or die;
            open INDEX, "data/ref/test_regions.blacklistfiltered.bed" or die;
            while ($val1=<PRED1>){
                chomp $val1;
                $val2=<PRED2>;
                chomp $val2;
                $tmp=<INDEX>;
                chomp $tmp;
                @table=split "\t", $tmp;
                if (exists $chr_to_id{$table[0]}){}else{
                    $chr_to_id{$table[0]}=$chr_id;
                    $chr_id++;
                }
                if (exists $start_to_id{$table[1]}){}else{
                    $start_to_id{$table[1]}=$start_id;
                    $start_id++;
                }
                $val1=sprintf("%.4f",$val1);
                $val2=sprintf("%.4f",$val2);
                $pred1[$chr_to_id{$table[0]}][$start_to_id{$table[1]}]=$val1;
                $pred2[$chr_to_id{$table[0]}][$start_to_id{$table[1]}]=$val2;
            }
            close PRED1;
            close PRED2;
            close INDEX;

            open TARGET, "$target" or die;
            <TARGET>;
            open OUTPUT1_SET1, ">${path2}${tf}_${cell}_set1_model_set1_test.txt" or die;
            open OUTPUT1_SET2, ">${path2}${tf}_${cell}_set1_model_set2_test.txt" or die;
            open OUTPUT2_SET1, ">${path2}${tf}_${cell}_set2_model_set1_test.txt" or die;
            open OUTPUT2_SET2, ">${path2}${tf}_${cell}_set2_model_set2_test.txt" or die;
            while($line=<TARGET>){
                chomp $line;
                @table=split "\t", $line;
                if ($table[$i] eq "U"){
                    $table[$i] = 0;
                }
                if ($table[$i] eq "B"){
                    $table[$i] = 1;
                }
                if ($table[$i] eq "A"){
                    $table[$i] = 0.5;
                }
                if (($table[$i]==1)||($table[$i]==0)){
                    if (exists $chr_set1{$table[0]}){ # if set1
                        $val1=$pred1[$chr_to_id{$table[0]}][$start_to_id{$table[1]}];
                        $val2=$pred2[$chr_to_id{$table[0]}][$start_to_id{$table[1]}];
                        print OUTPUT1_SET1 "$val1\n";
                        print OUTPUT2_SET1 "$val2\n";
                    }
                    if (exists $chr_set2{$table[0]}){ # if set2;
                        $val1=$pred1[$chr_to_id{$table[0]}][$start_to_id{$table[1]}];
                        $val2=$pred2[$chr_to_id{$table[0]}][$start_to_id{$table[1]}];
                        print OUTPUT1_SET2 "$val1\n";
                        print OUTPUT2_SET2 "$val2\n";
                    }
                }
            }
            close OUTPUT1_SET1;
            close OUTPUT1_SET2;
            close OUTPUT2_SET1;
            close OUTPUT2_SET2;
            close TARGET;
        }
        $i++;
    }
}
