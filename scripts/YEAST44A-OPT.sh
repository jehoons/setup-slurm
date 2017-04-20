#!/bin/bash
#SBATCH --job-name=YEAST44A
#SBATCH --workdir=/tmp
#SBATCH --time=100:00
#SBATCH --array=1

# openmp parallel is set to 4, thereby each task should be meant be n=4 tasks
# for each node. The option --ntasks-per-node=4 indicates this to sbatch.
# ref: http://www.umbc.edu/hpcf/resources-tara-2010/how-to-run-openmp.html
export OMP_NUM_THREADS=4
#SBATCH --ntasks-per-node=4

# Another important thing to note - if we change "--nodes" to 2, the job will
# be duplicated on two nodes, not parallelized across them as we would probably
# want. So it's recommended to leave --nodes=1
#SBATCH --nodes=1

PACKAGE="yeast-4.4a.tgz"

export PATH=/usr/local/MATLAB/R2013a/bin:$PATH

echo "Hello, I am `hostname`."

O_SLURM="slurm-${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.out"

O_PROG_LONG="output_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.mat"

ORG="${SLURM_SUBMIT_HOST}:${SLURM_SUBMIT_DIR}"

# slurm.out is stored in SLURM_WD. 
SLURM_WD=`pwd`

# output.mat is stored in TEMP_WD. 
TEMP_WD=`mktemp -d`

# Now, we we prepare program and data.
cd $TEMP_WD
echo "working directory: "`pwd`
scp -rpB ${SLURM_SUBMIT_HOST}:${SLURM_SUBMIT_DIR}/${PACKAGE} .
# extract it on current directory.
tar --strip-components=1 -xzf ${PACKAGE}
scp -rpB ${ORG}/input${SLURM_ARRAY_TASK_ID}.mat input.mat

# Now, we we prepare program and data. We need to build for each time, in order
# to make sure each binary fits to each machine.
echo "% unit_task.m
% author: jehoon song, song.jehoon@gmail.com
try
    build('with_omp');
    runOpt(60, 50, 1, 'input.mat', 'output.mat');
catch e 
    fprintf('%s\n',e.message); 
end 
exit " > unit_task.m

nohup matlab -nodisplay -nodesktop -r "unit_task"

# After work, we return the result file to original server:path. 
scp -rpB output.mat ${ORG}/${O_PROG_LONG}

# We also return slurm execution log to original server:path. 
scp -rpB $SLURM_WD/$O_SLURM ${ORG}/${O_SLURM}
echo "See you again!"
# clean after work
cd $SLURM_WD
rm -rf $TEMP_WD
rm -f $SLURM_WD/$O_SLURM


