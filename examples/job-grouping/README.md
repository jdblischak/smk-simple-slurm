# Job grouping

Snakemake has the feature to [group jobs][grouping]. This is convenient when you
have rule with a short execution time that has to be run many times. In this
situation, the rule would spend more time in the Slurm queue compared to
actually executing.

[grouping]: https://snakemake.readthedocs.io/en/stable/executing/grouping.html

However, when Snakemake groups multiple instances of a rule into a group to be
submitted to Slurm, many of the job attributes like the name of the rule and its
wildcards are no longer clearly defined. This means you can't use these
attributes when passing arguments to `sbatch`, e.g.
`--job-name=smk-{rule}-{wildcards}` and
`--output=logs/{rule}/{rule}-{wildcards}-%j.out`. This will make it more
difficult to interpret the names of the queued jobs and the output files.

Also note that Snakemake will sum resources like `mem_mb` and `threads`. This is
why this example doesn't include `--cpus-per-task={threads}`, since that causes
Snakemake to request a node with 100 threads.

```sh
# Sumbit the 10 exampleGroup jobs that each run 100 instances of exampleRule
snakemake --profile simple/ --groups exampleRule=exampleGroup --group-components exampleGroup=100

# Confirm 1000 output files were created
ls output/ | wc -l

# Confirm only 10 jobs were submitted to Slurm
ls logs/ | wc -l
```

**Note:** This example was inspired by the discussion in
[Issue #10](https://github.com/jdblischak/smk-simple-slurm/issues/10)
