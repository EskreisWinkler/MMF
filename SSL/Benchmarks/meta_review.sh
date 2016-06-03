#!/bin/bash

file=/home/eskreiswinkler/MMF/SSL/Benchmarks/scripts/run_review_datasetind$1_laptype$2_draws$3\.sh

sed -e "s;%1%;$1;g" -e "s;%2%;$2;g" -e "s;%3%;$3;g" template_review.sh > $file
sbatch $file
