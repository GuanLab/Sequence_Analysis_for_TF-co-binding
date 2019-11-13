#!/bin/bash

sed -n 1,8p train_list.txt > train_list_1.txt #24
sed -n 9,14p train_list.txt > train_list_2.txt #24
sed -n 15,24p train_list.txt > train_list_3.txt #27
sed -n 25,34p train_list.txt > train_list_4.txt #25
sed -n 35,45p train_list.txt > train_list_5.txt #25
sed -n 46,52p train_list.txt > train_list_6.txt #23
sed -n 53,56p train_list.txt > train_list_7.txt #24

