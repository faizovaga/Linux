### Задание 
 На виртуальной машине с Ubuntu 24.04 и LVM. 
1. Уменьшить том под / до 8G. 
2. Выделить том под /home. 
3. Выделить том под /var - сделать в mirror. 
4. /home - сделать том для снапшотов.
5. Прописать монтирование в fstab. Попробовать с разными опциями и разными файловыми системами (на выбор).
6. Работа со снапшотами: 
* a. сгенерить файлы в /home/; 
* b. снять снапшот; c. удалить часть файлов; 
* d. восстановится со снапшота.
#### 1. Уменьшить том под / до 8G. 
Исходный стенд, корневой каталог находится в разделе sda2 50Gb:  \
`root@Ubuntu2404-server:~# lsblk`
```
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   50G  0 disk
├─sda1   8:1    0    1M  0 part
└─sda2   8:2    0   50G  0 part /
```
Сначала необходимо перенести раздел /boot на новый раздел sdа3 2Gb, \
Далее корневую систему перенести на lvm диска sdb 10Gb, затем на уменьшенный sda2 8GB:
```
root@Ubuntu2404-server:~# mkfs.ext4 /dev/ubuntu-vg/ubuntu-lv
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 2096128 4k blocks and 524288 inodes
Filesystem UUID: d698595f-863f-4a2e-a387-ffd7ae1711a7
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done


root@Ubuntu2404-server:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   52G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    8G  0 part
│ └─ubuntu--vg-ubuntu--lv 252:1    0    8G  0 lvm  /
└─sda3                      8:3    0    2G  0 part /boot
sdb                         8:16   0   10G  0 disk
└─vg_root-lv_root         252:0    0   10G  0 lvm
sr0                        11:0    1 1024M  0 rom
```
#### 2. Выделить том под /home.

`root@Ubuntu2404-server:~# df -Th `
```
Filesystem                        Type   Size  Used Avail Use% Mounted on
tmpfs                             tmpfs  795M  1.1M  794M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv ext4   7.8G  3.0G  4.5G  40% /
tmpfs                             tmpfs  3.9G     0  3.9G   0% /dev/shm
tmpfs                             tmpfs  5.0M     0  5.0M   0% /run/lock
/dev/mapper/vg_var-lv_var         ext4   919M  466M  391M  55% /var
/dev/sda3                         ext4   2.0G  213M  1.6G  12% /boot
tmpfs                             tmpfs  795M   12K  795M   1% /run/user/1000
```
Необходимо создать новую LV LogVol_Home в разделе sda4 2GB:
```
root@Ubuntu2404-server:~# lvcreate -n LogVol_Home -L 1.G /dev/vg_home
  Logical volume "LogVol_Home" created.
  
root@Ubuntu2404-server:~# mkfs.ext4 /dev/ubuntu-vg/LogVol_Home
mke2fs 1.47.0 (5-Feb-2023)
The file /dev/ubuntu-vg/LogVol_Home does not exist and no size was specified.
root@Ubuntu2404-server:~# mkfs.ext4 /dev/vg_home/LogVol_Home

mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 262144 4k blocks and 65536 inodes


#### 3. Выделить том под /var - сделать в mirror.
```
root@Ubuntu2404-server:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   52G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    8G  0 part
│ └─ubuntu--vg-ubuntu--lv 252:1    0    8G  0 lvm  /
└─sda3                      8:3    0    2G  0 part /boot
sdb                         8:16   0   10G  0 disk
└─vg_root-lv_root         252:0    0   10G  0 lvm
sdc                         8:32   0    2G  0 disk
sdd                         8:48   0    2G  0 disk
sr0                        11:0    1 1024M  0 rom
```
Создаем PV /dev/sdc, /dev/sdd. VG vg_var. LV lv_var и ФС ext4 : /
```
root@Ubuntu2404-server:~# pvcreate /dev/sdc /dev/sdd
  Physical volume "/dev/sdc" successfully created.
  Physical volume "/dev/sdd" successfully created.

root@Ubuntu2404-server:~# vgcreate vg_var /dev/sdc /dev/sdd
  Volume group "vg_var" successfully created

root@Ubuntu2404-server:~# lvcreate -L 950M -m1 -n lv_var vg_var
  Rounding up size to full physical extent 952.00 MiB
  Logical volume "lv_var" created.

root@Ubuntu2404-server:~# mkfs.ext4 /dev/vg_var/lv_var
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 243712 4k blocks and 60928 inodes
```
Переносим каталог /var:
```
root@Ubuntu2404-server:/mnt# mount /dev/vg_var/lv_var /mnt
root@Ubuntu2404-server:/mnt# cp -aR /var/* /mnt/

root@Ubuntu2404-server:/mnt# mount /dev/vg_var/lv_var /mnt
root@Ubuntu2404-server:/mnt# cp -aR /var/* /mnt/
root@Ubuntu2404-server:/mnt# mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
root@Ubuntu2404-server:/mnt# umount /mnt
root@Ubuntu2404-server:/mnt# mount /dev/vg_var/lv_var /var
```
Проверка результатов:
```
root@Ubuntu2404-server:/mnt# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   52G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    8G  0 part
│ └─ubuntu--vg-ubuntu--lv 252:1    0    8G  0 lvm  /
└─sda3                      8:3    0    2G  0 part /boot
sdb                         8:16   0   10G  0 disk
└─vg_root-lv_root         252:0    0   10G  0 lvm
sdc                         8:32   0    2G  0 disk
├─vg_var-lv_var_rmeta_0   252:2    0    4M  0 lvm
│ └─vg_var-lv_var         252:6    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_0  252:3    0  952M  0 lvm
  └─vg_var-lv_var         252:6    0  952M  0 lvm  /var
