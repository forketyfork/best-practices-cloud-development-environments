# Best Practices of Cloud Development Environments

[![Build status](https://github.com/forketyfork/best-practices-cloud-development-environments/actions/workflows/build.yml/badge.svg)](https://github.com/forketyfork/best-practices-cloud-development-environments/actions/workflows/build.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/language-Docker-blue.svg)](https://www.docker.com/)

Source code for the talk on best practices for cloud development environments.

## Building and running the dev-container

```shell
docker build . -t forketyfork-petclinic-dev-container \
  --build-arg PUBLIC_KEY="key" \
  --build-arg SSH_USER=forketyfork \
  --build-arg REPOSITORY="https://github.com/spring-projects/spring-petclinic.git"

docker run -p 2222:2222 forketyfork-petclinic-dev-container
```
