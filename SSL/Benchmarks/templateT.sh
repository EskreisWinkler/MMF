#!/bin/bash
#SBATCH --job-name=secstr_%1%_%2%
#SBATCH --output=/home/eskreiswinkler/scratch-midway/output_secstr_%1%_%2%.out
#SBATCH --error=/home/eskreiswinkler/scratch-midway/output_secstr_%1%_%2%.err
#SBATCH --time=%3%:00:00
#SBATCH --partition=sandyb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12

LD_PRELOAD="/software/gcc-4.9-el6-x86_64/lib64/libstdc++.so.6" matlab -nodisplay -nojvm -r "addpath('/home/eskreiswinkler/MMF/SSL/Benchmarks'); MMF_comparisons_secstr(%1%,%2%); exit;" 
