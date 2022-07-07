#!/bin/bash

set -xe

module purge
module load cgpu
module load cuda
module load gcc
module load openmpi

export CRAYPE_LINK_TYPE=dynamic
HOME_BASE=$(pwd)
LAMMPS_SRC="${HOME_BASE}/lammps_src"
INSTALL_PREFIX="${HOME_BASE}/install_V100"

# Clone just the stable branch of LAMMPS if not already cloned.
if [ ! -d ${LAMMPS_SRC} ]; then
    git clone --single-branch --branch stable https://github.com/lammps/lammps.git ${LAMMPS_SRC}

    # The build instructions have been verified for the following git sha.
    # LAMMPS version - 23 June 2022
    git checkout 7d5fc356fe
fi

# Enter the lammps directory.
cd ${LAMMPS_SRC}

# Create the build dir .
if [ ! -d build_V100 ]; then
    mkdir build_V100
fi
cd build_V100
rm -rf *

# CMake build statement
cmake \
  -D CMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
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

# Only keep the install dir not the source and build dir.
cd ${HOME_BASE}
rm -rf ${LAMMPS_SRC}
