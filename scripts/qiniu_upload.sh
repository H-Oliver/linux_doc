#!/bin/bash
#Description:此脚本用于七牛头像的压缩更新，需要结合七牛的QSunSync工具覆盖上传

#Tools：dos2unix,wget,curl,imagemagick（convert）

#Author:oliver

#CreateTime:2017-8-14 17:16:28

# END INFO

urlText=/tmp/sqlvalue
dirname=/usr/local/src
quality=80


function download() {

#test sql
#mycli -u17testuser -p123456 -ht1.shangtv.cn -P3307 -D 17test -e \
#	"select image from php_anchor as p \
#	left join go_user as u on u.uid = p.uid  \
#	where p.uid not between 1 and 100 and u.image like 'http://face.17playlive.com%'" > $urlText

#pro sql
mycli -ugameuser -ptv#shangtv2017 -hshangtv.cn -P3306 -D games_temp -e \
	"select image from php_anchor as p \
	left join go_user as u on u.uid = p.uid  \
	where p.uid not between 1 and 100 and u.image like 'http://face.17playlive.com%'" > $urlText

#文件格式转换
dos2unix $urlText $urlText

#删除第一行内容
sed -i '1d' $urlText

#从文件获取内容
for url in `cat $urlText`
do
   wget -P $dirname $url
   ext=`curl -Is $url |grep "Content-Type:" |awk -F [': '] '{print $3}'`
   echo $ext
   filename=`echo "$url" |awk -F ['/'] '{print $4}'`
   echo $filename
   if [[ "$ext" =~ "png" ]] || [[ "$ext" =~ "image/png" ]]; then
     mv $dirname/$filename $dirname/$filename.png
   elif [[ "$ext" =~ "jpeg" ]] || [[ "$ext" =~ "image/jpeg" ]]; then
     mv $dirname/$filename $dirname/$filename.jpeg
   else
     echo "File mimetype error"
   fi

done
}

function compress() {
dirname=$1
for file_png in $dirname/*.png;
do
  convert  -quality "$quality" "$file_png" "${file_png%.png}.jpeg"
  rm -rf $file_png
done
}

function rename() {

for file in `find "$dirname" -name "*.jpeg"`
do
  mv $file ${file%.*}
done

}

#执行download
download

#执行compress
compress "$dirname"

#执行rename
rename

exit 0
