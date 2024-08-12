#!/bin/bash

set -xe

module rm darshan
module rm xalt

module unload cray-mpich
module use /global/common/software/nersc/pe/modulefiles/latest
module load PrgEnv-llvm
module load openmpi
# module load llvm/17
export PATH=/global/common/software/nersc/pe/gpu/llvm/nightly/bin:$PATH
export LD_LIBRARY_PATH=/global/common/software/nersc/pe/gpu/llvm/nightly/lib:$LD_LIBRARY_PATH

threads=64

HOME_BASE=$(pwd)
LAMMPS_SRC="${HOME_BASE}/lammps_for_cmake"
INSTALL_PREFIX="${HOME_BASE}/install_GPU_llvm19+ompi"

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
if [ ! -d build_llvm19+ompi ]; then
    mkdir build_llvm19+ompi
fi
cd build_llvm19+ompi
rm -rf *

cmake \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_Fortran_COMPILER=mpifort \
    -D CMAKE_C_COMPILER=mpicc \
    -D CMAKE_CXX_COMPILER=mpicxx \
    -D CMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -D LAMMPS_EXCEPTIONS=on \
    -D BUILD_SHARED_LIBS=on \
    -D BUILD_MPI=yes \
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

