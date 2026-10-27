#### Домашнее задание
* Создать свой RPM пакет (можно взять свое приложение, либо собрать, например,
Apache с определенными опциями).
* Создать свой репозиторий и разместить там ранее собранный RPM.

Реализовать это все либо в Vagrant, либо развернуть у себя через Nginx и дать ссылку на репозиторий.

#### Создать свой RPM пакет
##### Скачиваем nginx, модуль brotli и компилируем:
```
[root@localhost ~]# cd ngx_brotli/deps/brotli
[root@localhost brotli]# mkdir out && cd out
[root@localhost out]#  cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF                             -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -f                            function-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -                            m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-                            sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..
-- The C compiler identification is GNU 14.3.1
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /bin/cc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Build type is 'Release'
-- Performing Test BROTLI_EMSCRIPTEN
-- Performing Test BROTLI_EMSCRIPTEN - Failed
-- Compiler is not EMSCRIPTEN
-- Looking for log2 in m
-- Looking for log2 in m - found
-- Configuring done (0.5s)
-- Generating done (0.0s)
CMake Warning:
  Manually-specified variables were not used by the project:

    CMAKE_CXX_FLAGS

-- Build files have been written to: /root/ngx_brotli/deps/brotli/out
```
##### Сборка RPM пакета:
```
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
```
Проверка реузьтатов:
```
[root@localhost BUILD]# ll /root/rpmbuild/RPMS/x86_64/
total 1816
-rw-r--r--. 1 root root  32858 Oct 27 05:28 nginx-1.26.3-6.el10.7.x86_64.rpm

[root@localhost x86_64]# ls
nginx-1.26.3-6.el10.7.x86_64.rpm              nginx-mod-http-image-filter-1.26.3-6.el10.7.x86_64.rpm
nginx-all-modules-1.26.3-6.el10.7.noarch.rpm  nginx-mod-http-perl-1.26.3-6.el10.7.x86_64.rpm
nginx-core-1.26.3-6.el10.7.x86_64.rpm         nginx-mod-http-xslt-filter-1.26.3-6.el10.7.x86_64.rpm
nginx-filesystem-1.26.3-6.el10.7.noarch.rpm   nginx-mod-mail-1.26.3-6.el10.7.x86_64.rpm
nginx-mod-devel-1.26.3-6.el10.7.x86_64.rpm    nginx-mod-stream-1.26.3-6.el10.7.x86_64.rpm
[root@localhost x86_64]#  yum localinstall *.rpm


[root@localhost x86_64]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Tue 2026-10-27 05:35:35 EDT; 6s ago
```
##### Создать свой репозиторий:
```
[root@localhost x86_64]# createrepo /usr/share/nginx/html/repo/
Directory walk started
Directory walk done - 10 packages
Temporary output repo path: /usr/share/nginx/html/repo/.repodata/
Pool started (with 5 workers)
Pool finished
```
Проверка реузьтатов:

```
[root@localhost x86_64]#  yum repolist enabled | grep otus
otus                             otus-linux

[root@localhost repo]# yum list | grep otus
percona-release.noarch                                 1.0-34                                otus


Installed:
  percona-release-1.0-34.noarch

Complete!
```
