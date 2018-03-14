#!/bin/bash
echo --------------------LNMP Install--By OLiver----------------------------

# 关闭firewall：
# systemctl stop firewalld.service #停止firewall
# systemctl disable firewalld.service #禁止firewall开机启动
# 安装iptables防火墙
# yum install iptables-services #安装
# vi /etc/sysconfig/iptables #编辑防火墙配置文件
# systemctl restart iptables.service #最后重启防火墙使配置生效
# systemctl enable iptables.service #设置防火墙开机启动


useradd shangtv
passwd shangtv
#setting MariaDB yum
cat > /etc/yum.repos.d/mariadb.repo <<EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1.10/centos7-amd64
gpgkey = https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck = 1
EOF


yum clean all
yum makecache

#install Development tools
#yum -y groupinstall "Development Tools"

yum install -y libxml2 libxml2-devel libcrul libcurl-devel gd gd-devel libpng libpng-devel wget apr* autoconf automake bison bzip2 bzip2* cloog-ppl compat* cpp curl curl-devel fontconfig fontconfig-devel freetype freetype* freetype-devel gcc gcc-c++ gtk+-devel gd gettext gettext-devel glibc kernel kernel-headers keyutils keyutils-libs-devel krb5-devel libcom_err-devel libpng libpng-devel libjpeg* libsepol-devel libselinux-devel libstdc++-devel libtool* libgomp libxml2 libxml2-devel libXpm* libtiff libtiff* make mpfr ncurses* ntp openssl openssl-devel patch pcre pcre-devel perl php-common php-gd policycoreutils telnet t1lib t1lib* nasm nasm* zlib-devel gd-devel
#install mariadb
yum -y install MariaDB-*

#download packger
cd /usr/local/src
wget -ct 5 http://nchc.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
wget -ct 5 http://www.openssl.org/source/openssl-1.0.1i.tar.gz


#start MariaDB
service mysql start


#setting mariadb
mysql_secure_installation

mkdir /usr/local/php

mkdir /usr/local/nginx


#install libmcrypt
cd /usr/local/src
wget http://www.atomicorp.com/installers/atomic
chmod +x atomic
./atomic
yum -y install php-mcrypt libmcrypt libmcrypt-devel

#install php
cd /usr/local/src
wget http://cn2.php.net/distributions/php-7.0.5.tar.gz
tar zxvf php-7.0.5.tar.gz
cd php-7.0.5

groupadd php-fpm
useradd -g php-fpm php-fpm -s /bin/false
export LD_LIBRARY_PATH=/usr/local/libgd/lib

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
--with-fpm-user=php-fpm \
--with-fpm-group=php-fpm \
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

make && make install
cp /usr/local/src/php-7.0.5/php.ini-production /usr/local/php/etc/php.ini
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
mv /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
/usr/local/php/sbin/php-fpm -t
cp /usr/local/src/php-7.0.5/sapi/fpm/init.d.php-fpm /etc/rc.d/init.d/php-fpm
chmod +x /etc/rc.d/init.d/php-fpm
chkconfig php-fpm on

		  
echo 'export PATH=$PATH:/usr/local/php/bin' >> /etc/profile
source /etc/profile

#修改php配置文件
vim /usr/local/php/etc/php.ini

#找到"disable_functions =" （禁用掉某些比较“危险”函数，大概在305行），改为
disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,escapeshellcmd,dll,popen,disk_free_space,checkdnsrr,checkdnsrr,getservbyname,getservbyport,disk_total_space,posix_ctermid,posix_get_last_error,posix_getcwd, posix_getegid,posix_geteuid,posix_getgid, posix_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid, posix_getppid,posix_getpwnam,posix_getpwuid, posix_getrlimit, posix_getsid,posix_getuid,posix_isatty, posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid, posix_setpgid,posix_setsid,posix_setuid,posix_strerror,posix_times,posix_ttyname,posix_uname
 
#disable_functions = phpinfo,eval,passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_alter,ini_restore,dl,pfsockopen,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,fsockopen
#phpinfo,eval,passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_alter,ini_restore,dl,pfsockopen,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,fsockopen

