#!/bin/bash -l
#SBATCH -C gpu
#SBATCH -t 00:10:00
#SBATCH -J lmp_nano_gnu_mpich
#SBATCH -o lmp_nano_gnu_mpich.o%j
#SBATCH -A nintern
#SBATCH -n 1
#SBATCH -c 32
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=none

# spec.txt provides the input specification
# by defining the variables spec and BENCH_SPEC
source nano_spec.txt

mkdir lmp_nano_gnu_mpich_$spec.$SLURM_JOB_ID
cd    lmp_nano_gnu_mpich_$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../nano_spec.txt .

# This is needed if LAMMPS is built using cmake.
install_dir="../../../install_GPU_gnu-mpich"
export LD_LIBRARY_PATH=${install_dir}/lib64:$LD_LIBRARY_PATH
EXE=${install_dir}/bin/lmp

# Match the build env.
# module use /global/common/software/nersc/pe/modulefiles/latest
module load PrgEnv-gnu
module load mpich/4.1.1
module load cudatoolkit/11.7

gpus_per_node=1

input="-k on g $gpus_per_node -sf kk -pk kokkos newton on neigh half ${BENCH_SPEC} " 

command="srun -n $SLURM_NTASKS ./$EXE $input"

echo $command

$command
