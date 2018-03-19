#!/bin/sh 
# __author__ = 'oliver'

# This script is used by fast installed lnmp ......
# write by 2018/03/19

mkdir /software
cd /software/

#config firewall
yum install -y iptables-*
systemctl stop firewalld.service 
systemctl disable firewalld.service

#disable selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0

######start install nginx######
echo '######start install nginx######'
useradd www -s /sbin/nologin
yum -y install pcre pcre-devel zlib zlib-devel gcc-c++ gcc openssl*
tar zxvf nginx-1.12.0.tar.gz 
cd nginx-1.12.0/
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_realip_module --with-http_sub_module --with-http_gzip_static_module --with-http_stub_status_module  --with-pcre
make && make install
sleep 2
ln -s /usr/local/nginx/sbin/nginx /sbin/nginx
cat >> /usr/lib/systemd/system/nginx.service << EOF
[Unit]
Description=nginx - high performance web server
Documentation=http://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
 
[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=//usr/sbin/nginx -s reload
ExecStop=/usr/sbin/nginx -s stop
PrivateTmp=true
 
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload 
systemctl start nginx
systemctl enable nginx
systemctl status nginx
sleep 2
echo '######nginx is install completed done.######'


###### start install mysql ######
cd /software/
yum -y install ncurses ncurses-devel bison cmake gcc gcc-c++
groupadd mysql
useradd -s /sbin/nologin -g mysql mysql -M
id mysql
chown -R mysql.mysql /usr/local/mysql
tar zxvf mysql-boost-5.7.18.tar.gz 
cd mysql-5.7.18/
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_UNIX_ADDR=/usr/local/mysql/mysql.sock -DSYSCONFDIR=/usr/local/mysql/etc -DSYSTEMD_PID_DIR=/usr/local/mysql -DDEFAULT_CHARSET=utf8  -DDEFAULT_COLLATION=utf8_general_ci -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_PERFSCHEMA_STORAGE_ENGINE=1 -DMYSQL_DATADIR=/usr/local/mysql/data -DWITH_BOOST=boost -DWITH_SYSTEMD=1
sleep 1
make && make install
sleep 2
chown -R mysql.mysql /usr/local/mysql/
cd /usr/local/mysql/
echo '######create my.cnf######'
cat >> my.cnf << EOF
[client]
port = 3306
default-character-set=utf8mb4
socket = /usr/local/mysql/mysql.sock
 
[mysql]
port = 3306
default-character-set=utf8mb4
socket = /usr/local/mysql/mysql.sock

[mysqld]
user = mysql
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data
port = 3306
default-character-set=utf8
pid-file = /usr/local/mysql/mysqld.pid
socket = /usr/local/mysql/mysql.sock
server-id = 1

# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M 

sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
EOF

chown mysql.mysql my.cnf
echo 'PATH=/usr/local/mysql/bin:/usr/local/mysql/lib:$PATH' >> /etc/profile
echo 'export PATH' >> /etc/profile
source /etc/profile
bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
cp usr/lib/systemd/system/mysqld.service /usr/lib/systemd/system/
systemctl daemon-reload 
systemctl start mysqld
systemctl enable mysqld
ps -ef|grep mysql
systemctl status mysqld
echo '######mysql is install completed done.######'


###### start install php ######
cd /software
tar zxvf php-7.1.4.tar.gz
cd php-7.1.4/
./configure --help
yum -y install libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel curl curl-devel openssl openssl-devel
#./configure --prefix=/usr/local/php --enable-fpm --with-fpm-user=nginx --with-fpm-group=nginx --with-mysqli --with-zlib --with-curl --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --with-openssl --enable-mbstring --enable-xml --enable-session --enable-ftp --enable-pdo -enable-tokenizer --enable-zip
./configure --prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--enable-mysqlnd \
--with-mysql=shared,mysqlnd \
--with-mysqli=shared,mysqlnd \
--with-pdo-mysql=shared,mysqlnd \
--with-mysql-sock=/var/lib/mysql/mysql.sock \
--with-mysqli=/usr/bin/mysql_config \
--with-gd \
--with-png-dir \
--with-jpeg-dir \
--with-freetype-dir \
--with-xpm-dir \
--with-zlib-dir \
--with-iconv \
--enable-fpm \
--with-fpm-user=nginx \
--with-fpm-group=nginx \
--enable-libxml \
--enable-xml \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--enable-opcache \
--enable-mbregex \
--enable-mbstring \
--enable-ftp \
--enable-gd-native-ttf \
--with-openssl \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--without-pear \
--with-gettext \
--enable-session \
--with-mcrypt \
--with-curl \
--enable-exif \
--with-mhash \
--enable-ctype
sleep 1
make && make install
sleep 2
cp php.ini-development /usr/local/php/lib/php.ini
grep mysqli.default_socket  /usr/local/php/lib/php.ini
sed -i 's#mysqli.default_socket =#mysqli.default_socket = /usr/local/mysql/mysql.sock#'  /usr/local/php/lib/php.ini
grep mysqli.default_socket  /usr/local/php/lib/php.ini
grep date.timezone /usr/local/php/lib/php.ini
sed -i 's#;date.timezone =#date.timezone = Asia/Shanghai#' /usr/local/php/lib/php.ini
grep date.timezone /usr/local/php/lib/php.ini
/usr/local/php/bin/php -v
/usr/local/php/bin/php -m
cp /usr/local/php/etc/php-fpm.conf.default
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
grep -E 'user =|group =' /usr/local/php/etc/php-fpm.d/www.conf
sed -i 's#user = nginx#user = www#' /usr/local/php/etc/php-fpm.d/www.conf
sed -i 's#group = nginx#group = www#' /usr/local/php/etc/php-fpm.d/www.conf 
grep -E 'user =|group =' /usr/local/php/etc/php-fpm.d/www.conf
cp sapi/fpm/php-fpm.service /usr/lib/systemd/system/
grep -E 'PIDFile|ExecStart' /usr/lib/systemd/system/php-fpm.service
systemctl daemon-reload
systemctl enable php-fpm
systemctl start php-fpm
systemctl status php-fpm
echo '######php is install completed done.######'

####### create test.com file used by test lnmp config is correct or incorrect ######
cat >> /usr/local/nginx/html/test.php << EOF
<?php
phpinfo();
EOF
cd /usr/local/nginx/conf
sed -i '$i\include /usr/local/nginx/conf/conf.d/*;' nginx.conf
mkdir conf.d
cd conf.d/
echo '######create test.com.conf site file######'
cat >> test.com.conf <<EOF
server {
    listen       80;
    server_name  localhost;
    root         html;
    index  test.php;
location ~*.*\.(php|php5|php7)$ {
            include        fastcgi_params;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        }
}
EOF
systemctl reload nginx
systemctl reload php-fpm
sleep 2
echo '######LNMP is install completed done.######'
echo '######please Open the similar "172.17.11.186" to Visit the test.######'