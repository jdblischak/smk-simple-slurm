# Simple Slurm

A simple Snakemake profile for Slurm without `--cluster-config`

## Background and motivation

**tl;dr** Use the `--default-resources` option

* The Snakemake option `--cluster-config` allows you to set default and
  rule-specific resources when submitting jobs to a remote scheduler (e.g.
  slurm, sge, etc)
* The `--cluster-config` option has been replaced by `--profile`
    > This option is deprecated in favor of using `--profile`, see docs.
* It is difficult to replicate the features of `--cluster-config` with the
  current [official slurm profile](https://github.com/Snakemake-Profiles/slurm),
  e.g. [Issue 29](https://github.com/Snakemake-Profiles/slurm/issues/29)
* Multiple of the official profiles continue to use `--cluster-config`
* From the [documentation on cluster
  execution](https://snakemake.readthedocs.io/en/stable/executing/cluster.html#cluster-execution),
  it is possible to reproduce the behavior of `--cluster-config` using a
  combination of the option `--default-resources` and the field `resources` in
  specific rules

In general, the official profiles are attemtping to be very comprehensive and
cover many different use cases and HPC setups. The disadvantage of this is that
they are more complex to customize. The official slurm profile consists of 3
Python scripts, a shell script, and a config file.

In contrast, this simple profile is a single configuration file that you can
quickly download and edit. This approach also has its downsides, which are
described more below.

## How to use this profile

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

## Comparison to official slurm profile

### Advantages

* Easier to reason about and customize: fewer files and fewer moving parts
* Faster: submits more jobs per second
* No need to rely on `--cluster-config` to customize job resources

### The same

* It submits jobs to slurm and monitors their status
* It understands the job statuses PENDING, RUNNING, COMPLETING, and can even
  detect when a job fails from an out of memory error

### Disadvantages

* Can't use [group
  jobs](https://snakemake.readthedocs.io/en/stable/executing/grouping.html), but
  they [aren't easy to use in the first
  place](https://github.com/snakemake/snakemake/issues/872)
* It can't detect when a job was manually canceled with `scancel` or was
  canceled due to a timeout. See below for how to use a simple script to improve
  this.

## Using a cluster status script

By default, snakemake can monitor jobs sumbitted to slurm. I realized this when
reading this detailed [blog
post](http://bluegenes.github.io/Using-Snakemake_Profiles/), in which the author
decided not to use the provided `cluster-status.py` script. Thus if you don't
find that your jobs are silently failing often, then there's no need to worry
about this extra configuration step.

However, if you start to have jobs silently fail often, e.g. with status
`TIMEOUT` for exceeding their time limit, then you can add a custom script to
monitor the job status with the option
[`--cluster-status`](https://snakemake.readthedocs.io/en/stable/tutorial/additional_features.html#using-cluster-status).

The directory `extras/` contains multiple options for checking the status of the
jobs. You can choose which one you'd like to use:

* `status-sacct.py` - This is the example from the Snakemake documentation
* `status-sacct.sh` - This is a Bash translation of the example from the
  Snakemake documentation. The Python script is simply shelling out to `sacct`,
  so running Bash directly removes the overhead of repeatedly starting Python
  each time you check a job.
* `status-scontrol.sh` - This is a Bash translation of
  [`slurm-status.py`](https://github.com/Snakemake-Profiles/slurm/blob/master/%7B%7Bcookiecutter.profile_name%7D%7D/slurm-status.py#L35)
  from the official profile. If your HPC cluster doesn't have `sacct`
  configured, you can use this option.

To use one of these status scripts, add it to `config.yaml`, e.g.
`cluster-status: ../extras/status-sacct.sh`. Also, you will need to add the flag
`--parsable` to your `sbatch` command.
