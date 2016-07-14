#!/bin/bash
#SBATCH --job-name=cluster_data%1%
#SBATCH --output=/home/eskreiswinkler/scratch-midway/cluster/cluster_data%1%.out
#SBATCH --error=/home/eskreiswinkler/scratch-midway/cluster/cluster_data%1%.err
#SBATCH --time=10:00:00
#SBATCH --partition=sandyb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12

LD_PRELOAD="/software/gcc-4.9-el6-x86_64/lib64/libstdc++.so.6" matlab -nodisplay -nojvm -r "addpath('/home/eskreiswinkler/MMF/cluster_search/'); cluster_review(%1%); exit;" 
