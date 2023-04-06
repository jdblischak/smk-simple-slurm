# Specify a list of partitions

You can allow your job to run on more than one SLURM partition. In this case,
SLURM will choose which partition to run your job on. From the `sbatch`
manpage:

> If the job can use more than one partition, specify their names in a comma
  separate list and the one offering earliest initiation will be used with no
  regard given to the partition name ordering (although higher priority
  partitions will be considered first).


```yaml
cluster:
  sbatch
    --partition={resources.partition}
    --qos={resources.qos}
    --cpus-per-task={threads}
    --mem={resources.mem_mb}
    --job-name=smk-{rule}-{wildcards}
    --output=logs/{rule}/{rule}-{wildcards}-%j.out
default-resources:
  - partition="partition1,partition2,partition3,partition4,partition5"
  - qos=<name-of-quality-of-service>
  - mem_mb=1000
```

You can still specify a partition for jobs in the Snakefile as usual:

```python
rule partition1_only:
    resources:
        partition="partition1",
    shell: echo "executed on partition1"
 
rule any_partition:
    shell: echo "executed on whichever partition Slurm chose"
```
