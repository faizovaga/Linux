#### Описание домашнего задания 
##### Основная часть: 
* запустить 2 виртуальных машины (сервер NFS и клиента);
* на сервере NFS должна быть подготовлена и экспортирована директория; 
* в экспортированной директории должна быть поддиректория с именем upload с правами на запись в неё; 
* экспортированная директория должна автоматически монтироваться на клиенте при старте виртуальной машины (systemd, autofs или fstab — любым способом);
* монтирование и работа NFS на клиенте должна быть организована с использованием NFSv3.

####№ На первой виртуальной машине выполняется установка сервера NFS. \
Запускаем скрипт nfss_setup.sh на сервере:
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


На сервере создаем файл  client_file:
```
root@Ubuntu2404-server:/srv/share/upload# touch client_file
root@Ubuntu2404-server:/srv/share/upload# ls
client_file
```
