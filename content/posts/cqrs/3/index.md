---
title: "[Java]SpringBoot DataSource 이중화(CQRS 패턴) 구현"
date: 2024-03-19T20:20:06+09:00
#weight: 3
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

## DataSource 구현

JpaConfig내부에 DataSource를 Bean으로 등록하면, 이후 Spring이 해당 Bean의 설정을 통해 DataSource를 생성하므로 편리하게 DB에 접근할 수 있습니다.

> 두 개의 DataSource를 각각 구현하고, Transaction시점에 필요한 DataSource를 결정할 수 있도록 Spring에서는 AbstractRoutingDataSource라는 추상클래스를 제공합니다.

### Command & Read DataSource Bean 생성

우선, 쓰기와 읽기 DataSource를 다음과 같이 JpaConfig 내부에서 Bean으로 등록합니다.

```java
@Configuration
public class JpaConfig {
  @Bean("commandDataSource") // 원본 DB와 연결된 DataSource
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

  @Bean("queryDataSource") // Repl DB와 연결된 DataSource
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

읽기전용 트랜잭션인지 여부에 따라 동적으로 DataSource를 사용해야 하므로, 스프링에게 트랜잭션 시점에 해당 작업에 대해 알려주고, 필요한 DataSource를 동적으로 불러오도록 해야 합니다.

이를 위해 다음과 같이 추상 클래스인 AbstractRoutingDataSource를 상속받는 사용자 정의 클래스를 생성합니다.

```java
    @Slf4j // AbstractRoutingDataSource 구현
    public static class ReplicationRoutingDataSource extends AbstractRoutingDataSource {
        @Override
        protected Object determineCurrentLookupKey() {
            boolean isReadOnly = TransactionSynchronizationManager.isCurrentTransactionReadOnly();
            log.info("Use ReadOnly Datasource : {}", isReadOnly);
            return isReadOnly ? "replication" : "original";
        }
    }
```

> 위 설정에서 determineCurrentLookupKey 메서드를 구현하면 동적으로 DataSource를 라우팅하는 것이 가능한데, 그 key를 TransactionSynchronizationManager[^1]의 속성값(isCurrentTransactionReadOnly; 현재 트랜잭션이 읽기전용인지?)으로 사용해서 DataSource를 읽기 / 쓰기 시점에 결정합니다.

다음으로 위 클래스를 활용해서 실제로 DataSource를 결정 후 해당 DataSource를 Bean으로 등록합니다.

ReplicationRoutingDataSource 클래스는 AbstractRoutingDataSource를 상속받고 있기 때문에 해당 추상클래스의 메서드를 사용가능하여 다음과 같이 ReadOnly 여부에 따른 데이터소스를 설정하는 것이 가능합니다.

> ReadOnly여부는 @Transactional(readOnly = true)인지를 확인하여 결정됩니다. 이 때, org.springframework.transaction.annotation.Transactional을 사용해야 함을 주의합니다. (jakarta.transactional 아님!!)

```java
    @Bean("routingDataSource") // DataSource 종류에 따른 DataSource 라우팅(변경)
    public DataSource routingDataSource(@Qualifier("commandDataSource") DataSource commandDataSource,
                                        @Qualifier("queryDataSource") DataSource queryDataSource) {
        ReplicationRoutingDataSource routingDataSource = new ReplicationRoutingDataSource();

        // DataSource 라우팅
        Map<Object, Object> dataSourceMap = new HashMap<>();
        dataSourceMap.put("command", commandDataSource);
        dataSourceMap.put("query", queryDataSource);

        // 기본 DataSource 및 ReadOnly 여부에 따른 DataSource 설정
        routingDataSource.setDefaultTargetDataSource(commandDataSource); // commandDataSource를 기본 사용
        routingDataSource.setTargetDataSources(dataSourceMap); // ReadOnly여부에 따른 DataSource 변경

        return routingDataSource;
    }
