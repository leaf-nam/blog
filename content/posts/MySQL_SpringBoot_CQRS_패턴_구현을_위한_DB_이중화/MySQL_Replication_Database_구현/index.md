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
>
> - Docker : v25.0.3
> - MySQL : v8.3.0

시작에 앞서 간단히 Replication의 원리를 확인해보겠습니다.

{{<figure src="replication.jpg" caption="Slave DB는 Master DB의 로그파일을 참조하여 변경사항을 업데이트 합니다.">}}

1. **Master DB**는 데이터 변경사항을 **Binary log 파일**에 저장합니다.
2. **Slave DB**는 Binary log 파일의 변경사항을 감시하다가, **변경이 발생하면 해당 로그를 확인**합니다.
3. 변경사항을 Relay log파일에 적용합니다.
4. SQL Thread는 Relay log파일의 변경사항을 감시하다가, **변경이 발생하면 DB에 반영**합니다.

그럼 이제 본격적으로 MySQL Master DB와 Slave DB를 Docker 이미지로 생성하고, Replication 설정을 통해 Master DB의 변경사항을 Slave DB로 복제하는 실습을 진행하겠습니다.

## MySQL Docker 생성

Docker[^1]를 통해 가상 OS에 2개(Master, Slave)의 MySQL 서버를 생성해보겠습니다.

### MySQL Docker 이미지 다운로드

