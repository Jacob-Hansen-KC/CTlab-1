#!/bin/bash
#SBATCH --job-name=PyFR_CUDA
#SBATCH --partition=sixhour
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=64g
#SBATCH --time=0-03:00:00
#SBATCH --output=Couette_%j.log
#SBATCH --constraint=nvidia

echo "starting"
module purge
module load cuda/12.8
module load compiler/gcc/14.2
module load openmpi/5.0
module load conda/latest
conda activate pyfr

cd $HOME/work/PyFR-Test-Cases/2d-couette-flow

export LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH

#pyfr import couette-flow.msh couette-flow.pyfrm

#LD_PRELOAD=/home/j221h043/local/scotch-v7.0.8/build/lib/libscotcherr.so:/home/j221h043/local/scotch-v7.0.8/build/lib/libscotch.so pyfr partition -e quad:3 -e tri:2 -p scotch 2 couette-flow.pyfrm .

#python3 -c "import h5py; f = h5py.File('couette-flow.pyfrm', 'r'); print(list(f.keys()))"

echo "Running PyFR with OpenMP + MPI..."

pyfr -p run -b cuda couette-flow.pyfrm couette-flow.ini

#pyfr export couette-flow.pyfrm couette-flow-040.pyfrs couette-flow-040.vtu
