bash
#!/bin/bash

# Скрипт автоматической настройки NFS-сервера (192.168.0.118)
# Специально для клиента: 192.168.0.105

set -e # Остановить выполнение при любой ошибке

path="/srv/share/upload"
ip_client="192.168.0.105"

echo "---1. Установка сервера NFS "

# Убран apt-get update для ускорения, если база пакетов уже обновлена
apt-get install -y nfs-kernel-server 


echo "---2. Создание папки экспорта и прав на нее "

# Использование переменной гарантирует, что права изменятся именно там, где нужно
mkdir -p "$path"
chown -R nobody:nogroup "$path"
chmod 0777 "$path"
echo "Создана директория $path."

echo "---3. Настройка экспорта (/etc/exports) "

# Исправлено: в экспорт пишется точный путь из переменной + добавлена стабильная опция
cat << EOF > /etc/exports
$path $ip_client(rw,sync,root_squash,no_subtree_check)
EOF

systemctl enable --now nfs-kernel-server
exportfs -rav

echo "---4. Завершена настройка NFS сервера "