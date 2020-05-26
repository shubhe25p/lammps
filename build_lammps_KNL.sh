#!/bin/bash

# clone the lammps github repo
git clone https://github.com/lammps/lammps.git

# enter lammps directory and revert to the particular commit
cd lammps
git checkout 1316e93eb216b3bd14f77336284ec52b76b3d371

# copy the Makefile from top directory to MAKE/
cp ../Makefile.kokkos_phi src/MAKE/OPTIONS

echo "*******Entering into the src directory**************"
cd src

echo "*******Clean all object images and previous builds**************"
make clean-all
make no-all

echo "*******Setup SNAP and Kokkos modules**************"
make yes-snap
make yes-kokkos

echo "*******Build LAMMPS Kokkos version**************"
make -j kokkos_phi

echo "*******Create soft link for lmp_kokkos_phi in LAMMPS_BENCHMARK**************"
ln -s lmp_kokkos_phi ../../LAMMPS_Benchmarks
