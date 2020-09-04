#!/bin/bash

#SBATCH -A nstaff
#SBATCH -C gpu
#SBATCH -N 1
#SBATCH -t 2:00:00
#SBATCH --gres=gpu:1

echo "=============================================="
echo "Running a single node SNAP benchmark on 1 GPU"
echo "      2J14 problem size"
echo "=============================================="

NODES=1
EXE=lmp_cgpu

srun -u ./${EXE} -k on g 1 -sf kk -pk kokkos newton on neigh half -in in.snap.test -var nsteps 10 -var nx 10 -var ny 10 -var nz 10 -var snapdir 2J14_W.SNAP/
