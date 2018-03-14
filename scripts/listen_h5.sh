#!/bin/sh
echo "" >/var/log/h5.log
echo "-----------------------at time: `date`-----------------------" >>/var/log/h5.log
echo "" >>/var/log/h5.log
/bin/curl -s http://localhost/gameshare/index.php?s=CashRecord/auto_apply >> /var/log/h5.log
