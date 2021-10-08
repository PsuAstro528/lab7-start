#!/bin/bash
## Submit job to our class's allocation
#PBS -A ebf11_d_g_gc_default
## Alternatively could comment out line above (by adding a second # at the beginning of the line)
# and uncomment the lines below (by removing one #) to use the "Open" allocation
##PBS -A open
## Time requested: 0 hours, 5 minutes, 0 seconds
#PBS -l walltime=00:05:00
## Ask for 4 nodes, each with one core (you may still be assigned multiple cores on the same node)
#PBS -l nodes=4:ppn=1
## Each processors will use no more than 1GB of RAM
#PBS -l pmem=1gb
## combine STDOUT and STDERR into one file
#PBS -j oe
## Specifices job name, so easy to find in qstat
#PBS -N Ast528Lab7Ex1
## Uncomment next two PBS lines (by removing one of #'s in each line) and replace with your email if you want to be notifed when jobs start and stop
##PBS -M YOUR_EMAIL_HERE@psu.edu
## Ask for emails when jobs begins, ends or aborts
##PBS -m abe

echo "Starting job $PBS_JOBNAME"
date
echo "Job id: $PBS_JOBID"
echo "Was assigned the following nodes"
cat $PBS_NODEFILE

echo "Loading modules to provide Julia 1.6.0"
#module load anaconda3
module use /gpfs/group/RISE/sw7/modules
module load julia/1.6.0
export LD_LIBRARY_PATH=/gpfs/group/RISE/sw7/julia-1.6.0/julia-1.6.0/lib

echo "About to change into $PBS_O_WORKDIR"
cd $PBS_O_WORKDIR            # Change into directory where job was submitted from

date
echo "About to start Julia specifying list of assigned nodes"
julia --project --machine-file $PBS_NODEFILE ex1_parallel.jl
echo "Julia exited"


