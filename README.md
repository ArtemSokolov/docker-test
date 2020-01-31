# docker-test: Automatic building of parallel Docker images

The example demonstrates how to set up parallel Docker image builds from Dockerhub. In the overall setup, we have two versions of the code: 1) a fixed version tagged `v1.0` and 2) the `master` branch. We would like to derive two Docker images for each of these codebases: an image based on tensorflow and an image based on tensorflow-gpu.

To solve this, we create `hooks/build` which augments the default image name provided by Dockerhub with a "-gpu" suffix. The parallel build is then constructed and pushed to Dockerhub by hand. On the Dockerhub side, we create two automatic build rules: one for `v1.0` and the other for `master`. Each build rule will execute `hooks/build`, which in turn will correctly generate two parallel Docker images.

### On the GitHub side:

1. `Dockerfile`: Define the base image variable `TF_IMAGE` and give it a default value.
2. `hooks/build`: Use `--build-arg` to override the default value of `TF_IMAGE` in parallel image builds.
3. `hooks/build`: Use `$IMAGE_NAME`, which is provided by Dockerhub, to dynamically generate a tag for parallel image builds.
4. `hooks/build`: Build and push parallel images by hand. End the script by building the default image.
6. Create a `v1.0` release. In this example, the difference between `v1.0` and most recent `master` is the version of Python.

### On the Dockerhub side:

Create two automatic build rules:
- `master` -> `latest`
- `v1.0` -> `1.0`

### Testing

`docker pull` all four images. We expect that `1.0` and `1.0-gpu` will have python2, while `latest` and `latest-gpu` will have python 3. The `*-gpu` images should have GPU support.

``` bash
docker run -it --rm --runtime=nvidia artemsokolovdh/docker-test:1.0 bash
root@0449637fe38e:/# python --version
Python 2.7.15+
root@0449637fe38e:/# ls /dev/nvidia*
ls: cannot access '/dev/nvidia*': No such file or directory

docker run -it --rm --runtime=nvidia artemsokolovdh/docker-test:1.0-gpu bash
root@ae32b88f5cc6:/# python --version
Python 2.7.15+
root@ae32b88f5cc6:/# ls /dev/nvidia*
/dev/nvidia-uvm  /dev/nvidia-uvm-tools  /dev/nvidia0  /dev/nvidiactl
```
