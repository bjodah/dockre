#!/bin/bash
MOUNT=${1:-.}
PORT=${2:-8888}
NOTEBOOKCMD=${3:-jupyter-notebook}
IMAGE=${5:-bjodah/bjodahimg:latest}
if [[ "$MOUNT" == .* ]]; then
    MOUNT="$(pwd)/$MOUNT"
fi
if [[ ! -z "$DISPLAY" ]]; then
    ( sleep 2; xdg-open "http://127.0.0.1:$PORT" ) &
fi
echo $MYCMD
MYCMD="groupadd -f --gid \$HOST_GID \$HOST_WHOAMI; useradd --uid \$HOST_UID --gid \$HOST_GID --home /mount \$HOST_WHOAMI; sudo --set-home --login -u \$HOST_WHOAMI DOCKERIMAGE_USED=\$IMAGE PYTHONPATH=. $NOTEBOOKCMD --no-browser --port 8888 --ip=* --matplotlib=inline"
echo $MYCMD
docker run --rm --name "jupyter_notebook_$PORT" -p 127.0.0.1:$PORT:8888\
 -e DOCKERIMAGE_USED=$IMAGE -e HOST_WHOAMI=$(whoami) -e HOST_UID=$(id -u) -e HOST_GID=$(id -g)\
 -v $MOUNT:/mount -w /mount -it "$IMAGE" /bin/bash -c "$MYCMD"
