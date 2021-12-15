# orchestrator 세팅
현재 ```Master``` ```Slave``` Replication을 작동 시키고 있다. 하지만 이때, 만약 ```Master``` 서버가 죽어버린다면?
자동으로 ```Slave```를 ```Master``` 서버로 올려줘야 할 것이다. 이를 위해 오픈소스인 ```orchestrator```를 세팅하여 ```high availability```를 구성한다.


### 방법
> Orchestrator Container 실행

```docker
docker run -i -t --name orchestrator -h orchestrator --net mybridge --net-alias=orchestrator -p 3000:3000 -d openarkcode/orchestrator:latest
```
```ec2``` 인바운드로 3000번 포트를 열어준뒤, 해당 포트로 접근해본다.
아래와 같은 화면이 나오면 ```orchestrator``` 실행 성공

![image](https://user-images.githubusercontent.com/87312401/146126174-a41d0751-caf2-4087-a5b8-ac21c5c7aec1.png)

이제 ```Master``` db에 접근해서, 필요한 유저와 권한을 설정해준다.

```mysql
create user orc_client_user@'172.%' identified by 'orc_client_password';
GRANT SUPER, PROCESS, REPLICATION SLAVE, RELOAD ON *.* TO orc_client_user@'172.%'; 
GRANT SELECT ON mysql.slave_master_info TO orc_client_user@'172.%';
```

권한이 모두 설정되었으면 ```orchestrato``` 브라우저로 들어가 ```Clusters```의 ```discover``` 페이지로 이동한다.

![image](https://user-images.githubusercontent.com/87312401/146126743-c84f173b-661e-405c-a84c-d220156a0c00.png)

권한을 설정한 db의 이름을 입력한뒤 ```submit```을 클릭하고 대시보드를 확인한다.
3개의 인스턴스, 1개의 마스터, 2개의 슬레이브가 존재하면 성공이다.

![image](https://user-images.githubusercontent.com/87312401/146126805-247eeb85-520c-4f30-8255-e58de47b4fbc.png)


그렇다면 마스터 db가 장애를 발생할 때 어떻게 자동으로 ```failover```를 진행할까?

장애가 발생되면 ```orchestrator```에는 다음과 같이 에러가 발생한다.

![image](https://user-images.githubusercontent.com/87312401/146127073-15d585db-e433-4494-95b1-d2b456e1af9b.png)

화면의 ```Recover```를 클릭하고 ```7049a```를 master로 승격시켜준다.
대시보드를 확인하면, ```db001```의 인스턴스는 따로 분리되고 새로운 ```Master``` ```slave```가 구성된다  
![image](https://user-images.githubusercontent.com/87312401/146127173-0470ddd6-1ac5-427b-a84a-a759172834d1.png)

![image](https://user-images.githubusercontent.com/87312401/146127227-e5b04a56-c7f8-4dd4-8e30-51fbf44511ae.png)

이때 ```Master``` 로 전환된 ```db003```은 자동으로 ```readonly``` 설정이 OFF로 변경되었다.

![image](https://user-images.githubusercontent.com/87312401/146127562-abc85f2f-48fe-4f5e-8ae6-36a4b9ab2b4d.png)


장애가 발생한 마스터 db가 복구되면 ```db003```의 슬레이브로 변경시켜준다.

```
docker exec -it -uroot db001 /bin/bash
```

```mysql
set global read_only=1;

CHANGE MASTER TO MASTER_HOST='db003',
MASTER_USER='repl', MASTER_PASSWORD='repl',
MASTER_AUTO_POSITION=1;

start slave;
```

설정을 모두 마친뒤 다시 ```orchestrator```를 확인해보자. ```db001```이 ```db003```의 slave로 붙은 것을 확인할 수 있다.

![image](https://user-images.githubusercontent.com/87312401/146128142-1eefa8fb-9dc5-442c-b181-2d042b75111f.png)


이 ```failover``` 과정을 자동화해보자.

```orchestrator```에 접근하여 ```db003, db001``` 간에만 failover가 발생하도록 세팅해준다.
```
docker exec -it orchestrator /bin/bash
cd /etc/
vi orchestrator.conf.json

"RecoverMasterClusterFilters": [
"*"
],
"PromotionIgnoreHostnameFilters": ["db002"],

docker restart orchestrator
```

이렇게 되면 장애가 발생할 때 자동으로 ```Master```가 바뀐다. 
기존 마스터가 복구되면 다시 수동으로 ```slave```설정을 하여 세팅해주자.

다음에는 ```Master``` 가 변경되더라도 ```application```에서 자동으로 ```Master```를 바라보게 세팅해보자!


> docker host name 추가 (ex. -h db001)로 orchestrator에서 이름 안나오던 이슈 해결

![image](https://user-images.githubusercontent.com/87312401/146133723-af4206bd-23db-40dc-93a4-6636e771ee1c.png)

