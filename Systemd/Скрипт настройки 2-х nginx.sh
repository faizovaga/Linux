#!/bin/bash

# Скрипт автоматизации настройки двух независимых инстансов Nginx
# Запускать от имени root (sudo)

set -e # Остановить выполнение при любой ошибке

echo "=== 1. Остановка и отключение стандартного Nginx ==="
systemctl stop nginx || true
systemctl disable nginx || true

echo "=== 2. Создание файлов конфигурации Nginx ==="

# Конфигурация для первого инстанса (Порт 9001)
cat << 'EOF' > /etc/nginx/nginx-first.conf
pid /run/nginx-first.pid;
user www-data;
worker_processes auto;
error_log /var/log/nginx/error-first.log warn;

events {
    worker_connections 768;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log /var/log/nginx/access-first.log;
    sendfile on;
    types_hash_max_size 2048;

    server {
        listen 9001;
        server_name localhost;
        location / {
            root /var/www/html;
            index index.html index.htm;
        }
    }
}
EOF

# Конфигурация для второго инстанса (Порт 9002)
cat << 'EOF' > /etc/nginx/nginx-second.conf
pid /run/nginx-second.pid;
user www-data;
worker_processes auto;
error_log /var/log/nginx/error-second.log warn;

events {
    worker_connections 768;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log /var/log/nginx/access-second.log;
    sendfile on;
    types_hash_max_size 2048;

    server {
        listen 9002;
        server_name localhost;
        location / {
            root /var/www/html;
            index index.html index.htm;
        }
    }
}
EOF

echo "=== 3. Создание шаблонного systemd-юнита nginx@.service ==="
cat << 'EOF' > /etc/systemd/system/nginx@.service
[Unit]
Description=A high performance web server and a reverse proxy server (Instance: %I)
Documentation=man:nginx(8)
After=network.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx-%I.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-%I.conf -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx-%I.pid
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF

echo "=== 4. Перезапуск демона systemd и применение настроек ==="
systemctl daemon-reload

echo "=== 5. Запуск и включение автозагрузки новых инстансов ==="
systemctl enable --now nginx@first
systemctl enable --now nginx@second

echo "=== 6. Проверка статуса запущенных инстансов ==="
sleep 1
ps afx | grep nginx | grep -v grep

echo "Настройка успешно завершена!"
