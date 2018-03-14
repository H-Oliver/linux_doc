tail -100f /usr/local/nginx/logs/go_access.log | awk '{print $1}' | uniq -c | nali
