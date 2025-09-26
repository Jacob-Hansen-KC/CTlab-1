#!/bin/bash
#SBATCH --job-name=MPI_Juggling
#SBATCH --partition=sixhour
#SBATCH --ntasks-per-node=1
#SBATCH --nodes=2        
#SBATCH --constraint=ib         
#SBATCH --mem-per-cpu=100g       
#SBATCH --time=0-03:00:00        
#SBATCH --output=MPI_Test_%j.log

echo "starting"
module purge
module load compiler/intel/25
module load intel-mpi/25

cd $HOME/work
echo "compiling"

mpiifx -O3 -zero -real-size 64 -double-size 64 -march=native Juggling.f90 -o Juggling

echo "running"
mpirun -np 2 ./Juggling
