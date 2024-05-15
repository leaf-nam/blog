---
title: 'JPA Cascade vs Mysql Cascade vs Orphan Removal'
date: 2024-05-13T21:01:16+09:00
weight: 5001
tags: [ "concept" ]
categories: [ "concept" ]
author: "Leaf" # ["Me", "You"] multiple authors
description: "Cascade의 개념 차이에 대해 정리합니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 개요

프로젝트를 하던 중, 엔티티 연관관계에서 cascade를 잘못 사용하여 잘못된 엔티티가 삭제되었고, 테스트가 실패하는 상황이 발생했습니다.

동일한 실수를 반복하지 않도록, 이번 기회에 JPA Cascade 개념과 Orphan Removal과는 어떠한 차이가 있는지, 나아가 MySQL의 Cascade와는 어떻게 다른지 확인해보겠습니다.

## JPA Cascade

먼저 [Java EE 6의 가이드](https://docs.oracle.com/javaee/6/tutorial/doc/bnbqa.html#gjjnj)에는 다음과 같이 명시되어 있습니다.

{{<figure src="cascade_jpa.png" caption="Java EE6 가이드의 CASCADE 설명">}}

설명을 읽어보면 Cascade는 영속성 컨텍스트(Persistence Context)에 부모(Cascade옵션을 작성하는 엔티티)가 특정 작업을 수행할 때, 연관된 엔티티(이후 자식이라고 하겠습니다)도 같은 작업을
수행해야 함을 명시하고 있습니다.

자세한
내용은 [Hibernate의 공식문서](https://docs.jboss.org/hibernate/orm/7.0/userguide/html_single/Hibernate_User_Guide.html#pc-cascade)[^1]
를 살펴보면 더욱 이해하기 좋은 것 같습니다.

위 문서의 본문 예시를 참조하면 각 옵션의 주요 기능을 알 수 있습니다.[^2]

### 1. ALL

- 아래 모든 기능들을 포함하는 속성입니다.

```java

@Entity
public class Person {

    @Id
    private Long id;

    private String name;

    // Cascade가 All로 설정되어 모든 옵션이 적용되어 있습니다.
    @OneToMany(mappedBy = "owner", cascade = CascadeType.ALL)
    private List<Phone> phones = new ArrayList<>();

    // Getter, Setter 생략

    public void addPhone(Phone phone) {
        this.phones.add(phone);
        phone.setOwner(this);
    }
}

@Entity
public class Phone {

    @Id
    private Long id;

    @Column(name = "`number`")
    private String number;

    @ManyToOne(fetch = FetchType.LAZY)
    private Person owner;

    // Getter, Setter 생략
}
```

### 2. PERSIST

- persist[^3] 될 때 자식을 함께 저장합니다.

```java
// given
Person person = new Person();
person.setId(1L);
person.setName("John Doe");

Phone phone = new Phone();
phone.setId(1L);
phone.setNumber("123-456-7890");

person.addPhone(phone);

// when : cascade = PERSIST를 설정한 경우,
entityManager.persist(person);

// then : 다음과 같이 2개의 Insert 쿼리가 나갑니다.
INSERT INTO Person(name, id) VALUES( 'John Doe',1)

INSERT INTO Phone( `number`, person_id, id) VALUES( '123-456-7890',1,1)
```

### 3. MERGE

- 부모의 상태를 병합[^4]할 때, 자동으로 자식의 상태를 함께 확인해서 병합합니다.

```java
// given
Phone phone = entityManager.find(Phone.class, 1L);
Person person = phone.getOwner();

person.setName("John Doe Jr.");
phone.setNumber("987-654-3210");

entityManager.clear();

// when : cascade = MERGE를 설정한 경우,
entityManager.merge(person);

// then : 객체를 채우기 위해 다음과 같이 자동으로 Fetch Join이 나갑니다.
SELECT
  p.id as id1_0_1_,
  p.name as name2_0_1_,
  ph.owner_id as owner_id3_1_3_,
  ph.id as id1_1_3_,
  ph.id as id1_1_0_,
  ph."number" as number2_1_0_,
  ph.owner_id as owner_id3_1_0_
FROM
  Person p
LEFT OUTER JOIN
  Phone ph
      on p.id=ph.owner_id
WHERE
  p.id = 1
```

### 4. REMOVE

- 부모가 삭제될 떄 자식을 함께 삭제합니다. 참고로 Hibernate에는 DELETE라는 속성도 있는데 같은 동작이라고 합니다.
```java
// given : cascade = MERGE로 자식도 함께 영속성 컨텍스트로 불러와집니다.
Person person = entityManager.find(Person.class, 1L);

// when : cascade = REMOVE를 설정한 경우, 
entityManager.remove(person);

// then : 부모가 삭제되기 전 자식을 먼저 삭제합니다.
DELETE FROM Phone WHERE id = 1

DELETE FROM Person WHERE id = 1
```

### 5. DETACH

- 부모가 분리[^5]될 때, 자식도 함께 분리합니다.
```java
// given : cascade = MERGE로 자식도 함께 영속성 컨텍스트로 불러와집니다.
Person person = entityManager.find(Person.class, 1L);
Phone phone = person.getPhones().get(0);
assertTrue(entityManager.contains(person));
assertTrue(entityManager.contains(phone));

// when : cascade = DETACH를 설정한 경우, 
entityManager.detach(person);

// then : 부모가 컨텍스트에서 분리될 떄, 자식도 함께 분리합니다.
assertFalse(entityManager.contains(person));
assertFalse(entityManager.contains(phone));
```

### 6. Hibernate 추가 명세

- Hibernate에서는 추가로 LOCK, REFRESH, REPLICATE 세가지 옵션을 더 지원합니다.

#### LOCK

```java
// given : person 영속성 컨텍스트로 불러오기
Person person = entityManager.find(Person.class, 1L);
assertEquals(1, person.getPhones().size());
Phone phone = person.getPhones().get(0);
assertTrue(entityManager.contains(person));
assertTrue(entityManager.contains(phone));

// person 분리
entityManager.detach(person);
assertFalse(entityManager.contains(person));
assertFalse(entityManager.contains(phone));

// when : 
entityManager.unwrap(Session.class)
		.lock(person, new LockOptions(LockMode.NONE));

// then
assertTrue(entityManager.contains(person));
assertTrue(entityManager.contains(phone));
```

#### REFRESH

#### REPLICATE

## Orphan Removal

## MySQL Cascade

## 결론

## References

| URL | 게시일자 | 방문일자 | 작성자 |
|:----|:-----|:-----|:----|

[^1]: Hibernate는 JPA 명세의 구현체입니다.
[^2]: 쉬운 이해를 위해 별도의 예시를 만들기보다 본문 링크에 있는 예시를 최대한 그대로 시용하겠습니다.
[^3]: Spring Data JPA의 Repository에서는 save()메서드에 해당합니다.
[^4]: [JPA 공식문서](https://download.oracle.com/otndocs/jcp/persistence-2_2-mrel-eval-spec/index.html)에서는 Merge에 대해 다음과 같이 설명하고 있습니다.
    - The merge operation allows for the propagation of state from detached entities onto persistent entities
    managed by the entity manager.
    > 병합(merge) 작업은 분리(detached)된 엔티티에서의 상태를 엔티티 매니저(entity manager)가 관리하는 영속 엔티티로 전파할 수 있도록 합니다.
    - 즉, 위 예시에서는 영속 상태의 엔티티를 영속성 컨텍스트에 불러오는 과정에서 Merge 옵션이 있으면 부모와 자식을 한번에 가져오는 것으로 이해할 수 있습니다.
[^5]: [JPA 공식문서](https://download.oracle.com/otndocs/jcp/persistence-2_2-mrel-eval-spec/index.html)에서는 다음과 같은 상황에서 분리가 발생한다고 설명하고 있습니다.
    1. 트랜잭션 스코프(persistence context)의 영속성 컨텍스트를 사용하는 경우, 트랜잭션 커밋 시
    2. 트랜잭션 롤백 시
    3. 엔티티를 영속성 컨텍스트에서 분리(detach)하는 경우
    4. 영속성 컨텍스트를 비우는 경우
    5. 엔티티 매니저를 닫는 경우
    6. 엔티티를 직렬화하거나 엔티티를 값으로 전달할 때(예: 다른 애플리케이션 계층으로, 원격 인터페이스를 통해 등)
