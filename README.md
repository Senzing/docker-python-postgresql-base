# docker-python-postgresql-base

## Overview

The `senzing/python-postgresql-base` docker image is a Senzing-ready, python 2.7 image.
The image can be used in a Dockerfile `FROM senzing/python-base` statement to simplify
building apps with Senzing.

### Contents

1. [Expectations](#expectations)
    1. [Space](#space)
    1. [Time](#time)
    1. [Background knowledge](#background-knowledge)
1. [Demonstrate](#demonstrate)
    1. [Build docker image](#build-docker-image)
    1. [Create SENZING_DIR](#create-senzing_dir)
    1. [Configuration](#configuration)
    1. [Run docker container](#run-docker-container)
1. [Develop](#develop)
    1. [Prerequisite software](#prerequisite-software)
    1. [Set environment variables for development](#set-environment-variables-for-development)
    1. [Clone repository](#clone-repository)
    1. [Build docker image for development](#build-docker-image-for-development)

## Expectations

### Space

This repository and demonstration require 6 GB free disk space.

### Time

Budget 40 minutes to get the demonstration up-and-running, depending on CPU and network speeds.

### Background knowledge

This repository assumes a working knowledge of:

1. [Docker](https://github.com/Senzing/knowledge-base/blob/master/WHATIS/docker.md)

## Demonstrate

### Build docker image

```console
sudo docker build \
  --tag senzing/python-postgresql-base \
  https://github.com/senzing/docker-python-postgresql-base.git
```

### Create SENZING_DIR

1. If you do not already have an `/opt/senzing` directory on your local system, visit
   [HOWTO - Create SENZING_DIR](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/create-senzing-dir.md).

### Configuration

- **SENZING_DATABASE_URL** -
  Database URI in the form: `${DATABASE_PROTOCOL}://${DATABASE_USERNAME}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DATABASE}`
- **SENZING_DIR** -
  Location of Senzing libraries. Default: "/opt/senzing".

### Run docker container

1. Variation #2 - Run the docker container with external database and volumes.  Example:

    ```console
    export DATABASE_PROTOCOL=postgresql
    export DATABASE_USERNAME=postgres
    export DATABASE_PASSWORD=postgres
    export DATABASE_HOST=senzing-postgresql
    export DATABASE_PORT=5432
    export DATABASE_DATABASE=G2

    export SENZING_DATABASE_URL="${DATABASE_PROTOCOL}://${DATABASE_USERNAME}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DATABASE}"
    export SENZING_DIR=/opt/senzing

    sudo docker run -it  \
      --volume ${SENZING_DIR}:/opt/senzing \
      --env SENZING_DATABASE_URL="${SENZING_DATABASE_URL}" \
      senzing/python-postgresql-base
    ```

1. Variation #3 - Run the docker container accessing an external database in a docker network. Example:

   Determine docker network. Example:

    ```console
    sudo docker network ls

    # Choose value from NAME column of docker network ls
    export SENZING_NETWORK=nameofthe_network
    ```

    Run docker container. Example:

    ```console
    export DATABASE_PROTOCOL=mysql
    export DATABASE_USERNAME=root
    export DATABASE_PASSWORD=root
    export DATABASE_HOST=senzing-mysql
    export DATABASE_PORT=3306
    export DATABASE_DATABASE=G2

    export SENZING_DATABASE_URL="${DATABASE_PROTOCOL}://${DATABASE_USERNAME}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DATABASE}"
    export SENZING_DIR=/opt/senzing

    sudo docker run -it  \
      --volume ${SENZING_DIR}:/opt/senzing \
      --net ${SENZING_NETWORK} \
      --env SENZING_DATABASE_URL="${SENZING_DATABASE_URL}" \
      senzing/python-base
    ```

## Develop

### Prerequisite software

The following software programs need to be installed.

#### git

1. [Install Git](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-git.md)
1. Test

    ```console
    git --version
    ```

#### make

1. [Install make](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-make.md)
1. Test

    ```console
    make --version
    ```

#### docker

1. [Install docker](https://github.com/Senzing/knowledge-base/blob/master/HOWTO/install-docker.md)
1. Test

    ```console
    sudo docker --version
    sudo docker run hello-world
    ```

### Set environment variables for development

1. These variables may be modified, but do not need to be modified.
   The variables are used throughout the installation procedure.

    ```console
    export GIT_ACCOUNT=senzing
    export GIT_REPOSITORY=docker-python-base
    export DOCKER_IMAGE_TAG=senzing/python-base
    ```

1. Synthesize environment variables.

    ```console
    export GIT_ACCOUNT_DIR=~/${GIT_ACCOUNT}.git
    export GIT_REPOSITORY_DIR="${GIT_ACCOUNT_DIR}/${GIT_REPOSITORY}"
    export GIT_REPOSITORY_URL="git@github.com:${GIT_ACCOUNT}/${GIT_REPOSITORY}.git"
    ```

### Clone repository

1. Get repository.

    ```console
    mkdir --parents ${GIT_ACCOUNT_DIR}
    cd  ${GIT_ACCOUNT_DIR}
    git clone ${GIT_REPOSITORY_URL}
    ```

### Build docker image for development

1. Variation #1 - Using make command

    ```console
    cd ${GIT_REPOSITORY_DIR}
    sudo make docker-build
    ```

1. Variation #2 - Using docker command

    ```console
    cd ${GIT_REPOSITORY_DIR}
    sudo docker build --tag ${DOCKER_IMAGE_TAG} .
    ```

