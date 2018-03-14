#!/bin/bash
time=` date +%F `
log_file="/var/log/supervisord.log"
for target in $log_file
do
  file=`basename $target`
  basedir=`dirname $target`
  cd $basedir
  #echo $basedir/$file
  cat $file >> $file.$time
  cat /dev/null > $file
  /usr/bin/find $basedir -name "$file.*" -type f -atime +7 -delete
done
