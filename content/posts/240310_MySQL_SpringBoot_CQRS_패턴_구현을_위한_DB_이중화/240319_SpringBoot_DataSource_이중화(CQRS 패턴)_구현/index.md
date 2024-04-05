---
title: "SpringBoot DataSource 이중화(CQRS 패턴) 구현"
date: 2024-03-19T20:20:06+09:00
weight: 9870
tags: ["springboot", "implement", "mysql", "datasource", "jpa"]
categories: ["database"]
author: "Leaf"
description: "이중화된 MySQL DB에 접근할 수 있는 DataSource를 설정합니다."
cover:
  image: "cover.png" # image path/url
  alt: "cover image" # alt text
  caption: "돌고래가 뛰어노는 스프링을 만들어봤습니다."
  relative: false # when using page bundles set this to true
  hidden: true # only hide on current single page
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
---

## 도입

> 이전 포스팅 참조 :
> [DB 이중화 및 CQRS 패턴의 중요성](https://leaf-nam.github.io/posts/240310_mysql_springboot_cqrs_%ED%8C%A8%ED%84%B4_%EA%B5%AC%ED%98%84%EC%9D%84_%EC%9C%84%ED%95%9C_db_%EC%9D%B4%EC%A4%91%ED%99%94/240313_mysql_replication_database_%EA%B5%AC%ED%98%84/) > [MySQL Replication Database 구현](https://leaf-nam.github.io/posts/240310_mysql_springboot_cqrs_%ED%8C%A8%ED%84%B4_%EA%B5%AC%ED%98%84%EC%9D%84_%EC%9C%84%ED%95%9C_db_%EC%9D%B4%EC%A4%91%ED%99%94/240313_mysql_replication_database_%EA%B5%AC%ED%98%84/)

> 실습환경
>
> - Docker : v25.0.3
> - MySQL : v8.3.0
> - Java : v17.0.9
> - Spring : v3.2.4

저번 시간에 생성한 Master / Slave DB에 SpringBoot를 직접 연동해서 CRUD를 하는 실습을 진행합니다.

## 프로젝트 생성

1. [Springboot 프로젝트](https://start.spring.io)를 생성합니다.

- 아래 사진과 같이 JPA, Lombok, MySQL Driver 의존성을 추가하겠습니다.

{{<figure src="springboot.png" caption="스프링부트 프로젝트를 위와 같이 의존성을 추가하여 생성합니다.">}}

2. build.gradle 실행

- 위에서 생성한 프로젝트의 jar파일을 풀고, build.gradle 파일을 intellij 혹은 eclipse로 실행합니다.

{{<figure src="gradle.png" caption="gradle로 프로젝트를 실행하면 자동으로 소스파일 경로가 생성됩니다.">}}

## JpaConfig 클래스 생성

원래 스프링부트에 JPA 의존성을 추가하면 기본으로 설정된 DataSource를 불러와 사용하지만, 저번 시간에 분리한 Command(쓰기)와 Query(읽기) DB를 DataSource로 사용하기 위해 다음과 같이 JpaConfig를 설정하겠습니다.

```java
package com.replication.demo.config; // config 패키지 생성

import org.springframework.context.annotation.Configuration;

@Configuration // Spring에 자동으로 Bean을 등록하기 위함
public class JpaConfig {}
```

## DataSource Bean 구현

JpaConfig내부에 DataSource를 Bean으로 등록하면, 이후 Spring이 해당 Bean의 설정을 통해 JDBC를 구현하므로 펀리하게 DB에 접근할 수 있습니다.

> 두 개의 DataSource를 각각 구현하고, Transaction시점에 필요한 DataSource를 결정할 수 있도록 Spring에서는 AbstractRoutingDataSource라는 추상클래스를 제공합니다.

### Command & Read DataSource Bean 생성

우선, 쓰기와 읽기 DataSource를 다음과 같이 JpaConfig 내부에서 Bean으로 등록합니다.

```java
@Configuration
public class JpaConfig {
  @Bean // 원본 DB와 연결된 DataSource
  @Qualifier("commandDataSource")
  public DataSource commandDataSource() {
      HikariDataSource dataSource = DataSourceBuilder.create()
              .driverClassName("com.mysql.cj.jdbc.Driver")
              .url("jdbc:mysql://localhost:3307/target_db")
              .username("master_user")
              .password("1234")
              .type(HikariDataSource.class)
              .build();
      dataSource.setMaximumPoolSize(2); // Pool Size도 설정 가능합니다.
      return dataSource;
  }

  @Bean // Repl DB와 연결된 DataSource
  @Qualifier("queryDataSource")
  public DataSource queryDataSource() {
      HikariDataSource dataSource = DataSourceBuilder.create()
              .driverClassName("com.mysql.cj.jdbc.Driver")
              .url("jdbc:mysql://localhost:3308/target_db")
              .username("slave_user")
              .password("1234")
              .type(HikariDataSource.class)
              .build();
      dataSource.setMaximumPoolSize(5); // 보통 읽기전용 작업이 더 많기 때문에 크게 설정하겠습니다.
  }
}
```

> jdbc에서 사용하는 port 및 username과 password는 [저번 시간](https://leaf-nam.github.io/posts/240310_mysql_springboot_cqrs_%ED%8C%A8%ED%84%B4_%EA%B5%AC%ED%98%84%EC%9D%84_%EC%9C%84%ED%95%9C_db_%EC%9D%B4%EC%A4%91%ED%99%94/240313_mysql_replication_database_%EA%B5%AC%ED%98%84/#master-db-%EC%83%9D%EC%84%B1)에 생성한 DB 환경변수를 참고하시면 됩니다.

### RoutingDataSource 구현

### RoutingLazyDataSource 구현

## EntityManagerFactory 구현

### DataSource 세팅

### JpaVendorAdaptor 세팅

### JpaProperties 세팅

## TransactionManager 구현

### JpaTransactionManager 주입

## 결론

## References

| URL                                                                               | 게시일자 | 방문일자    | 작성자 |
| :-------------------------------------------------------------------------------- | :------- | :---------- | :----- |
| https://docs.spring.io/spring-data/relational/reference/jdbc/getting-started.html | 미확인   | 2024.03.31. | Spring |
