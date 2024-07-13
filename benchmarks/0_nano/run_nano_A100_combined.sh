#!/bin/bash -l
#SBATCH -C gpu
#SBATCH -t 00:10:00
#SBATCH -J lmp_all
#SBATCH -o lmp_all.o%j
#SBATCH -A nintern
#SBATCH -n 1
#SBATCH -c 32
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=none

# spec.txt provides the input specification
# by defining the variables spec and BENCH_SPEC
echo "------------------------------------------------------------------"
echo "Running LAMMPS with PrgEnv-gnu and Cray MPICH"
echo "------------------------------------------------------------------"
source nano_spec.txt

mkdir lmp_gnu_cmpich_$spec.$SLURM_JOB_ID
cd    lmp_gnu_cmpich_$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../nano_spec.txt .

# This is needed if LAMMPS is built using cmake.
install_dir="../../../install_PM"
export LD_LIBRARY_PATH=${install_dir}/lib64:$LD_LIBRARY_PATH
EXE=${install_dir}/bin/lmp

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

cd ..

echo "------------------------------------------------------------------"
echo "Running LAMMPS with PrgEnv-gnu and OpenMPI"
echo "------------------------------------------------------------------"

mkdir lmp_gnu_ompi_$spec.$SLURM_JOB_ID
cd    lmp_gnu_ompi_$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../nano_spec.txt .

# This is needed if LAMMPS is built using cmake.
install_dir="../../../install_GPU_gnu-ompi"
export LD_LIBRARY_PATH=${install_dir}/lib64:$LD_LIBRARY_PATH
EXE=${install_dir}/bin/lmp

# Match the build env.
module unload cray-mpich
module use /global/common/software/nersc/pe/modulefiles/latest
module load PrgEnv-gnu
module load cudatoolkit
module load openmpi

gpus_per_node=1

input="-k on g $gpus_per_node -sf kk -pk kokkos newton on neigh half ${BENCH_SPEC} " 

command="srun --mpi=pmix -n $SLURM_NTASKS ./$EXE $input"

echo $command

$command

cd ..

echo "------------------------------------------------------------------"
echo "Running LAMMPS with PrgEnv-llvm and OpenMPI"
echo "------------------------------------------------------------------"

mkdir lmp_llvm_ompi_$spec.$SLURM_JOB_ID
cd    lmp_llvm_ompi_$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../nano_spec.txt .

# This is needed if LAMMPS is built using cmake.
install_dir="../../../install_PM_GPU_LLVM"
export LD_LIBRARY_PATH=${install_dir}/lib64:$LD_LIBRARY_PATH
EXE=${install_dir}/bin/lmp

# Match the build env.
module unload cray-mpich
module unload cray-libsci
module use /global/common/software/nersc/pe/modulefiles/latest
module load PrgEnv-llvm
module load openmpi

gpus_per_node=1

input="-k on g $gpus_per_node -sf kk -pk kokkos newton on neigh half ${BENCH_SPEC} " 

command="srun --mpi=pmix -n $SLURM_NTASKS ./$EXE $input"

echo $command

$command

cd ..

echo "------------------------------------------------------------------"
echo "Running LAMMPS with PrgEnv-nvidia and Cray MPICH"
echo "------------------------------------------------------------------"

mkdir lmp_nv_cmpich_$spec.$SLURM_JOB_ID
cd    lmp_nv_cmpich_$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../nano_spec.txt .

# This is needed if LAMMPS is built using cmake.
install_dir="../../../install_GPU_nv-cmpich"
export LD_LIBRARY_PATH=${install_dir}/lib64:$LD_LIBRARY_PATH
EXE=${install_dir}/bin/lmp

# Match the build env.
module use /global/common/software/nersc/pe/modulefiles/latest
module load PrgEnv-nvidia
module load cudatoolkit
module load craype-accel-nvidia80
export MPICH_GPU_SUPPORT_ENABLED=1

gpus_per_node=1

input="-k on g $gpus_per_node -sf kk -pk kokkos newton on neigh half ${BENCH_SPEC} " 

command="srun -n $SLURM_NTASKS ./$EXE $input"

echo $command

$command


echo "------------------------------------------------------------------"
echo "Running LAMMPS with PrgEnv-llvm and CrayMPICH NOT SUPPORTED"
echo "------------------------------------------------------------------"

echo "------------------------------------------------------------------"
echo "Running LAMMPS with PrgEnv-llvm and MPICH CODE HANGS"
echo "------------------------------------------------------------------"

echo "------------------------------------------------------------------"
echo "Running LAMMPS with PrgEnv-gnu and MPICH CODE HANGS"
echo "------------------------------------------------------------------"

echo "------------------------------------------------------------------"
echo "Running LAMMPS with PrgEnv-nvidia and MPICH Permission denied"
echo "------------------------------------------------------------------"

echo "------------------------------------------------------------------"
echo "Running LAMMPS with PrgEnv-nvidia and OpenMPI Permission denied"
echo "------------------------------------------------------------------"