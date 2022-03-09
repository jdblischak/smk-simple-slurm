# Multiple clusters

**New feature:** The custom cluster status script for a multi-cluster setup is
now supported as of Snakemake 7.1.1 (see `simple/status-sacct-multi.sh`)

Submit jobs to a specific cluster. Edit the `Snakefile` rule `cluster_name` to
add the name of one or more of your clusters to the resouce `clusters`
(separated by commas). Run `sacctmgr --parsable show clusters | cut -d'|' -f1`
to view the names of the available clusters.

```python
rule cluster_name:
    output:
        "output/cluster.txt",
    resources:
        clusters="<cluster-name>",
```

You can also change the default cluster in `simple/config.yaml`:

```yaml
default-resources:
  - clusters=<default-cluster>
```

The example rule writes the name of the cluster to `output/cluster.txt`.

```sh
# Sumbit the job
snakemake --profile simple/

# Confirm the correct cluster was used
cat output/cluster.txt
```

**Note:** The file `simple/status-sacct-multi.sh` is a symlink to the actual
file in `extras/`
