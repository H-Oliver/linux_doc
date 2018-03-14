#!/bin/bash
date=` date -d "yesterday" +"%F"`
log_file=/var/log/supervisord.log.$date
mail="oliver@shangtv.cn,will@shangtv.cn,cart@shangtv.cn,sky@shangtv.cn,beard@shangtv.cn"
mail1="oliver@shangtv.cn"
#echo $log_file

if [ ! -e $log_file ]
then
  echo "" | mail -s "Supervisord log日志文件不存在" $mail1
else
  erro_time=`less $log_file | egrep 'terminated by SIGABRT|exit status 2' | awk -F "[ ,]" '{print $1,$2,$6,$5}'`
  erro_num=`less $log_file | egrep 'terminated by SIGABRT|exit status 2' | wc -l`
   if [ $erro_num -gt 0 ]
   then
     text="$date 服务器总奔溃次数: $erro_num\n\n ---------服务器进程奔溃时间统计如下---------\n\n $erro_time"
     #echo "$text"
     echo -e "$text" | mail -s "服务器奔溃昨日统计报表" $mail
   fi
fi
