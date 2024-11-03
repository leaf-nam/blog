---
title: "DB 이중화 및 CQRS 패턴의 중요성"
date: 2024-03-11T22:51:52+09:00
weight: 4
tags: ["replication", "architecture", "CQRS"]
categories: ["database"]
author: "Leaf"
description: "CQRS패턴을 구현하기 위한 DB이중화 기법에 대해 알아봅니다."
cover:
  image: "cover.jpg" # image path/url
  alt: "replication" # alt text
  caption: "DB를 이중화하는 것은 선택이 아닙니다." # display caption under cover
  relative: false # when using page bundles set this to true
  hidden: true # only hide on current single page
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
---

## 도입

우리가 일상에서 매일 접속하는 인터넷은 전세계의 수많은 사용자가 사용하는 만큼 항상 엄청난 트래픽이 발생합니다. 이러한 트래픽의 가장 중심에는 데이터베이스가 있습니다. 결국 사용자는 데이터베이스를 통해 다양한 정보를 획득합니다.

이러한 데이터베이스의 성능을 늘리기 위해 개발자들은 다양한 시도를 합니다. 그중에서도 이번에는 데이터베이스 이중화와 CQRS 패턴에 대해 알아보고, 이를 실제로 가상서버 및 코드로 구현해보려 합니다.

## DB 이중화 기법

데이터베이스 이중화에는 다양한 장점이 있습니다. 대표적으로

1. **장애 대응(Failover)** : DB가 1개라면, 해당 DB가 다양한 원인[^1]에 의해 장애가 발생했을 시 서비스 운영이 불가능합니다. DB를 이중화한다면 이러한 장애에 신속히 대응할 수 있으며, 차후 손실된 데이터를 복구하는 것도 가능합니다.
2. **부하 분산(Load Balancing)** : 하나의 DB가 받던 부하를 여러 DB로 분산한다면, 병목현상으로 인한 장애를 예방할 수 있을 뿐 아니라, 요청에 대한 신속한 응답을 기대할 수 있습니다.

또한, DB 이중화 기법을 통해 시스템의 두가지 성질을 달성할 수 있습니다.

- **HA(High Availability; 고가용성)**
  - 시스템을 최대한 중단 시간 없이 운영할 수 있는 특성을 말합니다.
  - HA를 판단하는 기준은 Availability가 있으며, 가용성에 따른 서비스 제공시간[^2]을 계산할 수 있습니다.
    |Availability |Downtime per year|
    |-------------|-------|
    |90% |36.5일|
    |99.99% |52.6분|
    |99.999% |5분 26초|
    |...|...|
    |99.9999999%|31.56 밀리초|
- **DR(Disaster Recovery; 재해복구)**
  - 자연재해 혹은 인위적 사고로부터 핵심 시스템을 복구하는 절차 혹은 지속성을 말합니다.
  - 이러한 DR의 목표와 실제는 RPO, RTO, RTA로 나뉘게 됩니다.
  - RTO(Recovery Time Objective) : 비즈니스의 지속성을 위한 복구 목표시간입니다.
  - RTA(Recovery Time Actual) : 실제 복구하는데 걸리는 시간입니다.
  - RPO(Recovery Point Objective) : 사고가 발생하면서 실제로 손실이 발생하는 시간입니다.
    {{<figure src="dr_rpo_rto.png" caption="RTO, RPO에 대한 설명" link="https://en.wikipedia.org/wiki/Disaster_recovery">}}

그럼 이러한 이중화 기법에는 어떠한 것이 있는지 알아보겠습니다.

> 사실 인프라나 하드웨어적 측면에서 훨씬 다양한 기법들이 있고, 오늘은 단일 소프트웨어(~~취준생~~) 수준의 이중화 기법을 알아보겠습니다.

### Replication

{{<figure src="twin.jpeg" caption="쌍둥이를 만듭니다." height="500">}}

- 동일한 데이터를 가지는 복제 데이터베이스를 생성합니다.
- 마스터(master)와 슬레이브(slave)로 구성되어 슬레이브가 마스터의 데이터를 복제하는 방식으로 동작합니다.

### Clustering

{{<figure src="cluster.jpeg" caption="동일한 작업을 하는 서버를 클러스터로 분리해 가용성을 확보할 수 있습니다." link="https://ko.m.wikipedia.org/wiki/%EC%BB%B4%ED%93%A8%ED%84%B0_%ED%81%B4%EB%9F%AC%EC%8A%A4%ED%84%B0">}}

- 동일한 작업을 여러 노드를 통해 수행하는 서비스 방식을 말하며, 동일한 업무를 처리해야 하기에 동일한 정보를 가지고 있어야 합니다.
- 작업을 분산하거나 동기화하는 과정에서 오버헤드가 발생할 수 있으며, 이러한 작업 스케줄링 및 동기화가 클러스터링에서 해결해야 할 과제입니다.

