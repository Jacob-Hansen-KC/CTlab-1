#!/bin/bash
#SBATCH --job-name=GPU_Parra
#SBATCH --partition=sixhour
#SBATCH --gres=gpu:a100:1
#SBATCH --time=0-03:00:00
#SBATCH --output=GPU_Parra_%j.log
#SBATCH --constraint=nvidia

echo "starting"
module purge
module load cuda/12.8

cd $HOME/work/Fortran

export LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH
echo "Compiling"
nvfortran -acc -O3 -gpu=cc80 -Minfo=accel RealHelloWorld.f90 -o HelloWorld1k
echo "Running"
./HelloWorld1k
