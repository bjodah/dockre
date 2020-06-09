#!/bin/bash
printf "Entering stage ${IN_DOCKER:-0}\n"
if [[ $IN_DOCKER == "1" ]]; then
    source /etc/bash.bashrc
    source $HOME/.bashrc
    set -e
    groupadd -f --gid $HOST_GID $HOST_LOGNAME
    if ! groups | grep sudo >/dev/null; then
        groupadd -f --gid 27 sudo
    fi
    useradd --uid $HOST_UID --gid $HOST_GID --groups sudo --home /home/$HOST_LOGNAME $HOST_LOGNAME
    mkdir -m 0755 -p /home/$HOST_LOGNAME/.config
    chown -R $HOST_UID:$HOST_GID /home/$HOST_LOGNAME
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    #stty cols $COLUMNS rows $LINES
    IN_DOCKER=2 su $HOST_LOGNAME -c "bash --rcfile \"$BASH_SOURCE\""
    exit $?
elif [[ $IN_DOCKER == "2" ]]; then
    source /etc/bash.bashrc
    #source $HOME/.bashrc
    echo "whoami: $(whoami), id -u: $(id -u), id -g: $(id -g), HOME: $HOME, USER: $USER, LOGNAME: $LOGNAME"
else
    set -ux
    MOUNT=$1
    DOCKERIMAGE=$2
    if groups | grep docker >/dev/null; then
        DOCKERCMD=docker
    else
        DOCKERCMD="sudo docker"
    fi
    HOST_LOGNAME=${SUDO_USER:-${LOGNAME}}
    DOCKRE_SCRIPTS_DIR=$(unset CDPATH && cd "$(dirname "$(realpath $0)")" && echo $PWD)
    
    # --cap-add SYS_ADMIN --device /dev/fuse \
    # --security-opt apparmor:unconfined \
    WORKDIR="$(realpath $MOUNT)"
    $DOCKERCMD run --rm --cap-add SYS_PTRACE --security-opt seccomp=unconfined \
               --detach-keys=ctrl-@ \
               -e TERM \
               -e IN_DOCKER=1 \
               -e HOST_LOGNAME=${HOST_LOGNAME} \
               -e HOST_UID=$(id -u ${HOST_LOGNAME}) \
               -e HOST_GID=$(id -g ${HOST_LOGNAME}) \
               -e WORKDIR="$(realpath $MOUNT)" \
               -v "$WORKDIR":"$WORKDIR" -w "$WORKDIR" \
               "${@:3}" \
               -v "$DOCKRE_SCRIPTS_DIR":/dockre-scripts \
               -it $DOCKERIMAGE \
               bash --rcfile /dockre-scripts/$(basename $0)
               # -e COLUMNS="$(tput cols)" \
               # -e LINES="$(tput lines)" \
fi
