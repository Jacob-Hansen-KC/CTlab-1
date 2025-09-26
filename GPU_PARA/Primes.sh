#!/bin/bash
#SBATCH --job-name=Primes
#SBATCH --partition=sixhour
#SBATCH --gres=gpu:a100:1
#SBATCH --time=0-03:00:00
#SBATCH --output=GPU_Parra_%j.log
#SBATCH --constraint=nvidia

echo "starting"
module purge
module load cuda/12.8

cd $HOME/work

export LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH

echo "Compiling"
nvfortran -acc -O3 -gpu=cc80 -Minfo=accel primes_Parra.f90 -o Primes
echo "Running"
./Primes