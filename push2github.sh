#!/bin/bash

ROOT_DIR=$(cd "$(dirname "$0")"; pwd)

source "$ROOT_DIR/backup.sh"

cd $BACKUP_DIR

git add .
git commit -sS -m "weekly update by crontab script" > /dev/null
git push &> /dev/null
