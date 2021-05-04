# Multiple clusters

**Warning:** Work in progress

Submit jobs to a specific cluster. Edit `simple/config.yml` to add the name of
one or more of your clusters to the argument `--clusters` (separated by commas).
Run `sacctmgr --parsable show clusters | cut -d'|' -f1` to view the names of the
available clusters.

The example rule writes the name of the cluster to `output/cluster.txt`.

```sh
# Sumbit the job
snakemake --profile simple/

# Confirm the correct cluster was used
cat output/cluster.txt
```
