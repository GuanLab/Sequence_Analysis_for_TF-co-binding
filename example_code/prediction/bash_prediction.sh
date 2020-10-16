#!/bin/bash

for i in {1..7}
do
    cp -r template H${i}
    sed -e "s/test_list_1/test_list_${i}/g" < prediction_H1.pl > H${i}/prediction_H${i}.pl
    cd H${i}
    perl prediction_H${i}.pl &
    cd ..
    sleep 1m
done



