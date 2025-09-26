#!/bin/bash
#SBATCH --job-name=PyFR_CUDA
#SBATCH --partition=sixhour
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=64g
#SBATCH --time=0-03:00:00
#SBATCH --output=Trifoil_%j.log
#SBATCH --constraint=nvidia

echo "starting"
module purge
module load cuda/12.8
module load compiler/gcc/14.2
module load openmpi/5.0
module load conda/latest
conda activate jhansen

cd $HOME/work/PyFR-Test-Cases/3d-triangular-aerofoil

export LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH

#pyfr import triangular-aerofoil.msh triangular-aerofoil.pyfrm

#LD_PRELOAD=/home/j221h043/local/scotch-v7.0.8/build/lib/libscotcherr.so:/home/j221h043/local/scotch-v7.0.8/build/lib/libscotch.so pyfr partition -p scotch 4 triangular-aerofoil.pyfrm .

#python3 -c "import h5py; f = h5py.File('triangular-aerofoil.pyfrm', 'r'); print(list(f.keys()))"

echo "Running PyFR with OpenMP + MPI..."

#mpiexec -n 4 --bind-to core --map-by socket --mca coll ^hcoll --mca pml ob1 pyfr run -b cuda triangular-aerofoil.pyfrm triangular-aerofoil.ini
pyfr run -b cuda triangular-aerofoil.pyfrm triangular-aerofoil.ini
#pyfr export triangular-aerofoil.pyfrm triangular-aerofoil-5.00.pyfrs triangular-aerofoil-5.00.vtu
