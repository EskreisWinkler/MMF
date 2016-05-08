#!/bin/bash
#
#$ -cwd
##$ -j y
#$ -S /bin/bash
#$ -o output/out_TIME.txt
#$ -e output/err_TIME.txt
##$ -t 1-10
#
. /etc/profile
#module load packages/matlab/r2013a

matlab -nodisplay -nojvm -r "MMF_comparisonsTIME($1,$2); exit;"

echo "Code has finished running." | mail -s "Alert" "jeskreiswinkler@gmail.com"