- [Docker 이미지 경로](https://hub.docker.com/_/mysql)에서 다운로드 받거나, 아래 명령어를 shell에서 사용합니다.
  ```docker
  docker pull mysql:8.3.0
  ```

### Master DB 생성

- Master DB를 다운로드 받은 Docker Image를 통해 생성하겠습니다.

  - 포트는 **3307 포트**를 사용하겠습니다.
  - **환경변수[^2]에 주의**해서 명령어를 입력해주세요.

    ```docker
    docker run -it --name mysql_master -p 3307:3307 -e MYSQL_ROOT_PASSWORD=1234 -e MYSQL_DATABASE=target_db -e MYSQL_USER=master_user -e MYSQL_PASSWORD=1234 -d mysql:8.3.0 --log-bin=master-bin --server-id=1 --port=3307 --default_authentication_plugin=mysql_native_password
    # 붙여넣기를 위해 줄바꿈을 하지 않았습니다. 환경변수와 설정에 대한 자세한 설명은 아래나 공식문서 참고해주세요.
    # -e MYSQL_ROOT_PASSWORD : 루트 계정의 비밀번호를 설정합니다.
    # -e MYSQL_DATABASE : 해당 이름의 데이터베이스를 생성합니다.
    # -e MYSQL_USER : 해당 유저를 생성합니다.
    # -e MYSQL_PASSWORD : 해당 유저의 비밀번호를 설정합니다.
    # --log-bin : 변경사항을 저장할 바이너리 로그파일의 이름을 설정합니다.
    # --server-id : 서버 식별자를 사용합니다. 통상 master id를 1, 나머지 id를 2 ~ 2^32-1로 설정하면 됩니다.
    # --port : MySQL을 실행할 컨테이너 내부 포트 주소를 변경합니다.
    # --default_authentication_plugin : 접속 시 암호화된 비밀번호를 사용할지 여부를 결정합니다. 위와 같이 설정하면 암호화를 사용하지 않습니다.
    # 공식문서 : https://hub.docker.com/_/mysql
    ```

### Slave DB 생성

- Slave DB의 내부 데이터베이스는 Master DB를 복제하기 때문에 동일한 이름으로 지정해야 합니다.

  - 포트는 **3308 포트**를 사용하겠습니다.

    ```docker
    docker run -it --name mysql_slave -p 3308:3308 -e MYSQL_ROOT_PASSWORD=1234 -e MYSQL_DATABASE=target_db -e MYSQL_USER=slave_user -e MYSQL_PASSWORD=1234 -d mysql:8.3.0 --log-bin=master-bin --server-id=2 --read-only=1 --port=3308 --default_authentication_plugin=mysql_native_password
    # --read-only=1 : 읽기전용 DB로 설정하여 Master DB와의 데이터 정합성이 깨지지 않도록 합니다.
    ```

## Master DB 설정

Slave DB가 Master DB의 정보를 받아오기 위해서는 Master 계정을 설정하고 로그파일을 확인해주어야 합니다.

### 계정 생성 및 권한 설정

- Slave DB를 연결하려면 Master DB에서 Master 계정을 생성한 후 **외부 접근 권한을 가능하도록 변경**해야 합니다.

  - Container 내부로 접근

    ```docker
    docker exec -it mysql_master /bin/bash
    ```

  - MySQL root 계정에 접속

    ```shell
    mysql -u root -p
    # 1234 입력
    ```

  - Master 계정 권한 변경

    ```mysql
    GRANT REPLICATION SLAVE ON *.* TO 'master_user'@'%';
    ```

### 로그파일 확인

- 이제 Master DB에서 변경사항이 발생하면 자동으로 업데이트 되는 로그파일을 확인해보겠습니다.

  - Slave DB에서 해당 파일을 모니터링하기 때문에, 해당 파일의 **이름과 포지션 값**을 연동해야 합니다.

    ```mysql
    SHOW MASTER STATUS\G;
    # +-------------------+----------+--------------+------------------+-------------------+
    # | File              | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
    # +-------------------+----------+--------------+------------------+-------------------+
    # | master-bin.000003 |      385 |              |                  |                   |
    # +-------------------+----------+--------------+------------------+-------------------+
    # 상태메시지 중 {File명}과 {Position} 확인 후 별도 저장
    ```

### Docker IP주소 확인

- Replication 설정 전에 Master DB의 **Docker IP 주소**를 확인해야 합니다.

  - mysql, Container 종료

    ```mysql
    exit
    #Bye
    exit
    #exit
    ```

  - Docker inspect를 통해 컨테이너 IP주소 확인

    ```docker
    docker inspect mysql_master
    #...(생략)
    #        "Gateway": "172.17.0.1",
    #        "GlobalIPv6Address": "",
    #        "GlobalIPv6PrefixLen": 0,
    #        "IPAddress": "172.17.0.2"
    #...(생략)
    ```

## Slave DB 설정

그럼 이제 Slave DB가 Master DB의 Log파일을 참조하도록 설정해보겠습니다.

### Replication 설정

- Slave DB에 접속해서 Replication 설정을 합니다.

  (master에 접속한 터미널은 그대로 두고, 별도의 터미널을 실행하시는 것을 권장합니다.)

  - Container 내부로 접근

    ```docker
    docker exec -it mysql_slave /bin/bash
    ```

  - MySQL root 계정에 접속

    ```shell
    mysql -u root -p
    # 1234 입력
    ```

    > slave 설정은 root 권한이 필요합니다.

  - Replication 설정을 합니다. 이 때, **쉼표와 자료형 문법에 주의**해야 합니다.[^3]

    ```mysql
    mysql> CHANGE REPLICATION SOURCE TO
    # 위에서 확인한 Master DB docker 내부주소를 입력합니다.
    mysql> SOURCE_HOST='{Master DB docker 내부주소}',
    mysql> SOURCE_PORT=3307,
    mysql> SOURCE_USER='master_user',
    mysql> SOURCE_PASSWORD='1234',
    # 아까 확인한 바이너리 로그파일의 이름 및 포지션을 적어야 합니다.
    mysql> SOURCE_LOG_FILE='{File명}',
    mysql> SOURCE_LOG_POS={Position};
    ```

  - Replication 동작을 시작합니다.
    ```mysql
    mysql> START SLAVE;
    # 만약 replication 설정을 변경하려면 'STOP SLAVE;'로 동작을 종료한 후 위 명령어를 통해 변경해야 합니다.
    ```

### 연결 완료여부 확인

- 이제 Slave 설정이 정상적으로 완료되었는지 확인해보겠습니다.

  ```mysql
  SHOW SLAVE STATUS\G;
  #  +----------------------------------+-------------+-------------+-------------+---------------+-------------------+---------------------+-------------------------------+---------------+-----------------------+------------------+-------------------+-----------------+---------------------+--------------------+------------------------+-------------------------+-----------------------------+------------+------------+--------------+---------------------+-----------------+-----------------+----------------+---------------+--------------------+--------------------+--------------------+-----------------+-------------------+----------------+-----------------------+-------------------------------+---------------+---------------+----------------+----------------+-----------------------------+------------------+--------------------------------------+-------------------------+-----------+---------------------+----------------------------------------------------------+--------------------+-------------+-------------------------+--------------------------+----------------+--------------------+--------------------+-------------------+---------------+----------------------+--------------+--------------------+------------------------+-----------------------+-------------------+
  #| Slave_IO_State                   | Master_Host | Master_User | Master_Port | Connect_Retry | Master_Log_File   | Read_Master_Log_Pos | Relay_Log_File                | Relay_Log_Pos | Relay_Master_Log_File | Slave_IO_Running | Slave_SQL_Running | Replicate_Do_DB | Replicate_Ignore_DB | Replicate_Do_Table | Replicate_Ignore_Table | Replicate_Wild_Do_Table | Replicate_Wild_Ignore_Table | Last_Errno | Last_Error | Skip_Counter | Exec_Master_Log_Pos | Relay_Log_Space | Until_Condition | Until_Log_File | Until_Log_Pos | Master_SSL_Allowed | Master_SSL_CA_File | Master_SSL_CA_Path | Master_SSL_Cert | Master_SSL_Cipher | Master_SSL_Key | Seconds_Behind_Master | Master_SSL_Verify_Server_Cert | Last_IO_Errno | Last_IO_Error | Last_SQL_Errno | Last_SQL_Error | Replicate_Ignore_Server_Ids | Master_Server_Id | Master_UUID                          | Master_Info_File        | SQL_Delay | SQL_Remaining_Delay | Slave_SQL_Running_State                                  | Master_Retry_Count | Master_Bind | Last_IO_Error_Timestamp | Last_SQL_Error_Timestamp | Master_SSL_Crl | Master_SSL_Crlpath | Retrieved_Gtid_Set | Executed_Gtid_Set | Auto_Position | Replicate_Rewrite_DB | Channel_Name | Master_TLS_Version | Master_public_key_path | Get_master_public_key | Network_Namespace |
  #+----------------------------------+-------------+-------------+-------------+---------------+-------------------+---------------------+-------------------------------+---------------+-----------------------+------------------+-------------------+-----------------+---------------------+--------------------+------------------------+-------------------------+-----------------------------+------------+------------+--------------+---------------------+-----------------+-----------------+----------------+---------------+--------------------+--------------------+--------------------+-----------------+-------------------+----------------+-----------------------+-------------------------------+---------------+---------------+----------------+----------------+-----------------------------+------------------+--------------------------------------+-------------------------+-----------+---------------------+----------------------------------------------------------+--------------------+-------------+-------------------------+--------------------------+----------------+--------------------+--------------------+-------------------+---------------+----------------------+--------------+--------------------+------------------------+-----------------------+-------------------+
  #| Waiting for source to send event | 172.17.0.2  | master_user |        3307 |            60 | master-bin.000003 |                 901 | a25cfc1154fc-relay-bin.000002 |           845 | master-bin.000003     | Yes              | Yes               |                 |                     |                    |                        |                         |                             |          0 |            |            0 |                 901 |            1063 | None            |                |             0 | No                 |                    |                    |                 |                   |                |                     0 | No                            |             0 |               |              0 |                |                             |                1 | fb49312a-e4e3-11ee-a432-0242ac110002 | mysql.slave_master_info |         0 |                NULL | Replica has read all relay log; waiting for more updates |                 10 |             |                         |                          |                |                    |                    |                   |             0 |                      |              |                    |                        |                     0 |                   |
  #+----------------------------------+-------------+-------------+-------------+---------------+-------------------+---------------------+-------------------------------+---------------+-----------------------+------------------+-------------------+-----------------+---------------------+--------------------+------------------------+-------------------------+-----------------------------+------------+------------+--------------+---------------------+-----------------+-----------------+----------------+---------------+--------------------+--------------------+--------------------+-----------------+-------------------+----------------+-----------------------+-------------------------------+---------------+---------------+----------------+----------------+-----------------------------+------------------+--------------------------------------+-------------------------+-----------+---------------------+----------------------------------------------------------+--------------------+-------------+-------------------------+--------------------------+----------------+--------------------+--------------------+-------------------+---------------+----------------------+--------------+--------------------+------------------------+-----------------------+-------------------+
  ```

  > Last_Error 메시지가 없고, Slave_SQL_Running_State에 'Replica has read all relay log; waiting for more updates' 라고 되어있으면 성공적으로 연결된 상태입니다.

- Master DB에서 해당 DB에 Table을 생성하고, 컬럼을 추가해보겠습니다.

  - Container 내부로 접근

    ```docker
    docker exec -it mysql_master /bin/bash
    ```

  - MySQL master 계정에 접속

    ```shell
    mysql -u master_user -p
    # 1234 입력
    ```

  - 테이블 및 컬럼 추가

    ```mysql
    # master shell
    mysql> USE target_db;
    mysql> CREATE TABLE test(id int, name varchar(10));
    mysql> INSERT INTO test(id, name) VALUES(1, 'leaf');
    ```

- Slave DB에서 해당 변경사항을 인식하는지 확인해보겠습니다.

  - Container 내부로 접근

    ```docker
    docker exec -it mysql_slave /bin/bash
    ```

  - MySQL slave 계정에 접속

    ```shell
    mysql -u slave_user -p
    # 1234 입력
    ```

  - 컬럼 확인
    ```mysql
    # slave shell
    mysql> USE target_db;
    mysql> SELECT * FROM test;
    # +------+------+
    # | id   | name |
    # +------+------+
    # |    1 | leaf |
    # +------+------+
    # 1 row in set (0.00 sec)
    # 위와 같이 테이블 및 컬럼이 정상 조회되면 성공입니다.
    ```

## 결론

**지금까지 Mysql과 Docker로 Replication을 구현하여 DB를 이중화 해보았습니다.**

다음 시간에는 Master, Slave DB를 SpringBoot와 Datasource로 연동하여 Application 내부에서 CRUD를 수행해 보겠습니다.

## References

| URL                                                      | 게시일자 | 방문일자    | 작성자 |
| :------------------------------------------------------- | :------- | :---------- | :----- |
| https://dev.mysql.com/doc/refman/8.0/en/replication.html | -        | 2024.03.13. | MySQL  |
| https://hub.docker.com/_/mysql                           | -        | 2024.03.13. | MySQL  |

[^1]: Docker는 가상화된 컨테이너를 생성 및 관리해주는 프로그램입니다. Docker가 설치되지 않았다면, [Docker 홈페이지](https://www.docker.com/products/docker-desktop/)를 통해 Docker Desktop을 설치 후 진행해주세요.
[^2]: 전체 환경변수는 [Docker 문서]()에서 확인하실 수 있습니다.
[^3]: MySQL문법과 동일하게 값(컬럼) 사이에는 쉼표를 적고, 정수형(Integer)은 따옴표를 적지 않으며 문자형(varchar)은 따옴표를 명시해야 MySQL이 해당 구문을 인식합니다.
