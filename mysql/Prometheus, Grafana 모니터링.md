# Prometheus, Grafana 모니터링

프로메테우스로 모니터링 데이터를 수집하고, Grafana로 대시보드 형태로 시각화해보자.

## 모니터링을 왜 해야 하는가?

프로젝트를 하면서 가장 필요하다고 느낀 것이 바로 ```모니터링```이다. 사실 많은 데이터가 오고가는 프로젝트는 해본 적이 없어 대부분의 에러가 코드, 쿼리에서 발생했지만
대용량 트래픽을 가용하는 서비스를 운영한다면 코드나 쿼리는 절대 에러가 나서는 안되고 ```db io```과정에서의 에러를 최소화 해야한다는 느낌을 받았다.

에러를 최소화 하기 위해서는 여러가지 방법이 있겠지만 가장 먼저 떠오르는 것은 ```예방```이다. 하지만 언제, 왜 장애를 낼 수 있는 정도 수준의 io가 발생하는지를 알지 못한다면 당연히 예방할 수 없다.

서버 개발자라면 모니터링에 대해서는 필수적으로 알고 있어야 하며 이를 어떻게 활용할 수 있을지도 고민해야한다. 
(인프라 개발자가 환경을 세팅해주더라도, 모니터링을 통해 장애에 원활하게 대응하는 것은 서버 + 인프라 개발자가 할 일이라고 생각한다.)

## Prometheus
프로메테우스는 ```node_exporter```와 ```mysqld_exporter```의 데이터를 가져와 모니터링 데이터로 저장한다.
Percona의 ```Docker``` 이미지에는 ```node_exporter```와 ```mysqld_exporter```가 없기 떄문에, Dockerfile을 직접 커스텀해줘야한다.

ec2 컨테이너에 올려 사용중이기 떄문에 ```FileZilla```를 사용하여 설치 파일들을 로컬에서 원격 서버 내 폴더에 이동시키고, ```Dockerfile```을 커스텀하여 이미지를 생성한다.


> 강의에서 제공하는 도커 파일

1. 같은 디렉터리의 파일 들을 copy한다.
2. root, tmp, opt/exporters 디렉토리에서 run을 통해 관련 내용을 실행시킨다.
3. mysql을 3306포트에 실행시킨다.

```Dockerfile
FROM centos:7
COPY ["Percona-Server-client-57-5.7.30-33.1.el7.x86_64.rpm",\
      "Percona-Server-server-57-5.7.30-33.1.el7.x86_64.rpm", \
      "Percona-Server-shared-57-5.7.30-33.1.el7.x86_64.rpm", \
      "Percona-Server-shared-compat-57-5.7.30-33.1.el7.x86_64.rpm", \
      "node_exporter-1.0.1.linux-amd64.tar.gz", \
      "mysqld_exporter-0.12.1.linux-amd64.tar.gz", \
      "start_node_exporter.sh", \
      "start_mysqld_exporter.sh", \
      ".my.cnf","/tmp/"]
USER root
RUN groupadd -g 1001 mysql
RUN useradd -u 1001 -r -g 1001 mysql
RUN yum install -y perl.x86_64 \
    libaio.x86_64 \
    numactl-libs.x86_64 \
    net-tools.x86_64 \
    sudo.x86_64 \
    openssl.x86_64
WORKDIR /tmp/
RUN rpm -ivh Percona-Server-shared-57-5.7.30-33.1.el7.x86_64.rpm \
    Percona-Server-shared-compat-57-5.7.30-33.1.el7.x86_64.rpm \
    Percona-Server-client-57-5.7.30-33.1.el7.x86_64.rpm \
    Percona-Server-server-57-5.7.30-33.1.el7.x86_64.rpm
RUN mkdir -p /opt/exporters/ && \
    tar -xzvf ./node_exporter-1.0.1.linux-amd64.tar.gz -C /opt/exporters && \
    tar -xzvf ./mysqld_exporter-0.12.1.linux-amd64.tar.gz -C /opt/exporters
WORKDIR /opt/exporters/
RUN mv node_exporter-1.0.1.linux-amd64 node_exporter && \
    mv mysqld_exporter-0.12.1.linux-amd64 mysqld_exporter && \
    mv /tmp/start_node_exporter.sh /opt/exporters/node_exporter/ && \
    mv /tmp/start_mysqld_exporter.sh /opt/exporters/mysqld_exporter/ && \
    mv /tmp/.my.cnf /opt/exporters/mysqld_exporter/ && \
    chmod o+x /opt/exporters/node_exporter/start_node_exporter.sh && \
    chmod o+x /opt/exporters/mysqld_exporter/start_mysqld_exporter.sh && \
    rm -rf /tmp/*.rpm && \
    /usr/bin/install -m 0775 -o mysql -g mysql -d /var/lib/mysql \
    /var/run/mysqld /docker-entrypoint-initdb.d
VOLUME ["/var/lib/mysql", "/var/log/mysql","/etc/percona-server.conf.d"]
COPY ps-entry.sh /tmp/docker-entrypoint.sh
RUN chmod +x /tmp/docker-entrypoint.sh
ENTRYPOINT ["/tmp/docker-entrypoint.sh"]
USER mysql
EXPOSE 3306
CMD ["mysqld"]

```

