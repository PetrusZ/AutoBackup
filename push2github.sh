#!/bin/bash

function main() {
    ROOT_DIR=$(cd "$(dirname "$0")"; pwd)

    source "$ROOT_DIR/backup.sh"

    cd $BACKUP_DIR

    git add .
    git commit -m "weekly update by crontab script" > /dev/null
    git push &> /dev/null
}

if [[ $# == 1 ]]; then
    BASE_PATH=$(cd "$(dirname "$0")"; pwd)
    BACKUP_DIR="$BASE_PATH/backup_${1}"

    source $BASE_PATH/variable.sh
    source $BASE_PATH/function.sh

    main $1
else
    echo "Usage:"
    echo "      $0 backup_dir_suffix"
fi
