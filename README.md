[![pipeline status](https://gitlab.conarx.tech/containers/mirror-service-push/badges/main/pipeline.svg)](https://gitlab.conarx.tech/containers/mirror-service-push/-/commits/main)

# Container Information

[Container Source](https://gitlab.conarx.tech/containers/mirror-service-push) - [GitHub Mirror](https://github.com/AllWorldIT/containers-mirror-service-push)

This is the Conarx Containers Mirror Push Service image, it provides the ability for mirrors to receive push updates.



# Mirrors

|  Provider  |  Repository                                         |
|------------|-----------------------------------------------------|
| DockerHub  | allworldit/mirror-service-push                      |
| Conarx     | registry.conarx.tech/containers/mirror-service-push |



# Conarx Containers

All our Docker images are part of our Conarx Containers product line. Images are generally based on Alpine Linux and track the
Alpine Linux major and minor version in the format of `vXX.YY`.

Images built from source track both the Alpine Linux major and minor versions in addition to the main software component being
built in the format of `vXX.YY-AA.BB`, where `AA.BB` is the main software component version.

Our images are built using our Flexible Docker Containers framework which includes the below features...

- Flexible container initialization and startup
- Integrated unit testing
- Advanced multi-service health checks
- Native IPv6 support for all containers
- Debugging options



# Community Support

Please use the project [Issue Tracker](https://gitlab.conarx.tech/containers/mirror-service-push/-/issues).



# Commercial Support

Commercial support for all our Docker images is available from [Conarx](https://conarx.tech).

We also provide consulting services to create and maintain Docker images to meet your exact needs.



# Environment Variables

Environment variables are available from...
* [Conarx Containers Alpine image](https://gitlab.conarx.tech/containers/alpine).


## MIRROR_PUSH_CONFIG

This environment variable is in a very specific multi-line format...

```
SSH_KEY /data/PATH
```

The SSH key email address is used as a filename suffixed with .conf, so please ensure it is included.



# Volumes


## /data

Mirror data directory.

Files and directories should be owned by 1001:1001.


## /etc/ssh/keys

In almost all cases this should be used to allow SSH host keys to persist.



# Exposed Ports

SSH port 22 is exposed.



# Usage

One would typically push mirror contents using a command like this...

```bash
rsync -e 'ssh -p 9022' -vAP /data/whatever push@localhost::incoming/
```
