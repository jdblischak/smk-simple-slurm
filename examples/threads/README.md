# Specify threads per rule

The example has two rules. One submits jobs with the default threads (1) and the
other requests 8 threads. There is no need to use `default-resources` for the
threads because `threads` is a special field managed by Snakemake.

```sh
# Sumbit the job
snakemake --profile simple/

# Confirm the correct time was requested
cat output/*

# Run the job locally. Threads should be scaled down.
rm output/*
snakemake --jobs 2
```
