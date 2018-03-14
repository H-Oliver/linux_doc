1.创建service数据文件夹
mkdir -p /opt/17wan/

setfacl -R -m u::rwx /opt/17wan
setfacl -R -m g::rwx /opt/17wan
setfacl -R -m o::rwx /opt/17wan
setfacl -d --set u::rwx /opt/17wan
setfacl -d --set g::rwx /opt/17wan
setfacl -d --set o::rwx /opt/17wan

2.创建dockerfile
cd /opt/17wan
tee Dockerfile <<EOF
FROM golang:latest
MAINTAINER server <server@shangtv.cn>

ENV TZ "Asia/Shanghai"

RUN mkdir -p /go/src/17wan
WORKDIR /go/src/17wan/
ADD config.ini /go/src/17wan
ADD yshd_game /go/src/17wan
ADD localtime /etc/localtime


RUN 
ADD supervisor_go.conf /etc/supervisor.conf.d/17wan-service.conf

RUN chmod 777 -R /go/src/17wan
volume ["/go/src/17wan"]
ENV PORT 3000
EXPOSE 3000

CMD ["nohup","/go/src/17wan/yshd_game","&"]
#ENTRYPOINT ["nohup","/go/src/17wan/yshd_game","&"]
EOF

3.编译docker images

dockcer build -t 17wanserver .

4.启动goweb容器

docker run -tid \
--name 17wan-1 \
--restart=always \
-p 3001:3000 \
--privileged=true \
-v /opt/17wan:/go/src/17wan \
-v /opt/17wan/images_1:/go/src/17wan/images
17wanserver

docker run -tid \
--name 17wan-1 \
--restart=always \
-p 3002:3000 \
--privileged=true \
-v /opt/17wan/:/go/src/17wan \
-v /opt/17wan/images_2:/go/src/17wan/images
17wanserver