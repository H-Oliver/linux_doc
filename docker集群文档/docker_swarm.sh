#!/bin/bash
#添加docker安装源
tee /etc/yum.repos.d/docker.repo<<EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

#安装docker

yum install docker-engine -y

#配置防火墙，默认采用firewall,可以修改成iptables

firewall-cmd --permanent --add-port={2375/tcp,3375/tcp,8500/tcp,8300/tcp,8301/tcp,8301/udp,8302/tcp,8302/udp,8400/tcp,8500/tcp,8600/tcp,8600/udp,8080/tcp,28015/tcp,29015/tcp}
firewall-cmd --reload
firewall-cmd --list-all

#增加tcp监听端口，并配置docker加速
sed -i 's/ExecStart=.*/ExecStart=\/usr\/bin\/dockerd -H unix\:\/\/\/var\/run\/docker.sock -D -H tcp\:\/\/0.0.0.0\:2375 --registry-mirror=https\:\/\/0xl18ug0.mirror.aliyuncs.com/g' /lib/systemd/system/docker.service

#重启docker
systemctl enable docker.service
systemctl restart docker.service
ps -ef |grep docker

#安装pip以及docker api
yum -y install epel-release
yum -y install python-pip
pip install docker-py docker-compose

#创建consul用户以及用户组
groupadd consul
useradd -g consul consul -s /bin/false

#创建consul数据存储文件夹
mkdir -p /opt/consul/{data,conf}
chown -R consul: /opt/consul

#设置服务器hosts文件，把cluster中的主机都要写入文件
echo "192.168.1.14    master.localhost.com" >> /etc/hosts
echo "192.168.1.15    slave1.localhost.com" >> /etc/hosts
echo "192.168.1.16    slave2.localhost.com" >> /etc/hosts
echo "192.168.1.17    slave3.localhost.com" >> /etc/hosts

ping master.localhost.com -c 2

#配置consul cluster
#拉取consul镜像
docker pull progrium/consul

#启动consul master server
#启动consul client
docker run -d \
-p 8300:8300 \
-p 8301:8301 \
-p 8301:8301/udp \
-p 8302:8302 \
-p 8302:8302/udp \
-p 8400:8400 \
-p 8500:8500 \
-p 8600:53 \
-p 8600:53/udp \
-v /opt/consul/data:/data \
-h $HOSTNAME \
--restart=always \
--name=consul-c2 \
progrium/consul \
-advertise 192.168.1.17 -join 192.168.1.14

#registrator状态获取
#slave

docker run -d \
--restart=always \
--name=registrator \
--net=host \
-v /var/run/docker.sock:/tmp/docker.sock \
gliderlabs/registrator \
-ip 192.168.1.17 \
consul://192.168.1.17:8500

#安装shipyard,swarm
#master

#安装swarm-agent
#slave

docker run -tid \
--restart=always \
--name shipyard-swarm-agent \
swarm:latest \
join --addr 192.168.1.17:2375 consul://192.168.1.14:8500