```

다음으로 위의 Bean을 LazyConnectionDataSourceProxy으로 감싸는데, 이는 트랜잭션 진입 시점이 아닌 실제 커넥션이 필요한 시점[^2]에 DataSource를 결정하기 위함입니다.

```java
    @Bean("routingLazyDataSource")  // Connection 시점에 DataSource 결정하기 위한 Proxy
    public DataSource routingLazyDataSource(@Qualifier("routingDataSource") DataSource routingDataSource) {
        return new LazyConnectionDataSourceProxy(routingDataSource);
    }
```

## EntityManagerFactory 구현

Spring에서는 트랜잭션의 동시성 문제[^3]를 해결하기 위해 EntityManager를 트랜잭션 시마다 생성하는 Factory Method 패턴을 구현하고 있습니다. 이를 위해 저희도 EntityManagerFactory에 위에서 설정한 DataSource를 직접 주입함으로써 동시성 문제를 해결할 수 있습니다.

```java
    @Bean("entityManagerFactory") // Entity 를 관리하기 위한 JPA Manager 설정
    LocalContainerEntityManagerFactoryBean entityManagerFactory(
            @Qualifier("routingLazyDataSource") DataSource dataSource) {
        LocalContainerEntityManagerFactoryBean emf = new LocalContainerEntityManagerFactoryBean();

        // DataSource 설정
        emf.setDataSource(dataSource);

        // EntityManager 가 관리할 Base Package 설정
        emf.setPackagesToScan("com.replication.demo.*");

        // Hibernate Vendor Adaptor 설정
        HibernateJpaVendorAdapter hibernateJpaVendorAdapter = new HibernateJpaVendorAdapter();
        hibernateJpaVendorAdapter.setDatabasePlatform("org.hibernate.dialect.MySQLDialect");
        emf.setJpaVendorAdapter(hibernateJpaVendorAdapter);

        // JPA 및 Hibernate 설정
        Properties properties = new Properties();
        properties.setProperty("spring.jpa.hibernate.ddl-auto", "create-drop");
        properties.setProperty("hibernate.show_sql","true");
        properties.setProperty("hibernate.format_sql","true");
        properties.setProperty("hibernate.default_batch_fetch_size", "100");
        emf.setJpaProperties(properties);

        return emf;
    }
```

> Vendor Adaptor는 JPA 구현체를 선택하기 위함이며, 보통 Hibernate를 많이 사용합니다.[^4] 기타 JPA 및 Hibernate 설정은 [JPA 공식 문서](https://docs.spring.io/spring-boot/docs/current/reference/html/application-properties.html#appendix.application-properties.data)와 [Hibernate 공식 문서](https://docs.jboss.org/hibernate/orm/6.4/userguide/html_single/Hibernate_User_Guide.html#settings)에서 더욱 자세한 옵션과 설명을 확인하실 수 있습니다.

## TransactionManager 구현

Spring에서 @Transactional를 통해 트랜잭션이 발생하면, Spring Container에서 TransactinManager를 불러와 트랜잭션을 수행합니다. 이 때, 위에서 구현한 DataSource와 EntityManager를 사용해서 트랜잭션을 수행하도록 하겠습니다.

```java
    @Bean("transactionManager")  // 트랜잭션 매니저 설정
    public PlatformTransactionManager transactionManager(
            @Qualifier("entityManagerFactory") EntityManagerFactory entityManagerFactory) {
        JpaTransactionManager jpaTransactionManager = new JpaTransactionManager();
        jpaTransactionManager.setEntityManagerFactory(entityManagerFactory);
        return jpaTransactionManager;
    }
