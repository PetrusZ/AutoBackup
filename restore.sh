#!/bin/bash
set -o errexit

function restore_perm() {
    if [[ $# != 1 ]]; then
        echo "restore_perm(): don't have enough arguments!"
        exit 1
    fi

    local path=$1

    local mode=$(grep $path$ $CONFIG_PERMS | awk '{print $1}')
    local own=$(grep $path$ $CONFIG_PERMS | awk '{print $2}')
    local group=$(grep $path$ $CONFIG_PERMS | awk '{print $3}')

    if [[ ! -n $mode ]]; then
        echo "$path's perm not exits"
        exit 1
    fi

    run chmod $mode $path
    run chown $own:$group $path
    # echo "chmod $mode $path"
    # echo "chown $own:$group $path"

    if [ -d $path ]; then
        # 是文件夹
        for file in `ls $path`
        do
            restore_perm $path/$file
        done
    fi
}

function restore_files() {
    local line=$1
    local dir=$2

    if [[ -d $BACKUP_DIR$line ]]; then
        run rsync -aHAXx $BACKUP_DIR$line $dir
        # echo "rsync -aHAXx $BACKUP_DIR$line $dir"
    else
        run rsync -aHAXx $BACKUP_DIR$line $line
        # echo "rsync -aHAXx $BACKUP_DIR$line $line"
    fi
}

function restore() {
    if [[ $# != 1 ]]; then
        echo "restore(): don't have enough arguments!"
        exit 1
    fi

    while read line
    do
        local name=$(echo $line | awk -F '/' '{print $NF}')
        local dir=$(echo $line | sed "s/\/${name}$//g")

        if [[ $1 == 'portage' ]]; then
            local keyword1="/etc/portage"
            local keyword2="/var/lib/portage/world"
            local keyword3="/var/db/repos/local"

            # Portage配置文件，先行安装
            if [[ $line == $keyword1* || $line == $keyword2 || $line == $keyword3 ]]; then
                mkdir_ifnot_exist $dir
                restore_files $line $dir
                restore_perm $line
            fi
        elif [[ $1 == 'system' ]]; then
            local keyword="/home/"
            if [[ $line != $keyword* ]]; then
                mkdir_ifnot_exist $dir
                restore_files $line $dir
                restore_perm $line
            fi
        elif [[ $1 == 'user' ]]; then
            local keyword="/home/"
            if [[ $line == $keyword* ]]; then
                mkdir_ifnot_exist $dir
                restore_files $line $dir
                restore_perm $line
            fi
        elif [[ $1 == 'all' ]]; then
            mkdir_ifnot_exist $dir
            restore_files $line $dir
            restore_perm $line
        fi
    done < <(cat $CONFIG_LIST | grep -Ev "^$|#")
}

if [[ $# == 2 ]]; then
    BASE_PATH=$(cd "$(dirname "$0")"; pwd)
    BACKUP_DIR="$BASE_PATH/backup"
    BACKUP_DIR="${BACKUP_DIR}_${1}"

    source $BASE_PATH/variable.sh
    source $BASE_PATH/function.sh

    old_IFS=$IFS
    IFS=$(echo -en "\n\b")


    if [[ $2 == 'portage' || $2 == 'system' || $2 == 'all' ]]; then
        if [ `id -u` -ne 0 ];then
            echo "THIS COMMANDC NEED RUN AS ROOT!"
            exit 1
        fi
        restore $2
    fi

    if [[ $2 == 'user' ]]; then
        if [ `id -u` -eq 0 ];then
            echo "THIS COMMAND NEED RUN AS USER!"
            exit 1
        fi
        restore $1
    fi
else
    echo "Usage:"
    echo "      $0 backup_dir_suffix portage"
    echo "      $0 backup_dir_suffix system"
    echo "      $0 backup_dir_suffix user"
    echo "      $0 backup_dir_suffix all"
fi

IFS=$old_IFS