```Dockerfile```과 COPY되어야 하는 설정, 실행 파일을 한 디렉토리에 넣고 ```Docker``` 이미지를 생성한다.

```docker
docker build -t mysql57:0.0 ./
```
해당 명령어를 실행하고 아래와 같은 화면이 나오면 성공이다.

![image](https://user-images.githubusercontent.com/87312401/146541169-4db3aad0-eae5-472e-8fa9-fdd2fee4739f.png)

만들어진 이미지로 docker 컨테이너를 실행시켜보자.

```docker
docker run -i -t --name mydb -e MYSQL_ROOT_PASSWORD="root" -d mysql57:0.0
```

### Prometheus 세팅

> ec2에서는 접근권한이 없어 root로 이동하여 하나하나 권한을 줬다.
> mysql 이라는 그룹이 이미 존재한다면 , mysql을 다른 아이디로 치환해서 사용하면 된다 !
> groupmod -g 1001 mysql 명령어를 사용하여 gid를 변경해주는 방법도 있다
```
groupadd -g 1001 mysql
useradd -u 1001 -r -g 1001 mysql
chown -R mysql:mysql /db/db001 /db/db002 /db/db003
```

```
docker run -i -t --name db001 -p 3306:3306 --net mybridge --net-alias=db001 -h db001 -v ~/db/db001/data:/var/lib/mysql -v ~/db/db001/log:/var/log/mysql -v ~/db/db001/config:/etc/percona-server.conf.d -e MYSQL_ROOT_PASSWORD="root" -d mysql57:0.0

docker run -i -t --name db002 -p 3307:3306 --net mybridge --net-alias=db002 -h db002 -v ~/db/db002/data:/var/lib/mysql -v ~/db/db002/log:/var/log/mysql -v ~/db/db002/config:/etc/percona-server.conf.d -e MYSQL_ROOT_PASSWORD="root" -d mysql57:0.0

docker run -i -t --name db003 -p 3308:3306 --net mybridge --net-alias=db003 -h db003 -v ~/db/db003/data:/var/lib/mysql -v ~/db/db003/log:/var/log/mysql -v ~/db/db003/config:/etc/percona-server.conf.d -e MYSQL_ROOT_PASSWORD="root" -d mysql57:0.0
```

> Prometheus container 실행

```
mkdir -p ~/db/prom001 ~/db/prom001/data ~/db/prom001/conf
chmod 777 ~/db/prom001 ~/db/prom001/data ~/db/prom001/conf
```

설정 디렉터리에 ```prometheus.yml``` 파일을 생성하여 각 컨테이너 별로 연결 정보를 작성한다. (node_port와 mysqld_port)
```yml
global:
  scrape_interval:     5s
  evaluation_interval: 5s

scrape_configs:
- job_name: linux_db001
  static_configs:
    - targets: ['db001:9100']
      labels:
        alias: db001
- job_name: mysql_db001
  static_configs:
    - targets: ['db001:9104']
      labels:
        alias: db001
- job_name: linux_db002
  static_configs:
    - targets: ['db002:9100']
      labels:
        alias: db002
- job_name: mysql_db002
  static_configs:
    - targets: ['db002:9104']
      labels:
        alias: db002
- job_name: linux_db003
  static_configs:
    - targets: ['db003:9100']
      labels:
        alias: db003
- job_name: mysql_db003
  static_configs:
    - targets: ['db003:9104']
      labels:
        alias: db003
```

이제 Prometheus를 실행시킨다.

```docker
docker run -i -t --name prom001 -h prom001 --net mybridge --net-alias=prom001 -p 9090:9090 -v ~/db/prom001/data:/data -v ~/db/prom001/conf:/etc/prometheus -d prom/prometheus-linux-amd64
```

프로메테우스 컨테이너가 실행되면, 모니터링 데이터를 수집할 수 있도록 ```Master``` db에 권한을 생성한다.

```mysqld
CREATE USER 'exporter'@'localhost' IDENTIFIED BY 'exporter123' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'localhost';
```

그리고 각 컨테이너 내부에서 shell script를 실행시켜 exporter가 작동할 수 있게 세팅한다.

```
docker exec db001 sh /opt/exporters/node_exporter/start_node_exporter.sh
docker exec db001 sh /opt/exporters/mysqld_exporter/start_mysqld_exporter.sh
docker exec db002 sh /opt/exporters/node_exporter/start_node_exporter.sh
docker exec db002 sh /opt/exporters/mysqld_exporter/start_mysqld_exporter.sh
docker exec db003 sh /opt/exporters/node_exporter/start_node_exporter.sh
docker exec db003 sh /opt/exporters/mysqld_exporter/start_mysqld_exporter.sh
```
이제 ```9090```포트에 접근하여 exporter가 두개씩 잘 실행되고 있는지 확인하고 아래와 같이 ```up```명령어를 입력했을 때, 각 db별로 2개씩 exporter가 돌아가면 정상적으로 실행된 것이다.

![image](https://user-images.githubusercontent.com/87312401/146548389-094af4a1-0954-4ee5-99c2-c2840a16c357.png)

### Grafana 세팅

> Grafana 컨테이너 실행

```docker
docker run -i -t --name grafana -h grafana -p 13000:3000 --net mybridge --net-alias=grafana -d grafana/grafana
```

ec2 인바운드에 13000포트를 열어두고 해당 포트로 접근하면 ```Grafana``` 메인 화면이 뜬다.
초기 Id/pw 는 admin/admin이다. 입력하고 접속해보자.

![image](https://user-images.githubusercontent.com/87312401/146549059-37651d6d-c7fc-4e7e-b648-79c334f7b6e3.png)

설정에 접근하여 ```Add datasource``` 를 클릭한다.

![image](https://user-images.githubusercontent.com/87312401/146549242-8967807c-eca9-4e3b-a83b-58875314f7e5.png)


그리고 만들어놓은 Prometheus 설정을 입력해준다.

![image](https://user-images.githubusercontent.com/87312401/146549345-e44c579e-0d9d-4005-afda-468903ef2583.png)
![image](https://user-images.githubusercontent.com/87312401/146549369-8cc131b0-fb00-4b5c-85cf-edaaea287714.png)

[링크](https://github.com/percona/grafana-dashboards/blob/main/dashboards/MySQL/MySQL_Instances_Overview.json) 의 json 파일을 받아 대시보드를 생성한다.

https://github.com/percona/grafana-dashboards/blob/main/dashboards/MySQL/MySQL_Instances_Overview.json


```Dashboard``` 에 json을  ```import``` 하여 그라파나 대시보드를 만들어주면 아래와 같이 대시보드를 확인할 수 있다 (다양한 대시보드 gui가 깃헙에 있음)

![image](https://user-images.githubusercontent.com/87312401/146551763-b13de4ec-531e-4a96-aef5-75115f0ac757.png)

