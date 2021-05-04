#!/usr/bin/env bash

# Check status of Slurm job submitted to one of multiple clusters

arg="$1"
jobid="${arg%%;*}"
cluster="${arg##*;}"

output=`sacct --clusters="$cluster" -j "$jobid" --format State --noheader | head -n 1 | awk '{print $1}'`

if [[ $output =~ ^(COMPLETED).* ]]
then
  echo success
elif [[ $output =~ ^(RUNNING|PENDING|COMPLETING|CONFIGURING|SUSPENDED).* ]]
then
  echo running
else
  echo failed
fi
