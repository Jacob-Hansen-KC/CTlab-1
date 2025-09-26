#!/bin/bash
#SBATCH --job-name=PyFR_CUDA
#SBATCH --partition=sixhour
#SBATCH --gres=gpu:1
#SBATCH --nodes=4
#SBATCH --cpus-per-task=12
#SBATCH --mem=64g
#SBATCH --time=0-03:00:00
#SBATCH --output=TayG_%j.log
#SBATCH --constraint=nvidia

echo "starting"
module purge
module load cuda/12.8
module load compiler/gcc/14.2
module load openmpi/5.0
module load conda/latest
conda activate jhansen

cd /home/j221h043/work/PyFR-Test-Cases/3d-taylor-green

export LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH

#unxz taylor-green.msh.xz

#pyfr import taylor-green.msh taylor-green.pyfrm

#LD_PRELOAD=/home/j221h043/local/scotch-v7.0.8/build/lib/libscotcherr.so:/home/j221h043/local/scotch-v7.0.8/build/lib/libscotch.so pyfr partition -p scotch 4 taylor-green.pyfrm .

#python3 -c "import h5py; f = h5py.File('taylor-green.pyfrm', 'r'); print(list(f.keys()))"

echo "Running PyFR with CUDA"
mpiexec -n 4 --bind-to core --map-by socket --mca coll ^hcoll --mca pml ob1 pyfr -p run -b cuda taylor-green.pyfrm taylor-green.ini

#pyfr export taylor-green.pyfrm taylor-green-20.00.pyfrs taylor-green-20.00.vtu
