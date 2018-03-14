#!/bin/bash
time=_` date +%y%m%d%H%M%S `
proc=yshd_game
datadir=/data/niuniu
backdir=/data/server-backup
packdir=/data/server-package
logfile=/var/log/yshd_game-restart.log
echo "" | tee $logfile
echo -e "\033[33m \033[1m              登陆用户：$(logname)  操作时间：`date +%F\ %T` \033[0m" | tee -a $logfile

#停用进程实时监控
sudo kill -9 `ps aux |grep "/script/listen_server.sh" |grep -v grep |awk '{print $2}'`
sudo chmod a+x $datadir/$proc
#发送重启信号
sudo kill -2 `ps aux |grep -w $datadir/$proc |grep -v grep | grep -v "tee -a $logfile" | awk '{print $2}'` > /dev/null  2>&1
echo ""
#倒计时
seconds_left=5
echo -e "\033[32m \033[1m                升级操作持续$seconds_left秒钟，请等待……\033[0m"
echo "" | tee $logfile
while [ $seconds_left -gt 0 ];do
    echo -n -e "\033[32m \033[1m                   还剩$seconds_left秒\033[0m"
    sleep 1
    seconds_left=$(($seconds_left - 1))
    echo -ne "\r     \r"
done

echo "" | tee -a $logfile
echo -e "\033[32m \033[1m                   服务器重启完成\033[0m" | tee -a $logfile
echo "" | tee -a $logfile
