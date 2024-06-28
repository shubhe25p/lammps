#!/bin/bash -l
#SBATCH -N 1
#SBATCH -C cpu
#SBATCH -t 00:30:00
#SBATCH -J lmp_cpu
#SBATCH -o lmp_cpu.o%j
#SBATCH -A nintern
#SBATCH -q regular
#SBATCH -n 64
#SBATCH -c 2

# spec.txt provides the input specification
# by defining the variables spec and BENCH_SPEC
source tiny_spec.txt

mkdir lmp_cpu_$spec.$SLURM_JOB_ID
cd    lmp_cpu_$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../tiny_spec.txt .

# This is needed if LAMMPS is built using cmake.
install_dir="../../../install_PMcpu"
export LD_LIBRARY_PATH=${install_dir}/lib64:$LD_LIBRARY_PATH
EXE=${install_dir}/bin/lmp

# Match the build env.
module load PrgEnv-gnu

input="${BENCH_SPEC} " 

command="srun -n $SLURM_NTASKS $EXE $input"

echo $command

$command