### Shading

{{<figure src="sharding.png" caption="샤딩은 pk를 분배하는 전략이 중요합니다." link="https://techblog.woowahan.com/2687/">}}

- 하나의 작업을 여러 노드에 분산해서 작업하는 서비스 방식을 말합니다.
- 데이터베이스에서는 데이터를 분산해서 저장하는 방식을 말하며, 이렇게 분산 저장된 데이터를 적절하게 인덱싱하는 것이 중요합니다.

> Clustering과 헷갈릴 수 있지만, Clustering은 동일한 DB를 여러개 만드는 반면, Shading은 하나의 DB를 쪼개는 방식입니다.
> Shading은 수평 분할로, 한 테이블의 행을 여러개의 DB로 분리한다고 생각하며 될 것 같습니다.

## CQRS 패턴

지금까지 DB 이중화의 목적과 종류에 대해 알아보았는데요, 그럼 CQRS패턴은 무엇일까요?

### 정의

CQRS[^3]패턴은 Command(Create, Update, Delete)와 Query(Read)의 책임을 분리하라는 원칙을 구현한 패턴입니다.

### 목적

Command와 Query를 분리하는 이유는 다음과 같습니다.

1. **읽기와 쓰기의 빈도 차이** : 어플리케이션 로직을 생각해보면, 통상 쓰기보다 읽기가 훨씬 많이 발생합니다. Command와 Query를 분리한다면, Query를 수행하는 DB를 Command용 DB보다 많이 생성함으로써 이러한 비율을 맞춰 서비스를 최적화할 수 있습니다.
2. **확장성** : 위에서 설명한 비율을 고민하며 독립적으로 DB를 확장할 수 있습니다.
3. **트랜잭션** : Command는 데이터를 변경하기에 트랜잭션이 발생하며, Query는 통상 읽기 전용으로 이루어집니다. 트랜잭션을 처리하는 로직이 분리되면 데이터 변경을 위한 로직을 관리하기 쉬워집니다.
4. **보안** : 쓰기 권한을 가진 요청을 통해서만 데이터가 변경되는지 확인하기가 용이해집니다.

### 구현

이러한 CQRS패턴은 어플리케이션 계층에서도 구현할 수 있지만, 데이터베이스를 분리하여 두 작업을 원천 분리할 수 있습니다.

그 중 대표적인 방법이 위에서 설명했던 Replication을 응용한 방식입니다. Replication은 위에서 설명한 것처럼 Master DB에서 변경된 데이터를 Slave DB에서 그대로 복제하는 특징을 가지고 있습니다.

따라서 **Command는 Master DB에서 수행하고, Query는 Slave DB에서 수행**하는 방식으로 Command와 Query를 분리할 수 있습니다.

## 결론

다양한 이점을 가진 DB 이중화의 다양한 방식을 알아보았고, 이를 통해 CQRS 패턴을 구현할 수 있습니다. 다음 시간부터는 MySQL에서 제공하는 Replication기술을 활용해 SpringBoot Server에서 CQRS패턴을 활용하는 예제를 직접 구현해보겠습니다.

> 이제야 좀 기술블로그 같은 주제를 다루는 것 같네요. 앞으로도 프로젝트나 다양한 이슈로부터 얻는 노하우와 기술들을 정리해 나가겠습니다.

## References

| URL                                                                | 게시일자    | 방문일자    | 작성자              |
| :----------------------------------------------------------------- | :---------- | :---------- | :------------------ |
| https://travislife.tistory.com/29                                  | 2020.08.03. | 2024.03.12. | 트레비스의 IT라이프 |
| https://if.kakao.com/                                              | 2022.12.09. | 2024.03.12. | if-kakao-2022       |
| https://en.wikipedia.org/wiki/Disaster_recovery                    | 2024.03.05. | 2024.03.12. | wikipedia           |
| https://techblog.woowahan.com/2687/                                | 2020.07.06. | 2024.03.12. | 송재욱, 전병두      |
| https://learn.microsoft.com/ko-kr/azure/architecture/patterns/cqrs | 미등록      | 2024.03.12. | Azure Storage       |

[^1]: 개발자 혹은 DB관리자의 실수, 정전, 천재지변, 해커의 공격 등 정말 다양한 원인이 있으며 이러한 모든 원인을 회피하는 것은 불가능합니다. 실제로 [2022년 10월 15일 발생한 카카오 데이터센터 화재](https://www.kakaocorp.com/page/detail/9902)로 1개월 이상 복구작업을 하기도 했습니다.
[^2]: 고가용성 시스템을 추구하는 [Erlang](https://www.erlang-solutions.com/) 은 nine nines(99.9999999%)를 달성했다고 하네요.
[^3]: Command and Query Responsibility Segregation; 명령과 쿼리 분리의 원칙입니다.
