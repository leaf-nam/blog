---
title: "MySQL Replication Database 구현"
date: 2024-03-13T23:07:00+09:00
weight: 988
tags: ["replication", "mysql", "docker", "shell"]
categories: ["database"]
author: "Leaf"
description: "Docker와 MySQL을 활용하여 Replication Database를 구현하는 실습을 진행합니다."
cover:
  image: "mysql_replication.webp" # image path/url
  alt: "mysql_repl" # alt text
  caption: "MySQL Replication은 Master와 Slave로 구성됩니다. 이미지 출처 : https://blog.knoldus.com/mysql-replication/" # display caption under cover
  relative: false # when using page bundles set this to true
  hidden: true # only hide on current single page
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
---

## 도입

> 이전 포스팅 참조 :
> [DB 이중화 및 CQRS 패턴의 중요성](https://leaf-nam.github.io/posts/240310_mysql_springboot_cqrs_%ED%8C%A8%ED%84%B4_%EA%B5%AC%ED%98%84%EC%9D%84_%EC%9C%84%ED%95%9C_db_%EC%9D%B4%EC%A4%91%ED%99%94/240313_mysql_replication_database_%EA%B5%AC%ED%98%84/)
> 실습환경

- Docker :
- MySQL :

시작에 앞서 간단히 Replication의 원리를 설명드리겠습니다.
<그림>
위에서 보시는 것처럼, Slave DB는 Master DB의 로그파일을 참조하여 변경사항을 업데이트 합니다.

그럼 이제 본격적으로 MySQL Master DB와 Slave DB를 Docker 이미지로 생성하고, Replication 설정을 통해 Master DB의 변경사항을 Slave DB로 복제하는 실습을 진행하겠습니다.

## MySQL Docker 생성

Docker[^1]를 통해 가상 OS에 2개(Master, Slave)의 MySQL 서버를 생성해보겠습니다.

### MySQL Docker 이미지 다운로드

- Docker 이미지 경로 :

### Master DB 생성

- Master DB를 다운로드 받은 Docker Image를 통해 생성하겠습니다.
- 환경변수[^2]를 주의해서 명령어를 입력해주세요.

  ```docker
  docker run -it --name master_mysql -e MYSQL_ROOT_PASSWORD=1234 -e MYSQL_DATABASE=target_db -e MYSQL_USER=master_user -e MYSQL_PASSWORD=1234 -p 3308:3308 -d mysql
  # 붙여넣기를 위해 줄바꿈 하지 않았습니다. 환경변수에 대한 자세한 설명은 위 주석이나 다음 링크를 참고해주세요.
  #
  ```

### Slave DB 생성

- Slave DB의 내부 데이터베이스는 Master DB를 복제하기 때문에 동일한 이름으로 지정해야 합니다.

  ```docker
  docker run -it --name slave_mysql -e MYSQL_ROOT_PASSWORD=1234 -e MYSQL_DATABASE=target_db -e MYSQL_USER=slave_user -e MYSQL_PASSWORD=1234 -p 3308:3308 -d mysql
  ```

## Master DB 설정

Slave DB가 Master DB의 정보를 받아오기 위해서는 로그파일를 생성하고, 권한 및 접근설정을 해주어야 합니다.

### 환경설정

- Replication을 설정하기 전, 환경설정을 통해 서버 식별자 및 mysql 로그파일을 생성해야 합니다.
- Docker Desktop을 활용해 설정파일을 직접 변경하시거나, echo 명령어나 vi편집기를 통해 간단히 설정파일을 수정할 수 있습니다.
- **아래 세가지 방법 중 편하신 방법을 사용하시면 됩니다.**

1. Docker Desktop 활용

   <사진 : docker desktop으로 환경파일 설정>

2. echo 명령어 활용

- container 내부로 접근

  ```docker
  docker exec -it mysql /bin/sh
  ```

- echo명령어로 설정파일에 설정 추가
  ```shell
  echo 뭐시기 >> /etc/mysql.conf
  echo 뭐시기 >> /etc/mysql.conf
  echo port="3307" >> /etc/mysql.conf
  ```

3. vi편집기 활용

   ```docker
   docker exec -it mysql /bin/sh
   ```

   ```shell
   # vi편집기 설치
   # vi편집기로 설정파일 열기
   vi /etc/mysql.conf
   # 설정파일 수정
   뭐시기 > 저시기
   뭐시기 > 저시기
   # 포트주소 변경
   port="3307"
   ```

### 계정 생성 및 권한 설정

- Slave DB를 연결하려면 Master DB에서 Master 계정을 생성한 후 외부 접근 권한을 가능하도록 변경해야 합니다.

- Container 내부로 접근

  ```

  ```

- MySQL에 접속

  ```

  ```

- Master계정 생성

  ```

  ```

- Master 계정 권한 변경

  ```

  ```

### 로그파일 확인

이제 Master DB에서 변경사항이 발생하면 자동으로 업데이트 되는 로그파일을 확인해보겠습니다. Slave DB에서 해당 파일을 모니터링하기 때문에, 해당 파일의 이름과 포지션 값을 지정해야 합니다.

```shell
mysql > SHOW MASTER STATUS\G
# 상태메시지 중 {File명}과 {Position} 확인 후 별도 저장
```

### Dump파일 생성

- 로그파일을 연동하기 전, Dump파일을 통해 Master DB와 Slave DB를 먼저 동기화해야 합니다.
- 먼저 Master DB에서 Dump파일을 생성하고 Local에 저장하겠습니다.

  ```

  ```

## Slave DB 설정

그럼 이제 Slave DB가 Master DB의 Log파일을 참조하도록 설정해보겠습니다.

### 환경설정

- Slave DB도 고유한 번호를 부여하여 관리해야 하므로 설정을 변경합니다.
- 또한, 읽기전용 DB로 설정하여 Slave DB가 복제가 아닌 방식으로 변경되어 Master DB와의 데이터 정합성이 깨지지 않도록 합니다.

- 환경설정 파일 변경[^0]

  ```

  ```

### Dump파일 복제

- Master DB에서 복제한 파일을 로컬을 통해 이동시킵니다.[^0]

  ```

  ```

### Replication 설정

- Slave DB에 접속해서 Replication 설정을 합니다. 이 때, 쉼표와 자료형 문법에 주의해야 합니다.[^0]

  ```

  ```

### 연결 완료여부 확인

- 이제 Slave 설정이 정상적으로 완료되었는지 확인해보겠습니다.

  ```

  ```

- 그럼 Master DB에서 해당 DB에 Table을 생성하고, 값을 변경 후 Slave DB에서 해당 변경사항을 인식하는지 확인해보겠습니다.

  ```

  ```

## 결론

## References

| URL | 게시일자 | 방문일자 | 작성자 |
| :-- | :------- | :------- | :----- |

[^1]: Docker가 설치되지 않았다면, [Docker 홈페이지]()를 통해 설치 후 진행해주세요.
[^2]: 전체 환경변수는 [Docker 문서]()에서 확인하실 수 있습니다.
[^0]:
    환경설정 파일을 변경하는 방법은 Master DB에서 사용한 방식 중 하나를 동일하게 적용하시면 됩니다.
    [^0] : Master DB Container → Local → Slave DB Container
    [^0] : MySQL문법과 동일하게 값(컬럼) 사이에는 쉼표를 적고, 정수형(Integer)은 따옴표를 적지 않으며 문자형(String)은 따옴표를 명시해야 MySQL이 해당 구문을 인식합니다.
