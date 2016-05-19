#!/bin/bash

file=/home/eskreiswinkler/MMF/SSL/Benchmarks/scripts/run_SSL_GPR_secstr_p$1_reg$2_frac$3_$4\.sh

sed -e "s;%1%;$1;g" -e "s;%2%;$2;g" -e "s;%3%;$3;g" -e "s;%4%;$4;g" -e "s;%5%;$5;g" template_SSL_GPR_secstr.sh > $file
sbatch $file
