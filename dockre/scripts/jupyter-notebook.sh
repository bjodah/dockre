#!/bin/bash
MOUNT=${1:-.}
PORT=${2:-8888}
NOTEBOOKCMD=${3:-jupyter-notebook}
TAG=${4:-latest}
IMAGE=${5:-bjodah/bjodahimg}
DOCKERIMAGE_USED="$IMAGE:$TAG"
if [[ "$MOUNT" == .* ]]; then
    MOUNT="$(pwd)/$MOUNT"
fi
if [[ ! -z "$DISPLAY" ]]; then
    ( sleep 2; xdg-open "http://127.0.0.1:$PORT" ) &
fi
echo $MYCMD
MYCMD="groupadd -f --gid \$HOST_GID \$HOST_WHOAMI; useradd --uid \$HOST_UID --gid \$HOST_GID --home /mount \$HOST_WHOAMI; sudo --set-home --login -u \$HOST_WHOAMI DOCKERIMAGE_USED=\$DOCKERIMAGE_USED PYTHONPATH=. $NOTEBOOKCMD --no-browser --port 8888 --ip=* --matplotlib=inline"
echo $MYCMD
docker run --rm --name "jupyter_notebook_$PORT" -p 127.0.0.1:$PORT:8888\
 -e DOCKERIMAGE_USED -e HOST_WHOAMI=$(whoami) -e HOST_UID=$(id -u) -e HOST_GID=$(id -g)\
 -v $MOUNT:/mount -w /mount -it "$DOCKERIMAGE_USED" /bin/bash -c "$MYCMD"
