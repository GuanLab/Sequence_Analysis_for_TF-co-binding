#!/usr/bin/perl

# make predictions 

@model_dir1=glob "/state2/hyangl/TF_co/model/H_best/*set1_eva"; # PARAMETER: F/G/H/I
@model_dir2=glob "/state2/hyangl/TF_co/model/H_best/*set2_eva"; # PARAMETER
$path="/state2/hyangl/TF_co/prediction/H/separated/"; # PARAMETER
system "mkdir -p $path";

$list_to_predict="/home/hyangl/TF_co/data/index/test_list_1.txt"; # PARAMETER

@cell_feature=("/state2/hyangl/TF_model/data/feature/anchor_bam_DNAse_largespace/", # PARAMETER
        "/state2/hyangl/TF_model/data/feature/anchor_bam_DNAse_diff_largespace/",
        "/state2/hyangl/TF_model/data/feature/anchor_bam_DNAse_max_min_largespace/",
        "/state2/hyangl/TF_model/data/feature/anchor_bam_DNAse_max_min_diff_largespace/");

@tf_feature=glob ("/state2/hyangl/TF_model/data/feature/tf_ru_max_top4_rank_largespace/*"); # PARAMETER: FG "xxx/" HI "xxx/*"

$rna_feature='/state2/hyangl/TF_model/data/feature/top_20'; # 60519747 lines, including index

