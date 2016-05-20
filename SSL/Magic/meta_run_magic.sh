#!/bin/bash

file=/home/eskreiswinkler/MMF/SSL/Magic/scripts/run_magic_reg$1_frac$2_$3\.sh

sed -e "s;%1%;$1;g" -e "s;%2%;$2;g" -e "s;%3%;$3;g" -e "s;%4%;$4;g" template_magic.sh > $file
sbatch $file
