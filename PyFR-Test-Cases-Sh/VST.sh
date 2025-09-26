#!/bin/bash
#SBATCH --job-name=PyFR_CUDA_Partition
#SBATCH --partition=sixhour
#SBATCH --gres=gpu:1
#SBATCH --nodes=2
#SBATCH --mem=64g
#SBATCH --time=0-03:00:00
#SBATCH --output=VST_%j.log
#SBATCH --constraint=nvidia

echo "starting"
module purge
module load cuda/11.4
module load compiler/gcc/14.2
module load openmpi/5.0
module load conda/latest
conda activate jhansen

cd $HOME/work/PyFR-Test-Cases/2d-viscous-shock-tube
export LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH


#pyfr import viscous-shock-tube.msh viscous-shock-tube.pyfrm

#LD_PRELOAD=/home/j221h043/local/scotch-v7.0.8/build/lib/libscotcherr.so:/home/j221h043/local/scotch-v7.0.8/build/lib/libscotch.so pyfr partition -p scotch 2 viscous-shock-tube.pyfrm .

#python3 -c "import h5py; f = h5py.File('viscous-shock-tube.pyfrm', 'r'); print(list(f.keys()))"

echo "Running PyFR with CUDA"
mpiexec -n 2 --bind-to core --map-by socket --mca coll ^hcoll --mca pml ob1 pyfr -p run -b cuda viscous-shock-tube.pyfrm viscous-shock-tube.ini

#pyfr export viscous-shock-tube.pyfrm viscous-shock-tube-1.00.pyfrs viscous-shock-tube-1.00.vtu
