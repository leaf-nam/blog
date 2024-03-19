---
title: "SpringBoot DataSource 이중화(CQRS 패턴) 구현"
date: 2024-03-19T20:20:06+09:00
weight: 987
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

// 실습 간단한 소개

## 프로젝트 생성

- start.spring.io
- 의존성 추가

## JpaConfig 설정

## DataSource 구현

### CommandDataSource 구현

### ReadDataSource 구현

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

| URL | 게시일자 | 방문일자 | 작성자 |
| :-- | :------- | :------- | :----- |
