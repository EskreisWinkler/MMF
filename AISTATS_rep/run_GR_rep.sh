#!/bin/bash
#
#$ -cwd
##$ -j y
#$ -S /bin/bash
#$ -o output/GR.out
#$ -e output/GR.err
##$ -t 1-10
#
. /etc/profile
#module load packages/matlab/r2013a

matlab -nodisplay -nojvm -r 'GR_rep; exit;'

echo "Code has finished running." | mail -s "Alert" "jeskreiswinkler@gmail.com"

