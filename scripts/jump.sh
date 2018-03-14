#!/bin/bash

trapper(){
  trap ':' INT EXIT TSTP TERM HUP
}

account_1(){
clear
echo -e ""
echo -ne "\033[35m \033[1m正在登陆服务器，请输入用户名:\033[0m "
read username
  echo "$username login server."
  clear
  ssh $username@120.76.96.73
}

account_4(){
clear
echo -e ""
echo -ne "\033[35m \033[1m正在登陆服务器，请输入用户名:\033[0m "
read username
  echo "$username login server."
  clear
  ssh $username@120.76.156.177
}

account_911(){
    echo -e ""
    echo -e "\033[35m\033[1m正在进入到跳板机，请按提示输入管理员用户名和密码\033[0m"
    echo -e ""
    read -p "请输入跳板机管理用户：" user
    stty -echo
    read -p "请输入跳板机管理密码：" password
    stty echo
    echo ""
    line=`cat /tmp/passwd | base64 -d`
    if [ "$user" = "admin" -a "$password" = "$line" ];then
      break
      sleep 3
    fi
}

main(){
while :
do
  trapper
  clear
  cat << menu
    ----------------------------------------------------------------
    |            欢迎使用跳板机平台                                |
    |                                                              | 
    |       1.  server001 -- 120.76.96.73                          |
    |       2.  server002 --                                       |
    |       3.  server003 --                                       |
    |       4.  server004 -- 120.76.156.177                        |
    |                                                              | 
    ----------------------------------------------------------------
menu

read -p "请选择需要登陆的服务器: " num
case "$num" in
  1)
    account_1
    ;;
  4)
    account_4
    ;;
  911)
    account_911
    ;;
  *)
    echo "select error."
esac
done
}

main
