

# 3DEXPERIENCE Platform Installation 

## 
```bash
cat /etc/redhat-release
```

##

```bash

rpm -Uvh  ksh-20120801-139.el7.x86_64.rpm
rpm -Uvh  libaio-devel-0.3.109-13.el7.x86_64.rpm
rpm -Uvh  libaio-0.3.109-13.el7.x86_64.rpm
rpm -Uvh  numactl-devel-2.0.9-7.el7.x86_64.rpm
rpm -Uvh  redhat-lsb-core-4.1-27.el7.centos.1.x86_64.rpm  redhat-lsb-submod-security-4.1-27.el7.centos.1.x86_64.rpm  spax-1.5.2-13.el7.x86_64.rpm
rpm -Uvh  motif-2.3.4-14.el7_5.x86_64.rpm libXp-1.0.2-2.1.el7.x86_64.rpm  xorg-x11-xbitmaps-1.1.1-6.el7.noarch.rpm
rpm  -Uvh httpd-2.4.6-88.el7.centos.x86_64.rpm  httpd-tools-2.4.6-88.el7.centos.x86_64.rpm
rpm -Uvh  mod_ssl-2.4.6-88.el7.centos.x86_64.rpm
rpm -Uvh  zlib-devel-1.2.7-18.el7.x86_64.rpm
rpm -Uvh  compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm
rpm -Uvh  xorg-x11-server-Xvfb-1.20.1-3.el7.x86_64.rpm

```

## 关闭防火墙

```bash
systemctl disable firewalld
systemctl stop firewalld
firewall-cmd –state
```

## 检查机器名
```bash
hostname
```

```bash
192.168.100.1 r2023x.3ds.com r2023x
192.168.100.1 r2023x.3ds.com untrusted
192.168.100.2 dsls_server
```


## 新建用户

新建一个用户用于3DE的安装，建议不要使用root安装。

```bash

groupadd -g 501 oinstall
groupadd -g 502 dba
groupadd -g 503 oper
groupadd -g 504 backupdba
groupadd -g 505 dgdba
groupadd -g 506 kmdba
groupadd -g 507 asmdba
groupadd -g 508 asmoper
groupadd -g 509 asmadmin
usermod -g oinstall -G  dba,oper,backupdba,dgdba,asmdba,asmoper,asmadmin,kmdba x3ds
```


## 修改该用户的环境变量

```bash
# vi /home/x3ds/.bash_profile

<add the following lines at the bottom of file>
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR
ORACLE_HOSTNAME=r2023x.mydomain.com;  export ORACLE_HOSTNAME
ORACLE_UNQNAME=MYDB; export  ORACLE_UNQNAME
ORACLE_BASE=/app/oracle; export  ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/19.3.0.0/db_1;  export ORACLE_HOME
ORACLE_SID=MYDB; export ORACLE_SID
PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH
LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib:/usr/local/lib;  export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export  CLASSPATH

```

配置完成后需要运行source ~/.bash_profile 生效，或者重启操作系统生效。

## 创建安装数据库的目录并开通权限

```bash
cd /
mkdir app
chmod -R 777 app
cd /app
mkdir -p ./oracle/product/19.3.0.0/db_1
chown -R x3ds:oinstall ./oracle
```

## 安装数据库

拷贝LINUX.X64_193000_db_home.zip into  /tmp

```bash
cd  /app/oracle/product/19.3.0.0/db_1
unzip  /tmp/LINUX.X64_193000_db_home.zip
```

安装Oracle19c数据库之前请编辑以下文件

```bash
vi  /app/oracle/product/19.3.0.0/db_1/cv/admin/cvu_config
```
<add the following>
```bash
CV_ASSUME_DISTID=OEL8.1
```
:x保存
使用新建用户x3ds运行安装程序
```bash
cd  /app/oracle/product/19.3.0.0/db_1
./runInstaller
```

使用lsnrctl status命令和tnsping MYDB命令进行数据库检测。
```bash
sqlplus system@MYDB
```
输入密码
```bash
select instance_name, status from  v$instance;
```
检查STATUS是否是OPEN


密码永不过期的设置：

```bash
sqlplus system/system_pwd@MYDB
ALTER PROFILE DEFAULT LIMIT  PASSWORD_LIFE_TIME UNLIMITED;
exit
```


## 安装Apache

使用root进行操作

```bash
systemctl enable httpd
systemctl start httpd
systemctl status httpd
chkconfig httpd on
```

注释掉这行

#IncludeOptional conf.d/*.conf

添加如下三行

KeepAlive On

KeepAliveTimeout 6

MaxKeepAliveRequests 400

测试apache服务是否启动成功。浏览器地址栏输入http://localhost，看到以下画面表示成功


## 安装Java

