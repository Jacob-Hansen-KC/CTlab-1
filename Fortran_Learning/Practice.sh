#!/bin/bash
#SBATCH --job-name=Primes
#SBATCH --partition=sixhour
#SBATCH --time=0-03:00:00
#SBATCH --output=Fortran_%j.log

echo "starting"
module purge
module load compiler/gcc/14.2

cd $HOME/work


echo "Compiling"
gfortran -c Eular_Int.f90    # Compile module
gfortran -c Test.f90         # Compile program that uses the module
gfortran -o test_program Eular_Int.o Test.o
echo "Running"
./test_program
