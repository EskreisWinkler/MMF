#!/bin/bash

file=/home/eskreiswinkler/MMF/cluster_review/scripts/cluster_data$1\.sh

sed -e "s;%1%;$1;g" template_cluster.sh > $file
sbatch $file
