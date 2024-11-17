---
title: "Lombok 생성자 주입 시 인터페이스 주입하기"
date: 2024-03-29T06:18:57+09:00
#weight: 2003
tags: ["tips", "lombok", "spring", "di"]
categories: ["tinytips"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "롬복을 활용해서 인터페이스를 생성자 주입받을 수 있습니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 인터페이스 생성자 주입

스프링에서는 의존성을 주입받는 다양한 기능이 있습니다. 그중 가장 많이들 사용하시는 롬복을 활용한 생성자 주입은 다음과 같습니다.

```java

@RequiredArgsConstructor
@Service
public class MyService {
  private final MyRepository myRepository;
}

// 빌드 시 lombok의 @RequiredArgsConstructor에 의해 추가되는 코드
public MyService(MyRepository myRepository) {
  this.myRepository = myRepository;
}
```

하지만 주입받아야 하는게 인터페이스[^1]라면 어떻게 의존성을 주입받을 수 있을까요?

> 인터페이스의 구현체가 1개라면 문제가 없지만, 여러개 있다면 문제가 됩니다. 스프링이 어떤 Bean을 주입해야 할지 선택하지 못하기 때문입니다.~~(결정장애)~~

## 직접 생성자 주입하기

정석적인 해결책입니다. lombok이 편하게 해주던 작업을 일일히 쳐주고 @Qualifier를 통해 명시해주면 됩니다.

```java
/**
 * interface인 MyRepository의 구현체로 jpaRepository와 mybatisRepository가 Bean으로 등록된 상황입니다.
 * @Repository(value = "jpaRepository")
 * @Repository(value = "mybatisRepository")
 */

@Service
public class MyService {
  private final MyRepository myRepository;

  public MyService(@Qualifier(jpaRepository) MyRepository myRepository) {
    this.myRepository = myRepository;
  }
}
```

> Lombok의 의존성을 제거할 수 있기 때문에 훨씬 좋은 코드[^2]이긴 하지만, 위의 작업이 귀찮고 롬복을 계속 사용하고 싶다면 다음 방법들을 참고하시면 됩니다.

## Primary 설정

만약 1개의 더 선호하는 Repository가 있다면 이 방법도 유용합니다.

```java
@Repository(value = "jpaRepository")
@Primary // 해당 설정으로 우선순위 부여
public class JpaRepository implements MyRepository{
  // 생략
}
```

> 그러나 2가지 Repository를 모두 사용해야 한다면 위 방법으로는 해결이 불가능합니다.

## Field Name 변경

스프링에서는 Field Name과 등록된 Bean의 이름이 같으면 자동으로 의존성을 주입해줍니다.

```java

/**
 * @Repository(value = "jpaRepository")
 * @Repository(value = "mybatisRepository")
 */

@RequiredArgsConstructor
@Service
public class MyService {

  // myRepository -> jpaRepository
  private final MyRepository jpaRepository;
}
```

> 가장 간단하게 해결이 가능합니다.

## 롬복 설정 변경

롬복 설정을 다음과 같이 바꾸면 @Qualifier를 사용할 수 있습니다.

```java
// 경로 : src/main/java/lombok.config(없으면 생성)
lombok.copyableAnnotations += org.springframework.beans.factory.annotation.Qualifier

// 위 설정 후 다음과 같이 사용 가능합니다.
@RequiredArgsConstructor
@Service
public class MyService {

  @Qualifier("jpaRepository") // Build시 @Qualifier도 함께 생성해줌!
  private final MyRepository myRepository;
}
```

> 롬복 설정을 변경하는게 귀찮기도 하지만, 종종 Field Name으로 DI가 안될때가 있습니다...(아직 원인은 찾지 못했습니다.)

## References

| URL                                                                                                   | 게시일자    | 방문일자    | 작성자     |
| :---------------------------------------------------------------------------------------------------- | :---------- | :---------- | :--------- |
| https://www.inflearn.com/questions/71872/requiredargsconstructor%EA%B3%BC-qualifier%EC%A7%88%EB%AC%B8 | 2020.10.02. | 2024.03.28. | vkdlxj3562 |

[^1]: 인터페이스는 구현체가 아니기 때문에 Bean으로 등록할 수 없습니다.
[^2]: 단위테스트를 하기 좋은 코드이기도 합니다. 참고로 아래와 같이 Spring에 의존하지 않고도 테스트할 수 있습니다.

    ```java
    @Test
    @DisplayName("스프링 컨테이너에 의존하지 않은 테스트")
    void dependencyInjectionWithoutSpringTest() {
        // given
        MyRepository myRepository = new JpaRepository();

        // when
        MyService myService = new MyService(myRepository);

        // then
        assertThat(myService).isNotNull();
        assertThat(myService.getMyRepository()).isNotNull();
        assertThat(myService.getMyRepository()).isInstanceOf(MyRepository.class);
    }
    ```
