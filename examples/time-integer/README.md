# Specify time as an integer

The example has two rules. One submits jobs with the default time (5 min) and
the other requests 10 min.

```sh
# Sumbit the job
snakemake --profile simple/

# Confirm the correct time was requested
cat output/*
```
