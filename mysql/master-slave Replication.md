# Master - slave Replication

참고 : [Maria DB 공식문서](https://mariadb.com/resources/blog/database-master-slave-replication-in-the-cloud/)

![image](https://user-images.githubusercontent.com/87312401/145986751-1d1b1c43-a7d7-405f-be2a-e6142ffb0c5e.png)


많은 개발자들은 성능, 다른 db에 대한 백업, 시스템 오류 완화를 위해 ```Master - Slave Replication```구조를 사용한다.
```Master``` db 서버는 업데이트 로그를 통해 한개 이상의 ```Slave```서버에 데이터를 저장시킨다.

```Master```에 저장됨과 동시에 ```slave```에 저장되는 동기방식으로 처리할 수 있고, 혹은 변화를 ```queue```에 담아 나중에 저장하는 비동기 방식도 가능하다.

```Maria DB```에서는 상세하게 이 구조를 사용해야 할 상황과 장점에 대해 적어놓았다. 한 번 확인해보자.

### Scale-out solutions
여러개의 ```Slave```를 추가하는 것은 성능 개선에 도움이 된다고 한다. 쓰기, 업데이트는 **무조건** ```Master``` 서버에서 이뤄져야 하고, 읽기 작업은 한 개 이상의 ```Slave```에서 이뤄진다.
이 구조는 쓰기, 업데이트와 읽기가 완전히 분리되어 있어, 각 기능의 성능을 크게 개선할 수 있다고 한다.

### Data security
```Master```의 데이터가 ```Slave```로 저장되고, ```Slave```는 replication 과정을 잠시 멈출 수 있기 때문에, 안전하게(Master에 영향 x) 데이터를 백업할 수 있다.

### Analytics
```Master```에서 계속 쓰기 작업이 진행되는 와중에도 ```Slave```에서 분석 작업을 실행하여 성능에 영향 없이 이 과정을 진행할 수 있다.


## Master - Slave Replication 구성해보기

```
mkdir -p ~/db/db002/data ~/db/db003/data
mkdir -p ~/db/db002/log ~/db/db003/log
mkdir -p ~/db/db002/config ~/db/db003/config
chmod 777 [위 모든 경로]
```

config 경로에 설정 파일을 추가해준다.
```
[mysqld]
log_bin                     = mysql-bin
binlog_format               = ROW
gtid_mode                   = ON
enforce-gtid-consistency    = true
server-id                   = 200 # db003 은 300
log_slave_updates
datadir                     = /var/lib/mysql
socket                      = /var/lib/mysql/mysql.sock
read_only # slave는 readonly

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links              = 0

log-error                   = /var/log/mysql/mysqld.log
pid-file                    = /var/run/mysqld/mysqld.pid

report_host                 = db002 # db003

[mysqld_safe]
pid-file                    = /var/run/mysqld/mysqld.pid
socket                      = /var/lib/mysql/mysql.sock
nice                        = 0

```

포트 번호, 디렉토리 경로에 주의하여 docker를 실행시킨다.
```docker
docker run -i -t --name db003 -p 3308:3306 -v ~/db/db003/data:/var/lib/mysql -v ~/db/db003/log:/var/log/mysql -v ~/db/db003/config:/etc/percona-server.conf.d -e MYSQL_ROOT_PASSWORD="root" -d percona:5.7.30
093aae65941a27f38f2c25dbd910a431e828ec6570d688801243fc8da0c2b8f0
```

실행 확인  
![image](https://user-images.githubusercontent.com/87312401/145989720-12feaac3-2ea3-4be2-b4a8-c92f25ab9703.png)

이제 ```Master``` db에 접근하여 설정을 추가해준다.

User를 생성하고, replication 관련 권한을 준다.
```mysql
CREATE USER 'repl'@'%' IDENTIFIED BY 'repl';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
```

bash로 돌아와 ```ifconfig```명령어를 통해 컨테이너 ip를 확인한다. 

```Slave```에 접근하여 ```Master```와 연결시켜 준다.

> Slave 입력
```mysql
RESET MASTER;
CHANGE MASTER TO MASTER_HOST='172.17.0.2',
MASTER_USER='repl', MASTER_PASSWORD='repl',
MASTER_AUTO_POSITION=1;

START SLAVE;
SHOW SLAVE STATUS\G;
```

잘 연결 됐다.  
![image](https://user-images.githubusercontent.com/87312401/145992184-37cfa41c-ea93-48f7-b126-63572b14ead3.png)


하지만 문제가 있다. 현재 ```Master``` ip를 설정해놨는데, Container가 재시작된다면? ip가 변경될 가능성이 있다.
이를 해결해보자.

### Bridge Network

```docker
docker network ls
docker network create --driver bridge mybridge
```

```docker
docker run -i -t --name db001 -p 3306:3306 --net mybridge --net-alias=db001 -h db001 -v ~/db/db001/data:/var/lib/mysql -v ~/db/db001/log:/var/log/mysql -v ~/db/db001/config:/etc/percona-server.conf.d -e MYSQL_ROOT_PASSWORD="root" -d percona:5.7.30

docker run -i -t --name db002 -p 3307:3306 --net mybridge --net-alias=db002 -h db002 -v ~/db/db002/data:/var/lib/mysql -v ~/db/db002/log:/var/log/mysql -v ~/db/db002/config:/etc/percona-server.conf.d -e MYSQL_ROOT_PASSWORD="root" -d percona:5.7.30

docker run -i -t --name db003 -p 3308:3306 --net mybridge --net-alias=db003 -h db003 -v ~/db/db003/data:/var/lib/mysql -v ~/db/db003/log:/var/log/mysql -v ~/db/db003/config:/etc/percona-server.conf.d -e MYSQL_ROOT_PASSWORD="root" -d percona:5.7.30
```

이제 마스터 호스트를 이름으로 지정하자.
```mysql
CHANGE MASTER TO MASTER_HOST='db001',
MASTER_USER='repl', MASTER_PASSWORD='repl',
MASTER_AUTO_POSITION=1;
```

모두 ```Slave```로 등록했으면 ```Master```에 값을 저장해보고, ```Slave```에서 확인해보자.
```Master```에 저장한 내용이 ```Slave```에도 잘 저장됐다면 성공이다!

