#!/bin/bash
#
#$ -cwd
##$ -j y
#$ -S /bin/bash
#$ -o output/out_secstr.txt
#$ -e output/err_secstr.txt
##$ -t 1-10
#
. /etc/profile
#module load packages/matlab/r2013a

matlab -nodisplay -nojvm -r 'MMF_comparisons_secstr(5,3,20); exit;'

echo "Code has finished running." | mail -s "Alert" "jeskreiswinkler@gmail.com"

