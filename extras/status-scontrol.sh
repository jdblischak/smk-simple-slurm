#!/usr/bin/env bash
set -eu

# Check status of Slurm job

jobid="$1"

output=`scontrol -o show job "$jobid" | sed "s/^.*JobState\=\(\S*\).*$/\1/"`

if [[ $output =~ ^(COMPLETED).* ]]
then
  echo success
elif [[ $output =~ ^(RUNNING|PENDING|COMPLETING|CONFIGURING|SUSPENDED).* ]]
then
  echo running
else
  echo failed
fi
