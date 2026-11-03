#### Домашнее задание
1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/default).
2. Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта (https://gist.github.com/cea2k/1318020).
3. Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно.

##### 1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова

```
root@Ubuntu2404-server:~# cat << 'EOF' > /etc/default/watchlog
# Configuration file for my watchlog service
# Place it to /etc/default

# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
```

```
root@Ubuntu2404-server:~# cat /var/log/watchlog.log
INFO Reading configuration from:
ALERT WARN Either no config or no quorum defined in config
INFO Created server with tickTime 3000 minSessionTimeout 6000
ERROR Selector failed to open
```


```
root@Ubuntu2404-server:~# cat << 'EOF' > /opt/watchlog.sh
> #!/bin/bash
> WORD=$1
> LOG=$2
> DATE=`date`
>
> if grep "$WORD" "$LOG" &> /dev/null
> then
>     logger "$DATE: I found word, Master!"
> else
>     exit 0
> fi
> EOF
```
```
root@Ubuntu2404-server:~# chmod +x /opt/watchlog.sh
```



```
root@Ubuntu2404-server:~# cat << 'EOF' > /etc/systemd/system/watchlog.service
> [Unit]
> Description=My watchlog service
> [Service]
> Type=oneshot
> EnvironmentFile=/etc/default/watchlog
> ExecStart=/opt/watchlog.sh $WORD $LOG
> EOF
```

```
cat << 'EOF' >  /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second
[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service
[Install]
WantedBy=multi-user.target
EOF
```
```
root@Ubuntu2404-server:~# systemctl start watchlog.service
root@Ubuntu2404-server:~# systemctl status watchlog.timer
● watchlog.timer - Run watchlog script every 30 second
     Loaded: loaded (/etc/systemd/system/watchlog.timer; disabled; preset: enabled)
     Active: active (waiting) since Sat 2026-10-31 13:44:53 UTC; 2min 19s ago
    Trigger: Sat 2026-10-31 13:47:34 UTC; 21s left
   Triggers: ● watchlog.service

Oct 31 13:44:53 Ubuntu2404-server systemd[1]: Started watchlog.timer - Run watchlo>
```


```
root@Ubuntu2404-server:~# tail -n 10 /var/log/syslog  | grep word
2026-10-31T13:52:05.204354+00:00 Ubuntu2404-server root: Sat Oct 31 01:52:05 PM UTC 2026: I found word, Master!
2026-10-31T13:52:45.211617+00:00 Ubuntu2404-server root: Sat Oct 31 01:52:45 PM UTC 2026: I found word, Master!
```

##### 2. Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта
```
root@Ubuntu2404-server:~# apt install spawn-fcgi php php-cgi php-cli  apache2 libapache2-mod-fcgid -y
```
```
root@Ubuntu2404-server:~# cat << 'EOF' > /etc/default/spawn-fcgi                   # Конфигурация для spawn-fcgi
FCGI_SOCKET=/var/run/php-fcgi.sock
FCGI_PROGRAM=/usr/bin/php-cgi
FCGI_USER=www-data
FCGI_GROUP=www-data
FCGI_CHILDREN=32
OPTIONS="-s $FCGI_SOCKET -f $FCGI_PROGRAM -u $FCGI_USER -g $FCGI_GROUP -C $FCGI_CHILDREN"
EOF
```
```
root@Ubuntu2404-server:~# cat << 'EOF' > /etc/systemd/system/spawn-fcgi.service   
[Unit]
Description=Spawn-fcgi startup service by Otus                                     
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/spawn-fcgi/fcgi.conf
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
```
```
root@Ubuntu2404-server:~# systemctl start spawn-fcgi
```
Проверка результатов:

```
root@Ubuntu2404-server:~# systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
     Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; preset: ena>
     Active: active (running) since Sat 2026-10-31 14:26:34 UTC; 11s ago
   Main PID: 8716 (php-cgi)
      Tasks: 33 (limit: 9419)
     Memory: 14.4M (peak: 14.5M)
        CPU: 18ms
     CGroup: /system.slice/spawn-fcgi.service
```

