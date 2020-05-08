#!/bin/bash

##Batch job for LAMMPS MPI+Kokkos. SNAP module set for 2J8 problem size. On KNL the best performance is via 64 MPI rank with 4 OMP threads per MPI rank. OpenMP is implemented using Kokkos framework.
#SBATCH --nodes=1
#SBATCH -C knl
#SBATCH -S 4
#SBATCH --time=00:30:00
#SBATCH --qos=debug

NODES=1
MPIPNODE=64
THREADS=4
EXE=lmp_kokkos_phi

export OMP_PLACES=threads
export OMP_PROC_BIND=true
export OMP_NUM_THREADS=${THREADS}

srun -u --cpu_bind=cores --nodes ${NODES} --ntasks-per-node ${MPIPNODE} ./${EXE} -k on t ${THREADS} -sf kk -in in.snap.test -var nsteps 10 -var nx 10 -var ny 10 -var nz 10 -var snapdir 2J14_W.SNAP/
