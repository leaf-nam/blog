---
title: "Org.springframework.data.mapping.MappingException 오류 해결"
date: 2024-04-02T22:36:05+09:00
#weight: 2004
tags: ["tips", "springboot", "gradle", "intellij", "mongoDB"]
categories: ["tinytips"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "Spring Data MongoDB에서 자주 만나는 MappingException 오류를 해결합니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 상황

- SpringBoot에서 MongoDB에 데이터를 저장하고, 저장한 데이터를 파싱하는 과정에서 다음과 같은 오류가 발생했습니다.

- 실행 코드

```java
// 몽고DB 컬렉션 클래스
@Document(collection = "indicators")
@Getter
@NoArgsConstructor
@Builder
@AllArgsConstructor
@Slf4j
public class Indicator {
    @Id
    private String id;
    private List<MatchIndicator> matchIndicators;
    private MatchIndicatorStatistics matchIndicatorStatistics;

    // 메서드 생략
}

// 컬렉션 조회 메서드
    @Override
    public Indicator getIndicatorInDB(String SummonerId) {
        Query query = Query.query(
                Criteria.where("_id").is(SummonerId));

        Indicator indicators = mongoTemplate.findOne(query, Indicator.class, "indicators");

        if (indicators == null) throw new RiotDataException(RiotDataError.NOT_IN_STATISTICS_DATABASE);
        else log.info("indicator founded : {}", indicators.getId());

        return indicators;
    }
```

- 오류 코드

```log
Parameter org.springframework.data.mapping.Parameter@691d29ad does not have a name
```

## 원인 분석

실제로 MongoDB에서 데이터를 정상 꺼내오는 로그는 다음과 같이 잘 찍혀있었습니다.

```log
Command "find" succeeded on database "matchup_statistics_db" in 1.627834 ms using a connection with driver-generated ID 3 and server-generated ID 321 to localhost:3311. The request ID is 6 and the operation ID is 5. Command reply: {"cursor": {"firstBatch": [{"_id": // 생략
```

또한, 이미 MongoDB에 데이터를 저장할 때는 문제없이 저장되었던 값을 꺼내오는 과정에서 오류가 발생했기 때문에, 꺼내온 값을 spring에서 mapping하는 과정에서 특정 파라미터를 인식하지 못해 발생했다고 생각했습니다.

## 해결

### 1. 기본 생성자 추가

- Spring에서 사용하는 mapping은 기본적으로 생성자를 통해 객체를 Reflection하기 때문에, 기본 생성자를 추가해야 합니다.(혹은 lombok의 @NoArgsConstructor)

> 해당 Collection의 Field에 들어가는 모든 클래스에 기본 생성자를 붙여주었지만 동일한 오류가 계속 발생했습니다.

### 2. @Field 추가

- MongoDB에서 객체를 생성해서 가져오는 과정에서 해당 어노테이션이 없으면 인식을 못해서 org.springframework.data.mapping.PropertyReferenceException 가 발생할 수 있다고 합니다.[^1]

> 저와 다른 종류의 오류이기도 하고, 저는 해당 어노테이션 없이 해결이 되었지만 혹시 해결되지 않는 분들은 적용해보시기 바랍니다.

### 3. Build Option : Intellij -> Gradle로 변경

- 해당 코드를 디버깅하면 다음 [소스코드](https://github.com/spring-projects/spring-framework/blob/main/spring-core/src/main/java/org/springframework/core/StandardReflectionParameterNameDiscoverer.java)에서 null이 발생함을 알 수 있습니다.

```java
@Nullable
private String[] getParameterNames(Parameter[] parameters) {
    String[] parameterNames = new String[parameters.length];
    for (int i = 0; i < parameters.length; i++) {
        Parameter param = parameters[i];
        if (!param.isNamePresent()) {
            return null; // null 발생
        }
        parameterNames[i] = param.getName();
    }
    return parameterNames;
}
```

즉, 빌드 시점에 파라미터가 설정되지 않아 발생하는 문제이며 이는 Gradle로 실행 시 자동으로 해결됩니다. 자세한 설명은 [해당 블로그](https://ricma.co/posts/tech/dev/migrating-to-spring-61-javac-parameters/)를 참고하시기 바랍니다.

> 저는 인텔리제이에서 빌드 옵션을 변경했더니 정상 실행이 되었습니다.
> {{<figure src="gradle_build.png" caption="Intellij에서 Gradle로 변경합니다.">}}

> 오류의 원인이 단순히 코드에만 있는 게 아니라, 프레임워크나 IDE등에 의해서도 충분히 발생할 수 있음을 항상 견지해야겠습니다. 그리고 프레임워크의 의존성을 줄여나가는 것도 좋은 방향이라고 생각합니다.

## References

| URL                                                                                                                                            | 게시일자    | 방문일자    | 작성자             |
| :--------------------------------------------------------------------------------------------------------------------------------------------- | :---------- | :---------- | :----------------- |
| https://ricma.co/posts/tech/dev/migrating-to-spring-61-javac-parameters                                                                        | 2023.09.22. | 2024.04.02. | Riccardo Macoratti |
| https://stackoverflow.com/questions/36160919/caused-by-org-springframework-data-mapping-model-mappingexception-no-property                     | 2016.03.22. | 2024.04.02. | user4821194        |
| https://stackoverflow.com/questions/53207049/spring-data-mongo-no-property-b-found-on-entity-class-when-retrieving-entity-by/53210768#53210768 | 2018.11.08. | 2024.04.02. | J.Pip              |

[^1]: [쏘니의 개발블로그:티스토리](https://juntcom.tistory.com/99)
