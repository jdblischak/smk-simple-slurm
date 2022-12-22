# Job array

If you have a rule in your Snakefile that must be executed many thousands of
times, this can become an extreme bottleneck. You can speed this step up by
submitting the rule as a [Slurm job array][slurm-job-array]. Not only will this
be faster, but it will make your sys admins happier because job arrays are much
less stressful for Slurm to process.

[slurm-job-array]: https://slurm.schedmd.com/job_array.html

To be clear, this is a hacky workaround to get things done. You'll need to
manually run all the steps prior to bottleneck rule first. You can use an
intermediate target rule for this purpose. After the job array has finished,
you can check with a downstream target rule to confirm that all of the output
files were properly created. This way you are still getting the reproducibility
benefits of Snakemake.

**Note:** This example was inspired by
[Snakemake Issue #301](https://github.com/snakemake/snakemake/issues/301)

The example processes 20,000 files in a single job array.

* `setup.sh` - creates fake input files

* `submit-job-array.sh` - determines missing or outdated output files, then
  submits job array. Also creates `snakemake-summary.txt` and `files.txt`

* `job-array.sh` - inherits the array index environment variable
  `SLURM_ARRAY_TASK_ID`, and then creates a single output file by running
  `snakemake --nolock`

```sh
# Create fake input files
bash setup.sh

# Confirm files to be created
snakemake -n --quiet
## Building DAG of jobs...
## Job stats:
## job        count    min threads    max threads
## -------  -------  -------------  -------------
## all            1              1              1
## process    20000              1              1
## total      20001              1              1

# Submit job array
bash submit-job-array.sh

# Confirm files have been created
snakemake -n --quiet
## Building DAG of jobs...
## Nothing to be done (all requested files are present and up to date).

# Not recommended, but you can compare to submitting individual jobs
rm -r output/bam
snakemake --profile simple/
```
