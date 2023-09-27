# Astro 528 Lab 7

For this lab you will be submitting jobs to the Roar Collab computer cluster that is part of Penn State's [Advanced CyberInfrastructure (ACI)](https://ics.psu.edu/computing-services/system-specifications/).  The class has already been using Roar Collab in previous labs.  We've used developed code and run it interactively using the BYOE JupyterLab environment and Pluto servers provided for the class.  These are very helpful for code development, data visualization and small scale tests of your code, including a few processors.  However, the real power of having access to a computer cluster is being able to access dozens or hundreds of processor cores.

A typical science application is to run run dozens, hundreds or even thousands of similar calculations.  For that, scientists need to be able to automate their calculations via scripts.  Those scripts will also tell the computer cluster (technically the *resource manager* and the *scheduler*) the information necessary to assign you jobs to a computer that has the requested configuration and to schedule that in a fair way given all the other jobs that haven submitted.  

## Exercise 1:  Using the ICDS-ACI Roar Clusters
#### Goals:
- Submit a batch job via Slurm
- Read and write data from batch job
- Run multiple jobs using a job array

#### Step-by-step Instructions:

Follow directions below to practice submitting jobs and inspecting their results.

1.  From your web browser, look over [ex1_serial.jl](ex1_serial.jl) and [ex1_parallel.jl](ex1_parallel.jl).  The point is simply to see what this code does.