sdd                         8:48   0    2G  0 disk
├─vg_var-lv_var_rmeta_1   252:4    0    4M  0 lvm
│ └─vg_var-lv_var         252:6    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_1  252:5    0  952M  0 lvm
  └─vg_var-lv_var         252:6    0  952M  0 lvm  /var
sr0                        11:0    1 1024M  0 rom
```
Запись инфо о каталоге /var в fstab для автоматического монтирования:
```
root@Ubuntu2404-server:/mnt# echo "`blkid | grep var: | awk '{print $2}'` \
> /var ext4 defaults 0 0" >> /etc/fstab

root@Ubuntu2404-server:~# cat /etc/fstab
/dev/disk/by-uuid/62bb7188-d637-4c38-9114-5e2d0e971dc6 / ext4 defaults 0 1
UUID=a35f6d52-4800-4659-92e6-86fd0c7e81bc /boot ext4 defaults 0 2
UUID=843068a2-903d-4e24-a64b-e58308b118bd /var ext4 defaults 0 0
```
По завершении работ очистить sdb:
```
root@Ubuntu2404-server:~# lvremove /dev/vg_root/lv_root
Do you really want to remove and DISCARD active logical volume vg_root/lv_root? [y/n]: y
  Logical volume "lv_root" successfully removed.
root@Ubuntu2404-server:~# vgremove /dev/vg_root
  Volume group "vg_root" successfully removed
root@Ubuntu2404-server:~# pvremove /dev/sdb
  Labels on physical volume "/dev/sdb" successfully wiped.
```
Проверка результатов:
```
root@Ubuntu2404-server:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   52G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    8G  0 part
│ └─ubuntu--vg-ubuntu--lv 252:1    0    8G  0 lvm  /
└─sda3                      8:3    0    2G  0 part /boot
sdb                         8:16   0   10G  0 disk
sdc                         8:32   0    2G  0 disk
├─vg_var-lv_var_rmeta_0   252:2    0    4M  0 lvm
│ └─vg_var-lv_var         252:6    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_0  252:3    0  952M  0 lvm
  └─vg_var-lv_var         252:6    0  952M  0 lvm  /var
sdd                         8:48   0    2G  0 disk
├─vg_var-lv_var_rmeta_1   252:4    0    4M  0 lvm
│ └─vg_var-lv_var         252:6    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_1  252:5    0  952M  0 lvm
  └─vg_var-lv_var         252:6    0  952M  0 lvm  /var
```

#### 4. Выделить том под /home 
```
root@Ubuntu2404-server:~# df -Th
Filesystem                        Type   Size  Used Avail Use% Mounted on
tmpfs                             tmpfs  795M  1.1M  794M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv ext4   7.8G  3.0G  4.5G  40% /
tmpfs                             tmpfs  3.9G     0  3.9G   0% /dev/shm
tmpfs                             tmpfs  5.0M     0  5.0M   0% /run/lock
/dev/mapper/vg_var-lv_var         ext4   919M  466M  391M  55% /var
/dev/sda3                         ext4   2.0G  213M  1.6G  12% /boot
tmpfs                             tmpfs  795M   12K  795M   1% /run/user/1000
```
Создаем новую LV LogVol_Home, ФС ext4
root@Ubuntu2404-server:~# lvcreate -n LogVol_Home -L 1.G /dev/vg_home
  Logical volume "LogVol_Home" created.
root@Ubuntu2404-server:~# mkfs.ext4 /dev/vg_home/LogVol_Home
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 262144 4k blocks and 65536 inodes
```
Монтируем новый LogVol_Home в /mnt/, копируем директорию /home:
```
root@Ubuntu2404-server:~# mount /dev/vg_home/LogVol_Home /mnt/
root@Ubuntu2404-server:~# cp -aR /home/* /mnt/
root@Ubuntu2404-server:~# rm -rf /home/*
root@Ubuntu2404-server:~# umount /mnt
root@Ubuntu2404-server:~# mount /dev/vg_home/LogVol_Home /home/
```
Запись инфо о каталоге /home в fstab для автоматического монтирования:
```
root@Ubuntu2404-server:~# echo "`blkid | grep Home | awk '{print $2}'` \
> /home xfs defaults 0 0" >> /etc/fstab
```
Проверка результатов:
```
root@Ubuntu2404-server:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   52G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    8G  0 part
│ └─ubuntu--vg-ubuntu--lv 252:5    0    8G  0 lvm  /
├─sda3                      8:3    0    2G  0 part /boot
└─sda4                      8:4    0    2G  0 part
  └─vg_home-LogVol_Home   252:6    0    1G  0 lvm  /home
sdb                         8:16   0   10G  0 disk
sdc                         8:32   0    2G  0 disk
├─vg_var-lv_var_rmeta_0   252:0    0    4M  0 lvm
│ └─vg_var-lv_var         252:4    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_0  252:1    0  952M  0 lvm
  └─vg_var-lv_var         252:4    0  952M  0 lvm  /var
sdd                         8:48   0    2G  0 disk
├─vg_var-lv_var_rmeta_1   252:2    0    4M  0 lvm
│ └─vg_var-lv_var         252:4    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_1  252:3    0  952M  0 lvm
  └─vg_var-lv_var         252:4    0  952M  0 lvm  /var
```






