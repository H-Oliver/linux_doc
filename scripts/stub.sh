#netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
#awk '{print $1,$4}' /usr/local/nginx/logs/go_access.log |sort |uniq -c 
#!/bin/bash
cat /usr/local/nginx/logs/go_access.log |sed -rn '/28\/Jan\/2015/p' > a.txt 
#统计a.txt里面有多少个ip访问
cat a.txt |awk '{print $1}'|sort |uniq > ipnum.txt
#通过shell统计每个ip访问次数
for i in `cat ipnum.txt`
do 
iptj=`cat /usr/local/nginx/logs/go_access.log |grep $i | grep -v 400 |wc -l`
echo "ip地址"$i"在2015-01-28日全天(24小时)累计成功请求"$iptj"次，平均每分钟请求次数为："$(($iptj/1440)) >> result.txt
done
