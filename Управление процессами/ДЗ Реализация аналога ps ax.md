#### Вариант 1. Реализация аналога ps ax

Создайте скрипт, который получает информацию о процессах через файловую систему /proc.
* Реализуйте вывод не менее следующих полей: PID, PPID, состояние процесса, имя или команда запуска.
* Проверьте работу скрипта на запущенной системе.
* Зафиксируйте пример результата работы. \
🟡 Ожидаемый результат:
* рабочий скрипт, выводящий список процессов по данным из /proc

--Посмотреть процессы nginx с PID
```
root@Ubuntu2404-server:~# pstree -p | grep nginx
           |-nginx(727)---nginx(728)
```
--Найти имя сервиса по найденным PID
```
root@Ubuntu2404-server:~# cat /proc/728/comm
nginx
root@Ubuntu2404-server:~# cat /proc/727/comm
nginx
```
--Посмотреть дерево создания процессов
```
root@Ubuntu2404-server:~# pstree -sp 727
systemd(1)───nginx(727)───nginx(728)
```
--Подробнее информация по родителю и потомку:
```
root@Ubuntu2404-server:~# ps -ef | grep nginx
root         727       1  0 07:31 ?        00:00:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data     728     727  0 07:31 ?        00:00:00 nginx: worker process
root        1425    1403  0 08:43 pts/4    00:00:00 grep --color=auto nginx
```

--Статусы, команды запуска:
```
root@Ubuntu2404-server:~# cat /proc/727/status | grep State
State:  S (sleeping)

root@Ubuntu2404-server:~# cat /proc/727/status | grep Ppid
PPid:   1

root@Ubuntu2404-server:~# cat /proc/727/cmdline
nginx: master process /usr/sbin/nginx -g daemon on; master_process on;


root@Ubuntu2404-server:~# cat /proc/728/status | grep State
State:  S (sleeping)

root@Ubuntu2404-server:~# cat /proc/728/status | grep PPid
PPid:   727

root@Ubuntu2404-server:~# cat /proc/728/cmdline
nginx: worker process
```
##### Реализация просмотра через скрипт ps_nginx.sh:
```
#!/bin/bash

# Процессы ("nginx")
TARGET_PROC="nginx"

# Заголовок
echo -e "PID\tPPID\tSTATE\tCOMMAND"


# Поиск  (PID) в директории /proc
for pid_dir in /proc/[0-9]*; do
   # echo $pid_dir

    pid=$(basename "$pid_dir")

    # Имя процесса из comm
    if [ -r "$pid_dir/comm" ]; then
        comm=$(cat "$pid_dir/comm")
        #echo $comm
    else
        continue
    fi

    # Фильтруем по переменной nginx
    if [[ "$comm" == *"$TARGET_PROC"* ]]; then
        # Извлекаем PPID и State из файла status
        # printf  "\n%s\n"  "$comm"
        ppid=$(awk '/^PPid:/ {print $2}' "$pid_dir/status" 2>/dev/null)
        state=$(awk '/^State:/ {print $2, $3}' "$pid_dir/status" 2>/dev/null)

        # Читаем полную команду запуска из cmdline (заменяя нулевые байты на пробелы)
        cmdline=$(tr '\0' ' ' < "$pid_dir/cmdline" 2>/dev/null)


        # Форматированный вывод строки
        printf "%-8s %-8s %-10s %s\n" "$pid" "$ppid" "$state" "$cmdline"
    fi
Done
```

Проверка результатов:
```
root@Ubuntu2404-server:~# ./ps_nginx.sh
PID     PPID    STATE   COMMAND
5198     1403     S (sleeping) /bin/bash ./ps_nginx.sh
727      1        S (sleeping) nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
728      727      S (sleeping) nginx: worker process
```