[jdk](https://github.com/ibmruntimes/semeru17-binaries/releases/download/jdk-17.0.5%2B8_openj9-0.35.0/ibm-semeru-open-jdk_x64_linux_17.0.5_8_openj9-0.35.0.tar.gz)

```bash

cd /app/
mkdir openjdk
cd openjdk/
ls
tar xvfz  /tmp/ibm-semeru-open-jdk_x64_linux_17.0.5_8_openj9-0.35.0.tar.gz
mv jdk-17.0.5+8 jdk17

```



编辑~/.bash_profile文件，在PATH之后添加

```bash
export JAVA_HOME=/app/openjdk/jdk17
export PATH=$JAVA_HOME/bin:$PATH
source ~/.bash_profile
which java

/app/openjdk/jdk17/bin/java
```

## 生成证书并安装

使用root账号操作

 ```bash
cd /etc/httpd/conf
vi httpd.conf
```

<在文件末尾添加以下内容>

```xml

<IfModule !ssl_module>
    LoadModule ssl_module modules/mod_ssl.so
</IfModule>

SSLRandomSeed startup builtin
SSLRandomSeed connect builtin
SSLCryptoDevice builtin

<VirtualHost r2023x.mydomain.com:80>
    ServerName r2023x.mydomain.com
    DocumentRoot "/var/www/html"
</VirtualHost>

Include conf/r2023x.conf
```

新建r2023x.conf文件 :

```bash
cd /etc/httpd/conf
vi r2023x.conf
```


Add the following lines

```xml
Listen 443

<VirtualHost r2023x.mydomain.com:443>

    ServerName r2023x.mydomain.com
    ServerAlias r2023x

    ErrorLog logs/r2023x_error_log
    TransferLog logs/r2023x_access_log

    LogLevel warn
    SSLEngine on
    SSLProxyEngine on

    SSLCertificateFile conf/ssl/r2023x.crt
    SSLCertificateKeyFile conf/ssl/r2023x.key

    SetEnvIf User-Agent ".*MSIE.*"  \
        nokeepalive ssl-unclean-shutdown  \
        downgrade-1.0  force-response-1.0
</VirtualHost>
```


## 重启apache服务

```bash
systemctl restarthttpd
```

打开浏览器，输入https://r2023x.mydomain.com，看到绿色的锁头表示证书安装成功。


## 安装3DPassport服务

### 数据库脚本

```bash
dbstart $ORACLE_HOME
sqlplus / as sysdba
```


```sql
SQL> CREATE TABLESPACE x3dpassadmin_ts

    DATAFILE '/app/oracle/oradata/MYDB/x3dpassadmin_ts.dbf'  SIZE 10M
    AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

SQL> CREATE TABLESPACE  x3dpasstokens_ts

    DATAFILE  '/app/oracle/oradata/MYDB/x3dpasstokens_ts.DBF' SIZE 10M

    AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED

    EXTENT MANAGEMENT LOCAL

    SEGMENT SPACE MANAGEMENT AUTO;

    CREATE USER x3dpassadmin IDENTIFIED  BY Qwerty12345;

    ALTER USER x3dpassadmin DEFAULT TABLESPACE  x3dpassadmin_ts;

    GRANT CREATE PUBLIC SYNONYM TO x3dpassadmin;

    GRANT CREATE SEQUENCE TO x3dpassadmin;

    GRANT CREATE SESSION TO x3dpassadmin;

    GRANT CREATE SYNONYM TO x3dpassadmin;

    GRANT CREATE TABLE TO x3dpassadmin;

    GRANT DROP PUBLIC SYNONYM TO x3dpassadmin;

    GRANT UNLIMITED TABLESPACE TO x3dpassadmin;

    CREATE USER x3dpasstokens IDENTIFIED  BY Qwerty12345;

    ALTER USER x3dpasstokens DEFAULT TABLESPACE  x3dpasstokens_ts;

    GRANT CREATE PUBLIC SYNONYM TO  x3dpasstokens;

    GRANT CREATE SEQUENCE TO x3dpasstokens;

    GRANT CREATE SESSION TO x3dpasstokens;

    GRANT CREATE SYNONYM TO x3dpasstokens;

    GRANT CREATE TABLE TO x3dpasstokens;

    GRANT DROP PUBLIC SYNONYM TO x3dpasstokens;

    GRANT UNLIMITED TABLESPACE TO x3dpasstokens;

 ```

 从 V6R2023x.AM_3DEXP_Platform.AllOS.3-17.iso文件中找到3DPassport/Linux64/1/，运行StartGUI.sh


安装完毕，用root编辑r2023x.conf文件

```bash
cd /etc/httpd/conf
vi r2023x.conf
```

文件末尾，</VirtualHost>之前，添加一行

```xml
Include /app/DassaultSystemes/R2023x/3DPassport/linux_a64/templates/3DPassport_httpd_fragment.conf
```

测试3DPassport服务
