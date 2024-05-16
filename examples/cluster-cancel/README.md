# Cancel running jobs with `--cluster-generic-cancel-cmd`

The smk-simple-slurm profile uses `--cluster-generic-submit-cmd` and not `--drmaa`. By default,
this means that if you cancel the main Snakemake process, any already submitted
jobs remain in the queue. To automatically cancel all running jobs when you
cancel the main Snakemake process (ie the default behavior of `--drmaa`), you
can specify `cluster-generic-cancel-cmd: scancel`. This will result in the job IDs of the
running jobs to be passed to `scancel`.

**Note:** This [feature][cluster-cancel] was added in Snakemake 7.0.0

[cluster-cancel]: https://snakemake.readthedocs.io/en/stable/tutorial/additional_features.html#using-cluster-cancel

**Note:** Similar to `--cluster-generic-status-cmd`, you must include the flag `--parsable`
to the `sbatch` command passed to `--cluster-generic-cancel-cmd` in order to pass the job ID to
`scancel`.

**Note:** The flag `--cluster-generic-cancel-nargs` control how many job IDs are passed
to each invocation of `scancel`. The default is 1000. I changed it to 50 in this
example simply to confirm that `scancel` can be called more than once (since
this example `Snakefile` submits 100 jobs). I recommend using the default unless
you have a specific reason to increase or decrease it.

**Note:** Only press Ctrl-C once. If you press it too quickly a second time,
Snakemake will be killed before it can finish canceling all the jobs with
`scancel`.

```sh
# Sumbit the jobs
snakemake --profile simple/

# Once the jobs have been submitted, kill snakemake with ctrl+c

# Confirm the error message was CANCELLED
grep -l CANCELLED logs/sleeper/sleeper-iteration\=* | wc -l
```
