#!/bin/bash

set -xe

module rm darshan
module rm xalt

module use /global/common/software/nersc/pe/modulefiles/latest
module load PrgEnv-gnu
module load cudatoolkit
module load mpich
module load craype
module load cray-dsmml
module load cray-libsci
export PATH=/opt/cray/pe/cce/17.0.0/binutils/x86_64/x86_64-pc-linux-gnu/bin:/opt/cray/pe/cce/17.0.0/binutils/cross/x86_64-aarch64/aarch64-linux-gnu/../bin:/opt/cray/pe/cce/17.0.0/utils/x86_64/bin:/opt/cray/pe/cce/17.0.0/bin:$PATH
export LD_LIBRARY_PATH=/opt/cray/pe/cce/17.0.0/cce-clang/x86_64/lib:$LD_LIBRARY_PATH

threads=64

HOME_BASE=$(pwd)
LAMMPS_SRC="${HOME_BASE}/lammps_src"
INSTALL_PREFIX="${HOME_BASE}/install_GPU_craycc-mpich"

# Clone just the stable branch of LAMMPS if not already cloned.
if [ ! -d ${LAMMPS_SRC} ]; then
    git clone --single-branch --branch stable https://github.com/lammps/lammps.git ${LAMMPS_SRC}
fi

# Enter the lammps directory.
cd ${LAMMPS_SRC}

# The build instructions have been verified for the following git sha.
# LAMMPS version - 23 June 2022
git checkout 7d5fc356fe

#update minimum architecture bc new versions of nvcc (>=12) dont support sm35
sed -i s/sm_35/sm_80/ ${LAMMPS_SRC}/lib/kokkos/bin/nvcc_wrapper

#patch minor allocation error
sed -i s/new\ char.7./new\ char[8]/ src/KOKKOS/kokkos.cpp

# Create the build dir .
if [ ! -d build_PM ]; then
    mkdir build_PM
fi
cd build_PM
rm -rf *

cmake \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_Fortran_COMPILER=ftn \
    -D CMAKE_C_COMPILER=cc \
    -D CMAKE_CXX_COMPILER=CC \
    -D CMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -D LAMMPS_EXCEPTIONS=on \
    -D BUILD_SHARED_LIBS=on \
    -D PKG_KOKKOS=yes -D Kokkos_ARCH_AMPERE80=ON -D Kokkos_ENABLE_CUDA=yes \
    -D PKG_MANYBODY=yes \
    -D PKG_REPLICA=yes \
    -D PKG_ML-SNAP=yes \
    -D PKG_EXTRA-FIX=yes \
    -D PKG_MPIIO=yes \
    -D LAMMPS_SIZES=BIGBIG \
    ../cmake

make -j${threads}
make install -j${threads}

# Only keep the install dir not the source and build dir.
cd ${HOME_BASE}
rm -rf ${LAMMPS_SRC}
