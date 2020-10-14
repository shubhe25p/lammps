**Introduction**

This is a Readme for the EXAALT Workflow Simulation
The main component in this workflow is the LAMMPS MD package.

EXAALT is an ECP project aimed at enabling long-timescale moledular dynamics through a combination of software optimization 
to enable excellent performance on exascale architectures and advanced sampling techniques to accelerate exploration of phase space. This benchmark instantiates one of the possible EXAALT workflows wherein the ParSplice manages multiple instances of the LAMMPS MD code as illustrated below.
More information about EXAALT, ParSplice and LAMMPS can be found at FIXME.

**Building**
The process of building the EXAALT benchmark as N-FIXME major steps steps:
- Installing the KOKKOS library (a LAMMPS dependency)
- Obtaining and compiling the LAMMPS (and EXAALT) source.
Both of these steps are performed by the 'build_lammps_KNL.sh' and 'build_lammps_V100.sh scripts; these are suitable for building on NERSC's Cori system and can be used as templates to guild the build process on other systems.

We have cloned the following version of the LAMMPS repo for this project :
Commit number - 1316e93eb216b3bd14f77336284ec52b76b3d371
Date - 03/31/2020
Optimized runs of the benchmark may use custom code or newer versions of LAMMPS, but NERSC supports only the tested version.

**Running**
Input files and batch scipts for N-FIXME problem sizes are provided in the LAMMPS_benchmarks directory.
The small problem is intended for build validation and profiling node-level performance characteristics.
A medium sized problem is provided to enable performance analysis for 
The large problem is meant to reflect performance at scale
The following table describes the approximate system resoures needed to run each of these jobs.

How can the concurrency be adjusted?

| Problem Size | Memory (GB) | V100 Sockets | Walltime (hours) |
| ------ | ------ | ------ | ------ |
| Small | cell | cell | cell |
| Medium | cell | cell | cell |
| Large | cell | cell | cell |

In the LAMMPS_Benchmarks directory batch.sh launches a single node job for the 2J14 problem size and the the expected results are shown in orignal-results.out

**Reporting**