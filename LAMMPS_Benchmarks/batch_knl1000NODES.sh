#!/bin/bash

#SBATCH --nodes=1000
#SBATCH -C knl
#SBATCH -S 4
#SBATCH --time=00:30:00
#SBATCH --qos=regular

NODES=1000
MPIPNODE=64
threads=4
EXE=lmp_knl

echo "==================================================="
echo "Running a SNAP benchmark on ${NODES} KNL nodes."
echo "Each KNL node uses ${MPINODE} MPI ranks
      and each MPI rank uses ${threads} number of threads."
echo"      2J14 problem size"
echo "==================================================="

export OMP_PLACES=threads
export OMP_PROC_BIND=true
export OMP_NUM_THREADS=${THREADS}

srun -u --cpu_bind=cores --nodes ${NODES} --ntasks-per-node ${MPIPNODE} ./${EXE} -k on t ${THREADS} -sf kk -in in.snap.test -var nsteps 10 -var nx 10 -var ny 10 -var nz 10 -var snapdir 2J14_W.SNAP/
