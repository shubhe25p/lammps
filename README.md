
# Introduction

This is a Readme for the EXAALT Workflow Simulation
The main component in this workflow is the LAMMPS MD package.

EXAALT is an ECP project aimed at enabling long-timescale moledular dynamics through a combination of software optimization 
to enable excellent performance on exascale architectures and advanced sampling techniques to accelerate exploration of phase space. This benchmark instantiates one of the possible EXAALT workflows wherein the ParSplice manages multiple instances of the LAMMPS MD code as illustrated below.
More information about EXAALT, ParSplice and LAMMPS can be found at FIXME.

# Building
The process of building the EXAALT benchmark has three basic steps: obtaining the source code, configuring the build system, and compiling the source code.  
Both of these steps are performed by the `build_lammps_KNL.sh` and `build_lammps_V100.sh` scripts;  
these are suitable for building on NERSC's Cori system and can be used as templates to guild the build process on other systems.

## Obtaining LAMMPS source code
The following three commands will clone a 03/31/2020 version of the LAMMPS repo.
Optimized runs of the benchmark may use custom code or newer versions of LAMMPS, but NERSC supports only the tested version.
```
    git clone --single-branch --branch master https://github.com/lammps/lammps.git
    cd lammps
    git checkout 2cd0e9edc4fc820db21f0ac4bb6b9cd3be9fd50e
```

## Configuring the LAMMPS build system
LAMMPS uses the Cmake tool to prepare the makefiles.
From within the `lammps` directory, run *one* of the following cmake commands that is most appropriate for your compute architecture. More cmake options that may be useful when customizing for other systems/architectures can be found in chapter 3 of the LAMMPS User Guide: https://lammps.sandia.gov/doc/Build.html.

| Host | cmake |
| ---- | ----- |
| Cori KNL | cmake -D CMAKE_INSTALL_PREFIX=$PWD/../install_knl/ \ <br>&nbsp;&nbsp;&nbsp;&nbsp; -D CMAKE_CXX_COMPILER=CC  \ <br>&nbsp;&nbsp;&nbsp;&nbsp;    -D CMAKE_Fortran_COMPILER=ftn \ <br>&nbsp;&nbsp;&nbsp;&nbsp;    -D PKG_USER-OMP=ON \ <br>&nbsp;&nbsp;&nbsp;&nbsp;    -D PKG_USER-INTEL=ON \ <br>&nbsp;&nbsp;&nbsp;&nbsp;    -D TBB_MALLOC_LIBRARY=**/path/to/libtbbmalloc.so.2** \ <br>&nbsp;&nbsp;&nbsp;&nbsp;    -D PKG_KOKKOS=ON -D DOWNLOAD_KOKKOS=ON \ <br>&nbsp;&nbsp;&nbsp;&nbsp; -D Kokkos_ARCH_KNL=ON \ <br>&nbsp;&nbsp;&nbsp;&nbsp;    -D PKG_SNAP=ON  \ <br>&nbsp;&nbsp;&nbsp;&nbsp;    -D CMAKE_POSITION_INDEPENDENT_CODE=ON \ <br>&nbsp;&nbsp;&nbsp;&nbsp;    -D CMAKE_EXE_FLAGS="-dynamic" \ <br>&nbsp;&nbsp;&nbsp;&nbsp;    ../cmake |
| Cori V100 | cmake -D CMAKE_INSTALL_PREFIX=$PWD/../install_V100 \ <br>&nbsp;&nbsp;&nbsp;&nbsp;  -D Kokkos_ARCH_VOLTA70=ON \ <br>&nbsp;&nbsp;&nbsp;&nbsp;  -D CMAKE_BUILD_TYPE=Release \ <br>&nbsp;&nbsp;&nbsp;&nbsp;  -D MPI_CXX_COMPILER=mpicxx \ <br>&nbsp;&nbsp;&nbsp;&nbsp;  -D BUILD_MPI=yes \ <br>&nbsp;&nbsp;&nbsp;&nbsp;  -D CMAKE_CXX_COMPILER=$PWD/../lib/kokkos/bin/nvcc_wrapper \ <br>&nbsp;&nbsp;&nbsp;&nbsp;  -D PKG_SNAP=yes \ <br>&nbsp;&nbsp;&nbsp;&nbsp;  -D PKG_GPU=no \ <br>&nbsp;&nbsp;&nbsp;&nbsp;  -D PKG_KOKKOS=yes \ <br>&nbsp;&nbsp;&nbsp;&nbsp;  -D Kokkos_ENABLE_CUDA=yes \ <br>&nbsp;&nbsp;&nbsp;&nbsp;  ../cmake |
| Generic Linux | cmake -D CMAKE_INSTALL_PREFIX=$PWD/../install_gcc/ \ <br>&nbsp;&nbsp;&nbsp;&nbsp; -D CMAKE_CXX_COMPILER=g++ \ <br>&nbsp;&nbsp;&nbsp;&nbsp; -D CMAKE_Fortran_COMPILER=gfortran \ <br>&nbsp;&nbsp;&nbsp;&nbsp; -D BUILD_MPI=yes \ <br>&nbsp;&nbsp;&nbsp;&nbsp; -D MPI_CXX_COMPILER=mpicxx \ <br>&nbsp;&nbsp;&nbsp;&nbsp; -D PKG_USER-OMP=ON \ <br>&nbsp;&nbsp;&nbsp;&nbsp; -D PKG_KOKKOS=ON \ <br>&nbsp;&nbsp;&nbsp;&nbsp; -D DOWNLOAD_KOKKOS=ON \ <br>&nbsp;&nbsp;&nbsp;&nbsp; -D Kokkos_ARCH_FIXME=ON \ <br>&nbsp;&nbsp;&nbsp;&nbsp; -D PKG_SNAP=ON \ <br>&nbsp;&nbsp;&nbsp;&nbsp; -D CMAKE_POSITION_INDEPENDENT_CODE=ON \ <br>&nbsp;&nbsp;&nbsp;&nbsp; -D CMAKE_EXE_FLAGS="-dynamic" \ <br>&nbsp;&nbsp;&nbsp;&nbsp; ../cmake |

## Compiling LAMMPS
Again from the `lammps` directory, the following commands will compile LAMMPS and install the executable at `lammps/install_ARCH/bin/lmp`.
```
make
make install
```
For convenience in later steps (when running the benchmark), you may want to create links to the executables in the LAMMPS_benchmarks directory:
```
cd ../LAMMPS_benchmarks
ln -s ../lammps/install_knl/bin/lmp  ./lmp_knl
ln -s ../lammps/install_cgpu/bin/lmp ./lmp_cgpu
```

# Running the EXAALT benchmark
Input files and batch scipts for N-FIXME problem sizes are provided in the LAMMPS_benchmarks directory.
The small problem is intended for build validation and profiling node-level performance characteristics.
A medium sized problem is provided to enable performance analysis for 
The large problem is meant to reflect performance at scale
The following table describes the approximate system resoures needed to run each of these jobs.

How can the concurrency be adjusted?

| Problem Size | Memory (GB) | V100 Sockets | Walltime (hours) |
| ------       | ------      | ------       | ------           |
| Small        | cell        | cell         | cell             |
| Medium       | cell        | cell         | cell             |
| Large        | cell        | cell         | cell             |

In the LAMMPS_Benchmarks directory batch.sh launches a single node job for the 2J14 problem size and the the expected results are shown in orignal-results.out

# Reporting
