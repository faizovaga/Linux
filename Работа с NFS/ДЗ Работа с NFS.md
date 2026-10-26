#### Описание домашнего задания 
##### Основная часть: 
* запустить 2 виртуальных машины (сервер NFS и клиента);
* на сервере NFS должна быть подготовлена и экспортирована директория; 
* в экспортированной директории должна быть поддиректория с именем upload с правами на запись в неё; 
* экспортированная директория должна автоматически монтироваться на клиенте при старте виртуальной машины (systemd, autofs или fstab — любым способом);
* монтирование и работа NFS на клиенте должна быть организована с использованием NFSv3.

##### На первой виртуальной машине выполняется установка сервера NFS. \
Запускаем на сервере скрипт nfss_setup.sh https://github.com/faizovaga/Linux/blob/main/%D0%A0%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%D1%81%20NFS/nfss_setup.sh :
```
faizovaga@Ubuntu2404-server:~$ nano nfss_setup.sh
faizovaga@Ubuntu2404-server:~$ chmod +x nfss_setup.sh
faizovaga@Ubuntu2404-server:~$ sudo ./nfss_setup.sh
```
Проверка результатов:
```
root@Ubuntu2404-server:~# exportfs -s
/srv/share  192.168.0.105(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
```
На сервере  в папке экспортирования создаем файл client_file:
```
root@Ubuntu2404-server:/srv/share/upload# touch client_file
root@Ubuntu2404-server:/srv/share/upload# ls
client_file
```

##### На второй виртуальной машине выполняется установка клиента NFS. \

Запустить скрипт nfsc_setup.sh https://github.com/faizovaga/Linux/blob/main/%D0%A0%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%20%D1%81%20NFS/nfsc_setup.sh:
```
root@ubuntu2404-client:~# ./nfsc_setup.sh
```
Перейти в папку /mnt/upload/:
```
root@ubuntu2404-client:~# ls -la /mnt
```
Проверить, что  папка примонтировлась:
```
root@ubuntu2404-client:~# df -Th
Filesystem                       Type   Size  Used Avail Use% Mounted on
tmpfs                            tmpfs  197M  1.1M  196M   1% /run
/dev/sda2                        ext4    25G  2.8G   21G  12% /
tmpfs                            tmpfs  985M     0  985M   0% /dev/shm
tmpfs                            tmpfs  5.0M     0  5.0M   0% /run/lock
tmpfs                            tmpfs  197M   12K  197M   1% /run/user/1000
192.168.0.118:/srv/share/upload/ nfs     49G  3.8G   43G   9% /mnt

root@ubuntu2404-client:~# mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=66,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=4039)
192.168.0.118:/srv/share/upload/ on /mnt type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.0.118,mountvers=3,mountport=59027,mountproto=udp,local_lock=none,addr=192.168.0.118)

root@ubuntu2404-client:/mnt# showmount -a 192.168.0.118
All mount points on 192.168.0.118:
192.168.0.105:/srv/share/upload
```


Проверка наличия файлов, файл  final_check создан, а client_file был экспортирован:
```
root@ubuntu2404-client:/mnt# touch final_check
root@ubuntu2404-client:/mnt# ls
client_file  final_check

```
