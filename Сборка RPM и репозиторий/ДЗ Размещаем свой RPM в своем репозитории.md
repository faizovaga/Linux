#### Домашнее задание
* Создать свой RPM пакет (можно взять свое приложение, либо собрать, например,
Apache с определенными опциями).
* Создать свой репозиторий и разместить там ранее собранный RPM.

Реализовать это все либо в Vagrant, либо развернуть у себя через Nginx и дать ссылку на репозиторий.

#### Создать свой RPM пакет

[root@localhost SPECS]# rpmbuild -ba nginx.spec -D 'debug_package %{nil}'
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.aDhS2B
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd nginx-1.26.3
+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/nginx-1.26.3-6.el10.7.x86_64
+ RPM_EC=0
++ jobs -p
+ exit 0
Executing(rmbuild): /bin/sh -e /var/tmp/rpm-tmp.Rp9TWx
+ umask 022
+ cd /root/rpmbuild/BUILD
+ rm -rf /root/rpmbuild/BUILD/nginx-1.26.3-SPECPARTS
+ rm -rf nginx-1.26.3 nginx-1.26.3.gemspec
+ RPM_EC=0
++ jobs -p
+ exit 0
[root@localhost SPECS]#
