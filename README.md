# Best Practices of Cloud Development Environments

Source code for the talk.

## Building and running the dev-container

```shell
docker build . -t forketyfork-petclinic-dev-container \
  --build-arg PUBLIC_KEY="key" \
  --build-arg SSH_USER=forketyfork \
  --build-arg REPOSITORY="https://github.com/spring-projects/spring-petclinic.git"

docker run -p 2222:2222 forketyfork-petclinic-dev-container
```
