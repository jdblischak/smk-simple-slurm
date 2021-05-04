# Simple Slurm

> A simple Snakemake profile for Slurm without `--cluster-config`

* [Features](#features)
* [Limitations](#limitations)
* [Quick start](#quick-start)
* [Customizations](#customizations)

The option [`--cluster-config`][cluster-config] is deprecated, but it's still
possible to set default and rule-specific resources for [submitting jobs to a
remote scheduler][cluster-execution] using a combination of
`--default-resources` and the `resources` field in individual rules. This
profile is a simplified alternative to the more comprehensive [official Slurm
profile for Snakemake][slurm-official].

## Features

* Only requires a single configuration file to get started submitting jobs to
  Slurm

* Easily add or remove options to pass to `sbatch`

* Automatically saves the log files as `logs/{rule}/{rule}-{wildcards}-%j.out`,
  where `{rule}` is the name of the rule, `{wildcards}` is any wildcards passed
  to the rule, and `%j` is the job number

* Automatically names jobs using the pattern `smk-{rule}-{wildcards}`

* Fast! It can quickly submit jobs and check their status because it doesn't
  invoke a Python script for these steps, which adds up when you have thousands
  of jobs

* No reliance on the deprecated option `--cluster-config` to customize job
  resources

* By default it understands the job statuses PENDING, RUNNING, COMPLETING, and
  can even detect when a job fails from an out of memory error

* (Optional) You can pass a simple script (see [`extras/`](extras/)) to
  [`--cluster-status`][cluster-status] to handle the job statuses TIMEOUT and CANCELED

## Limitations

* Can't use [group jobs][grouping], but they [aren't easy to use in the first
  place][grouping-issue]

## Quick start

1. Download the configuration file `config.yaml` to your Snakemake project. It
   has to be in a subdirectory, e.g. `simple`.

1. Open it in your favorite text editor and replace all the placeholders
   surrounded in angle brackets (`<>`) with the options you use to submit jobs
   on your cluster

1. You can override any of the defaults by adding a `resources` field to a rule,
   e.g.

    ```python
    rule much_memory:
        resources:
            mem_mb=64000
    ```

1. Invoke snakemake with the profile:

    ```sh
    snakemake --profile simple/
    ```

## Customizations

See the directory [`examples/`](examples/) for examples you can experiment with
on your cluster.

### A fixed argument to `sbatch`, e.g. `--account`

To pass an additional argument to `sbatch` that will be fixed across all job
submissions, add it directly to the arguments passed to `sbatch` in the field
`cluster`. For example, to specify an account to use for all job submissions,
you can add the `--account` argument as shown below:

```yaml
cluster:
  mkdir -p logs/{rule} &&
  sbatch
    --partition={resources.partition}
    --qos={resources.qos}
    --cpus-per-task={threads}
    --mem={resources.mem_mb}
    --job-name=smk-{rule}-{wildcards}
    --output=logs/{rule}/{rule}-{wildcards}-%j.out
    --account=myaccount
```

### A variable argument to `sbatch`, e.g. `--time`

To pass an additional argument to `sbatch` that can vary across job submissions,
add it to the arguments passed to `sbatch` in the field `cluster`, list a
default value in the field `default-resources`, and update any rules that
require a value different from the default.

For example, the `config.yaml` below sets a default time of 1 hour, and the
example rule overrides this default for a total of 3 hours. Note that the quotes
around the default time specification are required, even though you don't need
quotes when specifying the default for either `partition` or `qos`.

```yaml
cluster:
  mkdir -p logs/{rule} &&
  sbatch
    --partition={resources.partition}
    --qos={resources.qos}
    --cpus-per-task={threads}
    --mem={resources.mem_mb}
    --job-name=smk-{rule}-{wildcards}
    --output=logs/{rule}/{rule}-{wildcards}-%j.out
    --time={resources.time}
default-resources:
  - partition=<name-of-default-partition>
  - qos=<name-of-quality-of-service>
  - mem_mb=1000
  - time="01:00:00"
```

```python
# A rule in Snakefile
rule more_time:
    resources:
        time = "03:00:00"
```

Note that `sbatch` accepts time defined using various formats. Above I used
`hours:minutes:seconds`, but the simple slurm profile is agnostic to how you
choose to configure this. It's a good idea to be consistent across rules, but
it's not required. From Slurm 19.05.7:

> A time limit of zero requests that no time limit be imposed. Acceptable time
> formats include "minutes", "minutes:seconds", "hours:minutes:seconds",
> "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds".

Thus to instead use `minutes`, you could acheive the same effect as above with:

```yaml
cluster:
  mkdir -p logs/{rule} &&
  sbatch
    --partition={resources.partition}
    --qos={resources.qos}
    --cpus-per-task={threads}
    --mem={resources.mem_mb}
    --job-name=smk-{rule}-{wildcards}
    --output=logs/{rule}/{rule}-{wildcards}-%j.out
    --time={resources.time}
default-resources:
  - partition=<name-of-default-partition>
  - qos=<name-of-quality-of-service>
  - mem_mb=1000
  - time=60
```

```python
# A rule in Snakefile
rule more_time:
    resources:
        time = 180
```

See [`examples/time-integer/`](examples/time-integer/) and
[`examples/time-string/`](examples/time-string/) for examples you can play with.

### Using a cluster status script

By default, snakemake can monitor jobs sumbitted to slurm. I realized this when
reading this detailed [blog post][no-cluster-status], in which the author
decided not to use the `cluster-status.py` script provided by the [official
Slurm profile][slurm-official]. Thus if you don't find that your jobs are
silently failing often, then there's no need to worry about this extra
configuration step.

However, if you start to have jobs silently fail often, e.g. with status
`TIMEOUT` for exceeding their time limit, then you can add a custom script to
monitor the job status with the option [`--cluster-status`][cluster-status].

The directory [`extras/`](extras/) contains multiple options for checking the
status of the jobs. You can choose which one you'd like to use:

* `status-sacct.py` - This is the example from the Snakemake documentation

* `status-sacct.sh` - (recommended) This is a Bash translation of the example
  from the Snakemake documentation. The Python script is simply shell-ing out to
  `sacct`, so running Bash directly removes the overhead of repeatedly starting
  Python each time you check a job

* `status-scontrol.sh` - This is a Bash translation of
  [`slurm-status.py`](https://github.com/Snakemake-Profiles/slurm/blob/master/%7B%7Bcookiecutter.profile_name%7D%7D/slurm-status.py#L35)
  from the [official profile][slurm-official]. If your HPC cluster doesn't have
  `sacct` configured, you can use this option

To use one of these status scripts:

1. Download the script to your profile directory where `config.yaml` is located

1. Add the field `cluster-status` to your `config.yaml`, e.g. `cluster-status:
   status-sacct.sh`

1. Add the flag `--parsable` to your `sbatch` command (requires Slurm version
   14.03.0rc1 or later)

[cluster-config]: https://snakemake.readthedocs.io/en/stable/snakefiles/configuration.html#cluster-configuration-deprecated
[cluster-execution]: https://snakemake.readthedocs.io/en/stable/executing/cluster.html
[cluster-status]: https://snakemake.readthedocs.io/en/stable/tutorial/additional_features.html#using-cluster-status
[grouping]: https://snakemake.readthedocs.io/en/stable/executing/grouping.html
[grouping-issue]: https://github.com/snakemake/snakemake/issues/872
[no-cluster-status]: http://bluegenes.github.io/Using-Snakemake_Profiles/
[slurm-official]: https://github.com/Snakemake-Profiles/slurm
