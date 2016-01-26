#!/bin/bash -xu
#
# This script runs a docker image for e.g. out-of-source builds.
#
# Examples
# --------
#
#   $ build.sh input/ output/ "make" bjodah/bjodahimg latest
# 
# Notes
# -----
# Your user need to be in the docker group (docker is not invoked with "sudo").
# To add your user to the docker group you may write:
#
#  $ sudo adduser $(whoami) docker
#

ABS_INPUT_PATH=$(unset CDPATH && cd "$1" && echo $PWD)
ABS_OUTPUT_PATH=$(unset CDPATH && cd "$2" && echo $PWD)

# Since docker run as uid 0 by default we export our uid and gid and set ownership
# of files in our volume /output before exiting the container.

cat <<'EOF' | docker run --rm -e RUNCMD="${3:-make}" -e TERM -e HOST_UID=$(id -u) -e HOST_GID=$(id -g) -v $ABS_INPUT_PATH:/input:ro -v $ABS_OUTPUT_PATH:/output -w /output -i ${4}:${5} bash -x
cp -rau /input/. .
addgroup --gid "$HOST_GID" mygroup
adduser --disabled-password --uid "$HOST_UID" --gid "$HOST_GID" --gecos '' myuser
chown "$HOST_UID":"$HOST_GID" /root
su -m myuser -c "$RUNCMD"
BUILD_EXIT=$?
exit $BUILD_EXIT
EOF
