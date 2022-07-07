#!/bin/bash

set -xe
export CRAYPE_LINK_TYPE=dynamic
HOME_BASE=$(pwd)
LAMMPS_SRC="${HOME_BASE}/lammps_src"
INSTALL_PREFIX="${HOME_BASE}/install_knl"

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
if [ ! -d build_knl ]; then
    mkdir build_knl
fi
cd build_knl
rm -rf *

# CMake build statement
cmake -D CMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
  -D CMAKE_CXX_COMPILER=CC \
  -D CMAKE_Fortran_COMPILER=ftn \
  -D PKG_USER-OMP=ON \
  -D PKG_USER-INTEL=ON \
  -D TBB_MALLOC_LIBRARY=/opt/intel/compilers_and_libraries_2019.3.199/linux/tbb/lib/intel64/gcc4.7/libtbbmalloc.so.2 \
  -D PKG_KOKKOS=ON \
  -D DOWNLOAD_KOKKOS=ON \
  -D Kokkos_ARCH_KNL=yes \
  -D Kokkos_ENABLE_OPENMP=yes \
  -D PKG_ML-SNAP=ON \
  -D CMAKE_POSITION_INDEPENDENT_CODE=ON \
  ../cmake

# A second cmake command is needed because a few local variables need to be overwritten.
# Looks like a bug in the current commit.
#cmake ../cmake

# make && make install
make -j16
make install -j16

# Only keep the install dir not the source and build dir.
cd ${HOME_BASE}
rm -rf ${LAMMPS_SRC}