```

> PlatformTransactionManager는 다양한 플랫폼의 트랜잭션을 지원하기 위한 클래스이며, 위에서는 JpaTransactionManager를 사용했지만 HibernateTransactionManager나 JdbcTransactionManager등의 플랫폼도 사용 가능합니다.

## 테스트

이제 Config 설정이 완료되었으니, 직접 Test를 통해 원하는 기능이 제대로 실행되는지 확인해보겠습니다.

### Entity 생성

테스트코드를 작성하기 전, DB에 저장할 엔티티 클래스를 먼저 생성하겠습니다.

- User Entity 생성

  ```java
  package com.replication.demo.entity;

  import jakarta.persistence.*;
  import lombok.*;

  import java.util.List;

  @Entity(name = "users")
  @NoArgsConstructor
  @Getter @Setter
  public class User {

      @Id @GeneratedValue
      @Column(name = "user_id")
      private Long id;

      private String name;

      private Integer age;

      @OneToMany(mappedBy = "owner")
      private List<Computer> computers;
  }
  ```

- Computer Entity 생성

  ```java

  package com.replication.demo.entity;

  import jakarta.persistence.*;
  import lombok.Getter;
  import lombok.NoArgsConstructor;
  import lombok.Setter;

  @Entity(name = "computer")
  @NoArgsConstructor
  @Getter @Setter
  public class Computer {

      @Id @GeneratedValue
      @Column(name = "computer_id")
      private Long id;

      @Enumerated(EnumType.STRING)
      private ComputerType type;

      @Column(name = "os")
      private String OS;

      @ManyToOne
      @JoinColumn(name = "owner_id")
      private User owner;

  }
  ```

- Computer Type 생성

  ```java
  package com.replication.demo.entity;

  public enum ComputerType {
    MAC, WINDOW, LINUX
  }
  ```

### 테스트코드 작성

마지막으로, 테스트코드를 통해 Command(readOnly = false) 트랜잭션과 Query(readOnly = true) 트랜잭션을 분리하여 정상적으로 조회되는지 확인해보겠습니다.

```java
package com.replication.demo;

