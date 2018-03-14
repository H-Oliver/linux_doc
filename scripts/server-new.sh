#!/bin/bash
### INFO BEGIN
### 此脚本用户操作测试服（重启、升级）
### Author:Oliver
### CreateDate:2017年9月7日
### INFO END

time=_` date +%y%m%d%H%M%S `
PID=1
proc=yshd_game
process=17wan-t1
RETVAL=`docker inspect $process |grep Status|awk -F '[:,"]' '{print $5}'`
datadir=/opt/17wanserver
backdir=/data/server-backup
packdir=/data/server-package
upgrade_log=/var/log/yshd_game-upgrade.log
restart_log=/var/log/yshd_game-restart.log

function trapper(){
#屏蔽菜单其它输入
  trap ':' INT EXIT TSTP TERM HUP
}

function countdown(){
#倒计时
seconds_left=5
echo -e "\033[32m \033[1m                       操作持续$seconds_left秒钟，请等待……\033[0m"
while [ $seconds_left -gt 0 ];do
  echo -n -e "\033[32m \033[1m                        还剩$seconds_left秒\033[0m"
  sleep 1
  seconds_left=$(($seconds_left - 1))
  echo -ne "\r     \r"
done
}

function upgrade_srv(){
#升级服务器
clear
echo -e "\033[33m \033[1m              登陆用户：$(logname)  操作时间：`date +%F\ %T` \033[0m" | tee -a $upgrade_log

if [ -e "$datadir/$proc" -a -e "$packdir/yshd_game.zip" ]; then
    sudo mv $datadir/yshd_game $backdir/yshd_game$time 2>&1 | tee -a $upgrade_log
    unzip $packdir/yshd_game.zip -d $datadir/ 2>&1 | tee -a $upgrade_log
    sudo mv $packdir/yshd_game.zip $packdir/yshd_game.zip$time 2>&1 | tee -a $upgrade_log
    sudo chmod a+x $datadir/yshd_game
    if [ $RETVAL = "running" ];then
      sudo docker exec $process kill -2 $PID 2>&1 | tee -a $upgrade_log
    else
      sudo docker restart $process 2>&1 | tee -a $upgrade_log
    fi
    countdown
    if [ $RETVAL = "running" ];then
      echo -e "\033[32m \033[1m                       服务器升级完成\033[0m" | tee -a $upgrade_log
    else
      echo -e "\033[32m\033[1m                        服务器升级失败,请排除故障再运行restart\033[0m" | tee -a $upgrade_log
    fi

else
    if [ ! -e "$datadir/$proc" -a -e "$packdir/yshd_game.zip" ]; then
        echo -e "\033[35m \033[1m              注意:服务器进程文件\"$proc\"不存在，可能已移除或删除了哦\033[0m" |tee -a $upgrade_log
    elif [ -e "$datadir/$proc" -a ! -e "$packdir/yshd_game.zip" ]; then
        echo -e "\033[35m \033[1m              注意:yshd_game.zip 更新包未上传到服务器,请上传程序包哦\033[0m" |tee -a $upgrade_log
    elif [ ! -e "$datadir/$proc" -a ! -e "$packdir/yshd_game.zip" ]; then
        echo -e "\033[35m \033[1m              注意:yshd_game.zip 更新包未上传到服务器,请上传程序包哦\033[0m" |tee -a $upgrade_log
        echo -e "\033[35m \033[1m                   服务器进程文件\"$proc\"不存在，可能已移除或删除了哦\033[0m" |tee -a $upgrade_log
    fi

fi
}

function restart_srv(){
#重启服务器
clear
echo -e "\033[33m \033[1m              登陆用户：$(logname)  操作时间：`date +%F\ %T` \033[0m" | tee -a $restart_log
if [ $RETVAL = "running" ];then
  sudo docker exec $process kill -2 $PID 2>&1 | tee -a $restart_log
else
  sudo docker restart $process 2>&1 | tee -a $restart_log
fi
countdown
if [ $RETVAL = "running" ];then
  echo -e "\033[32m \033[1m                       服务器重启完成\033[0m" | tee -a $restart_log
else
  echo -e "\033[32m\033[1m                        服务器重启失败,请排除故障再运行restart\033[0m" | tee -a $restart_log
fi
}

function sure_1(){
#确认操作函数
while true :
do
  read -r -p "你确定吗(Are You Sure)[y/N]: " input
  case $input in
   [yY][eE][sS]|[yY])
    upgrade_srv
    break
    ;;

   [nN][oO]|[nN])
    exit 1
    break
    ;;

   *)
    echo "invalid input..."
    ;;

  esac
done
}

function sure_2(){
#确认操作函数
while true :
do
  read -r -p "你确定吗(Are You Sure)[y/N]: " input
  case $input in
   [yY][eE][sS]|[yY])
    restart_srv
    break
    ;;

   [nN][oO]|[nN])
    exit 1
    break
    ;;

   *)
    echo "invalid input..."
    ;;

  esac
done
}

function main(){
#主函数
while :
do
trapper
clear
cat << menu
       ----------------------------------------------
      |                                              |
      |      1.  升级服务器 [Upgrade Server]         |
      |      2.  重启服务器 [Restart Server]         |
      |      3.  退出 [ByeBye]                       |
      |                                              |
       ----------------------------------------------
menu
read -p "请输入对应的序号(Please Enter The Numbers): " num
echo ""
case $num in
  1)
  sure_1
  break
  ;;

  2)
  sure_2
  break
  ;;

  3)
  exit 3
  ;;

  *)
  echo "invalid input..."
 esac
done
}

main
