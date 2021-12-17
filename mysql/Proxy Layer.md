# Proxy Layer

db 인프라 상에서는 ```orchestrator```를 이용해 ```Master```에 장애가 발생하면 ```slave```를 ```Master```로 승격시켜주었는데,
애플리케이션 상에서는 계속 기존 ```Master```로 요청을 보낼 것이다. 이 문제는 ```Proxy Layer```라는 오픈소스를 통해 해결 가능하다.


> 디렉토리 생성
```
mkdir -p ~/db/proxysql/data ~/db/proxysql/conf
chmod 777 ~/db/proxysql ~/db/proxysql/data ~/db/proxysql/conf
```

> conf 경로에 설정파일 생성한 뒤 644 권한 부여
```
datadir="/var/lib/proxysql"
admin_variables=
{
    admin_credentials="admin:admin;radmin:radmin"
    mysql_ifaces="0.0.0.0:6032"
}
mysql_variables=
{
    threads=4
    max_connections=2048
    default_query_delay=0
    default_query_timeout=36000000
    have_compress=true
    poll_timeout=2000
    interfaces="0.0.0.0:6033"
    default_schema="information_schema"
    stacksize=1048576
    server_version="5.5.30"
    connect_timeout_server=3000
    monitor_username="monitor"
    monitor_password="monitor"
    monitor_history=600000
    monitor_connect_interval=60000
    monitor_ping_interval=10000
    monitor_read_only_interval=1500
    monitor_read_only_timeout=500
    ping_interval_server_msec=120000
    ping_timeout_server=500
    commands_stats=true
    sessions_sort=true
    connect_retries_on_failure=10
}
```

> docker 실행
```docker
docker run -i -t --name proxysql -h proxysql --net mybridge --net-alias=proxysql -p 16032:6032 -p 16033:6033 -v ~/db/proxysql/data:/var/lib/proxysql -v ~/db/proxysql/conf/proxysql.cnf:/etc/proxysql.cnf -d proxysql/proxysql
```

> ProxySQL에 admin으로 접근
```
mysql -h127.0.0.1 -P16032 -uradmin -pradmin --prompt "ProxySQL Admin>"
```

ProxySQL Admin에 접속하여 Proxy Layer를 구성해보자

### Test 환경 구성

```
docker exec -it -uroot db001 /bin/bash
mysql -uroot -p
```

> test용 database를 생성하고, user와 user권한을 부여한다.
```mysql
create database testdb default character set utf8;
create user appuser@'%' identified by 'apppass';
grant select, insert, update, delete on testdb.* to appuser@'%';
```

> 모니터링용 user를 생성하고 권한을 부여한다.
```mysql
create user 'monitor'@'%' identified by 'monitor';
grant REPLICATION CLIENT on *.* to 'monitor'@'%';
flush privileges;
```

### ProxySQL 설정

> hostgroup을 세팅하여 Master, Slave 를 구분해준다.
```mysql
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (10, 'db001', 3306);
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (20, 'db001', 3306);
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (20, 'db002', 3306);
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (20, 'db003', 3306);
INSERT INTO mysql_replication_hostgroups VALUES (10,20,'read_only','');
LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;
```

> application용 유저정보 설정, 쿼리 룰 설정
```mysql
INSERT INTO mysql_users(username,password,default_hostgroup,transaction_persistent) VALUES ('appuser','apppass',10,0);
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;
INSERT INTO mysql_query_rules(rule_id,active,match_pattern,destination_hostgroup) VALUES (1,1,'^SELECT.*FOR UPDATE$',10);
INSERT INTO mysql_query_rules(rule_id,active,match_pattern,destination_hostgroup) VALUES (2,1,'^SELECT',20);
LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;
```

> shell script 생성 (select test)
```
vi app_test_conn.sh
-----------------------
# !/bin/bash
while true;
do

  mysql -uappuser -papppass -h172.31.38.111 -P16033 -N -e "select @@hostname,now()" 2>&1| grep -v "Warning"

  sleep 1

done
~
-------------------
sh app_test_conn.sh
```

아래와 같이 세대의 서버에 번갈아가며 쿼리가 날라가면 성공이다.  
![image](https://user-images.githubusercontent.com/87312401/146504619-632bd245-da4c-4427-a8a9-dcaa528b6cc0.png)

> shell script 생성 (insert test)
간단하게 ```Master``` db에 접근하여 insert용 테이블을 생성한다.

> 스크립트 작성
```
vi app_test_insert.sh
--------------------------
#!/bin/bash

while true;
do
  mysql -uappuser -papppass -h172.31.38.111 -P16033 -N -e "insert into testdb.insert_test select @@hostname,now()" 2>&1| grep -v "Warning"
  
  sleep 1

done

--------------------------
sh app_test_insert.sh
```

모든 ```insert```를 ```db001```에서 실행시킨다.

![image](https://user-images.githubusercontent.com/87312401/146505486-76e42283-3c7c-4889-87e1-be6003ac07ed.png)

이제 ```Proxy SQL```을 통해 ```Master```에 ```insert```를 하는 와중에, 강제로 ```Master```db에 장애를 발생시켜보자.

![image](https://user-images.githubusercontent.com/87312401/146506322-d1c89ca7-e58e-4930-96a2-b2f8a900cdd7.png)

위 사진에서 처럼 자동으로 ```Master```가 ```db002```로 바뀌는 것을 확인할 수 있다.
```orchestrator```를 통해 다시 한 번 확인해보면, ```db002```가 ```db003```을 갖고 있고 ```db001```은 recovery 대기 상태로 따로 관리된다.

![image](https://user-images.githubusercontent.com/87312401/146506558-556571a5-dbc1-4338-a354-e4741821a1b6.png)

다시 ```db001```을 ```Master``` db로 failback 해보자

```
docker start db001
docker exec -it -uroot db001 /bin/bash

mysql -uroot -p

set global read_only=1;

CHANGE MASTER TO MASTER_HOST='db002',
MASTER_USER='repl', MASTER_PASSWORD='repl',
MASTER_AUTO_POSITION=1;

start slave;
```

이제 ```db001```의 Master가 ```db002```가 되었다.

![image](https://user-images.githubusercontent.com/87312401/146506898-e97bb776-63a3-427c-acb3-cbf9a2d73254.png)

지나온 과정처럼, db002 를 stop시키고 다시 복구 과정을 거치자.

![image](https://user-images.githubusercontent.com/87312401/146508897-2ed3e1b5-9450-4b03-9eb1-dfea426498ca.png)

다시 원상복구 후, shell script를 실행하면, db001로만 insert가 되는 것을 확인할 수 있다.  
![image](https://user-images.githubusercontent.com/87312401/146508960-5334b3a3-1842-4379-b8cb-9cae1184731a.png)



