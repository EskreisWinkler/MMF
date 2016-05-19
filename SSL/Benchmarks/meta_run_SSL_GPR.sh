#!/bin/bash

file=/home/eskreiswinkler/MMF/SSL/Benchmarks/scripts/run_SSL_GPR_$1_$2\.sh

sed -e "s;%1%;$1;g" -e "s;%2%;$2;g" -e "s;%3%;$3;g" template_SSL_GPR.sh > $file
sbatch $file
