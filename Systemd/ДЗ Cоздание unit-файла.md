#### Домашнее задание
1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/default).
2. Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта (https://gist.github.com/cea2k/1318020).
3. Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно.

1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова

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
