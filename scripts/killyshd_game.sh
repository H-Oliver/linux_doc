#!/bin/bash
sudo kill -2 `ps aux |grep -w yshd_game |grep -v grep |awk '{print $2}'` > /dev/null  2>&1

