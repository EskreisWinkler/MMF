#!/bin/bash
#
#$ -cwd
##$ -j y
#$ -S /bin/bash
#$ -o output/SSL_GPR.out
#$ -e output/SSL_GPR.err
##$ -t 1-10
#
. /etc/profile
#module load packages/matlab/r2013a

matlab -nodisplay -nojvm -r "SSL_GPR($1,$2); exit;"

echo "Code has finished running." | mail -s "Alert" "jeskreiswinkler@gmail.com"

