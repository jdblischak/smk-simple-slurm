# Dynamic resources

A powerful technique for dynamically allocating resources is to increase the
memory requirement after each failed attempt. This allows you to specify a
minimum memory that is sufficient for most of the jobs but also accomodate the
occasional large job.

The example rule quickly fails, and each time Snakemake re-submits it with
increased memory.

```sh
# Sumbit the job
snakemake --profile simple/

# Confirm the correct memory was requested
scontrol show job <jobid> | grep mem
```
