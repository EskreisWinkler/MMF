#!/bin/bash
#SBATCH --job-name=SSL_p%1%_reg%2%_fr%3%_%4%
#SBATCH --output=/home/eskreiswinkler/scratch-midway/SSL_secstr_p%1%_reg%2%_fr%3%_%4%.out
#SBATCH --error=/home/eskreiswinkler/scratch-midway/SSL_secstr_p%1%_reg%2%_fr%3%_%4%.err
#SBATCH --time=%5%:00:00
#SBATCH --partition=sandyb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem=25000

LD_PRELOAD="/software/gcc-4.9-el6-x86_64/lib64/libstdc++.so.6" matlab -nodisplay -nojvm -r "addpath('/home/eskreiswinkler/MMF/SSL/Benchmarks'); SSL_GPR_secstr(%1%,%2%,%3%,%4%); exit;" 
