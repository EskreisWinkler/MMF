#!/bin/bash
#SBATCH --job-name=review_dataset%1%_laptype%2%_draws%3%
#SBATCH --output=/home/eskreiswinkler/scratch-midway/review/review_data%1%_laptype%2%_draws%3%.out
#SBATCH --error=/home/eskreiswinkler/scratch-midway/review/review_data%1%_laptype%2%_draws%3%.err
#SBATCH --time=10:00:00
#SBATCH --partition=sandyb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12

LD_PRELOAD="/software/gcc-4.9-el6-x86_64/lib64/libstdc++.so.6" matlab -nodisplay -nojvm -r "addpath('/home/eskreiswinkler/MMF/SSL/Benchmarks'); SSL_review(%1%,%2%,%3%); exit;" 