#找到";date.timezone ="（大概在913行），修改为date.timezone = Asia/Shanghai

#找到"expose_php = On"(禁止显示php版本的信息，大概在366行)，修改为
expose_php = Off 
 
#;找到"short_open_tag = Off"(支持php短标签，大概在202行)，修改为
short_open_tag = On 
 
#找到";opcache.enable=0"(支持opcode缓存，大概在1838行)，修改为
opcache.enable=1
 
#找到";opcache.enable_cli=0"(支持opcode缓存，大概在1841行)，修改为
opcache.enable_cli=0

#并在下面加入'zend_extension = "opcache.so"'一行,&nbsp;开启opcode缓存功能
zend_extension = "opcache.so"
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1

#支持pdo_mysql
extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20151012/pdo_mysql.so
#配置php-fpm
vim /usr/local/php/etc/php-fpm.conf
#取消pid前面的分号
pid = run/php-fpm.pid
#;...

vim /usr/local/php/etc/php-fpm.d/www.conf
#设置php-fpm运行账号为php-fpm
user = php-fpm
#设置php-fpm运行组为php-fpm
group = php-fpm

pm = dynamic

pm.max_children = 1000

pm.start_servers = 5

pm.min_spare_servers = 1

pm.max_spare_servers = 500

/etc/init.d/php-fpm restart



yum install -y pcre pcre-devel openssl openssl-devel

groupadd nginx
useradd -g nginx nginx -s /bin/false
mkdir /var/cache/nginx
cd /usr/local/src
wget http://nginx.org/download/nginx-1.9.14.tar.gz
wget http://nginx.org/download/nginx-1.11.7.tar.gz
wget http://nginx.org/download/nginx-1.13.8.tar.gz
# wget http://nginx.org/download/nginx-1.9.15.tar.gz
git clone https://github.com/miyanaga/nginx-requestkey-module.git
git clone https://github.com/arut/nginx-rtmp-module.git
# wget http://wiki.nginx.org/File:Nginx-accesskey-2.0.3.tar.gz
# git clone https://github.com/jieer/ngx_http_accesskey.git

#下载安装openssl
 cd /usr/local/src
wget https://www.openssl.org/source/openssl-1.1.0c.tar.gz
wget https://www.openssl.org/source/openssl-1.1.0g.tar.gz
tar -xvf openssl-1.1.0c.tar.gz
cd /usr/local/src/openssl-1.1.0c
./config --openssldir=/usr/local/ssl
make && make install
./config shared --openssldir=/usr/local/ssl
make clean
make && make install


tar zxvf nginx-1.9.14.tar.gz
cd nginx-1.9.14

# ./configure --prefix=/usr/local/nginx \
# --without-http_memcached_module \
# --user=nginx \
# --group=nginx \
# --with-http_stub_status_module \
# --with-http_ssl_module \
# --with-http_gzip_static_module \
# --with-http_dav_module \
# --with-http_random_index_module \
# --with-http_addition_module \
# --with-http_sub_module \
# --with-http_realip_module \
# --without-http_rewrite_module \
# --with-openssl \
# --with-zlib \
# --with-pcre \
# --add-module=/usr/local/src/nginx-requestkey-module \
# --add-module=/usr/local/src/nginx-rtmp-module/

#配置log和conf路径
./configure --prefix=/usr/local/nginx \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
--user=nginx \
--group=nginx \
--with-http_v2_module \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_auth_request_module \
--with-mail \
--with-mail_ssl_module \
--with-file-aio \
--with-ipv6 \
--with-http_v2_module \
--with-http_slice_module \
--with-threads \
--with-stream \
--with-stream_ssl_module \
--with-pcre=/usr/local/src/pcre-8.38 \
--with-openssl=/usr/local/src/openssl-1.1.0c \
--add-module=/usr/local/src/nginx-requestkey-module \
--add-module=/usr/local/src/nginx-rtmp-module/ \
--add-module=/usr/local/src/nginx_upstream_check_module-master/

==============================================================================

#通用.configure

