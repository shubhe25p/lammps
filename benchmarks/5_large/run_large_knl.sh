#!/bin/bash
#SBATCH --nodes=4096
#SBATCH -C knl
#SBATCH -S 4
#SBATCH --time=01:00:00
#SBATCH --qos=regular
#SBATCH -A m888
#SBATCH -J lmp_large

# spec.txt provides the input specification
# by defining the variables spec and BENCH_SPEC
source large_spec.txt

mkdir lammps_$spec.$SLURM_JOB_ID
cd    lammps_$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../large_spec.txt .

NODES=${SLURM_JOB_NUM_NODES}
MPIPNODE=64
THREADS=1
EXE=../../../lammps/build_knl/lmp

export OMP_PLACES=threads
export OMP_PROC_BIND=true
export OMP_NUM_THREADS=${THREADS}

#profiling options
#
export IPM_LOG=none
export IPM_ROOT=/global/common/software/m1759/ipm/install/cori_intel_cray-mpich
export LD_PRELOAD=$IPM_ROOT/lib/libipm.so
#
#module load darshan
#export DARSHAN_LOGFILE=lammps_$spec.darshan.log


srun -u --cpu_bind=cores --nodes ${NODES} --ntasks-per-node ${MPIPNODE} \
	${EXE} -k on t ${THREADS} -sf kk \
	${BENCH_SPEC} \
	> lammps_$spec.out

