---
title: "Jnuit_테스트에서_객체_필드명_비교하기"
date: 2024-03-23T23:19:23+09:00
weight: 2002
tags: ["tips", "springboot", "junit"]
categories: ["tinytips"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "Junit에서 객체 필드명을 편하게 테스트할 수 있습니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 상황

- 기존 코드를 리팩토링하는 과정에서 엔티티 객체에 있던 @Data를 @Getter로 변경중이었습니다.
  > 테스트를 위해 임시로 @Data를 붙여놓고 사용중이었습니다.

```java
@Getter // 기존 : @Data
@Builder
@AllArgsConstructor
public class LaneInfo {
    private TeamPosition teamPosition;
    private boolean isBottomLane;
    private int myTeamId;
    private int myLaneNumber;
    private int oppositeLaneNumber;
    private int myBottomDuoNumber;
    private int oppositeBottomDuoNumber;
    //...(생략)
}

```

- 기존에 잘 동작하던 아래 테스트에서 오류가 발생했습니다.

```java
//생략
// matchIndicator가 가진 laneInfo와 given에서 주어진 laneInfo 비교
assertThat(matchIndicators.get(0)
        .getMetadata()
        .getLaneInfo())
        .isEqualTo(laneInfo);
```

## 원인 분석

- 오류 로그는 다음과 같았습니다.

```log
Expected :com.ssafy.matchup_statistics.indicator.entity.match.LaneInfo@1150d471
Actual   :com.ssafy.matchup_statistics.indicator.entity.match.LaneInfo@6393bf8b
```

> 해당 테스트코드는 기존에는 잘 동작했고, 각 필드가 하나라도 달라지면 실패하던 테스트코드였습니다.

> 또한, Equals 비교는 ==(isSameAs) 비교와 다르게 해당 객체의 속성값으로 참, 거짓을 판단하는 것으로 알고 있었기에 더욱 의아했습니다.

- equals는 String과 같은 값 타입 객체에서는 잘 작동했지만, 재귀적으로 내부에 여러 class가 있는 경우

## 해결

1. Equals Overriding

```java

```

1. 각 필드 직접 비교

```java
assertThat(matchIndicators.get(0)
        .getMetadata()
        .getLaneInfo()
        .getTeamPosition())
        .isEqualTo(laneInfo.getTeamPosition());

assertThat(matchIndicators.get(0)
        .getMetadata()
        .getLaneInfo()
        .getIsBottomLane())
        .isEqualTo(laneInfo.getIsBottomLane());
//(생략 : 모든 필드 다 비교)
```

2. 재귀적으로 필드값 비교

```java
assertThat(matchIndicators.get(0)
        .getMetadata()
        .getLaneInfo())
        .usingRecursiveComparison()
        .isEqualTo(laneInfo);
```

> 위 코드보다 훨씬 깔끔하게 테스트가 가능합니다. ~~assertJ 짱!~~
> 참고로 아래 메서드로 비교하지 않을 필드를 제외할 수 있습니다.

```java
// 무시할 필드값
ignoringFields(String… fieldsToIgnore)
// 무시할 정규표현식
ignoreFieldsMatchingRegexes(String… regexes)
// 무시할 타입(클래스)
ignoringFieldsOfTypes(Class… typesToIgnore)
```

## References

| URL                                                                              | 게시일자    | 방문일자    | 작성자       |
| :------------------------------------------------------------------------------- | :---------- | :---------- | :----------- |
| https://umanking.github.io/2021/06/11/assertj-field-recursive-comparision/       | 2021.06.11. | 2024.03.23. | CodeNexus    |
| https://assertj.github.io/doc/#assertj-core-recursive-comparison-ignoring-fields | 2024.02.17. | 2024.03.23. | assertj-core |
