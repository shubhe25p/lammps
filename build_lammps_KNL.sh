#!/bin/bash

set -xe
export CRAYPE_LINK_TYPE=dynamic

# Clone the lammps github repo if not already cloned.
if [ ! -d lammps ]; then
git clone --single-branch --branch master https://github.com/lammps/lammps.git

export CRAYPE_LINK_TYPE=dynamic
cd lammps
# Checkout the commit from 09/02/2020.
#git checkout 2cd0e9edc4fc820db21f0ac4bb6b9cd3be9fd50e

cd ../
fi

# Enter the lammps directory.
cd lammps

# Create the build dir .
if [ ! -d build_knl ]; then
mkdir build_knl
fi
cd build_knl

# CMake build statement
cmake -D CMAKE_INSTALL_PREFIX=$PWD/../install_knl/ \
  -D CMAKE_CXX_COMPILER=CC -D CMAKE_Fortran_COMPILER=ftn \
  -D PKG_USER-OMP=ON \
  -D PKG_USER-INTEL=ON -D TBB_MALLOC_LIBRARY=/opt/intel/compilers_and_libraries_2019.3.199/linux/tbb/lib/intel64/gcc4.7/libtbbmalloc.so.2 \
  -D PKG_KOKKOS=ON -D DOWNLOAD_KOKKOS=ON -D Kokkos_ARCH_KNL=ON \
  -D PKG_SNAP=ON \
  -D CMAKE_POSITION_INDEPENDENT_CODE=ON \
  ../cmake

# A second cmake command is needed because a few local variables need to be overwritten.
# Looks like a bug in the current commit.
cmake ../cmake

# make && make install
make -j16
make install -j16
