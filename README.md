This repository describes the Materials by Design benchmark
from the [NERSC-10 Workflow benchmark suite](URL-tbd).<br>
The [NERSC-10 benchmark run rules](URL-tbd) should be reviewed before running this benchmark.<br>
Note, in particular:
- The NERSC-10 run rules apply to the Materials by Design benchmark except where explicitly noted within this README.
- The run rules define "baseline", "ported" and "optimized" categories of performance optimization.
- Responses to the NERSC-10 RFP should include performance estimates for the "baseline" category;
  results for the "ported" and "optimized" categories are optional.
- RFP responses should estimate the performance for the "xlbench" problem on the proposed architecture.
- The projected walltime for the "xlbench" problem on the proposed system
  must not exceed the "reference time" measured by runnning  the "large" problem on Perlmutter.
  Concurrency adjustments (i.e. weak- or strong-scaling) may be needed to match the reference time.
- The "capability factor" (c) descibes the increase in
computational work (e.g. flops) between the large and xlbench problems,
and may be used to guide resource requirments for the xlbench problem.
The capability factor is also used  to compute  the [SSI metric](URL-tbd).

# 0. Materials by Design Overview
A fundamental challenge for molecular dynamics (MD) simulation is to propagate the dynamics for a sufficiently long simulated time to sample all of the relevant molecular configurations.  Historical MD workflows have therefore consisted of long-running jobs (or sequences of jobs), where each time-step may be accelerated by disributing atoms across parallel processing units, but the series of time-steps progresses sequentially. Recent advances in MD sampling effectivly provide route to parallelize the time dimension of the simulation as well.  

EXAALT is an ECP project aimed at enabling long-timescale MD through a combination of software optimization to enable excellent performance on exascale architectures and the advanced sampling methods mentioned above. 
One of the possible EXAALT workflows uses ParSplice to manage multiple instances of the LAMMPS MD engine.

<img width="49%" alt="EXAALT workflow"    src="figures/exaalt_workflow.png"    title="EXAALT workflow" >
<img width="49%" alt="EXAALT decorrelate" src="figures/exaalt_decorrelate.png" title="EXAALT decorrelate" >

An individual LAMMPS job is relatively brief, and ParSplice provides a hierarchical task management layer that uses physics-based criteria to select which configurations to in order to efficiently explore the potential energy survace.  More information about EXAALT, ParSplice and LAMMPS can be found at:
- EXAALT:    https://www.exascaleproject.org/research-project/exaalt/
- ParSplice: https://doi.org/10.1021/acs.jctc.5b00916
- LAMMPS:     https://doi.org/10.1016/j.cpc.2021.108171 

The Materials by Design workflow benchmark is based on  the ParSplice +  LAMMPS workflow, 
but the ParSplice workflow engine is not involved in the benchmark because it would add significant complexity in compiling, running and performance analysis of the simulations.  Instead, the benchmark consists of a single run of the LAMMPS MD package, which is the performance critical component of the workflow, typically using over 95% of the EXAALT runtime. The benchmark problem simulates the high-pressure BC8 phase of carbon using the Spectral Neighbor Analysis Potential (SNAP). LAMMPS's highly optimized implementation of the SNAP potential was written using the Kokkos portability layer, as described in: https://doi.org/10.1145/3458817.3487400

# 1. Code Access and Compilation Details
The process of building the benchmark has three basic steps:
obtaining the source code, configuring the build system, and compiling the source code.
The build instructions in this sections follow the `build_lammps_cpu.sh` script,
which is suitable for a generic Linux workstation without a GPU accelerator,
can be used as templates to guild the build process on other systems.
Examples for NERSC's Perlmutter-CPU and Perlmutter-GPU systems can be found in
the build_lammps_PMcpu.sh and build_lammps_PM.sh scripts.


## 1.1 Obtaining LAMMPS source code
The following three commands will clone the stable branch of LAMMPS from version 23 June 2022. This is the required version for baseline runs of the benchmark. Optimized runs may use custom code or newer versions of LAMMPS, but NERSC supports only the tested version.
```console
    git clone --single-branch --branch stable https://github.com/lammps/lammps.git
    cd lammps_src
    git checkout 7d5fc356fe
```

<!-- The kokkos version number was obtained from 
 https://github.com/lammps/lammps/releases/tag/stable_23Jun2022_update1 -->
Kokkos version 3.6.1 is distributed with and used by this LAMMPS version.
Baseline results must use this version of the Kokkos library and backends.
Optimized results may use other versions of Kokkos 
and may include custom backends optimized for the target architecture.


