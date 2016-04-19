#!/bin/bash
#
#$ -cwd
##$ -j y
#$ -S /bin/bash
#$ -o output/out.txt
#$ -e output/err.txt
##$ -t 1-10
#
. /etc/profile
#module load packages/matlab/r2013a

matlab -nodisplay -nojvm < Zhu_figure_maker.m 

echo "Code has finished running." | mail -s "Alert" "jeskreiswinkler@gmail.com"

