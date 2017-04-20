#!/bin/bash
###SBATCH --nodelist=tesla0
#SBATCH --exclude=ras
#SBATCH --job-name=YEAST44A
#SBATCH --workdir=/home/pbs
#SBATCH --ntasks-per-node=4
#SBATCH --array=1-2187
#SBATCH --nodes=1
#SBATCH --time=100:00
#SBATCH --output=slurm-%A_%a.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gistmecha@gmail.com

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
export OMP_NUM_THREADS=4

# Another important thing to note - if we change "--nodes" to 2, the job will
# be duplicated on two nodes, not parallelized across them as we would probably
# want. So it's recommended to leave --nodes=1
export PATH=/usr/local/MATLAB/R2013a/bin:$PATH

# Working directory for slurm: 
SLURM_WD=`pwd`

# ORG is the location(host:path) where the job is submitted.
ORG="${SLURM_SUBMIT_HOST}:${SLURM_SUBMIT_DIR}"
# Argument 1 is a package name, for example, abc.tgz.
PACKAGE="$1"
# The LOGFILE name and --output="output-pattern" should be match.
ATID="${SLURM_ARRAY_TASK_ID}" # short id
AJID="${SLURM_ARRAY_JOB_ID}"
LONGID="${AJID}_${ATID}" # long id

LOGFILE="slurm-${LONGID}.out"
INPUT="input${ATID}.mat"
OUTPUT="output${LONGID}.mat"

echo "The job(${LONGID}) is running in `hostname`."
echo "package: ${PACKAGE}"
echo "slurm directory: ${SLURM_WD}"

# output.mat is stored in TEMP_WD. 
TEMP_WD=`mktemp -d`

# Now, we we prepare program and data.
cd $TEMP_WD
echo "program directory: ${TEMP_WD}"

if [ -z "$1" ]
then 
    echo "fail: package not defined" 
    scp -rpB ${SLURM_WD}/${LOGFILE} ${ORG}
    exit 0
else 
    echo "success: package defined"
fi 

#SLURM_PACKAGE_DIR=${SLURM_WD}/.slurm_package_dir
#mkdir -p ${SLURM_PACKAGE_DIR}
## if the package is found, then it does not download it again.
#if [ -f "${SLURM_PACKAGE_DIR}/${PACKAGE}" ]
#then
#    echo "success: previous package found"
#else
#    scp -rpB ${ORG}/${PACKAGE} ${SLURM_PACKAGE_DIR}
#fi
#cp ${SLURM_PACKAGE_DIR}/${PACKAGE} .

scp -rpB ${ORG}/${PACKAGE} .

if [ -f "${PACKAGE}" ]
then 
    echo "success: package available"
    tar --strip-components=1 -xzf ${PACKAGE}
else
    echo "fail: package not available"
    scp -rpB ${SLURM_WD}/${LOGFILE} ${ORG}
    exit 0
fi

{   # input download 
    scp -rpB ${ORG}/${INPUT} .
} || {
    echo "fail: input download"
    scp -rpB ${SLURM_WD}/${LOGFILE} ${ORG}
    exit 0
}

if [ -z "${INPUT}" ]
then 
    echo "fail: input download"
    scp -rpB ${SLURM_WD}/${LOGFILE} ${ORG}
    exit 0
else
    echo "success: input download"
fi

# You can test with this, before applying real program.
echo "% hello_slurm.m
try
    disp('hello_slurm')
    in = load('${INPUT}');
    save('${OUTPUT}');
catch e 
    fprintf('%s\n', e.message); 
end 
exit " > hello_slurm.m

# Now, we we prepare program and data. We need to build for each time, in order
# to make sure each binary fits to each machine.
echo "% unitworker.m
try
    % command 1 
    build('with_omp');
    % command 2
    runOpt(100, 500, 1, '${INPUT}', '${OUTPUT}'); 
catch e 
    fprintf('%s\n', e.message); 
end 
exit " > unitworker.m

{   # Following try-catch statement ensures transferring 
    # slurm-number.out
    echo "--- program start ---"
    nohup matlab -nodisplay -nodesktop -r "unitworker"
    echo "--- program end ---"
    echo "success: program execution (but, output can be missing...)"
} || {
    # following command will be executed at any time:
    echo "fail: program execution failed for the job, ${LONGID}"
    scp -rpB ${SLURM_WD}/${LOGFILE} ${ORG}
    exit 0
}

if [ -f "${OUTPUT}" ]
then
    echo "success: output found"
else
    echo "fail: output not found"
    scp -rpB ${SLURM_WD}/${LOGFILE} ${ORG}
    exit 0
fi

{
    scp -rpB ${OUTPUT} ${ORG}
    echo "success: output transferred"
    echo "perfect"
} || { 
    echo "fail: output not transferred"
    scp -rpB ${SLURM_WD}/${LOGFILE} ${ORG}
    exit 0
}

{
    scp -rpB ${SLURM_WD}/${LOGFILE} ${ORG}
} || {
    echo "fail: logfile not transferred"
    exit 0
}

# clean after work
cd ${SLURM_WD}
rm -rf ${TEMP_WD}
rm -f ${SLURM_WD}/${LOGFILE}

exit 0
# tar cvfz yeast-4.4a_$(date +%y%m%d_%H%M).tgz yeast-4.4a" 
# sbatch --array=1-2187 array_inout.sh
# zip -P password file.zip file 
# unzip -o -P password file.zip

# md5sum ... 
# sed?


