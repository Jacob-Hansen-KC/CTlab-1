#!/bin/bash
#SBATCH --job-name=GPU_Heat
#SBATCH --partition=sixhour
#SBATCH --gres=gpu:a100:1
#SBATCH --ntasks=2      
#SBATCH --time=0-03:00:00
#SBATCH --output=GPU_Heat_%j.log
#SBATCH --constraint=nvidia    

echo "starting"
module purge
module load cuda/11.4
module load compiler/nvc/.24.7
module load nvhpc-openmpi3/24.7
export LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH
export IBV_LOG_WARNINGS=0
cd $HOME/work
echo "compiling"
#mpifort -cuda -mp -O2 Heat_Transfer_MP.f90 -o Heat_Transfer_MP
#mpirun -np 2 --map-by socket --mca coll ^hcoll --mca pml ob1 --mca btl ^openib ./Heat_Transfer_MP
nvfortran -cuda -gpu=cc70 -cuda Heat_Transfer_P.f90 -o Heat_Transfer_P
./Heat_Transfer_P
module load compiler/intel/25
ifx -O3 -zero -real-size 64 -double-size 64 -march=native Heat_Transfer.f90 -o Heat_Transfer
./Heat_Transfer
