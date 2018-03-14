Shell跳板机案例。要求用户登录到跳板机仅能执行管理员给定的选项动作，不允许以任何形式中断脚本到跳板机服务器上执行任何系统命令。

1）首先做好SSH密钥验证（跳板机地址192.168.33.128）。
以下操作命令在所有机器上操作：

[root@oldboy~]# useradd jump  #<==要在所有机器上操作。
[root@oldboy~]# echo 123456|passwd --stdin jump #<==要在所有机器上操作。
Changingpassword for user jump.
passwd:all authentication tokens updated successfully.
以下操作命令仅在跳板机上操作：

[root@oldboy~]# su - jump
[jump@oldboy~]$ ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa >/dev/null 2>&1  #<==生成密钥对。
[jump@oldboy~]$ ssh-copy-id -i ~/.ssh/id_dsa.pub 192.168.33.130   #<==将公钥分发到其他服务器。
Theauthenticity of host '192.168.33.130 (192.168.33.130)' can't be established.
RSA keyfingerprint is fd:2c:0b:81:b0:95:c3:33:c1:45:6a:1c:16:2f:b3:9a.
Are yousure you want to continue connecting (yes/no)? yes
Warning:Permanently added '192.168.33.130' (RSA) to the list of known hosts.
jump@192.168.33.130'spassword:
Now trylogging into the machine, with "ssh '192.168.33.130'", and check in:
  
  .ssh/authorized_keys
  
to makesure we haven't added extra keys that you weren't expecting.
  
[jump@oldboy~]$ ssh-copy-id -i ~/.ssh/id_dsa.pub 192.168.33.129  #<==将公钥分发到其他服务器。
Theauthenticity of host '192.168.33.129 (192.168.33.129)' can't be established.
RSA keyfingerprint is fd:2c:0b:81:b0:95:c3:33:c1:45:6a:1c:16:2f:b3:9a.
Are yousure you want to continue connecting (yes/no)? yes
Warning:Permanently added '192.168.33.129' (RSA) to the list of known hosts.
jump@192.168.33.129'spassword:
Now trylogging into the machine, with "ssh '192.168.33.129'", and check in:
  
  .ssh/authorized_keys
  
to makesure we haven't added extra keys that you weren't expecting.
2）实现传统的远程连接菜单选择脚本。
菜单脚本如下：
                cat <<menu
                  1)web01-192.168.33.129
                  2)web02-192.168.33.130
                  3)exit
menu
3）利用linux信号防止用户中断信号在跳板机上操作。

functiontrapper () {
        trap ':' INT  EXIT TSTP TERM HUP  #<==屏蔽这些信号。
}
4）用户登录跳板机后即调用脚本（不能命令行管理跳板机），并只能按管理员的要求选单。
以下为实战内容。
脚本放在跳板机上：

[root@oldboy~]# echo '[ $UID -ne 0 ] && . /server/scripts/jump.sh'>/etc/profile.d/jump.sh  
[root@oldboy~]# cat /etc/profile.d/jump.sh
[ $UID-ne 0 ] && . /server/scripts/jump.sh
[root@oldboyscripts]# cat /server/scripts/jump.sh

#!/bin/sh
#oldboy training
trapper(){
    trap ':' INT EXIT TSTP TERM HUP  #<==定义需要屏蔽的信号，冒号表示啥都不做。
}
main(){
while :
do
      trapper
      clear
      cat<<menu
       1)Web01-192.168.33.129
       2)Web02-192.168.33.130
menu
read -p"Pls input a num.:" num
case"$num" in
    1)
        echo 'login in 192.168.33.129.'
        ssh 192.168.33.129
        ;;
    2)
        echo 'login in 192.168.33.130.'
        ssh 192.168.33.130
        ;;
    110)
        read -p "your birthday:" char
        if [ "$char" = "0926"];then
          exit
          sleep 3
        fi
        ;;
    *)
        echo "select error."
        esac
done
}
main
执行效果如下：

[root@oldboy~]# su - jump  #<==切到普通用户即弹出菜单，工作中直接用jump登录，即弹出菜单。
     1)Web01-192.168.33.129
     2)Web02-192.168.33.130
Pls inputa num.:
     1)Web01-192.168.33.129
     2)Web02-192.168.33.130
Pls inputa num.:1  #<==选1进入Web01服务器。
login in192.168.33.129.
Lastlogin: Tue Oct 11 17:23:52 2016 from 192.168.33.128
[jump@littleboy~]$  #<==按ctrl+d退出到跳板机服务器再次弹出菜单。
     1)Web01-192.168.33.129
     2)Web02-192.168.33.130
Pls inputa num.:2     #<==选2进入Web02服务器。
login in192.168.33.130.
Lastlogin: Wed Oct 12 23:30:14 2016 from 192.168.33.128
[jump@oldgirl~]$   #<==按ctrl+d退出到跳板机服务器再次弹出菜单。
     1)Web01-192.168.33.129
    2)Web02-192.168.33.130
Pls inputa num.:110    #<==选110进入跳板机命令提示符。
yourbirthday:0926      #<==需要输入特别码才能进入的，这里管理员通道，密码要保密呦。
[root@oldboyscripts]#  #<==跳板机管理命令行。