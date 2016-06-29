#!/bin/bash
#
#$ -cwd
##$ -j y
#$ -S /bin/bash
#$ -o output/Gnu.out
#$ -e output/Gnu.err
##$ -t 1-10
#
. /etc/profile
#module load packages/matlab/r2013a

matlab -nodisplay -nojvm -r 'Gnu_rep; exit;'

echo "Code has finished running." | mail -s "Alert" "jeskreiswinkler@gmail.com"

