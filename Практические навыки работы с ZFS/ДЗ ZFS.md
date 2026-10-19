1. Определить алгоритм с наилучшим сжатием:
* определить, какие алгоритмы сжатия поддерживает zfs (gzip, zle, lzjb, lz4);
* создать 4 файловых системы, на каждой применить свой алгоритм сжатия;
* для сжатия использовать либо текстовый файл, либо группу файлов.
2. Определить настройки пула.
* С помощью команды zfs import собрать pool ZFS.
* Командами zfs определить настройки:
* размер хранилища;
* тип pool;
* значение recordsize;
* какое сжатие используется;
* какая контрольная сумма используется.
3. Работа со снапшотами:
* скопировать файл из удаленной директории;
* восстановить файл локально. zfs receive;
* найти зашифрованное сообщение в файле secret_message.



#### 1. Определение алгоритма с наилучшим сжатием
```
root@Ubuntu2404-server:~# lsblk
NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0    52G  0 disk
├─sda1                      8:1    0     1M  0 part
├─sda2                      8:2    0     8G  0 part
│ └─ubuntu--vg-ubuntu--lv 252:0    0     8G  0 lvm  /
└─sda3                      8:3    0     2G  0 part /boot
sdb                         8:16   0 512.9M  0 disk
sdc                         8:32   0 512.9M  0 disk
sdd                         8:48   0 512.9M  0 disk
sde                         8:64   0 512.9M  0 disk
sdf                         8:80   0 512.9M  0 disk
sdg                         8:96   0 512.9M  0 disk
sdh                         8:112  0 512.9M  0 disk
sdi                         8:128  0 512.9M  0 disk
sr0                        11:0    1  1024M  0 rom


root@Ubuntu2404-server:~# apt install zfsutils-linux

root@Ubuntu2404-server:~# sudo modprobe zfs
root@Ubuntu2404-server:~# zpool create otus1 mirror /dev/sdb /dev/sdc
root@Ubuntu2404-server:~# zpool create otus2 mirror /dev/sdd /dev/sde
root@Ubuntu2404-server:~# zpool create otus3 mirror /dev/sdf /dev/sdg

root@Ubuntu2404-server:~# zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  AL               TROOT
otus1   480M   111K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus2   480M   111K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus3   480M   111K   480M        -         -     0%     0%  1.00x    ONLINE  -

root@Ubuntu2404-server:~# zfs set compression=lzjb otus1
root@Ubuntu2404-server:~# zfs set compression=lz4 otus2
root@Ubuntu2404-server:~# zfs set compression=gzip-9 otus3
root@Ubuntu2404-server:~# zfs set compression=zle otus4

root@Ubuntu2404-server:~# zfs get all | grep compression
otus1  compression           lzjb                   local
otus2  compression           lz4                    local
otus3  compression           gzip-9                 local
otus4  compression           zle                    local


root@Ubuntu2404-server:~# for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done

root@Ubuntu2404-server:~# lsblk
NAME                      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0    52G  0 disk
├─sda1                      8:1    0     1M  0 part
├─sda2                      8:2    0     8G  0 part
│ └─ubuntu--vg-ubuntu--lv 252:0    0     8G  0 lvm  /
└─sda3                      8:3    0     2G  0 part /boot
sdb                         8:16   0 512.9M  0 disk
├─sdb1                      8:17   0   503M  0 part
└─sdb9                      8:25   0     8M  0 part
sdc                         8:32   0 512.9M  0 disk
├─sdc1                      8:33   0   503M  0 part
└─sdc9                      8:41   0     8M  0 part
sdd                         8:48   0 512.9M  0 disk
├─sdd1                      8:49   0   503M  0 part
└─sdd9                      8:57   0     8M  0 part
sde                         8:64   0 512.9M  0 disk
├─sde1                      8:65   0   503M  0 part
└─sde9                      8:73   0     8M  0 part
sdf                         8:80   0 512.9M  0 disk
├─sdf1                      8:81   0   503M  0 part
└─sdf9                      8:89   0     8M  0 part
sdg                         8:96   0 512.9M  0 disk
├─sdg1                      8:97   0   503M  0 part
└─sdg9                      8:105  0     8M  0 part
sdh                         8:112  0 512.9M  0 disk
├─sdh1                      8:113  0   503M  0 part
└─sdh9                      8:121  0     8M  0 part
sdi                         8:128  0 512.9M  0 disk
├─sdi1                      8:129  0   503M  0 part
└─sdi9                      8:137  0     8M  0 part
sr0                        11:0    1  1024M  1 rom

root@Ubuntu2404-server:~# df -hT
Filesystem                        Type   Size  Used Avail Use% Mounted on
tmpfs                             tmpfs  795M  1.2M  794M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv ext4   7.8G  4.2G  3.3G  57% /
tmpfs                             tmpfs  3.9G     0  3.9G   0% /dev/shm
tmpfs                             tmpfs  5.0M     0  5.0M   0% /run/lock
/dev/sda3                         ext4   2.0G  213M  1.6G  12% /boot
tmpfs                             tmpfs  795M   12K  795M   1% /run/user/1000
otus1                             zfs    352M   22M  331M   7% /otus1
otus2                             zfs    352M   18M  335M   6% /otus2
otus3                             zfs    352M   11M  341M   4% /otus3
otus4                             zfs    352M   40M  313M  12% /otus4



root@Ubuntu2404-server:~# ls -l /otus*
/otus1:
total 22136
-rw-r--r-- 1 root root 41273476 Oct  2 07:31 pg2600.converter.log

/otus2:
total 18027
-rw-r--r-- 1 root root 41273476 Oct  2 07:31 pg2600.converter.log

/otus3:
total 10976
-rw-r--r-- 1 root root 41273476 Oct  2 07:31 pg2600.converter.log

/otus4:
total 40352
-rw-r--r-- 1 root root 41273476 Oct  2 07:31 pg2600.converter.log

root@Ubuntu2404-server:~# zfs list
NAME    USED  AVAIL  REFER  MOUNTPOINT
otus1  21.8M   330M  21.6M  /otus1
otus2  17.8M   334M  17.6M  /otus2
otus3  10.9M   341M  10.7M  /otus3
otus4  39.6M   312M  39.4M  /otus4


root@Ubuntu2404-server:~# zfs get all | grep compressratio | grep -v ref
otus1  compressratio         1.82x                  -
otus2  compressratio         2.23x                  -
otus3  compressratio         3.66x                  -
otus4  compressratio         1.00x 
```

