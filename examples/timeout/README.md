# Handle timeout error with `--cluster-generic-status-cmd`

Snakemake can **not** handle timeout errors from Slurm by default (`TIMEOUT`).
You need to pass a custom script to `--cluster-generic-status-cmd` to process timeout
errors. You have multiple options for this custom script in `extras/`.

The example has has one rule that requests 10 seconds of runtime and sleeps for
30 seconds. By default Snakemake will fail to see the failed job and stall
indefinitely waiting for the job to complete.

**Note:** At least on the current HPC cluster I have access to, `--qos`
overrides the value I set for `--time`. If this job doesn't fail for you, you'll
need to set `qos` to the option with the shortest runtime and increase the
`sleep` time. Alternatively you can kill the job yourself with `scancel`, which
simulates the same effect (i.e. only works with `--cluster-generic-status-cmd`).

**Note:** I already added the flag `--parsable` to the call to `sbatch` in
`config.v8+.yaml`. This is required to pass only the job ID to the cluster status
scripts.

```sh
# Sumbit the job
snakemake --profile simple/

# Once the job fails, kill snakemake with ctrl+c

# Confirm the the error message
grep error logs/timeout/timeout--*.out

# Submit the job with --cluster-generic-status-cmd
snakemake --profile simple/ --cluster-generic-status-cmd ../../extras/status-sacct.sh
# If sacct isn't configured on your cluster, use the scontrol version
snakemake --profile simple/ --cluster-generic-status-cmd ../../extras/status-scontrol.sh
```
