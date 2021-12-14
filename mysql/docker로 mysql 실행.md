> Windows라 Centos7가 없어서 EC2 인스턴스 하나 생성하여 진행
> putty로 실행시켰고, root 가 아니라 ec2 상황에 맞게 directory 설정 잘해야함.

## ec2 생성 후 docker 설치

인스턴스에 설치한 패키지 및 패키지 캐시를 업데이트합니다.
```
sudo yum update -y
```
최신 Docker Engine 패키지를 설치합니다. Amazon Linux 2
```
sudo amazon-linux-extras install docker
```
Docker 서비스를 시작합니다.
```
sudo service docker start
```
sudo를 사용하지 않고도 Docker 명령을 실행할 수 있도록 docker 그룹에 ec2-user를 추가합니다.
```
sudo usermod -a -G docker ec2-user
```

## mysql docker에 실행

```docker
docker run -i -t --name db001 -p 3306:3306 -e MYSQL_ROOT_PASSWORD="root" -d percona:5.7.30
```
```-i, -t``` : container에 shell로 접속해서 사용할 수 있는 옵션  
```-e``` : 환경변수 세팅  

![image](https://user-images.githubusercontent.com/87312401/145951207-48b50213-b060-494c-9723-35c2983f660f.png)

> mysql에 접근

```docker
docker exec -it db001 /bin/bash
```

> IP를 이용한 접근
```docker
mysql -uroot -p {ip}
```

> Stateless  
> docker 이미지만 있으면 Container는 언제나 재시작될 수 있다. 만약 삭제 후 재시작되면 docker image는 초기 상태로 재시작된다. (Stateless)
> 이때 , DB는 데이터를 저장해야 하는데 MYSQL 컨테이너가 삭제, 재생성되면 어떻게 될까? 데이터는 날아간다.

### Volume 설정

> mysql를 local에 저장하기 위해 폴더 생성
```
mkdir -p ~/db/db001/data
```

> 권한 설정 (docker mysql 내 관련 내용 write하기 위함)
```
chmod 777 ~/db ~/db/db001 ~/db/db001/data
```

> docker volume 설정에 맞게 실행
```
docker run -i -t --name db001 -p 3306:3306 -v ~/db/db001/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD="root" -d percona:5.7.30
```

> db에 샘플 데이터를 넣어준다.

![image](https://user-images.githubusercontent.com/87312401/145982604-86b1c2a3-e3c0-4a5d-8304-f08f6d2c3d37.png)

현재 컨테이너를 삭제하고 재실행해도, 같은 데이터가 저장되어 있어야 한다.
> Volume 명령어를 통해 로컬 폴더의 db관련 내용을 mysql 디렉토리와 동기화했기 떄문에 가능

추가적으로 로깅, 설정을 로컬과 연동하기 위해서는 각 폴더, 설정파일을 생성하고 volume으로 추가하면 된다.

```
docker run -i -t --name db001 -p 3306:3306 -v ~/db/db001/data:/var/lib/mysql -v ~/db/db001/log:/var/log/mysql -v ~/db/db001/conf:/etc/percona-server.conf.d -e MYSQL_ROOT_PASSWORD="root" -d percona:5.7.30
b7f0fb9deb4d757aed3643a89be661d4e29bc5bf118c978f6038363a0b917c14

```