#### 2. Определение настроек пула

```
root@Ubuntu2404-server:~# wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'
--2026-10-19 10:27:26--  https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download

root@Ubuntu2404-server:~# tar -xzvf archive.tar.gz
zpoolexport/
zpoolexport/filea
zpoolexport/fileb

root@Ubuntu2404-server:~# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
status: Some supported features are not enabled on the pool.
        (Note that they may be intentionally disabled if the
        'compatibility' property is set.)
 action: The pool can be imported using its name or numeric identifier, though
        some features will not be available without an explicit 'zpool upgrade'.
 config:

        otus                         ONLINE
          mirror-0                   ONLINE
            /root/zpoolexport/filea  ONLINE
            /root/zpoolexport/fileb  ONLINE

root@Ubuntu2404-server:~# zpool status
  pool: otus
 state: ONLINE
status: Some supported and requested features are not enabled on the pool.
        The pool can still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done,
        the pool may no longer be accessible by software that does not support
        the features. See zpool-features(7) for details.
config:

        NAME                         STATE     READ WRITE CKSUM
        otus                         ONLINE       0     0     0
          mirror-0                   ONLINE       0     0     0
            /root/zpoolexport/filea  ONLINE       0     0     0
            /root/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors


root@Ubuntu2404-server:~# zfs get available otus
NAME  PROPERTY   VALUE  SOURCE
otus  available  350M  


root@Ubuntu2404-server:~# zfs get readonly otus
NAME  PROPERTY  VALUE   SOURCE
otus  readonly  off     default

root@Ubuntu2404-server:~# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local


root@Ubuntu2404-server:~# zfs get compression otus
NAME  PROPERTY     VALUE           SOURCE
otus  compression  zle             local


root@Ubuntu2404-server:~# zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
```

#### 3. Работа со снапшотом, поиск сообщения от преподавателя
```
root@Ubuntu2404-server:~#
[1]+  Done                    wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI
root@Ubuntu2404-server:~#

root@Ubuntu2404-server:~# zfs receive otus/test@today < otus_task2.file


root@Ubuntu2404-server:~# find /otus/test -name "secret_message"
/otus/test/task1/file_mess/secret_message


root@Ubuntu2404-server:~# cat /otus/test/task1/file_mess/secret_message
https://otus.ru/lessons/linux-hl/
```
