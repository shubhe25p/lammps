#!/bin/bash

set -xe
export CRAYPE_LINK_TYPE=dynamic

# Need a Kokkos DOWNLOAD to set the path to nvcc_wrapper.
KOKKOS_PATH=$HOME/Kokkos/kokkos

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
cmake -D CMAKE_INSTALL_PREFIX=$PWD/../install_V100/ \
  -D CMAKE_CXX_COMPILER=$KOKKOS_PATH/bin/nvcc_wrapper \
  -D PKG_KOKKOS=ON -D DOWNLOAD_KOKKOS=ON -DKokkos_ENABLE_CUDA=ON -D Kokkos_ARCH_VOLTA70=ON \
  -D CMAKE_CXX_FLAGS="--expt-extended-lambda" \
  -D PKG_SNAP=ON \
  ../cmake

# make && make install
make -j16
make install -j16
