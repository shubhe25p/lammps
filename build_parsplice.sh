#!/bin/bash

## Load the appropriate modules
set -e
module purge
module load cgpu
module load gcc/9.3.0
module load openmpi/4.0.3
module load cuda/11.1.1


## Install dir
#export parsplice_install=$SCRATCH/SimulationWorkflows/ParSplice/install
export parsplice_install=$PWD/parsplice_install
export HOME=$PWD
threads=32
export LD_LIBRARY_PATH=$parsplice_install/lib:$LD_LIBRARY_PATH

build_eigen=true
build_boost=true
build_nauty=true
build_lammps_mpi=true
build_lammps_cuda=true
build_parsplice=true

## Clone parsplice repo
if [ ! -d parsplice ]; then
    git clone git@gitlab.com:exaalt/parsplice.git
    cd parsplice
    git checkout rank-assignment
    cd ../
fi
cd parsplice
cd deps

if [ $build_eigen = true ]; then
    tar -xvf eigen-eigen-26667be4f70b.tar.bz2
    cd eigen-eigen-26667be4f70b
    if [ ! -d build ]; then
        mkdir build
    fi
    cd build
    rm -rf *
    cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_INSTALL_PREFIX=$parsplice_install ../
    make -j$threads install
    cd ../
fi

cd $HOME/parsplice/deps

## Build Boost
if [ $build_boost = true ]; then
    if [ ! -d boost_1_64_0 ]; then
        tar -xzvf boost_1_64_0.tar.gz
    fi
    cd boost_1_64_0
    ./bootstrap.sh --prefix=$parsplice_install
    ./b2 toolset=gcc cxxflags=-std=c++11
    ./b2 install
    cd ../
fi

cd $HOME/parsplice/deps
if [ $build_nauty = true ]; then
    rm -rf nauty26r7/ 
    tar -xzvf nauty26r7.tar.gz
    cd nauty26r7
    ./configure --prefix=$parsplice_install
    make -j$threads
    cp nauty.a $parsplice_install/lib/libnauty.a
    if [ ! -d $parsplice_install/include/nauty ]; then
        mkdir -p $parsplice_install/include/nauty
    fi
    cp *.h $parsplice_install/include/nauty/
fi

cd $HOME

if [ $build_lammps_mpi = true ]; then
    if [ ! -d lammps ]; then
      git clone https://github.com/lammps/lammps.git
    fi
    cd lammps
    git pull
    if [ ! -d build_mpi ]; then
        mkdir -p build_mpi
    fi
    cd build_mpi
    rm -rf *
    cmake -DCMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=$PWD/../mpi_install -D BUILD_MPI=yes -D LAMMPS_MACHINE=mpi -D BUILD_SHARED_LIBS=yes -D CMAKE_CXX_COMPILER=g++ -D CMAKE_C_COMPILER=gcc -D CMAKE_MPICXX_COMPILER=mpicxx -D CMAKE_MPIC_COMPILER=mpicc ../cmake/
    make -j$threads
    make install

## Copy MPI lammps to parsplice_install
    cp $HOME/lammps/mpi_install/lib64/liblammps_mpi* $parsplice_install/lib
    if [ ! -d $parsplice_install/include/lammps ]; then
        mkdir -p $parsplice_install/include/lammps/
    fi
    cp $HOME/lammps/mpi_install/include/lammps/* $parsplice_install/include/lammps
fi

cd $HOME
echo "$HOME"

if [ $build_lammps_cuda = true ]; then
    if [ ! -d lammps ]; then
      git clone https://github.com/lammps/lammps.git
    fi
    cd lammps
    git pull
    if [ ! -d build_cuda ]; then
        mkdir -p build_cuda
    fi
    cd build_cuda
    rm -rf *
    cmake   -D CMAKE_INSTALL_PREFIX=$PWD/../cuda_install   -D Kokkos_ARCH_VOLTA70=ON   -D CMAKE_BUILD_TYPE=Release   -D MPI_CXX_COMPILER=mpicxx   -D BUILD_MPI=yes   -D CMAKE_CXX_COMPILER=$PWD/../lib/kokkos/bin/nvcc_wrapper   -D PKG_SNAP=yes   -D PKG_GPU=no   -D PKG_KOKKOS=yes   -D Kokkos_ENABLE_CUDA=yes -D BUILD_SHARED_LIBS=yes  ../cmake
    make -j$threads
    make install

## remove older lammps lib (if present) and link new cuda lammps to parsplice_install
    if [ -d $parsplice_install/lib/liblammps.so ]; then
        rm $parsplice_install/lib/liblammps.so
    fi

    ln -s $HOME/lammps/cuda_install/lib64/liblammps.so $parsplice_install/lib/liblammps.so
    ln -s $HOME/lammps/cuda_install/lib64/liblammps.so.0 $parsplice_install/lib/liblammps.so.0
fi

cd $HOME

if [ $build_parsplice = true ]; then
    cd parsplice
    if [ ! -d build ]; then
        mkdir -p build
    fi
    cd build
    rm -rf *
    cmake -DCMAKE_INSTALL_PREFIX=$parsplice_install -D CMAKE_BUILD_TYPE=Release -D CMAKE_PREFIX_PATH=$parsplice_install/include -D CMAKE_CXX_COMPILER=mpicxx -D CMAKE_C_COMPILER=mpicc ../
    make -j$threads
    make install
fi

echo "DONE"
