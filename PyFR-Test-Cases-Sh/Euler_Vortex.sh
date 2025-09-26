#!/bin/bash
#SBATCH --job-name=PyFR_OpenMP_MPI
#SBATCH --partition=sixhour
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=251g
#SBATCH --constraint=ib          # Only nodes with Infiniband (ib)
#SBATCH --time=0-03:00:00
#SBATCH --output=Euler_Vortex_%j.log
#SBATCH --constraint=avx512

module load conda/latest
conda activate jhansen
module load compiler/gcc/14.2
module load openmpi/5.0

export PATH=$HOME/local/bin:$PATH
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export PYFR_XSMM_PATH=$HOME/libxsmm/lib/libxsmm.so
export LD_LIBRARY_PATH=$HOME/libxsmm/lib:$CONDA_PREFIX/lib:$HOME/local/lib:$LD_LIBRARY_PATH
export PYFR_OMP_CC=icx
unset UCX_NET_DEVICES
unset HCOLL_MAIN_IB

cd $HOME/work/PyFR-Test-Cases/2d-euler-vortex
#pyfr import euler-vortex.msh euler-vortex.pyfrm #import msh

#LD_PRELOAD=/home/j221h043/local/scotch-v7.0.8/build/lib/libscotcherr.so:/home/j221h043/local/scotch-v7.0.8/build/lib/libscotch.so pyfr partition -p scotch 2 euler-vortex.pyfrm .

#python3 -c "import h5py; f = h5py.File('euler-vortex.pyfrm', 'r'); print(list(f.keys()))" #check Partition

#pyfr import euler-vortex.msh euler-vortex.pyfrm

echo "Running PyFR with OpenMP + MPI..."
mpiexec -n 2 --bind-to core --map-by socket --mca coll ^hcoll --mca pml ob1 pyfr run --backend openmp euler-vortex.pyfrm euler-vortex.ini

#pyfr export euler-vortex.pyfrm euler-vortex-100.0.pyfrs euler-vortex-100.0.vtu

#sbatch Euler_Vortex.sh
