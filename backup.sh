#!/bin/bash

set -o errexit

function delete_old_files() {
    # reserve
    local reserve_files
    if [[ -e $RESERVE_FILE ]]; then
        while read line
        do
            local full_path="$BACKUP_DIR/$line"
            reserve_files+="($full_path)"
        done < <(cat $RESERVE_FILE | grep -Ev "^$|#")
    fi

    local dir=$1
    for file in `ls -a $dir`       #注意此处这是两个反引号，表示运行系统命令
    do
        if [[ $file == '.' || $file == '..' || $file == 'backup_stamp' ]]; then
            continue
        fi

        if [ -d $dir"/"$file ]
        then
            # 如果目录为空也不在列表中，则直接删除
            local count=`ls -a $dir'/'$file | wc -l`
            if [[ $count == 2 && -z $(grep $original_path$ $CONFIG_PERMS) ]]; then
                run rm -r $dir/$file
            else
                delete_old_files $dir"/"$file
            fi
        else
            local full_path=`readlink -f $dir`
            full_path=$full_path/$file
            local original_path=$(echo $full_path | sed -e "s|"$dir"||g")

            # 该文件不在列表中
            if [[ -z $(grep $original_path$ $CONFIG_PERMS) ]]; then
                # 该文件不在.git目录中，也不是RESERVE_FILE、CONFIG_PERMS、CONFIG_LIST
                if [[ -z $(echo $full_path | grep '.git') && $full_path != $RESERVE_FILE && $full_path != $CONFIG_PERMS && $full_path != $CONFIG_LIST ]]; then
                    # 该文件不在RESERVE_FILE的列表中
                    if [[ -z $(echo "${reserve_files[@]}" | grep -w $full_path) ]]; then
                        run rm $full_path
                        # echo "rm $full_path"
                    fi
                fi
            fi
        fi
    done
}

function stat_dir(){
    local path=$1
    for file in `ls -a $path`       #注意此处这是两个反引号，表示运行系统命令
    do
        if [[ $file == '.' || $file == '..' ]]; then
            continue
        fi

        local perm=`stat -c "%a %u %g" $path"/"$file`
        echo "$perm $path"/"$file" >> $CONFIG_PERMS   #在此处处理文件即可

        if [ -d $path"/"$file ]
        then
            stat_dir $path"/"$file
        fi
    done
}

function backup() {
    local original=$1
    local backup=$2

    uid=$(stat -c "%u" $original)
    readable=$(stat -c "%a" $original)
    readable=${readable:2}

    if [[ $readable == 4 || $readable == 5 || $readable == 7 || $uid == 1000 ]]; then
        run cp  -aL $original $backup
        # echo "cp -aL $line $BACKUP_DIR/$dir"
    else
        run sudo cp -aL $original $backup
        run sudo chown -R 1000:1000 $backup
        # echo "sudo cp -aL $line $BACKUP_DIR/$dir"
        # echo "run sudo chown -R 1000:1000 $backup"
    fi
}

function main() {
    local backup_dir=$1
    mkdir_ifnot_exist $backup_dir

    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")

    echo -n "" > $CONFIG_PERMS

    run rm -f $LOG_FILE

    while read line
    do
        # 获取目录和文件名
        name=$(echo $line | awk -F '/' '{print $NF}')
        dir=$(echo $line | sed "s/\/${name}$//g" | awk '{print substr($1,2)}')

        # 备份文件
        mkdir_ifnot_exist $backup_dir/$dir
        backup $line $backup_dir/$dir

        # 记录权限
        perm=`stat -c "%a %u %g" $line`
        echo "$perm $line" >> $CONFIG_PERMS

        if [ -d $line ]; then
            stat_dir $line
        fi
    done < <(cat $CONFIG_LIST | grep -Ev "^$|#")

    delete_old_files $backup_dir


    IFS=$SAVEIFS

    touch $backup_dir/backup_stamp
    date > $backup_dir/backup_stamp
}


if [[ $# == 1 ]]; then
    BASE_PATH=$(cd "$(dirname "$0")"; pwd)
    BACKUP_DIR="${BASE_PATH}/backup_${1}"

    source $BASE_PATH/variable.sh
    source $BASE_PATH/function.sh

    main $BACKUP_DIR
else
    echo "Usage:"
    echo "      $0 backup_dir_suffix"
fi
