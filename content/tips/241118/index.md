---
title: "[Java] JPA detached entity passed to persist 오류 해결하기"
date: 2024-11-18T22:53:05+09:00
weight: #1
tags: ["tips"]
categories: ["tinytips"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "detached entity passed to persist 오류를 해결합니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 상황

JPA를 사용해서 엔티티를 저장하는 로직에서 종종 발생하는 오류입니다.

> 저는 DataJpaTest를 작성하다가 `em.persist(member)` 메서드를 실행하면 발생했습니다.

## 오류 메시지

`detached entity passed to persist`오류 메시지는 다음과 같습니다.

```java
detached entity passed to persist: pull_up.infra.database.entity.Member
jakarta.persistence.EntityExistsException: detached entity passed to persist: pull_up.infra.database.entity.Member
	at org.hibernate.internal.ExceptionConverterImpl.convert(ExceptionConverterImpl.java:126)
	at org.hibernate.internal.ExceptionConverterImpl.convert(ExceptionConverterImpl.java:167)
	at org.hibernate.internal.ExceptionConverterImpl.convert(ExceptionConverterImpl.java:173)
	at org.hibernate.internal.SessionImpl.firePersist(SessionImpl.java:763)
	at org.hibernate.internal.SessionImpl.persist(SessionImpl.java:741)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:77)
	at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.base/java.lang.reflect.Method.invoke(Method.java:569)
	at org.springframework.orm.jpa.SharedEntityManagerCreator$SharedEntityManagerInvocationHandler.invoke(SharedEntityManagerCreator.java:319)
	at jdk.proxy3/jdk.proxy3.$Proxy148.persist(Unknown Source)
	at pull_up.global.entity.BaseEntityTest.testCreateAt(BaseEntityTest.java:35)
	at java.base/java.lang.reflect.Method.invoke(Method.java:569)
	at java.base/java.util.ArrayList.forEach(ArrayList.java:1511)
	at java.base/java.util.ArrayList.forEach(ArrayList.java:1511)
Caused by: org.hibernate.PersistentObjectException: detached entity passed to persist: pull_up.infra.database.entity.Member
	at org.hibernate.event.internal.DefaultPersistEventListener.persist(DefaultPersistEventListener.java:88)
	at org.hibernate.event.internal.DefaultPersistEventListener.onPersist(DefaultPersistEventListener.java:77)
	at org.hibernate.event.internal.DefaultPersistEventListener.onPersist(DefaultPersistEventListener.java:54)
	at org.hibernate.event.service.internal.EventListenerGroupImpl.fireEventOnEachListener(EventListenerGroupImpl.java:127)
	at org.hibernate.internal.SessionImpl.firePersist(SessionImpl.java:757)
	... 11 more
```

## 해석하기

오류 메시지(`detached entity passed to persist`)를 그대로 해석하면 다음과 같습니다.

> 분리된 엔티티를 저장하려고 시도했습니다.

- 그렇다면 엔티티가 분리되었다는 것은 무슨 뜻일까요?

## JPA Javadoc

- 우선 가장 위에 적힌 오류인 EntityExistsException을 [JPA Javadoc](https://jakarta.ee/specifications/platform/9/apidocs/jakarta/persistence/entityexistsexception)에서 찾아보았고, 다음과 같은 문구를 확인했습니다.

  `Thrown by the persistence provider when EntityManager.persist(Object) is called and the entity already exists. `

- 이를 해석하면 다음과 같습니다.

  `EntityManager.persist(Object) 메서드가 호출될 때, 해당 엔티티가 이미 존재하면 지속성 제공자(persistence provider)가 예외를 던집니다.`

- 대충 이미 저장된 엔티티를 다시 저장하려고 해서 발생했구나! 라고 눈치챌 수 있었습니다.
  > 그런데 저는 테스트 도중에 저장하지 않은 객체를 persist하려고 시도했는데 이러한 오류가 발생했습니다. 이에 좀더 찾아보았습니다.

## Hibernate Javadoc

- 이번에는 구현체인 Hibernate에서 발생한 원인인 PersistentObjectException 오류를 [Hibernate Javadoc](https://docs.jboss.org/hibernate/orm/6.6/javadocs/org/hibernate/PersistentObjectException.html)에서 찾아보았습니다.

  `Thrown when the user passes a persistent instance to a Session method that expects a transient instance.`

- 이를 해석하면 다음과 같습니다.

  `사용자가 세션(EntityManager 구현체)에게 임시 객체라고 판단되는 객체를 영구 객체로 전달했을때 발생합니다.`

> 즉, 세션(Entity Manager)에게 이미 저장된 임시 객체를 줘놓고 저장하라고 했으니 오류가 발생한 것입니다.

그렇다면 세션은 이러한 객체를 어떻게 임시 객체라고 판단할까요?

## Spring Data JPA Reference Docs

이는 Hibernate를 공식 구현체로 사용하는 [Spring Data JPA의 공식문서](https://docs.spring.io/spring-data/jpa/reference/jpa/entity-persistence.html#jpa.entity-persistence.saving-entities.strategies)에 좀 더 자세히 나와있습니다.

`By default Spring Data JPA inspects first if there is a Version-property of non-primitive type. If there is, the entity is considered new if the value of that property is null. Without such a Version-property Spring Data JPA inspects the identifier property of the given entity. If the identifier property is null, then the entity is assumed to be new. Otherwise, it is assumed to be not new.`

### 해석

아래는 위 원본을 해석한 것입니다.

- 기본적으로 Spring Data JPA는 다음 순서로 엔티티를 검사하여 새 엔티티인지 판단합니다:

1. **Version 속성 확인**[^1]

- Version 속성이 존재하고, 해당 속성이 **비-기본 타입(Wrapper 클래스 등)**일 경우,
  - Version 속성의 값이 null이라면 새로운 엔티티로 간주합니다.
  - Version 속성의 값이 null이 아니면 기존 엔티티로 간주합니다.

2. **Version 속성이 없는 경우**

- Identifier(식별자) 속성(Primary Key)을 검사합니다.

  - Identifier 속성의 값이 null이라면 새로운 엔티티로 간주합니다.
  - Identifier 속성의 값이 null이 아니면 기존 엔티티로 간주합니다.

## 결론

`detached entity passed to persist`가 발생하는 주요 원인은 다음과 같습니다.

1. 이미 저장된 객체를 다시 저장하려고 시도했을 때
2. Version 속성이 null이 아닌 객체를 저장하려고 했을 떄
3. 식별자(id)가 null이 아닌 객체를 저장하려고 했을 때

> 저의 경우는 테스트에서 임시로 생성한 Member 객체에 id를 설정한 뒤 저장하려고 시도해서 위 오류가 발생했습니다.

## References

| URL                                                                                                                                                      | 게시일자 | 방문일자    | 작성자    |
| :------------------------------------------------------------------------------------------------------------------------------------------------------- | :------- | :---------- | :-------- |
| [JPA Javadoc](https://jakarta.ee/specifications/platform/9/apidocs/jakarta/persistence/entityexistsexception)                                            | -        | 2024.11.18. | Jakarta   |
| [Hibernate Javadoc](https://docs.jboss.org/hibernate/orm/6.6/javadocs/org/hibernate/PersistentObjectException.html)                                      | -        | 2024.11.18. | Hibernate |
| [SpringDataJPA 공식문서](https://docs.spring.io/spring-data/jpa/reference/jpa/entity-persistence.html#jpa.entity-persistence.saving-entities.strategies) | -        | 2024.11.18. | Spring    |

[^1]: Version 속성은 JPA의 낙관적 락(Optimistic Locking)을 설정할 때 주로 사용한다고 합니다.
