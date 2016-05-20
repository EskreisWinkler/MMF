#!/bin/bash
#SBATCH --job-name=magic_reg%1%_fr%2%_%3%
#SBATCH --output=/home/eskreiswinkler/scratch-midway/magic_reg%1%_fr%2%_%3%.out
#SBATCH --error=/home/eskreiswinkler/scratch-midway/magic_reg%1%_fr%2%_%3%.err
#SBATCH --time=%4%:00:00
#SBATCH --partition=sandyb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem=25000

LD_PRELOAD="/software/gcc-4.9-el6-x86_64/lib64/libstdc++.so.6" matlab -nodisplay -nojvm -r "addpath('/home/eskreiswinkler/MMF/SSL/Magic'); SSL_magic(%1%,%2%,%3%,%4%); exit;" 
