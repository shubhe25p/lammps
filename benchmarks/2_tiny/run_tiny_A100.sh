#!/bin/bash -l
#SBATCH -C gpu
#SBATCH -t 00:10:00
#SBATCH -J lmp_tiny
#SBATCH -o lmp_tiny.o%j
#SBATCH -A nstaff_g
#SBATCH -n 4
#SBATCH -c 32
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=none

# spec.txt provides the input specification
# by defining the variables spec and BENCH_SPEC
source tiny_spec.txt

mkdir lammps_$spec.$SLURM_JOB_ID
cd    lammps_$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../tiny_spec.txt .

# This is needed if LAMMPS is built using cmake.
export LD_LIBRARY_PATH=../../../perlmutter/build_pm/lib64:$LD_LIBRARY_PATH
EXE=../../../perlmutter/build_pm/bin/lmp

# Match the build env.
module load PrgEnv-gnu
module load cudatoolkit
module load craype-accel-nvidia80

gpus_per_node=4

input="-k on g $gpus_per_node -sf kk -pk kokkos newton on neigh half ${BENCH_SPEC} " 

command="srun -n $SLURM_NTASKS ./$EXE $input"

echo $command

$command
