#!/bin/bash

#VAR
BASE_PATH=$(cd "$(dirname "$0")"; pwd)
CONFIG_LIST="$BACKUP_DIR/list.conf"
CONFIG_PERMS="$BACKUP_DIR/perms.conf"
RESERVE_FILE="$BACKUP_DIR/reserve.conf"

# Insert ctrl character
# ctrl-V then esc will print ^[
# ctrl-V then ctrl-shift-m will print ^M
BACK_UP="\033[1K\033[0G"
WARN="\033[33;1m"
BAD="\033[31;1m"
BOLD="\033[1m"
GOOD="\033[32;1m"

QUIET='1'
DEBUG=''

LOG_DISABLED='1'
LOG_FILE="${BACKUP_DIR}.log"
LOG_PREFIX=
