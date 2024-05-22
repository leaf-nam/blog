---
title: "MySQL - SpringBoot CQRS 패턴 구현을 위한 DB 이중화"
date: 2024-03-10T21:16:28+09:00
weight: 990
tags: ["replication", "mysql", "springboot", "implement"]
categories: ["database"]
author: "Leaf"
description: "CQRS패턴을 구현하기 위해 DB를 이중화하고 실제로 SpringBoot에 적용합니다."
disableHLJS: true # to disable highlightjs
ShowReadingTime: false
ShowWordCount: false
cover:
  image: "database.jpeg" # image path/url
  alt: "database duplication" # alt text
  caption: "분산형 데이터베이스는 Scale out이 용이합니다." # display caption under cover
  relative: true # when using page bundles set this to true
  hidden: false # only hide on current single page
---

1. DB 이중화 및 CQRS 패턴의 중요성
2. MySQL Replication Database 구현
3. SpringBoot DataSource 이중화(CQRS 패턴) 구현
