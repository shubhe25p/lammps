This is a Readme for the EXAALT Workflow Simulation
The main component in this workflow is the LAMMPS MD package.

We have cloned the following version of the LAMMPS repo for this project :
Commit number - 1316e93eb216b3bd14f77336284ec52b76b3d371
Date - 03/31/2020

The script buil_lammps_KNL.sh in lammps builds the KNL module for LAMMPS and creates a soft-link in the LAMMPS_Benchmarks directory.
In the LAMMPS_Benchmakrs directory batch.sh launches a single node job for the 2J14 problem size and the the expected results are shown in orignal-results.out

