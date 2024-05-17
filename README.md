# Simple Slurm

> A simple Snakemake profile for Slurm without `--cluster-generic-*-cmd`

- [Simple Slurm](#simple-slurm)
  - [Features](#features)
  - [Limitations](#limitations)
  - [Quick start](#quick-start)
  - [Customizations](#customizations)
    - [A fixed argument to `sbatch`, e.g. `--account`](#a-fixed-argument-to-sbatch-eg---account)
    - [A variable argument to `sbatch`, e.g. `--time`](#a-variable-argument-to-sbatch-eg---time)
    - [Using a cluster status script](#using-a-cluster-status-script)
    - [Multiple clusters](#multiple-clusters)
  - [Use speed with caution](#use-speed-with-caution)
  - [License](#license)

The option [`--cluster-config`][cluster-config] is removed in `snakemake>8.0.0`, but it's still
possible to set default and rule-specific resources for [submitting jobs to a
remote scheduler][cluster-execution] using a combination of
`--default-resources` and the `resources` field in individual rules. This
profile is a simplified alternative to the more comprehensive [official Slurm
profile for Snakemake][slurm-official]. For more background, this [blog
post][sichong-post] by Sichong Peng nicely explains this strategy for replacing
`--cluster-config`.

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
  of jobs (however, please see the section [Use speed with
  caution](#use-speed-with-caution))

* No reliance on the now-removed option `--cluster-config` or hard-to-read command-line flags (`--cluster-generic-*-cmd`)
  to customize job resources

* By default it relies on Snakemake's built-in ability to understand the job
  statuses PENDING, RUNNING, COMPLETING, and OUT_OF_MEMORY

* (Optional, but recommended) You can pass a simple script (see
  [`extras/`](extras/)) to [`--cluster-generic-status-cmd`][cluster-status] to additionally
  handle the job statuses TIMEOUT and CANCELED

* **New** Support for [cluster-cancel][] feature introduced in Snakemake 7.0.0
  (see [`examples/cluster-cancel/`](examples/cluster-cancel/))

* **New** Full support for [multi-cluster setups][multi_cluster] (using a custom
  status script requires Snakemake 7.1.1+). See the section [Multiple
  clusters](#multiple-clusters) below

* **New** Adaptable for use with [AWS ParallelCluster][aws-parallelcluster]. See
  [Christian Brueffer's][cbrueffer] profile
  [snakemake-aws-parallelcluster-slurm][]

## Limitations

* If you use [job grouping][grouping], then you can't dynamically name the jobs
  and log files based on the name of the rules. This doesn't prevent you from
  using this profile and benefiting from its other features, but it is less
  convenient. Also note that [job grouping isn't easy to use in the first
  place][grouping-issue], since it sums resources like `mem_mb` and `threads`,
  but that is a limitation of Snakemake itself, and not anything in particular
  with this profile **UPDATE:** As of Snakemake 7.11, there is improved support
  for [managing the maximum resources requested when submitting a grouped
  job][resources-and-group-jobs] that executes multiple rules. It's still
  non-trivial, but now at least possible. See the example in
  [`examples/job-grouping/`](examples/job-grouping/) for a demonstration of how
  to use the new features

* Wildcards can't contain `/` if you want to use them in the name of the Slurm
  log file. This is a Slurm requirement (which makes sense, since it has to
  create a file on the filesystem). You'll either have to change how you manage
  the wildcards or remove the `{wildcards}` from the pattern passed to `--output`,
  e.g. `--output=logs/{rule}/{rule}-%j.out`.
  Note that you can still submit wildcards containing `/` to `--job-name`

* Requires Snakemake version 8.0.0 or later (released 2023-12-20, see
  [changelog](https://github.com/snakemake/snakemake/blob/main/CHANGELOG.md#800-2023-12-20)). You can test this directly in your `Snakefile` with
  [`min_version()`][min_version]. If you require an older version of Snakemake, please see the [`v7` branch](https://github.com/jdblischak/smk-simple-slurm/tree/v7)

## Quick start

1. Download the configuration file [`config.v8+.yaml`](simple/config.v8+.yaml) to your
   Snakemake project. It has to be in a subdirectory, e.g. `simple/`

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
`cluster-generic-submit-cmd`. For example, to specify an account to use for all job submissions, you can add the `--account` argument as shown below:

```yaml
executor: cluster-generic
cluster-generic-submit-cmd:
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

For example, the `config.v8+.yaml` below sets a default time of 1 hour, and the
example rule overrides this default for a total of 3 hours. Note that the quotes
around the default time specification are required, even though you don't need
quotes when specifying the default for either `partition` or `qos`.

```yaml
executor: cluster-generic
cluster-generic-submit-cmd:
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

Thus to instead use `minutes`, you could achieve the same effect as above with:

```yaml
executor: cluster-generic
cluster-generic-submit-cmd:
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
Note that specifying the time as a string requires a minimum Snakemake version
of 5.15.0.

### Using a cluster status script

By default, snakemake can monitor jobs submitted to slurm. I realized this when
reading this detailed [blog post][no-cluster-status], in which the author
decided not to use the `cluster-status.py` script provided by the [official
Slurm profile][slurm-official]. Thus if you don't find that your jobs are
silently failing often, then there's no need to worry about this extra
configuration step.

However, if you start to have jobs silently fail often, e.g. with status
`TIMEOUT` for exceeding their time limit, then you can add a custom script to
monitor the job status with the option [`--cluster-generic-status-cmd`][cluster-status].

The directory [`extras/`](extras/) contains multiple options for checking the
status of the jobs. You can choose which one you'd like to use:

* `status-sacct.py` - This is the example from the [Snakemake
  documentation][cluster-status]. It uses `sacct` to query the status of each
  job by its ID

* `status-sacct.sh` - (**recommended**) This is a Bash translation of the example
  from the [Snakemake documentation][cluster-status]. The Python script is
  simply shell-ing out to `sacct`, so running Bash directly removes the overhead
  of repeatedly starting Python each time you check a job

* `status-scontrol.sh` - This is a Bash script that uses `scontrol` to query the
  status of each job by its ID. The `scontrol` command is from
  [`slurm-status.py`](https://github.com/Snakemake-Profiles/slurm/blob/master/%7B%7Bcookiecutter.profile_name%7D%7D/slurm-status.py#L35)
  in the [official profile][slurm-official]. If your HPC cluster doesn't have
  `sacct` configured, you can use this option

* `status-sacct-multi.sh` - Support for multi-cluster setup (see section
  [Multiple clusters](#multiple-clusters))

To use one of these status scripts:

1. Download the script to your profile directory where `config.yaml` is located

1. Make the script executable, e.g. `chmod +x status-sacct.sh`

1. Add the field `cluster-generic-status-cmd` to your `config.yaml`, e.g. `cluster-generic-status-cmd: status-sacct.sh`

1. Add the flag `--parsable` to your `sbatch` command (requires Slurm version
   14.03.0rc1 or later)

### Multiple clusters

It's possible for Slurm to submit jobs to [multiple different
clusters][multi_cluster]. Below is my advice on how to configure this. However,
I've worked with multiple HPC clusters running Slurm, and have never encountered
this situation. Thus I'd appreciate any contributions to improve the
documentation below.

1. If you have access to multiple clusters, but only need to submit jobs to the
   default cluster, then you shouldn't have to modify anything in this profile

1. If you want to always submit your jobs to a cluster other than the default,
   or use multiple clusters, then pass the option `--clusters` to `sbatch`, e.g.
   to submit your jobs to either cluster "c1" or "c2"

    ```yaml
    # config.v8+.yaml
    executor: cluster-generic
    cluster-generic-submit-cmd:
      mkdir -p logs/{rule} &&
      sbatch
        --clusters=c1,c2
    ```

1. To set a default cluster and override it for specific rules, use
   `--default-resources`. For example, to run on "c1" by default but "c2" for a
   specific rule:

    ```yaml
    # config.v8+.yaml
    executor: cluster-generic
    cluster-generic-submit-cmd:
      mkdir -p logs/{rule} &&
      sbatch
        --clusters={resources.clusters}
    default-resources:
      - clusters=c1
    ```

    ```python
    # Snakefile
    rule different_cluster:
        resources:
            clusters="c2"
    ```

1. Using a custom cluster status script in a multi-cluster setup requires
   Snakemake 7.1.1+ (or Snakemake 8.0.0+ if you are using the new `--cluster-generic-*-cmd` flags). After you add the flag `--parsable` to `sbatch`, it will return `jobid;cluster_name`. I adapted `status-sacct.sh` to handle this
   situation. Please see [`examples/multi-cluster/`](examples/multi-cluster) to
   try out `status-sacct-multi.sh`

## Use speed with caution

A big benefit of the simplicity of this profile is the speed in which jobs can
be submitted and their statuses checked. The [official Slurm profile for
Snakemake][slurm-official] provides a lot of extra fine-grained control, but
this is all defined in Python scripts, which then have to be invoked for each
job submission and status check. I needed this speed for a pipeline that had an
aggregation rule that needed to be run tens of thousands of times, and the run
time for each job was under 10 seconds. In this situation, the job submission
rate and status check rate were huge bottlenecks.

However, you should use this speed with caution! On a shared HPC cluster, many
users are making requests to the Slurm scheduler. If too many requests are made
at once, the performance will suffer for all users. If the rules in your
Snakemake pipeline take at least more than a few minutes to complete, then it's
overkill to constantly check the status of multiple jobs in a single second. In
other words, only increase `max-jobs-per-second` and/or
`max-status-checks-per-second` if either the submission rate or status checks to
confirm job completion are clear bottlenecks.

## License

This is all boiler plate code. Please feel free to use it for whatever purpose
you like. No need to attribute or cite this repo, but of course it comes with no
warranties. To make it official, it's released under the [CC0][] license. See
[`LICENSE`](LICENSE) for details.

[aws-parallelcluster]: https://aws.amazon.com/hpc/parallelcluster/
[cbrueffer]: https://github.com/cbrueffer
[CC0]: https://creativecommons.org/publicdomain/zero/1.0/
[changelog]: https://snakemake.readthedocs.io/en/stable/project_info/history.html
[cluster-cancel]: https://snakemake.readthedocs.io/en/stable/tutorial/additional_features.html#using-cluster-cancel
[cluster-config]: https://snakemake.readthedocs.io/en/stable/snakefiles/configuration.html#cluster-configuration-deprecated
[cluster-execution]: https://snakemake.readthedocs.io/en/stable/executing/cluster.html
[cluster-status]: https://snakemake.readthedocs.io/en/stable/tutorial/additional_features.html#using-cluster-status
[grouping]: https://snakemake.readthedocs.io/en/stable/executing/grouping.html
[grouping-issue]: https://github.com/snakemake/snakemake/issues/872
[min_version]: https://snakemake.readthedocs.io/en/stable/snakefiles/writing_snakefiles.html#depend-on-a-minimum-snakemake-version
[multi_cluster]: https://slurm.schedmd.com/multi_cluster.html
[no-cluster-status]: http://bluegenes.github.io/Using-Snakemake_Profiles/
[resources-and-group-jobs]: https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#resources-and-group-jobs
[sichong-post]: https://www.sichong.site/workflow/2021/11/08/how-to-manage-workflow-with-resource-constraint.html
[slurm-official]: https://github.com/Snakemake-Profiles/slurm
[snakemake-aws-parallelcluster-slurm]: https://github.com/cbrueffer/snakemake-aws-parallelcluster-slurm
