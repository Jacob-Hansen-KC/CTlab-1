#!/bin/bash
#SBATCH --job-name=PyFR_CUDA
#SBATCH --partition=sixhour
#SBATCH --gres=gpu:1
#SBATCH --nodes=4
#SBATCH --cpus-per-task=12
#SBATCH --mem=64g
#SBATCH --time=0-03:00:00
#SBATCH --output=Double_Mach_CUDA_%j.log
#SBATCH --constraint=nvidia

echo "starting"
module purge
module load cuda/12.8
module load compiler/gcc/14.2
module load openmpi/5.0
module load conda/latest
conda activate pyfr

cd $HOME/work/PyFR-Test-Cases/2d-double-mach-reflection

export LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH

#pyfr import double-mach-reflection.msh double-mach-reflection.pyfrm

#LD_PRELOAD=/home/j221h043/local/scotch-v7.0.8/build/lib/libscotcherr.so:/home/j221h043/local/scotch-v7.0.8/build/lib/libscotch.so pyfr partition -p scotch 4 double-mach-reflection.pyfrm .

#python3 -c "import h5py; f = h5py.File('double-mach-reflection.pyfrm', 'r'); print(list(f.keys()))"

echo "Running PyFR with CUDA"
mpiexec -n 4 --bind-to core --map-by socket --mca coll ^hcoll --mca pml ob1 pyfr -p run -b cuda double-mach-reflection.pyfrm double-mach-reflection.ini

#pyfr export double-mach-reflection.pyfrm double-mach-reflection-0.20.pyfrs double-mach-reflection-0.20.vtu
