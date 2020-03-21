#!/bin/bash

run() {
    local retval
    local cmd_line=''

    for cmd in "$@" ; do
        if [[ -z $cmd_line ]]; then
            cmd_line="$cmd"
        else
            cmd_line="$cmd_line $cmd"
        fi
    done

    if "$@"; then
        retval=$?
        good_msg "Executed: '$cmd_line'"
    else
        retval=$?
        bad_msg "Failed (${retval}): '$cmd_line'"
    fi

    return ${retval}
}

log_msg() {
    if [ ${LOG_DISABLED} ]; then
        return
    fi

    if [ ! -f "${LOG_FILE}" ]
    then
        touch "${LOG_FILE}"
    fi

    local log_prefix=
    [ -n "${LOG_PREFIX}" ] && log_prefix="${LOG_PREFIX}: "

    local msg=${1}

    LANG=C echo "[$(date +"%Y-%m-%d %H:%M:%S")] ${log_prefix}${msg}" >> "${LOG_FILE}"
}

splash() {
    return 0
}

# msg functions arguments
# $1 string
# $2 hide flag

good_msg() {
    if [[ -z "$2" ]]; then
        local hide_flag=0
    else
        local hide_flag=$2
    fi

    if [ -n "${QUIET}" ] && [ -z "${DEBUG}" ]; then
        hide_flag=1
    fi

    local msg_string=${1}
    msg_string="${msg_string:-...}"

    log_msg "[OK] ${msg_string}"

    if [ "$hide_flag" != '1' ]; then
        printf "%b\n" "${GOOD}>>${NORMAL}${BOLD} ${msg_string} ${NORMAL}"
    fi
}

good_msg_n() {
    if [[ -z "$2" ]]; then
        local hide_flag=0
    else
        local hide_flag=$2
    fi

    if [ -n "${QUIET}" ] && [ -z "${DEBUG}" ]; then
        hide_flag=1
    fi
    local hide_flag=$2

    local msg_string=${1}
    msg_string="${msg_string:-...}"

    log_msg "[OK] ${msg_string}"

    if [ "$hide_flag" != '1' ]; then
        printf "%b" "${GOOD}>>${NORMAL}${BOLD} ${msg_string}"
    fi
}

bad_msg() {
    local msg_string=${1}
    msg_string="${msg_string:-...}"

    log_msg "[!!] ${msg_string}"

    if [ "$2" != '1' ]
    then
        splash 'verbose' >/dev/null &
        printf "%b\n" "${BAD}!!${NORMAL}${BOLD} ${msg_string} ${NORMAL}"
    fi
}

warn_msg() {
    local msg_string=${1}
    msg_string="${msg_string:-...}"

    log_msg "[**] ${msg_string}"

    [ "$2" != '1' ] && printf "%b\n" "${WARN}**${NORMAL}${BOLD} ${msg_string} ${NORMAL}"
}

mkdir_ifnot_exist() {
    if [[ $# != 1 ]]; then
        echo "mkdir_ifnot_exist(): don't have enough arguments!"
        exit 1
    fi

    local dir=$1

    if [ ! -d $dir ]; then
        run mkdir -p $dir
    fi
}

