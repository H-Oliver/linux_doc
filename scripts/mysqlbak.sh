#!/bin/bash
backupdir=/mysqlbak
time=_` date +%y%m%d%H%M%S `
db_name=all
db_name1=mygo
db_name2=easyui
db_name3=info
db_name4=games
db_name5=faxian
db_name6=games_temp
db_user=bakuser
db_pass=bakpassword
db_ip=127.0.0.1
#db_backup_parameter= --single-transaction --flush-logs --master-data=2 --opt --default-character-set=utf8mb4 --routines --triggers

/bin/mysqldump -u$db_user -p$db_pass -h$db_ip --databases $db_name1 --single-transaction --flush-logs --master-data=2 --opt --default-character-set=utf8mb4 --routines --triggers > /$backupdir/$db_name1$time.sql
#/bin/mysqldump -u$db_user -p$db_pass -h$db_ip --databases $db_name2 --single-transaction --flush-logs --master-data=2 --opt --default-character-set=utf8mb4 --routines --triggers > /$backupdir/$db_name2$time.sql
#/bin/mysqldump -u$db_user -p$db_pass -h$db_ip --databases $db_name3 --single-transaction --flush-logs --master-data=2 --opt --default-character-set=utf8mb4 --routines --triggers > /$backupdir/$db_name3$time.sql
/bin/mysqldump -u$db_user -p$db_pass -h$db_ip --databases $db_name4 --single-transaction --flush-logs --master-data=2 --opt --default-character-set=utf8mb4 --routines --triggers > /$backupdir/$db_name4$time.sql
/bin/mysqldump -u$db_user -p$db_pass -h$db_ip --databases $db_name6 --single-transaction --flush-logs --master-data=2 --opt --default-character-set=utf8mb4 --routines --triggers > /$backupdir/$db_name6$time.sql
#/bin/mysqldump -u$db_user -p$db_pass -h$db_ip --all-databases > /$backupdir/$db_name$time.sql
find $backupdir -name "*.sql" -type f -atime +30 -exec rm -rf {} \; >/dev/null 2>&1
