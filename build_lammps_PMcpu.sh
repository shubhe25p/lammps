#!/bin/bash

#set -xe

module rm darshan
module rm xalt
# module load PrgEnv-gnu

threads=4

HOME_BASE=$(pwd)
LAMMPS_SRC="${HOME_BASE}/lammps_src"
INSTALL_PREFIX="${HOME_BASE}/install_PMcpu"

# Clone just the stable branch of LAMMPS if not already cloned.
if [ ! -d ${LAMMPS_SRC} ]; then
    git clone --single-branch --branch stable https://github.com/lammps/lammps.git ${LAMMPS_SRC}
fi

# Enter the lammps directory.
cd ${LAMMPS_SRC}

# The build instructions have been verified for the following git sha.
# LAMMPS version - 23 June 2022
git checkout 7d5fc356fe

#patch minor allocation error
sed -i s/new\ char.7./new\ char[8]/ src/KOKKOS/kokkos.cpp

# Create the build dir .
if [ ! -d build_PMcpu ]; then
    mkdir build_PMcpu
fi
cd build_PMcpu
rm -rf *

cmake -D CMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
      -D CMAKE_CXX_COMPILER=CC \
      -D CMAKE_Fortran_COMPILER=ftn \
      -D BUILD_MPI=yes \
      -D MPI_CXX_COMPILER=CC \
      -D PKG_USER-OMP=ON \
      -D PKG_KOKKOS=ON \
      -D DOWNLOAD_KOKKOS=ON \
      -D Kokkos_ARCH_FIXME=ON \
      -D PKG_ML-SNAP=ON \
      -D CMAKE_POSITION_INDEPENDENT_CODE=ON \
      -D CMAKE_EXE_FLAGS="-dynamic" \
      ../cmake

make -j${threads}
make install -j${threads}

# Only keep the install dir not the source and build dir.
#cd ${HOME_BASE}
#rm -rf ${LAMMPS_SRC}
