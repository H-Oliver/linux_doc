#!/bin/bash
time=_` date +%y%m%d%H%M%S `
process=yshd_game
datadir=/data/niuniu
backdir=/data/server-backup
packdir=/data/server-package
logfile=/var/log/yshd_game_rollback.log
echo "#################### $(logname) : `date +%F##%T` ####################" | tee $logfile

