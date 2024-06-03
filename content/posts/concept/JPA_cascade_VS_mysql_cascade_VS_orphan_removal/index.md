---
title: "JPA Cascade vs Orphan Removal"
date: 2024-05-13T21:01:16+09:00
weight: 5001
tags: ["concept", "JPA", "Hibernate"]
categories: ["concept", "JPA"]
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

동일한 실수를 반복하지 않도록, 이번 기회에 JPA Cascade 개념과 Orphan Removal과는 어떠한 차이가 있는지 확인해보겠습니다.

## JPA(Hibernate) Cascade

먼저 [Java EE 6의 가이드](https://docs.oracle.com/javaee/6/tutorial/doc/bnbqa.html#gjjnj)에는 다음과 같이 명시되어 있습니다.

{{<figure src="cascade_jpa.png" caption="Java EE6 가이드의 CASCADE 설명">}}

설명을 읽어보면 Cascade는 영속성 컨텍스트(Persistence Context)에 부모(Cascade옵션을 작성하는 엔티티)가 특정 작업을 수행할 때, 연관된 엔티티(이후 자식이라고 하겠습니다)도 같은 작업을
수행해야 함을 명시하고 있습니다.

자세한 내용은 [Hibernate의 공식문서](https://docs.jboss.org/hibernate/orm/7.0/userguide/html_single/Hibernate_User_Guide.html#pc-cascade)[^1]
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

### 2. PERSIST[^3]

- DB에 저장될 때 자식을 함께 저장합니다.

```java
// given : Person과 phone 엔티티 생성 및 등록
Person person = new Person();
person.setId(1L);
person.setName("John Doe");
Phone phone = new Phone();
phone.setId(1L);
phone.setNumber("123-456-7890");
person.addPhone(phone);

// when : person 저장
entityManager.persist(person);

// then : 다음과 같이 2개의 Insert 쿼리가 나가면서 연관된 자식을 함께 저장합니다.
INSERT INTO Person(name, id) VALUES( 'John Doe',1)
INSERT INTO Phone( `number`, person_id, id) VALUES( '123-456-7890',1,1)
```

### 3. MERGE[^4]

- 부모의 상태를 병합할 때, 자동으로 자식의 상태를 함께 확인해서 병합합니다.

```java
// given : DB에서 엔티티 조회, 변경사항 생성 후 영속성 컨텍스트를 clear() -> 엔티티 분리
Phone phone = entityManager.find(Phone.class, 1L);
Person person = phone.getOwner();
person.setName("John Doe Jr.");
phone.setNumber("987-654-3210");
entityManager.clear();

// when : person 병합(merge)
entityManager.merge(person);

// then : 객체를 채우기 위해 다음과 같이 자동으로 Fetch Join이 나가서 자식 엔티티의 값을 채웁니다.
SELECT
  p.id as id1_0_1_,
  p.name as name2_0_1_,
  ph.owner_id as owner_id3_1_3_,
  ph.id as id1_1_3_,
  ph.id as id1_1_0_,
  ph."number" as number2_1_0_,
  ph.owner_id as owner_id3_1_0_
FROM Person p
LEFT OUTER JOIN Phone ph
  on p.id=ph.owner_id
WHERE
  p.id = 1
```

### 4. REMOVE

- 부모가 삭제될 떄 자식을 함께 삭제합니다. 참고로 Hibernate에는 DELETE라는 속성도 있는데 같은 동작이라고 합니다.

```java
// given : person을 불러오기
Person person = entityManager.find(Person.class, 1L);

// when : person 삭제
entityManager.remove(person);

// then : 부모가 삭제되기 전 자식을 먼저 삭제합니다.
DELETE FROM Phone WHERE id = 1
DELETE FROM Person WHERE id = 1
```

### 5. DETACH[^5]

- 부모가 분리될 때, 자식도 함께 분리합니다.

```java
// given : person을 불러오기
Person person = entityManager.find(Person.class, 1L);
Phone phone = person.getPhones().get(0);
assertTrue(entityManager.contains(person));
assertTrue(entityManager.contains(phone));

// when : 영속성 컨텍스트에서 Person을 분리할 경우,
entityManager.detach(person);

// then : 부모가 컨텍스트에서 분리될 떄, 자식도 함께 분리합니다.
assertFalse(entityManager.contains(person));
assertFalse(entityManager.contains(phone));
```

### 6. Hibernate 추가 명세

- Hibernate에서는 추가로 LOCK, REFRESH, REPLICATE 세가지 옵션을 더 지원합니다.
- Session에서 사용하는 위 세가지 메서드의 편의를 제공하기 위함입니다.

**CascadeType.LOCK[^6]**

- 부모 조회 시 Lock이 될때 자식도 lock에 걸릴 것 같지만, 그렇게 동작하지는 않는다고 합니다.[^7]
- Lock 옵션을 적용하여 부모를 영속성 컨텍스트에 다시 불러오면(reattach), 자식도 함께 불러오는 옵션입니다.
- 아래 예시에서 session[^8]의 Lock() 메서드를 통해 부모를 조회하면 자식 또한 함께 조회되는 것을 볼 수 있습니다.

```java
// given : person을 불러오기
Person person = entityManager.find(Person.class, 1L);
assertEquals(1, person.getPhones().size());
Phone phone = person.getPhones().get(0);
assertTrue(entityManager.contains(person));
assertTrue(entityManager.contains(phone));

// when : 부모 분리 후 lock메서드를 통해 session을 다시 불러올 경우
entityManager.detach(person);
assertFalse(entityManager.contains(person));
assertFalse(entityManager.contains(phone));
entityManager.unwrap(Session.class)
		.lock(person, new LockOptions(LockMode.NONE));

// then : 부모, 자식 한번에 조회
assertTrue(entityManager.contains(person));
assertTrue(entityManager.contains(phone));
```

**CascadeType.REFRESH[^9]**

- 부모가 새로고침(Refresh) 될 때, 자식도 함께 새로고침하는 옵션입니다.
- 정합성 보장을 위해 DB와 영속성 컨텍스트를 일치화 후 작업해야 할 때 유용할 것 같습니다.

```java
// given : person을 불러오기
Person person = entityManager.find(Person.class, 1L);
Phone phone = person.getPhones().get(0);

// when : 엔티티 값 변경 후 새로고침하기
person.setName("John Doe Jr.");
phone.setNumber("987-654-3210");
entityManager.refresh(person);

// then : 변경사항이 반영되지 않고, DB에 있는 값이 그대로 적용됨
assertEquals("John Doe", person.getName());
assertEquals("123-456-7890", phone.getNumber());
```

**CascadeType.REPLICATE[^10]**

- 부모가 다른 데이터소스를 수정할 때, 자식도 함께 수정하는 옵션입니다.
- CQRS 분리나 Scale Out등을 위해 여러 데이터소스를 함께 사용한다면 유용할 것 같습니다.

```java
// given : person과 phone 생성(저장하지 않은 상태)
Person person = new Person();
person.setId(1L);
person.setName("John Doe Sr.");
Phone phone = new Phone();
phone.setId(1L);
phone.setNumber("(01) 123-456-7890");
person.addPhone(phone);

// when : 다른 데이터소스에 있는 값 덮어쓰기
entityManager.unwrap(Session.class).replicate(person, ReplicationMode.OVERWRITE);

// then : 다음과 같이 자동으로 다른 데이터소스를 수정하는 쿼리가 나갑니다.
SELECT id FROM Person WHERE id = 1
SELECT id FROM Phone WHERE id = 1

UPDATE Person SET name = 'John Doe Sr.' WHERE id = 1
UPDATE Phone SET "number" = '(01) 123-456-7890', owner_id = 1 WHERE id = 1
```

> 지금까지 JPA와 Hibernate의 Cascade 옵션에 대해 알아보았습니다. 결국 영속성 컨텍스트에 부모-자식 엔티티를 한번에 불러오거나 생성, 변경, 삭제하는 옵션이라고 할 수 있겠습니다.

## Orphan Removal

다음은 Orphan Removal 옵션입니다.

해당 옵션에 대한 설명은 [JPA 기본 명세](https://download.oracle.com/otndocs/jcp/persistence-2_2-mrel-eval-spec/index.html) 45p에 잘 나와있습니다.(GPT 3.5 번역)

> 일대일(OneToOne) 또는 일대다(OneToMany)로 지정된 연관 관계는 orphanRemoval 옵션을 사용할 수 있습니다. orphanRemoval이 적용될 때 다음과 같은 동작이 발생합니다:

> 연관 관계의 대상이 되는 엔터티가 연관 관계에서 제거되면(예: 연관 관계를 null로 설정하거나 연관 관계 컬렉션에서 엔터티를 제거함으로써), 고아가 된 엔터티에 대해 삭제 작업이 적용됩니다. 삭제 작업은 플러시(flush) 작업 시점에 적용됩니다. orphanRemoval 기능은 부모 엔터티에 의해 개인적으로 "소유"되는 엔터티를 위해 의도된 것입니다. 이 기능을 사용할 경우, 응용 프로그램은 특정한 제거 순서에 의존해서는 안 되며, 고아가 된 엔터티를 다른 연관 관계에 재할당하거나 해당 엔터티를 지속(persist)하려고 시도해서는 안 됩니다. 고아가 된 엔터티가 분리(detached) 상태이거나, 새로 생성된 상태이거나, 삭제된 상태인 경우, orphanRemoval의 의미는 적용되지 않습니다.

> 관리되는 소스 엔터티에 대해 삭제 작업이 적용되면, 삭제 작업은 섹션 3.2.3[^11]의 규칙에 따라 연관 관계의 대상 엔터티에 전파됩니다(따라서 연관 관계에 대해 cascade=REMOVE를 명시할 필요는 없습니다).

즉, 일대일 또는 일대다 연관관계에서 **부모 엔티티의 참조가 사라지면, 영속성 컨텍스트를 flush하는 시점에 자식 엔티티를 삭제**합니다.

또한, **부모 엔티티를 삭제하면 자동으로 cascade=REMOVE를 적용한 것과 같이 자식을 삭제**하는 효과도 줍니다.

```java
// given : person을 불러오기
Person person = entityManager.find(Person.class, 1L);
Phone phone = person.getPhones().get(0);
assertEquals(phone.getId(), 1);

// when : person에서 phone 참조값 제거 후 flush
person.getPhones().set(0, null);
entityManager.flush();

// then : 참조가 사라진 자식(고아) 엔티티를 삭제합니다.
DELETE FROM Phone WHERE id = 1
```

## 결론

- 제가 잘못 이해하고 있던 부분은 CascadeType.REMOVE는 삭제되는게 아니라 영속성 컨텍스트에서 분리될 때 함께 분리된다고 생각한 점이었습니다(이 기능은 CascadeType.DETACH와 헷갈렸던 것 같습니다.).
- 사실 Orphan Removal과 CascadeType.REMOVE는 기능적으로는 동일하지만, REMOVE는 삭제(EntityManager.remove())를 명시할때만 발동되는 반면 Orphan Removal은 삭제 뿐 아니라 null이나 참조값 변경 등으로 참조가 없어질 때에도 삭제하는 것이 가장 큰 차이인 것 같습니다.
  > 확실히 두루뭉실하게 알고 있던 지식들이 공식문서를 통해 접하니 좀더 확실하게 알게 된 느낌입니다. 앞으로도 잘 모르겠다 싶으면 공식문서를 참고하는 습관을 들여야겠습니다.

## References

| URL                                                                                      | 게시일자    | 방문일자    | 작성자    |
| :--------------------------------------------------------------------------------------- | :---------- | :---------- | :-------- |
| https://docs.oracle.com/javaee/6/tutorial/doc/bnbqa.html#gjjnj                           | 2013.       | 2024.05.13. | Oracle    |
| https://docs.jboss.org/hibernate/orm/7.0/userguide/html_single/Hibernate_User_Guide.html | 2024.05.03. | 2024.05.13. | Hibernate |
| https://download.oracle.com/otndocs/jcp/persistence-2_2-mrel-eval-spec/index.html        | 2017.07.17. | 2024.05.13. | Oracle    |

[^1]: Hibernate는 JPA 명세의 구현체입니다.
[^2]: 쉬운 이해를 위해 별도의 예시를 만들기보다 본문 링크에 있는 예시를 최대한 그대로 시용하겠습니다.
[^3]: Spring Data JPA의 Repository에서 save() 메서드에 해당합니다.
[^4]:
    [JPA 공식문서](https://download.oracle.com/otndocs/jcp/persistence-2_2-mrel-eval-spec/index.html)에서는 Merge에 대해 다음과 같이 설명하고 있습니다.

    - The merge operation allows for the propagation of state from detached entities onto persistent entities
      managed by the entity manager.
      > 병합(merge) 작업은 분리(detached)된 엔티티에서의 상태를 엔티티 매니저(entity manager)가 관리하는 영속 엔티티로 전파할 수 있도록 합니다.
    - 즉, 위 예시에서는 영속 상태의 엔티티를 영속성 컨텍스트에 불러오는 과정에서 Merge 옵션이 있으면 부모와 자식을 한번에 가져오는 것으로 이해할 수 있습니다.

[^5]:
    [JPA 공식문서](https://download.oracle.com/otndocs/jcp/persistence-2_2-mrel-eval-spec/index.html)에서는 다음과 같은 상황에서 분리가 발생한다고 설명하고 있습니다.

    1. 트랜잭션 스코프(persistence context)의 영속성 컨텍스트를 사용하는 경우, 트랜잭션 커밋 시
    2. 트랜잭션 롤백 시
    3. 엔티티를 영속성 컨텍스트에서 분리(detach)하는 경우
    4. 영속성 컨텍스트를 비우는 경우
    5. 엔티티 매니저를 닫는 경우
    6. 엔티티를 직렬화하거나 엔티티를 값으로 전달할 때(예: 다른 애플리케이션 계층으로, 원격 인터페이스를 통해 등)

[^6]: Lock은 트랜잭션 발생 시 데이터 경합(충돌)이 발생할 것을 예방하기 위해, 조회 시 다른 트랜잭션을 통해 DB가 변경되지 않도록 접근을 통제하는 것을 말합니다.
[^7]: 이렇게 동작시키기 위해서는 jakarta.persistence.lock.scope = PessimisticLockScope.EXTENDED 값을 사용해야 합니다.
[^8]: Hibernate의 Session은 JPA의 영속성 컨텍스트를 구현한 개념입니다. 위 예제에서는 EntityManager의 unwrap() 메서드를 사용하여 Session을 획득한 후, lock() 메서드를 통해 잠금을 설정하고 있습니다. 이 때, CascadeType.LOCK 옵션을 통해 영속성 컨택스트에서 분리(detach)된 부모와 자식 엔티티를 한번에 가져오게 됩니다.
[^9]: Session에서 영속성 컨텍스트와 실제 Database를 동일하게 맞추는 메서드입니다. 작업 과정에서 DB가 변경되거나 트리거가 실행되어 엔티티와 DB가 다를 때 새로고침을 하여 일치화하는 메서드입니다.
[^10]: Session에 있는 엔티티를 **다른 데이터소스의 데이터**와 일치화하는 메서드입니다.
[^11]: 섹션 3.2.3은 cascade=REMOVE에 대한 설명입니다.
