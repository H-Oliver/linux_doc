#!/bin/sh
log=/var/log/h5_daily.log
echo "" > $log
echo "-----------------------at time: `date`-----------------------" >> $log
echo "" >> $log
/bin/curl -s http://localhost/gameshare/index.php?s=DailyData/dailyDataAdd 2>&1 >> $log
/bin/curl -s http://localhost/gameshare/index.php?s=DailyData/updateChannelKeep 2>&1 >> $log
