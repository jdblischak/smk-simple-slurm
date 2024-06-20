# Run jobs inside a  singularity container

The example has a single rule, which is run in a singularity container.  To run this example you will need singularity installed and available in your `$PATH` (i.e the shell command `which singularity` must return the path to the singularity executable).

## Running the example
```sh
snakemake --profile simple/ 
```

## A note on containers

This example relies on the user having some method for obtaining docker images that can be converted to singularity images. This example uses a [publicly available dockerhub R image](https://hub.docker.com/r/rocker/r-ver).  A major caveat of using dockerhub is that if you run this example on a widely use cluster it is possible you will get an error like:

```log
Building DAG of jobs...
Pulling singularity image docker://rocker/r-ver.
WorkflowError:
Failed to pull singularity image from docker://rocker/r-ver:
FATAL:   While making image from oci registry: error fetching image to cache: failed to get checksum for docker://rocker/r-ver: Error reading manifest latest in docker.io/rocker/r-ver: toomanyrequests: You have reached your pull rate limit. You may increase the limit by authenticating and upgrading: https://www.docker.com/increase-rate-limit
```

If you get this error this means that you will likely need an alternate means of obtaining docker images.  One good option is to build and host your container using the [GitHub Container Regsitry](https://github.com/features/packages).  

If you host the images somewhere other than on dockerhub it is likely that you will need to authenticate to obtain the image.  In the case of GitHub Container Registry, You can read more about that [here](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry).

Here is an example of how the authentication workflow works
```sh
# set username and password as env variables 
export SINGULARITY_DOCKER_USERNAME=foo
export SINGULARITY_DOCKER_PASSWORD=bar
snakemake --profile simple/ 
```