2.  For this lab, you'll mostly be using the command-line interface to submit jobs to Roar Collab.  You can get to a command line on Roar Collab by using:
   -  Clicking the terminal tile inside the JupyterLab Server Launcher that you've been using, 
   - `ssh submit.aci.ics.psu.edu` (I've found sometimes this is easier to copy/paste text across windows.), or
   -  the Interactive Desktop [screenshot](images/InteractiveDesktop.png).

Note that the number of cores you are allocated when using the JupyterLab Server or Interactive Desktop affects the number of cores for your interactive session, but does not prevent you from submitting batch jobs that use more (or fewer) cores.

3.  Clone your project repo, change into that directory and test that the code for example 1 runs successfully.  E.g.,
```sh
git clone REPO_URL
cd REPO_DIR
julia --project ex1_serial.jl
```
### Submitting & Running a Serial Job

4.  Look over the file [ex1_serial.slurm](ex1_serial.slurm) to see what resources you are about to request.  Then submit a batch job using
 ```sh
sbatch ex1_serial.slurm
 ```

5.  Check on the status of the queue using `squeue`.  That's probably more information than you wanted about other people's jobs.  You can check only your own jobs by running `squeue -u YOUR_USER_ID`.  
In each line, the first column is the job id, the second column is the partition (which part of the cluster the job is being run on), the third column is the name of job, the fourth column is the the user name of the person who submitted the job, the next column is just one or two letters indicating the job status, the next column is the duration that the job has been running, the next-to-last column is the number of nodes the job is running on, and the final column is list of nodes that the job is running on.

Check on your job's status.  Common letters in the status column are PD for pending (i.e., waiting to start), R for running, and CG for completing (cleaning up after your job has finished).
The time required for your job to start depends on how many resources you've requested, and how many resources have been consumed by other jobs that you've run (during the last ~90 days and relative to the size of your allocation).  It will likely take at a few minutes to start (but potentially up to an hour if you're using the class allocation and noone is using more than their share).  If it's taking a while to start, then you can skip ahead to step 7 (and come back to 6 later, after your job has completed).

Once your job starts, it should finish quickly.  At that point, the job status should change to 'CG' (completing) and a little while later it will be removed from the list of jobs listed by `squeue`.

6. Once you're job is done, there should be a new file in the directory that you submitted the job from with a name like `ex1_serial_5946548.log`, where the number is the numerical portion of the Slurm JOB ID.
Inspect this file to make sure the job behaved as expected.  If so, use git to add, commit and push it to your GitHub repository.  
If any of your attempts don't work, then fix the issue, try again.  Once you get it to work, delete the old output from the broken jobs and only add/commit/push the output once you've get it working.

### Submitting & Running a Parallel Job

Before we run code in parallel spanning multiple processes, we need to setup your ssh keys to allow processes to communicate with each other without you constantly entering passwords.  To do that run the following commands on Roar Collab.
```sh
touch ~/.ssh/authorized_keys; 
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys 
chmod 600 ~/.ssh/authorized_keys 
```
You shouldn't need to run those again.  

7. Now, test the parallel code (first using using just a few cores all on one compute node).  Look over the file [ex1_parallel_1node.slurm](ex1_parallel_1node.slurm) and note how it differs from [ex1_serial.slurm](ex1_serial.slurm).  Then submit a batch job using
 ```sh
 sbatch ex1_parallel_1node.slurm
 ```
Check on the job status, and once it's finished inspect the output, and make sure it did what you expected.  

Once the parallel job runs successfully, use git to add, commit and push it to your GitHub repository.
And if it's taking a while to start, then you can skip ahead to step 8 or 9 (and come back to finish this step later after your parallel job has completed).

8. Next, test the parallel code (using multiple cores, each on a different compute node).  Look over the file [ex1_parallel_multinode.slurm](ex1_parallel_multinode.slurm) and note how it differs from [ex1_serial.slurm](ex1_serial.slurm) and [ex1_parallel_1node.slurm](ex1_parallel_1node.slurm) .  Then inspect Inspect [setup_slurm_manager.jl](setup_slurm_manager.jl) to see how we're adding the worker processors assigned by slurm. Then submit a batch job using
 ```sh
 sbatch ex1_parallel_multinode.slurm
 ```

If you're interested, you can try changing the number of cores or nodes requested or other Slurm job parameters.  

### Submitting & Running a Job Array

Often a scientist will want to run several jobs that do basically the same calculations, but using slightly different inputs.  Those could be as simple as different random seeds (so that you don't accidentally do exactly the same calculation twice in two different jobs).  Or each job could analyze data stored in different input files (e.g., a bunch of spectra in separate FITS files).  While you could submit each of these as an individual job, this can be tedious and error prone, so there's a convenient way to submit a "job array".  (If you're just submitting a dozen jobs, it's not hard to write your own scripts which are equally good.  But if you're submitting hundreds of jobs, then it's actually important to use job arrays, so as to not overload the scheduler.)  Submitting a job array is easy, you just add a line '#SBATCH --array=N-M' to the slurm script, where N and M are lower and upper bounds of the job array ids.  If you're submitting a large number of jobs, then you can also specify a maximum number of jobs (P) that will be allowed to run at once using '#SBATCH --array=N-M%P'.

9.  In order for each job in the job array to do what we want (rather than the same thing each time), we'll need to add some code at the beginning of the program, so each job can figure out precisely what it should do.  In this example, we'll write the characteristics for each job to a file and then read that file in at the beginning of each job.  To create such a file, inspect and run the notebook [ex1_PrepareInputForJobArrays.jl](ex1_PrepareInputForJobArrays.jl).  You can either run it from the command line with
```sh
julia --project ex1_PrepareInputForJobArrays.jl
```
Verify that the file 'ex1_job_array_in.csv' was created and contains values you expect.

10.  Inspect the script the slurm script [ex1_job_array.slurm](ex1_job_array.slurm) and compare it to [ex1_serial.slurm](ex1_serial.slurm).  Submit the job using
```sh
sbatch ex1_job_array.slurm
```
To check the status of each individual element of the job array, you can use `squeue` but adding the '-r' option array like `squeue -r`.

11.  Check on the job status, and once they've finished inspect the output, and make sure it did what you expected.  Then use git to add, commit and push the output files to your GitHub repository.


## Exercise 2:  Parallel Programming for Distributed-Memory Model
#### Goals:
- Reinforce programming using [`Distributed Arrays`](https://juliaparallel.github.io/DistributedArrays.jl/latest/)
- Explain differences in performance when using multiple processor cores on same node versus using multiple processor cores on different nodes

#### Step-by-step Instructions:

In this exercise, we'll perform the same calculations as in [exercise 2 of lab 6](https://github.com/PsuAstro528/lab6-start/blob/master/ex2.ipynb).  However, instead of using a shared-memory model (possible on a multi-core workstation) as in Lab 6, we will run the calculations on multiple compute nodes spread across the [Roar Collab cluster](https://www.icds.psu.edu/roar-collab-user-guide/) using a distributed memory model.

You're welcome to inspect or even run the [ex2.ipynb notebook](ex2.ipynb) one cell at a time to see how it works.  However, the main point of this lab is to see how to run such a calculation in parallel over multiple processor cores that are not necessarily on the same processor.  (Then, you'll compare the performance depending on whether the processors assigned are on the same node or different nodes.)

1. Inspect [ex2_parallel_1node.slurm](ex2_parallel_1node.slurm) and [ex2_run_nb.jl](ex2_run_nb.jl).  Update the slurm script to have your email address.  Then submit the slurm script [ex2_parallel_1node.slurm](ex2_parallel_1node.slurm) using `sbatch`.  The email notifications are particularly useful for this exercise, as they'll tell you how long your job waited in the queue as well as how long they took to run.  Once the job completes, inspect the output files to make sure it performed as expected.  

ex2_parallel_1node.slurm  ex2_parallel_combo.slurm  ex2_parallel_multinode.slurm

2.  Inspect [ex2_parallel_multinode.slurm](ex2_parallel_multinode.slurm) and compare it to [ex2_parallel_1node.slurm](ex2_parallel_1node.slurm).  Submit this job via `sbatch`. Once the job completes, inspect the output log file to make sure it performed as expected.

3.  Modify [ex2_parallel_1node.slurm](ex2_parallel_1node.slurm) and [ex2_parallel_multinode.slurm](ex2_parallel_multinode.slurm) so that each of them uses 8 CPU cores.  Change the lines with SBATCH options '--nodes', '--ntasks-per-node' and '--ntasks' as needed, so that the jobs run on one node for the first script and spread across 8 different nodes for the second script.  Submit both as job via `sbatch`.  Once the new jobs complete, inspect the output log files to make sure that they ran succesfully.  

4.  Compare and contrast the performance time required for various steps and add your responces to this README below.  

4a. How did the time required to perform the 'map(...)' calculations compare between when the assigned processors were on the same node versus on different nodes?  (Remember to ignore the first call in each set of calls due to compilation.)

INSERT RESPONSE

4b. How did the time required to perform the 'collect(map(...))' calculations compare between when the assigned processors were on the same node versus on different nodes?

INSERT RESPONSE

4c. How did the time required to perform the 'mapreduce(...)' calculations compare between when the assigned processors were on the same node versus on different nodes?

INSERT RESPONSE

4d. What explains differences in the relative timing of the three calculations discussed above?

INSERT RESPONSE

4e. At the end of the notebook, it gradually removed worker processes and benchmarked the function to compute the mean squared error.  Did the scaling of run time versus number of workers avaliable change depending on whether the processes were assigned to the same node or different nodes?

INSERT RESPONSE

4f. How did the time that your jobs waited in the queue before starting compare depending on whether you asked for all the processors to be on compute node?

INSERT RESPONSE


5.  If you'll want to use more than ~16 CPU cores for your project, then inspect the script [ex2_parallel_combo.slurm](ex2_parallel_combo.slurm) and compare it to [ex2_parallel_multinode.slurm](ex2_parallel_multinode.slurm).  Submit this job via `sbatch`. Once the job completes, inspect the output log file to make sure it performed as expected.

5a.  What is this slurm script doing differently?  Why would that be important for using many CPU cores?


## Exercise 3:  Run your project code using the Cluster
#### Goals:
- Apply lessons learned in exercises 1 & 2 for your own class project

#### Step-by-step Instructions:

1.  Create a slurm script that successfully runs an example case using your project's serial code.  (If you don't have a working example yet, then you can have the script run your project's tests.)

2.  Create a new slurm script that runs and benchmarks your project's serial code for different problem sizes.  Depending on the details of your project, you might have one '.jl' or '.ipynb' file that performs all the benchmarks in sequence (like at the end of ex2), or you might have a separate slurm script for each problem size that you benchmark.

3.  (I expect that some students will only get to this and subsequent steps after the due date for Lab 7.  But I include them here for any who are ready to start benchmarking their parallel code now.)  Once you have a parallel version of your project code working in an interactive environment, then make a Slurm script that runs the parallel version of your code.  Run the script, make sure that it gives the expected results and that it's actually using the processors its been assigned (as opposed to running in serial).

4.  Benchmark the performance of your code as a function of the number of processors used, keeping the problem size fixed.  Make a plot showing the *strong scaling* of the performance critical section your code (i.e., run time as a function of problem size) as the number of processors varies from 1, 2, 4, 8, 12, 16, 20, 24.  How does the performance benefit compare to a linear scaling?  If your code is scaling well even at >16 processors (i.e., the run time continues to decrease nearly linearly with number of processors), then keep increasing the number of processors until the run time levels off (or you reach 100 cores).

5.  Repeat the benchmarks from step 4, but using at least a few problem sizes (spanning at least two orders of magnitude if possible, i.e., big enough so that you can see the benefits of parallelism).

6. Benchmark the performance of your code as a function of the number of processors used, but now growing the problem size in proportion to the number of processors.  Make a plot showing the *weak scaling* of the performance critical section your code (i.e., run time as a function of problem size) changing the problem size by at least a factor of 16.  How does the run time scale with the problem size (and number of processors)?

7.  Repeat step 6, but now compare the performance when using multiple processor cores on a single node versus the same number of processor cores spread across multiple nodes.  

8.  Save the scripts you use for this exercise.  You might even want to clean them up and document them.  Near the end of the semester, you'll repeat this process for both of the parallel versions of your code.  (Hopefully, the results may improve as you optimize your parallel code between now and then.)  Then, you'll show the resulting figures in your presentation and final report to help illustrated what you learned about how well your code parallelizes.
