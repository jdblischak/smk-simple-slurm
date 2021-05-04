# Jobs per second

By avoiding extra Python scripts to handle job submissions and status checks,
the simple profile can submit many jobs per second to Slurm. This is critical if
you have an embarrassingly parallel step that you need to run thousands of
times.

The example submits 1000 jobs as quickly as possible, records the time that
Snakemake submitted them to Slurm, then analyzes the results.

```sh
# Sumbit the jobs
time snakemake --profile simple/

# View the jobs-per-second results
cat output/jobs-per-second.txt
```
