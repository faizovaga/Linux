
### Задание 
* Добавить в виртуальную машину несколько дисков 
* Собрать RAID-0/1/5/10 на выбор 
* Сломать и починить RAID 
* Создать GPT таблицу, пять разделов и смонтировать их в системе.
#### 1. RAID 10
Посмотреть все доступные диски для сборки RAID: \
`faizovaga@Ubuntu2404-desktop:~$ lsblk `
 ```
sdd           8:48   0   10G  0 disk
sde           8:64   0   10G  0 disk
sdf           8:80   0   10G  0 disk
sdg           8:96   0   25G  0 disk 
 ```
Занулить суперблоки и запустить команду создания RAID 10:
``` 
faizovaga@Ubuntu2404-desktop:~$ sudo  mdadm --zero-superblock --force /dev/sd{d,e,f,g} 
faizovaga@Ubuntu2404-desktop:~$ sudo mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{d,e,f,g}
 
mdadm: layout defaults to n2
mdadm: layout defaults to n2
mdadm: chunk size defaults to 512K
mdadm: size set to 10476544K
mdadm: largest drive (/dev/sdg) exceeds size (10476544K) by more than 1%
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
 ```
Посмотреть как собрался RAID : 
 ```
faizovaga@Ubuntu2404-desktop:~$ cat /proc/mdstat

Personalities : [raid0] [raid1] [raid4] [raid5] [raid6] [raid10] [linear]
md0 : active raid10 sdg[3] sdf[2] sde[1] sdd[0]
      20953088 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
      [==============>......]  resync = 70.7% (14821504/20953088) finish=0.4min speed=206276K/sec
 ```
 ```
faizovaga@Ubuntu2404-desktop:~$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Thu Oct  8 16:43:20 2026
        Raid Level : raid10
        Array Size : 20953088 (19.98 GiB 21.46 GB)
     Used Dev Size : 10476544 (9.99 GiB 10.73 GB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

    Number   Major   Minor   RaidDevice State
       0       8       48        0      active sync set-A   /dev/sdd
       1       8       64        1      active sync set-B   /dev/sde
       2       8       80        2      active sync set-A   /dev/sdf
       3       8       96        3      active sync set-B   /dev/sdg

 ```
#### 2.Сломать и починить RAID
Зафейлить один из дисков: 
 ```
faizovaga@Ubuntu2404-desktop:~$ sudo mdadm /dev/md0 --fail /dev/sdg
mdadm: set /dev/sdg faulty in /dev/md0

faizovaga@Ubuntu2404-desktop:~$ sudo mdadm -D /dev/md0`

    Number   Major   Minor   RaidDevice State
       0       8       48        0      active sync set-A   /dev/sdd
       1       8       64        1      active sync set-B   /dev/sde
       2       8       80        2      active sync set-A   /dev/sdf
       -       0        0        3      removed

       3       8       96        -      faulty   /dev/sdg
 ```
Удалить неисправный диск: 
```
faizovaga@Ubuntu2404-desktop:~$ sudo mdadm /dev/md0 --remove /dev/sdg
mdadm: hot removed /dev/sdg from /dev/md0
```
Добавить диск: 
```
faizovaga@Ubuntu2404-desktop:~$ sudo mdadm /dev/md0 --add /dev/sdg
mdadm: added /dev/sdg
```
Посмотреть статус RAID:
```
faizovaga@Ubuntu2404-desktop:~$ cat /proc/mdstat
Personalities : [raid0] [raid1] [raid4] [raid5] [raid6] [raid10] [linear]
md0 : active raid10 sdg[4] sdf[2] sde[1] sdd[0]
      20953088 blocks super 1.2 512K chunks 2 near-copies [4/3] [UUU_]
      [===========>.........]  recovery = 55.6% (5832576/10476544) finish=0.3min speed=208306K/sec

md127 : active (auto-read-only) raid1 sdc[2]
      10476544 blocks super 1.2 [2/1] [U_]


faizovaga@Ubuntu2404-desktop:~$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Thu Oct  8 16:43:20 2026
        Raid Level : raid10
        Array Size : 20953088 (19.98 GiB 21.46 GB)
     Used Dev Size : 10476544 (9.99 GiB 10.73 GB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Thu Oct  8 16:54:07 2026
             State : clean
```
### 3.Создать GPT таблицу, пять разделов и смонтировать их в системе.
```
faizovaga@Ubuntu2404-desktop:~$ sudo parted -s /dev/md0 mklabel gpt


faizovaga@Ubuntu2404-desktop:~$ sudo parted /dev/md0 mkpart primary ext4 0% 20%
Information: You may need to update /etc/fstab.

faizovaga@Ubuntu2404-desktop:~$ sudo parted /dev/md0 mkpart primary ext4 20% 40%
Information: You may need to update /etc/fstab.

faizovaga@Ubuntu2404-desktop:~$ sudo parted /dev/md0 mkpart primary ext4 40% 60%
Information: You may need to update /etc/fstab.

faizovaga@Ubuntu2404-desktop:~$ sudo parted /dev/md0 mkpart primary ext4 60% 80%
Information: You may need to update /etc/fstab.

faizovaga@Ubuntu2404-desktop:~$ sudo parted /dev/md0 mkpart primary ext4 80% 100%
Information: You may need to update /etc/fstab.


faizovaga@Ubuntu2404-desktop:~$ for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
faizovaga@Ubuntu2404-desktop:~$ sudo mkdir -p /raid/part{1,2,3,4,5}
faizovaga@Ubuntu2404-desktop:~$ for i in $(seq 1 5); do sudo mount /dev/md0p$i  /raid/part$i; done
```
Проверка результатов:
```
faizovaga@Ubuntu2404-desktop:~$ df -Th
/dev/md0p1     ext4   3.9G   24K  3.7G   1% /raid/part1
/dev/md0p2     ext4   3.9G   24K  3.7G   1% /raid/part2
/dev/md0p3     ext4   3.9G   24K  3.7G   1% /raid/part3
/dev/md0p4     ext4   3.9G   24K  3.7G   1% /raid/part4
/dev/md0p5     ext4   3.9G   24K  3.7G   1% /raid/part5

faizovaga@Ubuntu2404-desktop:~$ sudo fdisk -l 

Disk /dev/md0: 19.98 GiB, 21455962112 bytes, 41906176 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 524288 bytes / 1048576 bytes
Disklabel type: gpt
Disk identifier: C2A82033-37A3-4BAA-B861-182A1F4BD0B4

Device        Start      End Sectors Size Type
/dev/md0p1     2048  8380415 8378368   4G Linux filesystem
/dev/md0p2  8380416 16762879 8382464   4G Linux filesystem
/dev/md0p3 16762880 25143295 8380416   4G Linux filesystem
/dev/md0p4 25143296 33525759 8382464   4G Linux filesystem
/dev/md0p5 33525760 41904127 8378368   4G Linux filesystem
```
