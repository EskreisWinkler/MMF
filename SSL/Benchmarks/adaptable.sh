#!/bin/bash
#
#$ -cwd
##$ -j y
#$ -S /bin/bash
#$ -o output/out_kmat.txt
#$ -e output/err_kmat.txt
##$ -t 1-10
#
. /etc/profile
#module load packages/matlab/r2013a

matlab -nodisplay -r 'secstr_nn_maker; exit;'

echo "Code has finished running." | mail -s "Alert" "jeskreiswinkler@gmail.com"

