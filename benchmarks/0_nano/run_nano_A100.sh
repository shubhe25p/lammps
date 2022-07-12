#!/bin/bash -l
#SBATCH -C gpu
#SBATCH -t 00:10:00
#SBATCH -J lmp_nano
#SBATCH -o lmp_nano.o%j
#SBATCH -A nstaff_g
#SBATCH -n 1
#SBATCH -c 32
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=none

# spec.txt provides the input specification
# by defining the variables spec and BENCH_SPEC
source nano_spec.txt

mkdir lammps_$spec.$SLURM_JOB_ID
cd    lammps_$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../nano_spec.txt .

# This is needed if LAMMPS is built using cmake.
export LD_LIBRARY_PATH=../../../install_PM/lib64:$LD_LIBRARY_PATH
EXE=../../../install_PM/bin/lmp

# Match the build env.
module load PrgEnv-gnu
module load cudatoolkit
module load craype-accel-nvidia80
export MPICH_GPU_SUPPORT_ENABLED=1

gpus_per_node=1

input="-k on g $gpus_per_node -sf kk -pk kokkos newton on neigh half ${BENCH_SPEC} " 

command="srun -n $SLURM_NTASKS ./$EXE $input"

echo $command

$command
