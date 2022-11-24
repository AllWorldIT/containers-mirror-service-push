#!/bin/sh

apk add --no-cache socat


# Generate key
ssh-keygen -t ed25519 -f /root/testsshkey

# Grab key
KEY=$(cat /root/testsshkey.pub)

# Setup config
export MIRROR_PUSH_CONFIG="$KEY /data"

