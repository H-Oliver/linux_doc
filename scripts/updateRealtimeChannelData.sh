#!/bin/sh
log=/var/log/Realtime.log
echo "" > $log
echo "-----------------------at time: `date`-----------------------" >> $log
echo "" >> $log
/bin/curl -s http://localhost/gameshare/index.php?s=DailyData/updateRealtimeChannelData 2>&1 >> $log
