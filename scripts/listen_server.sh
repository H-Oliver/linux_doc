#!/bin/sh
proc=/data/niuniu/yshd_game
mail="oliver@shangtv.cn,will@shangtv.cn,cart@shangtv.cn,sky@shangtv.cn,beard@shangtv.cn"
mail1="oliver@shangtv.cn"
while true
do
    procnum=`ps aux |grep $proc |grep -v grep |wc -l`
    if [ "$procnum" -eq "0" ];then
        text="--------`date +%F\ %T`---------\n 服务器奔溃，请排查故障\n 服务器奔溃，请排查故障\n 服务器奔溃，请排查故障\n \n重要的事说三遍"
        echo -e "$text" | mail -s "【重要】YSHD_GAME服务器奔溃，请排查故障!!!" $mail
    fi
    sleep 2
done
