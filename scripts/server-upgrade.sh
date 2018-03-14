#!/bin/bash
time=_` date +%y%m%d%H%M%S `
proc=yshd_game
package_file=yshd_game.zip
config_file=config.ini
docker_process=17wan-t1
datadir=/data/niuniu
backdir=/data/server-backup
packdir=/data/server-package
logfile=/var/log/yshd_game-upgrade.log
listen_script=/script/listen_server.sh

echo "" | tee $logfile
echo -e "\033[33m \033[1m              登陆用户：$(logname)  操作时间：`date +%F\ %T` \033[0m" | tee -a $logfile
echo "" | tee -a $logfile
echo -e "\033[33m \033[1m             升级前服务器进程状态如下：\033[0m"
echo "" | tee -a $logfile
#查询服务器重启之前的状态
sudo ps aux |grep -w "$datadir/$proc" | grep -v grep |grep -v "tee -a $logfile" |tee -a $logfile
echo "" | tee -a $logfile
#停用进程实时监控
sudo kill -9 `ps aux |grep "/script/listen_server.sh" |grep -v grep |awk '{print $2}'`

#重启过程条件判断
if [ -e "$datadir/$proc" -a -e "$packdir/yshd_game.zip" ]; then
    #备份原程序
    sudo mv $datadir/yshd_game $backdir/yshd_game$time 2>&1 | tee -a $logfile
    #解压新程序到工作目录
    unzip $packdir/yshd_game.zip -d $datadir/ 2>&1 | tee -a $logfile
    #备份新程序包
    sudo mv $packdir/yshd_game.zip $packdir/yshd_game.zip$time 2>&1 | tee -a $logfile
    #给新程序增加可执行权限
    sudo chmod a+x $datadir/yshd_game
    #给进程发送重启信号
    sudo kill -2 `ps aux |grep -w "$proc" |grep -v grep | awk '{print $2}'` 2>&1
    echo "" | tee -a $logfile
    #倒计时
    seconds_left=5
    echo -e "\033[32m \033[1m                升级操作持续$seconds_left秒钟，请耐心等待…………\033[0m"
    echo ""

    while [ $seconds_left -gt 0 ];do
        echo -n -e "\033[32m \033[1m               正在倒计时,还剩:$seconds_left秒"
        sleep 1
        seconds_left=$(($seconds_left - 1))
        echo -ne "\r     \r"
    done

    echo -e "\033[32m \033[1m                服务器(`date +%F\ %T`)升级完成\033[0m" | tee -a $logfile
    echo "" | tee -a $logfile
    #重启实时监控脚本
    /bin/bash $listen_script &
    echo "" | tee -a $logfile

else
    if [ ! -e "$datadir/$proc" -a -e "$packdir/$package_file" ]; then
        echo "" | tee -a $logfile
        echo -e "\033[35m \033[1m          注意:服务器进程文件\"$proc\"不存在，可能已移除或删除了哦\033[0m" |tee -a $logfile
        echo "" | tee -a $logfile

    elif [ -e "$datadir/$proc" -a ! -e "$packdir/$package_file" ]; then
        echo "" | tee -a $logfile
        echo -e "\033[35m \033[1m          注意:更新包\"$package_file\"未上传到服务器,请上传程序包哦\033[0m" |tee -a $logfile
        echo "" | tee -a $logfile

    elif [ ! -e "$datadir/$proc" -a ! -e "$packdir/$package_file" ]; then
        echo "" | tee -a $logfile
        echo -e "\033[35m \033[1m          注意:更新包\"$package_file\"未上传到服务器,请上传程序包哦\033[0m" |tee -a $logfile
        echo "" | tee -a $logfile
        echo -e "\033[35m \033[1m               服务器进程文件\"$proc\"不存在，可能已移除或删除了哦\033[0m" |tee -a $logfile
        echo "" | tee -a $logfile
    fi
fi
