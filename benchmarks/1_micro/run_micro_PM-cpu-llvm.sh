#!/bin/bash -l
#SBATCH -N 1
#SBATCH -C cpu
#SBATCH -t 00:30:00
#SBATCH -J lmp_micro_PM_cpu-llvm
#SBATCH -o lmp_micro_PM_cpu-llvm.o%j
#SBATCH -A nintern
#SBATCH -q debug
#SBATCH -n 64
#SBATCH -c 2

# spec.txt provides the input specification
# by defining the variables spec and BENCH_SPEC
source micro_spec.txt

mkdir lammps_cpu-llvm-$spec.$SLURM_JOB_ID
cd    lammps_cpu-llvm-$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../micro_spec.txt .

# This is needed if LAMMPS is built using cmake.
install_dir="../../../install_PM_CPU_llvm"
export LD_LIBRARY_PATH=${install_dir}/lib64:$LD_LIBRARY_PATH
EXE=${install_dir}/bin/lmp

# Match the build env.
module unload cray-mpich
module unload cray-libsci
module load PrgEnv-llvm
module load openmpi

input="${BENCH_SPEC} " 

command="srun --mpi=pmix -n $SLURM_NTASKS $EXE $input"

echo $command

$command
