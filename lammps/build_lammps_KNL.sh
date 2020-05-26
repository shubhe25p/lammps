#!/bin/bash
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
