#!/bin/bash

set -xe

module purge
module load esslurm
module load cuda/11.0.1
#module load cuda/10.2.89
module load gcc/8.3.0
module load openmpi/4.0.2

# Clone the lammps github repo if not already cloned.
if [ ! -d lammps ]; then
git clone --single-branch --branch master https://github.com/lammps/lammps.git

cd lammps
# Checkout the commit from 09/02/2020.
git checkout 2cd0e9edc4fc820db21f0ac4bb6b9cd3be9fd50e

cd ../
fi

# Enter the lammps directory.
cd lammps

# Create the build dir .
if [ ! -d build_V100 ]; then
mkdir build_V100
fi
cd build_V100

# CMake build statement
cmake \
  -D CMAKE_INSTALL_PREFIX=$PWD/../install_V100 \
  -D Kokkos_ARCH_VOLTA70=ON \
  -D CMAKE_BUILD_TYPE=Release \
  -D MPI_CXX_COMPILER=mpicxx \
  -D BUILD_MPI=yes \
  -D CMAKE_CXX_COMPILER=$PWD/../lib/kokkos/bin/nvcc_wrapper \
  -D PKG_SNAP=yes \
  -D PKG_GPU=no \
  -D PKG_KOKKOS=yes \
  -D Kokkos_ENABLE_CUDA=yes \
  ../cmake

# make && make install
make -j16
make install -j16
