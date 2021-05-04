# Handle out of memory error

Snakemake can handle out of memory errors from Slurm by default without any
assistance from a custom script passed to `--cluster-status`.

The example has has one rule that requests only 100 MB of memory and then
attempts to sort a large sequence of random integers. It fails with an out of
memory error from Slurm. Snakemake should properly detect the error and
shutdown.

```sh
# Sumbit the job
snakemake --profile simple/

# Confirm the the error message
grep error logs/out_of_memory/out_of_memory--*.out
```
