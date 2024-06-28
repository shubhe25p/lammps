#!/bin/bash -l
#SBATCH -C gpu
#SBATCH -q regular
#SBATCH -t 00:30:00
#SBATCH -J lmp_gpu
#SBATCH -o lmp_gpu.o%j
#SBATCH -A nintern
#SBATCH -n 32
#SBATCH -c 32
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=none

# spec.txt provides the input specification
# by defining the variables spec and BENCH_SPEC
source medium_spec.txt

mkdir lmp_gpu_$spec.$SLURM_JOB_ID
cd    lmp_gpu_$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../medium_spec.txt .

# This is needed if LAMMPS is built using cmake.
install_dir="../../../install_PM"
export LD_LIBRARY_PATH=${install_dir}/lib64:$LD_LIBRARY_PATH
EXE=${install_dir}/bin/lmp

# Match the build env.
module load PrgEnv-gnu
module load cudatoolkit
module load craype-accel-nvidia80
export MPICH_GPU_SUPPORT_ENABLED=1

gpus_per_node=4

input="-k on g $gpus_per_node -sf kk -pk kokkos newton on neigh half ${BENCH_SPEC} " 

command="srun -n $SLURM_NTASKS ./$EXE $input"

echo $command

$command