open FILE, "$list_to_predict" or die;
while ($line=<FILE>){
    chomp $line;
    $the_file=$line;
    @t=split '\.', $line;
    $the_tf=$t[0];
    $the_cell=$t[1];

    print "$the_tf\t$the_cell\n";
    open INDEX, "$rna_feature" or die;
    $num=0; # index for all feature files
    foreach $the_feature (@cell_feature){
        $name='INPUT'.$num;
        open $name, "$the_feature/$the_cell" or die;
        $num++;
    }
    foreach $the_feature (@tf_feature){
        $name='INPUT'.$num;
        open $name, "$the_feature" or die; # PARAMETER: FG $the_feature/$the_tf HI $the_feature
        $num++;
    }

    $lll_i=0;
    $file_i=0;
    
    while ($line=<INDEX>){
        chomp $line;
        @table=split "\t", $line;
        shift @table;
        shift @table;
        shift @table;

        $additional='';
        $i=1;
        foreach $val (@table){
            $additional.=" $i:$val";
            $i++;
        }
        $j=0;
        while($j<$num){
            $name='INPUT'.$j;
            $line1=<$name>;
            chomp $line1;
            @table1=split "\t", $line1;
            foreach $val (@table1){
                $additional.=" $i:$val";
                $i++;
            }
            $j++;
        }

        if (($lll_i%1000000)==0){ # make prediction of every 1,000,000 lines
            close NEW; # I think if test.dat too big, xgboost cannot accept it due to limited memory
            @pred=();
            $count=0;
            if ($file_i>0){
            foreach $dir (@model_dir1){
                @t=split '/', $dir;
                $model_name=pop @t;
                @pair=split '_', $model_name;
                $tf1="$pair[0]_$pair[1]";
                $cell1=$pair[2]; # training cell

                if($the_tf eq $tf1){ # use prediction from best models of all other cell lines
                    if (($the_cell eq $cell1) ){print "$cell1\t$the_cell\texcluded\n";}else{
                        $perf=0;
                        $model="$dir/the_model";
#                        $model='';
#                        @all_models=glob "$dir/*auprc.txt";
#                        foreach $the_model (@all_models){ # find the best performing model and avoid overfitting
#                            open OLD, "$the_model" or die;
#                            $line=<OLD>;
#                            chomp $line;
#                            $val=$line;
#                            if ($val>$perf){
#                                $perf=$val;
#                                $model=$the_model;
#                            }
#                        }
#                        $model=~s/\.auprc\.txt//g;
                        system "cp $model the_model";
                        system "/home/hyangl/software/xgboost/xgboost xgtree.conf task=pred model_in=the_model";
                        open OLD, "output.dat" or die;
                        $i=0;
                        while ($line=<OLD>){
                            chomp $line;
                            $pred[$i]+=$line;
                            $i++;
                        }
                        close OLD;
                        $count++;
                    }
                }
            }
            
            
            $imax=$i;
            open PRED, ">${path}${file_i}_${the_file}_set1_model" or die;
            $i=0;
            while ($i<$imax){
                $val=$pred[$i]/$count;
                print PRED"$val\n";
                $i++;
            }
            close PRED;

            @pred=();
            $count=0;
            foreach $dir (@model_dir2){
                @t=split '/', $dir;
                $model_name=pop @t;
                @pair=split '_', $model_name;
                $tf1="$pair[0]_$pair[1]";
                $cell1=$pair[2]; # training cell

                if($the_tf eq $tf1){
                    if (($the_cell eq $cell1) ){}else{
                        $perf=0;
                        $model="$dir/the_model";
#                        $model='';
#                        @all_models=glob "$dir/*auprc.txt";
#                        foreach $the_model (@all_models){
#                            open OLD, "$the_model" or die;
#                            $line=<OLD>;
#                            chomp $line;
#                            $val=$line;
#                            if ($val>$perf){
#                                $perf=$val;
#                                $model=$the_model;
#                            }
#                        }
#                        $model=~s/\.auprc\.txt//g;
                        system "cp $model the_model";
                        system "/home/hyangl/software/xgboost/xgboost xgtree.conf task=pred model_in=the_model";
                        open OLD, "output.dat" or die;
                        $i=0;
                        while ($line=<OLD>){
                            chomp $line;
                            $pred[$i]+=$line;
                            $i++;
                        }
                        close OLD;
                        $count++;
                    }
                }
            }
            
            
            $imax=$i;
            open PRED, ">${path}${file_i}_${the_file}_set2_model" or die;
            $i=0;
            while ($i<$imax){
                $val=$pred[$i]/$count;
                print PRED"$val\n";
                $i++;
            }
            close PRED;
            } # if ($file_i>0)
            open NEW, ">test.dat" or die;

            $file_i++;
        } # if (($lll_i%1000000)==0)
        print NEW "0";
        print NEW "$additional\n";
        $lll_i++;
                
    } # while ($line=<INDEX>)
    close NEW; # make prediction of the rest less than 1,000,000 lines
    @pred=();
    $count=0;
    foreach $dir (@model_dir1){
        @t=split '/', $dir;
        $model_name=pop @t;
        @pair=split '_', $model_name;
        $tf1="$pair[0]_$pair[1]";
        $cell1=$pair[2]; # training cell

        if($the_tf eq $tf1){
            if (($the_cell eq $cell1) ){}else{
                $perf=0;
                $model="$dir/the_model";
#                $model='';
#                @all_models=glob "$dir/*auprc.txt";
#                foreach $the_model (@all_models){
#                    open OLD, "$the_model" or die;
#                    $line=<OLD>;
#                    chomp $line;
#                    $val=$line;
#                    if ($val>$perf){
#                        $perf=$val;
#                        $model=$the_model;
#                    }
#                }
#                $model=~s/\.auprc\.txt//g;
                system "cp $model the_model";
                system "/home/hyangl/software/xgboost/xgboost xgtree.conf task=pred model_in=the_model";
                open OLD, "output.dat" or die;
                $i=0;
                while ($line=<OLD>){
                    chomp $line;
                    $pred[$i]+=$line;
                    $i++;
                }
                close OLD;
                $count++;
            }
        }
    }
    
    
    $imax=$i;
    open PRED, ">${path}${file_i}_${the_file}_set1_model" or die;
    $i=0;
    while ($i<$imax){
        $val=$pred[$i]/$count;
        print PRED "$val\n";
        $i++;
    }
    close PRED;

    @pred=();
    $count=0;
    foreach $dir (@model_dir2){
        @t=split '/', $dir;
        $model_name=pop @t;
        @pair=split '_', $model_name;
        $tf1="$pair[0]_$pair[1]";
        $cell1=$pair[2]; # training cell

        if($the_tf eq $tf1){
            if (($the_cell eq $cell1) ){print "$the_cell\t$cell1\texcluded\n";}else{
                $perf=0;
                $model="$dir/the_model";
#                $model='';
#                @all_models=glob "$dir/*auprc.txt";
#                foreach $the_model (@all_models){
#                    open OLD, "$the_model" or die;
#                    $line=<OLD>;
#                    chomp $line;
#                    $val=$line;
#                    if ($val>$perf){
#                        $perf=$val;
#                        $model=$the_model;
#                    }
#                }
#                $model=~s/\.auprc\.txt//g;
                system "cp $model the_model";
                system "/home/hyangl/software/xgboost/xgboost xgtree.conf task=pred model_in=the_model";
                open OLD, "output.dat" or die;
                $i=0;
                while ($line=<OLD>){
                    chomp $line;
                    $pred[$i]+=$line;
                    $i++;
                }
                close OLD;
                $count++;
            }
        }
    }
                
    $imax=$i;
    open PRED, ">${path}${file_i}_${the_file}_set2_model" or die;
    $i=0;
    while ($i<$imax){
        $val=$pred[$i]/$count;
        print PRED "$val\n";
        $i++;
    }
    close PRED;
    $j=0;
    while($j<$num){
        $name="INPUT".$j;
        close $name;
        $j++;
    }
}