## 1.2 Configuring the LAMMPS build system
LAMMPS uses the CMake tool to configure the build system and generate the makefiles.
From within the `lammps` directory, run the CMake commands
that is most appropriate for your compute architecture.
The example below is suitable for generic Linux workstation without a GPU accelerator.
Additional cmake options that may be useful when customizing for other systems/architectures can be found
in chapter 3 of the [LAMMPS User Guide](https://lammps.sandia.gov/doc/Build.html).

```
cmake -D CMAKE_INSTALL_PREFIX=$PWD/../install_cpu/ \
      -D CMAKE_CXX_COMPILER=g++ \
      -D CMAKE_Fortran_COMPILER=gfortran \
      -D BUILD_MPI=yes \
      -D MPI_CXX_COMPILER=mpicxx \
      -D PKG_USER-OMP=ON \
      -D PKG_KOKKOS=ON \
      -D DOWNLOAD_KOKKOS=ON \
      -D Kokkos_ARCH_FIXME=ON \
      -D PKG_ML-SNAP=ON \
      -D CMAKE_POSITION_INDEPENDENT_CODE=ON \
      -D CMAKE_EXE_FLAGS="-dynamic" \
      ../cmake
```

## 1.3  Building LAMMPS
The build scripts configure, build and install the lammps library in the repo's main directory path. The following commands will compile LAMMPS and install the executable at `lammps/install_<ARCH>/bin/lmp`.
```console
make
make install
```

# 2. Running the benchmark

Input files and batch scipts for seven (7) problem sizes are provided in the benchmarks directory.
NERSC-10 RFP responses should provide results (measured or projected) for the "xlbench" problem size.
SSI reference values from NERSC's Perlutter system were evaluated using the "large" problem size.
Other problem sizes  have been provided as a convenience,
to facilitate profiling at different scales (e.g. socket, node, blade or rack),
and extraplation to larger sizes.
This collection of problems form a weak scaling series
where each successively larger problem simulates eight times as many atoms as the previous one.
Computational requirements are expected to scale linearly with the number of atoms.
The following table lists the approximate system resoures
needed to run each of these jobs on Perlmutter.
The C parameter is an estimate of the compuational complexity of the problem relative to the "large" problem.


|Index | Size    |  #atoms |    Capability <bf> Factor (c)            |
|----- | ----    |  ------ | ------          |
|0     | nano    |     65k |  8<sup>-5</sup> |
|1     | micro   |    524k |  8<sup>-4</sup> |
|2     | tiny    |   4.19M |  8<sup>-3</sup> |
|3     | small   |   33.6M |  8<sup>-2</sup> |
|4     | medium  |   268.M |      0.125      |
|5     | large   |   2.15B |       1         |
|6     | xlbench |   17.2B |       8         |

Each problem has its own subdirectory within the benchmarks directory.
Within those directories, the `run_<size>_A100.sh` script shows
how the jobs were executed on Perlmutter. 

The essential  steps are to
1. add a link to the data that are common to all problem sizes: `ln -s ../../common`
2. load the size-specific simulation parameters into the BENCH_SPEC variable: `source <size>_spec.txt`
3. run the job: `srun -n #ranks  /path/to/lammps/lmp  <lammps_options>  ${BENCH_SPEC}
No lammps_options are needed for CPU-only runs.
The recommended lammps_options for Perlmutter-GPU (and similar systems) are:
"-k on g 1 -sf kk -pk kokkos newton on neigh half" 

# 3. Results

## 3.1 Correctness
Correctness can be verified by comparing the total energy per unit cell after 100 time-steps
to the expected value on computed on Perlmutter ( -8.7467391 ).
The relevant energy measurement can be extracted by the command
```grep '       100' lammps.out | awk '{print $5}'```
The tolerance for the relative error is a physics-motivated function of the problem size
and is more strict for larger problems.
The `validate.py` script is provided to perform the comparison.
```
$ validate.py --help
| validate.sh: test output correctness for the NERSC-10 LAMMPS benchmark.
| Usage: validate.sh <output_file>
|
$ validate.py lmp_nano.out
| Found size: 0_nano
| Validation: PASSED
| LAMMPS_walltime(sec): 3.14565
```

## 3.2 Timing

The  walltime of the job can be extracted from the LAMMPS output by the command
```grep "Loop time:" lammps.out```
It is also printed by `validate.py`.

## 3.3 Reference Performance on Perlmutter

The sample data in the table below are measured runtimes from NERSC's Perlmutter GPU system.
Perlmutter's  GPU nodes have one AMD EPYC 7763 CPU and four NVIDIA A100 GPUs;
GPU jobs used four MPI tasks per node, each with one GPU and 16 cores.
The upper rows of the table describe the weak-scaling performance of LAMMPS.
Lower rows desribe the strong-scaling performance of LAMMPS when running the large problem.

| Size    |  #PM nodes | Total Mem(GB) | #time(sec) |
| ----    | ---------- | ------------- | ---------  |
| nano    |    0.25    |      0.14     |      3     |
| micro   |    0.25    |      0.23     |     25     |
| tiny    |       1    |      1.33     |     54     |
| small   |       1    |      7.32     |    424     |
| medium  |       8    |      58.6     |    405     |
| large   |      32    |      453.     |    805     |
| large   |      64    |      453.     |    445     |
| large   |     128    |      453.     |    213     |
| large   |     256    |      453.     |    130     |
| large   |     512    |     453.      |     55     |
| large   |    1024    |     453.      |     31*    |

The reference time was determined
by running the large problem on 1024 Perlmutter GPU-nodes
and is marked by a *.
The projected walltime for the "xlbench" problem on the proposed system
must not exceed this value.

## 3.4 Reporting

Benchmark results should include projections of the walltime xlbench problem size for the workflow. 
The hardware configuration 
(i.e. the number of elements from each pool of computational resources) 
needed to achieve the estimated timings must also be provided. 
For example, if proposing a system with more than one type of compute node, 
then report the number and type of nodes used to run the workflow. 
If the proposed system enables disaggregation/ composability, 
a finer grained resource list is needed, as described in the [Workflow-SSI document](link).

For the electronic submission, 
include all the source and makefiles used to build on the target platform 
and input files and runscripts. 
Include all standard output files.



