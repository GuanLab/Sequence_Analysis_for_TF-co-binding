#!/bin/bash

for i in {2..7}
do
    cp -r template H${i}
    sed -e "s/train_list_1/train_list_${i}/g" < train_model_H1.pl > H${i}/train_model_H${i}.pl
    cd H${i}
    perl train_model_H${i}.pl &
    cd ..
done



