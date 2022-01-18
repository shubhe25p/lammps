#!/bin/bash
#SBATCH --job-name=4V-0He # Job name
#SBATCH --time=00:15:00              # Time limit hrs:min:sec
#SBATCH -C gpu
#SBATCH -q early_science
#SBATCH -A m3916_g
#SBATCH -n 600
#SBATCH --ntasks-per-node=60
#SBATCH -c 2
#SBATCH --gpus-per-node=4 
#SBATCH --gpu-bind=map_gpu:0,1,2,3

export SLURM_CPU_BIND="cores"

cd $SLURM_SUBMIT_DIR

#date;hostname;pwd

source /global/cfs/cdirs/m3916/exaalt-local/env.sh

export OMP_NUM_THREADS=1
./clean.sh
srun     parsplice

date

