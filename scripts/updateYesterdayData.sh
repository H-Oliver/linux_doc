#!/bin/sh
log=/var/log/h5_yesterday.log
echo "" > $log
echo "-----------------------at time: `date`-----------------------" >> $log
echo "" >> $log
/bin/curl -s http://localhost/gameshare/index.php?s=DailyData/updateYesterdayData 2>&1 >> $log
