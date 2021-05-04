# Specify time as a string

The example has two rules. One submits jobs with the default time (5 min) and
the other requests 10 min. It uses the format `days-hours:minutes:seconds`.

**Important quirk:** When specifying the `default-resources` in `config.yaml`,
you typically don't need to wrap strings in quotes. But in this case you do,
presumably because `0-00:05:00` looks number-y.

```sh
# Sumbit the job
snakemake --profile simple/

# Confirm the correct time was requested
cat output/*
```
