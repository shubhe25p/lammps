#!/bin/bash -l
#SBATCH -C gpu
#SBATCH -t 00:10:00
#SBATCH -J lmp_nano_nv_ompi
#SBATCH -o lmp_nano_nv_ompi_.o%j
#SBATCH -A nintern
#SBATCH -n 1
#SBATCH -c 32
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=none

# spec.txt provides the input specification
# by defining the variables spec and BENCH_SPEC
source nano_spec.txt

mkdir lmp_nano_nv_ompi_$spec.$SLURM_JOB_ID
cd    lmp_nano_nv_ompi_$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../nano_spec.txt .

# This is needed if LAMMPS is built using cmake.
install_dir="../../../install_GPU_nv-ompi"
export LD_LIBRARY_PATH=${install_dir}/lib64:$LD_LIBRARY_PATH
EXE=${install_dir}/bin/lmp

# Match the build env.
module unload cray-mpich
module use /global/common/software/nersc/pe/modulefiles/latest
module load PrgEnv-nvidia
module load cudatoolkit
module load openmpi

gpus_per_node=1

input="-k on g $gpus_per_node -sf kk -pk kokkos newton on neigh half ${BENCH_SPEC} " 

command="srun --mpi=pmix -n $SLURM_NTASKS ./$EXE $input"

echo $command

$command