import com.replication.demo.entity.Computer;
import com.replication.demo.entity.ComputerType;
import com.replication.demo.entity.User;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.junit.jupiter.api.*;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.Rollback;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class DemoApplicationTests {

	@PersistenceContext
	EntityManager em;

	@Test
	@Order(1)
	void contextLoads() {
	}

	@Test
	@Order(2)
	@DisplayName("최초 데이터 입력")
	@Transactional(readOnly = false)
	@Rollback(value = false)
	void init() {
		// 사용자 생성
		User user = new User();
		user.setAge(28);
		user.setName("leaf");

		// 컴퓨터 1 생성 및 저장
		List<Computer> computers = new ArrayList<>();
		Computer macCom = new Computer();
		macCom.setOS("Ventura");
		macCom.setType(ComputerType.MAC);
		macCom.setOwner(user);
		computers.add(macCom);
		em.persist(macCom);

		// 컴퓨터 2 생성 및 저장
		Computer windowCom = new Computer();
		windowCom.setOS("WINDOW 11");
		windowCom.setType(ComputerType.WINDOW);
		windowCom.setOwner(user);
		computers.add(windowCom);
		em.persist(windowCom);

		// 컴퓨터 사용자에 추가 후 사용자 저장
		user.setComputers(computers);
		em.persist(user);
		em.flush();
		em.clear();
	}

	@Test
	@Order(3)
	@DisplayName("사용자 조회 시 컴퓨터 잘 불러오는지 테스트")
	@Transactional(readOnly = true)
	void userQueryWithComputer() {
	    // given
		List<User> users = em.createQuery(
		  			"select u " +
                                        "from users as u " +
                                        "join u.computers as c", User.class)
				.getResultList();

	    // when
		User userInDB = users.get(0);

	    // then

            // 사용자명, 나이 테스트
		assertThat(userInDB.getName()).isEqualTo("leaf");
		assertThat(userInDB.getAge()).isEqualTo(28);
		assertThat(userInDB.getComputers()).hasSize(2);

            // 맥북 컴퓨터 가지고 있는지 테스트
		assertThat(userInDB.getComputers()).anyMatch(c -> c.getOS().equals("Ventura"));
		assertThat(userInDB.getComputers()).anyMatch(c -> c.getType().equals(ComputerType.MAC));

            // 윈도우 컴퓨터 가지고 있는지 테스트
		assertThat(userInDB.getComputers()).anyMatch(c -> c.getOS().equals("WINDOW 11"));
		assertThat(userInDB.getComputers()).anyMatch(c -> c.getType().equals(ComputerType.WINDOW));
	}
}
```

> @RollBack(false)를 통해 롤백을 방지한 후 다음 테스트가 실행되도록 설계했습니다.[^5]

{{<figure src="test_result.png" caption="테스트 실행결과, 위와 같이 데이터소스 선택 및 실제 SQL이 잘 나가는 것을 확인할 수 있습니다.">}}

## 결론

지금까지 이중화된 DB의 데이터소스를 SpringBoot에서 동적으로 선택하여 실제 DB와 연동 후 테스트까지 수행했습니다. 해당 프로젝트의 소스코드는 [깃허브](https://github.com/leaf-nam/replication_demo)에 올려두었으니, 필요 시 참고하시기 바랍니다.

## References

| URL                                                                                                                             | 게시일자    | 방문일자    | 작성자  |
| :------------------------------------------------------------------------------------------------------------------------------ | :---------- | :---------- | :------ |
| https://docs.spring.io/spring-data/relational/reference/jdbc/getting-started.html                                               | 미확인      | 2024.03.31. | Spring  |
| https://docs.spring.io/spring-boot/docs/current/reference/html/application-properties.html#appendix.application-properties.data | 미확인      | 2024.04.10. | Spring  |
| https://stackoverflow.com/questions/24643863/is-entitymanager-really-thread-safe                                                | 2014.07.09. | 2024.04.10. | Ken Y-N |

[^1]: 트랜잭션 동기화 기법을 사용하기 위한 클래스입니다. 보통 여러 트랜잭션을 한번에 커밋 및 롤백하여 정합성을 보장하기 위해 사용합니다.
[^2]: 특히 Hibernate의 영속성 컨텍스트와 같은 1차 캐시를 사용할 경우, DataSource 접근이 필요하지 않지만 @Transactional로 인해 불필요한 커넥션이 발생하게 됩니다. LazyConnectionDataSourceProxy으로 Proxy객체를 사용할 경우 실제로 Connection이 필요한 시점에 DataSource에 접근하기 때문에 성능상 이점이 많습니다.
[^3]: Entity Manager는 Thread-Safe하지 않기 때문에, Factory를 통해 필요 시점에 새로운 Entity Manager를 생성해서 활용해야 합니다. [해당 StackOverflow](https://stackoverflow.com/questions/24643863/is-entitymanager-really-thread-safe)를 읽어보시면, 이 때 주입되는 Entity Manager는 Proxy형태로, 실제 트랜잭션 시점에 진짜 Entity Manager로 대체되기 때문에 Thread-Safe 할 수 있다고 합니다.
[^4]: 참고로 JPA의 EntityManagerFactory대신 Hibernate의 SessionFactory를 구현하는 방법도 있지만, 이는 JPA의 구현체에 의존하므로 좋지 않은 것 같습니다(DIP 위반). 하지만 Hibernate만의 특정 기술을 사용해야만 하는 상황에서는 SessionFactory를 구현 후 TransactionManager에 HibernateTransactionManager를 사용하시면 될 것 같습니다.
[^5]: 원래는 @BeforeEach 를 사용하여 DB를 초기화하면 되지만, 트랜잭션 범위 설정이 클래스 단위로 제한되어 @Transactional(readOnly = true)를 지정하면 init() 메서드에 @Transactional(readOnly = false)를 설정해도 DB에 값이 반영되지 않는 문제가 발생했습니다. 하는 수 없이 위와 같은 방식으로 설계했습니다.
