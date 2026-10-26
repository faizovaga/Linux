#!/bin/bash

# Скрипт автоматической настройки NFS-сервера (192.168.0.118)
# Клиент: 192.168.0.105

SERVER_IP="192.168.0.118"
SERVER_SHARE="/srv/share/upload/"
LOCAL_MOUNT="/mnt"

set -e # Остановить выполнение при любой ошибке


echo "---1. Установка клиента  NFS "

apt-get install -y nfs-common
#mkdir -p "$LOCAL_MOUNT"



#Запись в fstab
cat << EOF >> /etc/fstab
$SERVER_IP:$SERVER_SHARE $LOCAL_MOUNT nfs vers=3,noauto,x-systemd.automount 0 0
EOF

mount -a

systemctl daemon-reload
systemctl restart remote-fs.target


