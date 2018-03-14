#!/bin/bash
/bin/mysqldump -ubakuser -pbakpassword -h127.0.0.1 --all-databases > /mysqlbak/all-$(date +%y%m%d).sql
