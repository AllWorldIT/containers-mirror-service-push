# Introduction

This is the AllWorldIT mirror push image, used for mirrors which accept push/uploads.



# Environment


## MIRROR_PUSH_CONFIG

This environment variable is in a very specific format...

`SSH_KEY /data/PATH`

The SSH key email address is used as a filename suffixed with .conf, so please ensure it is included.



# Volumes


## Volume: /etc/ssh/keys

SSH keys that should persist.


## Volume: /data

Data directory.

Ownership should be set to 1001:1001.


# Usage

`rsync -e 'ssh -p 9022' -vAP /data/whatever push@localhost::incoming/`

