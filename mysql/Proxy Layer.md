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
