#!/bin/bash
#SBATCH --job-name=MPI_HT_Test
#SBATCH --partition=sixhour
#SBATCH --ntasks-per-node=1  
#SBATCH --nodes=2               
#SBATCH --constraint=ib         
#SBATCH --mem-per-cpu=128g       
#SBATCH --time=0-03:00:00        
#SBATCH --output=MPI_Test_%j.log

echo "starting"
module purge
module load compiler/intel/25
module load intel-mpi/25

cd $HOME/work
echo "compiling"
#mpif90 Hello_World.f90 -o Hello_World
#mpirun -np 64 ./Hello_World

mpiifx -O3 -zero -real-size 64 -double-size 64 -march=native Heat_Transfer_MPI.f90 -o Heat_Transfer_MPI

echo "running"
mpirun -np 2 ./Heat_Transfer_MPI