./configure --prefix=/usr/local/nginx \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
--user=nginx \
--group=nginx \
--with-http_v2_module \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_auth_request_module \
--with-mail \
--with-mail_ssl_module \
--with-file-aio \
--with-ipv6 \
--with-http_v2_module \
--with-http_slice_module \
--with-threads \
--with-stream \
--with-stream_ssl_module \
--with-pcre=/usr/local/src/pcre-8.38 \
--add-module=/usr/local/src/nginx-requestkey-module \
--add-module=/usr/local/src/nginx-rtmp-module/ \
--add-module=/usr/local/src/nginx_upstream_check_module-master/ \
--with-openssl=/usr/local/src/openssl-1.1.0c \

===============================================================================

mkdir -pv /var/cache/nginx/{client_temp,proxy_temp,fastcgi_temp,uwsgi_temp,scgi_temp}

make && make install

echo >> /etc/rc.d/init.d/nginx <<EOF
#!/bin/sh
#
# nginx - this script starts and stops the nginx daemon
#
# chkconfig: - 85 15
# description: Nginx is an HTTP(S) server, HTTP(S) reverse \
# proxy and IMAP/POP3 proxy server
# processname: nginx
# config: /usr/local/nginx/conf/nginx.conf
# pidfile: /usr/local/nginx/logs/nginx.pid
 
# Source function library.
. /etc/rc.d/init.d/functions
 
# Source networking configuration.
. /etc/sysconfig/network
 
# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0
nginx="/usr/local/nginx/sbin/nginx"
prog=$(basename $nginx)
NGINX_CONF_FILE="/usr/local/nginx/conf/nginx.conf"
[ -f /etc/sysconfig/nginx ] && . /etc/sysconfig/nginx
lockfile=/var/lock/subsys/nginx
 
make_dirs() {
	# make required directories
	user=`$nginx -V 2>&1 | grep "configure arguments:" | sed 's/[^*]*--user=\([^ ]*\).*/\1/g' -`
	if [ -z "`grep $user /etc/passwd`" ]; then
	useradd -M -s /bin/nologin $user
	fi
	options=`$nginx -V 2>&1 | grep 'configure arguments:'`
	for opt in $options; do
	if [ `echo $opt | grep '.*-temp-path'` ]; then
	value=`echo $opt | cut -d "=" -f 2`
	if [ ! -d "$value" ]; then
	# echo "creating" $value
	mkdir -p $value && chown -R $user $value
	fi
	fi
	done
}
 
start() {
	[ -x $nginx ] || exit 5
	[ -f $NGINX_CONF_FILE ] || exit 6
	make_dirs
	echo -n $"Starting $prog: "
	daemon $nginx -c $NGINX_CONF_FILE
	retval=$?
	echo
	[ $retval -eq 0 ] && touch $lockfile
	return $retval
}
 
stop() {
	echo -n $"Stopping $prog: "
	killproc $prog -QUIT
	retval=$?
	echo
	[ $retval -eq 0 ] && rm -f $lockfile
	return $retval
}
 
restart() {
	#configtest || return $?
	stop
	sleep 1
	start
}
 
reload() {
	#configtest || return $?
	echo -n $"Reloading $prog: "
	killproc $nginx -HUP
	RETVAL=$?
	echo
}
 
force_reload() {
	restart
}
 
configtest() {
	$nginx -t -c $NGINX_CONF_FILE
}
 
rh_status() {
	status $prog
}
 
rh_status_q() {
	rh_status >/dev/null 2>&1
}
 
case "$1" in
start)
rh_status_q && exit 0
$1
;;
stop)
 
rh_status_q || exit 0
$1
;;
restart|configtest)
$1
;;
reload)
rh_status_q || exit 7
$1
;;
force-reload)
force_reload
;;
status)
rh_status
;;
condrestart|try-restart)
rh_status_q || exit 0
;;
*)
echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload|configtest}"
exit 2
esac
EOF

chmod 775 /etc/rc.d/init.d/nginx
chkconfig nginx on
/etc/rc.d/init.d/nginx start
echo 'export PATH=$PATH:/usr/local/nginx/sbin' >> /etc/profile
source /etc/profile






