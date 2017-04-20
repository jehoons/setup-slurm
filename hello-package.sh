#!/bin/bash
#SBATCH --nodelist=pascal
# SBATCH --exclude=
#SBATCH --job-name=TEST
#SBATCH --workdir=/home/pbs
# SBATCH --ntasks-per-node=4
#SBATCH --array=1-5
#SBATCH --nodes=1
#SBATCH --time=100:00
# SBATCH --output=SLURM-%A_%a.out
#SBATCH --output=SLURM-%a.out
# SBATCH --mail-type=ALL
# SBATCH --mail-user=gistmecha@gmail.com

# matlab_multi.sh is a script file for matlab jobs.  For example you can run
# this script as: 
# sbatch matlab_multi.sh package.tgz <ENTER>
# Author: Je-Hoon Song, song.jehoon@gmail.com

# The output of slurm will be written in following format: 
# --output=<filename pattern> example: 
# "slurm-%A_%a.out" for array jobs
# "slurm-%j.out" for normal jobs

# openmp parallel is set to 4, thereby each task should be meant be n=4 tasks
# for each node. The option --ntasks-per-node=4 indicates this to sbatch.
# ref: http://www.umbc.edu/hpcf/resources-tara-2010/how-to-run-openmp.html
# export OMP_NUM_THREADS=4

# Another important thing to note - if we change "--nodes" to 2, the job will
# be duplicated on two nodes, not parallelized across them as we would probably
# want. So it's recommended to leave --nodes=1

# --------------------------------------
# Step 0. Variable and directory setting
# --------------------------------------
DIR_SUBMIT="${SLURM_SUBMIT_HOST}:${SLURM_SUBMIT_DIR}"
DIR_BOOTING=`pwd`
DIR_PROGRAM="$DIR_BOOTING/SLURM_PROG"
DIR_DATA="$DIR_BOOTING/SLURM_DATA"
OUTPUT="OUTPUT-${SLURM_ARRAY_TASK_ID}.txt"
PACKAGE="${SLURM_SUBMIT_HOST}:git/codebase/slurm/hello.py.gz"
PROGRAM="${SLURM_SUBMIT_HOST}:git/codebase/slurm/hello.py"
# OUTPUT="OUTPUT-${SLURM_ARRAY_JOB_ID}-${SLURM_ARRAY_TASK_ID}.txt"
# LOG="slurm-${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.out"
mkdir -p $DIR_PROGRAM
mkdir -p $DIR_DATA
TEMP_WD=`mktemp -d`
set >> $OUTPUT
# --------------------------------------------
# Step 1. Prepare program and dependancy files
# --------------------------------------------
rsync -h -v -r -P -t $PROGRAM $TEMP_WD
rsync -h -v -r -P -t $PACKAGE $DIR_PROGRAM
cd $DIR_PROGRAM
gzip -d $DEP

# -----------------------------------------
# Step 2. Start computing in temp directory
# -----------------------------------------
cd $TEMP_WD
export PATH=/usr/local/MATLAB/R2013a/bin:$PATH
export PYTHONPATH=$DIR_PROGRAM:$PYTHONPATH
echo "Program directory: ${DIR_PROGRAM}" >> $OUTPUT
echo "Working directory: `hostname`:${TEMP_WD}" >> $OUTPUT
python "hello.py" >> $OUTPUT

# -----------------------------------------
# Step 3. Process output file
# -----------------------------------------
mv $TEMP_WD/$OUTPUT $DIR_DATA

# robust file copy method: 
#i="0" 
#max_iter="100"
#while [ $i -lt $max_iter ]
#do
#    sleep $(( ( RANDOM % 10 )  + 1 ))
#    ssh ${SLURM_SUBMIT_HOST} test -f ${SLURM_SUBMIT_DIR}/$OUTPUT \
#        && (i="9999" && echo "file transfer ok: $OUTPUT") \
#        || (echo "try: $i" && scp -rpB $TEMP_WD/$OUTPUT ${ORG})
#    i=$[$i+1]
#done

echo "bye!" >> $OUTPUT

exit 0
