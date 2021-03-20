#!/bin/bash
printf "Entering stage ${IN_DOCKER:-0}\n"
if [[ $IN_DOCKER == "1" ]]; then
    printf "Docker-level 1.\n"
    source /etc/bash.bashrc
    source $HOME/.bashrc
    set -e
    groupadd -f --gid $HOST_GID $HOST_LOGNAME
    if ! groups | grep sudo >/dev/null; then
        groupadd -f --gid 27 sudo
    fi
    useradd --uid $HOST_UID --gid $HOST_GID --groups sudo --home /home/$HOST_LOGNAME --shell /bin/bash $HOST_LOGNAME
    mkdir -m 0755 -p /home/$HOST_LOGNAME/.config
    chown -R $HOST_UID:$HOST_GID /home/$HOST_LOGNAME
    echo "Set disable_coredump false" >> /etc/sudo.conf
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    sudo -E -u $HOST_LOGNAME /bin/bash -c "export HOME=/home/$HOST_LOGNAME; export IN_DOCKER=2; source $BASH_SOURCE"
    if [[ "${DONTEXIT:-0}" == "0" ]]; then
        exit
    else
        printf "Docker-level 1.\n"
    fi
elif [[ $IN_DOCKER == "2" ]]; then
    echo "Docker-level 2, whoami: $(whoami), id -u: $(id -u), id -g: $(id -g), HOME: $HOME, USER: $USER, LOGNAME: $LOGNAME"
    set -ex
    ${RUNSCRIPT}
else
    echo "Docker-level 0 (docker is about to be launched)."
    set -ux
    MOUNT="$1"
    DOCKERIMAGE="$2"
    COMMAND="$3"
    if groups | grep docker >/dev/null; then
        DOCKERCMD=docker
    else
        DOCKERCMD="sudo docker"
    fi
    HOST_LOGNAME=${SUDO_USER:-${LOGNAME}}
    DOCKRE_SCRIPTS_DIR=$(unset CDPATH && cd "$(dirname "$(realpath $0)")" && echo $PWD)
    WORKDIR="$(realpath $MOUNT)"
    ABS_PREFIX=$(unset CDPATH && cd "$(dirname "$(realpath $0)")/.." && echo $PWD)
    set -ux
    $DOCKERCMD run --rm \
               --cap-add SYS_PTRACE \
               --security-opt seccomp=unconfined \
               --detach-keys=ctrl-^ \
               -e TERM \
               -e PREFIXBASENAME=$(head -n1 $ABS_PREFIX/README.rst) \
               -e IN_DOCKER=1 \
               -e HOST_LOGNAME="${HOST_LOGNAME}" \
               -e HOST_UID=$(id -u "${HOST_LOGNAME}") \
               -e HOST_GID=$(id -g "${HOST_LOGNAME}") \
               -e DONTEXIT:"${DONTEXIT:-0}" \
               -e RUNSCRIPT="$COMMAND" \
               -e WORKDIR=$(realpath "$MOUNT") \
               -v "$WORKDIR":"$WORKDIR" -w "$WORKDIR" \
               -v "$DOCKRE_SCRIPTS_DIR":/dockre-scripts \
               -it "$DOCKERIMAGE" \
               bash --rcfile /dockre-scripts/$(basename $0)
fi
