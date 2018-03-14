#!/bin/bash
docker run --restart=always --name mysql-master -p 3307:3306 -v /usr/local/mysql/data:/var/lib/mysql -v /usr/local/mysql/conf:/etc/mysql/conf.d  -e MYS_ROOT_PASSWORD=Passwd2017 -d bug-mysql-backup
