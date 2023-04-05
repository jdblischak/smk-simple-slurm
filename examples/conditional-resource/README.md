# Specify a resource conditionally

Sometimes you only need an argument to `sbatch` in certain circumstances. For
example, if your cluster has lots of partitions, you may want
SLURM to select a partition based on job resources like
`cpus-per-task`, `mem` and `time`, without specifying the partition explicitly.
In this case you wound need Snakemake to submit the job without the `--partition`
argument.

The following profile uses an empty `partitionFlag` by default.

```yaml
cluster:
  sbatch
    {resources.partitionFlag}
    --qos={resources.qos}
    --cpus-per-task={threads}
    --mem={resources.mem_mb}
    --job-name=smk-{rule}-{wildcards}
    --output=logs/{rule}/{rule}-{wildcards}-%j.out
default-resources:
  - partitionFlag=""
  - qos=<name-of-quality-of-service>
  - mem_mb=1000
```

You may need to specify the partition for certain jobs. This can be done by
adding the `partitionFlag` resource to the rule, as in the following Snakefile:

```python
rule withPartitionFlag:
    resources:
        partitionFlag="--partition=aSpecificPartition",
    shell: echo "executed on aSpecificPartition"
 
rule withoutPartitionFlag:
    shell: echo "executed on whichever partition Slurm chose"
```
