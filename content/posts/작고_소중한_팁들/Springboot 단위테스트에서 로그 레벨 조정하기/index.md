---
title: "Springboot 단위테스트에서 로그 레벨 조정하기"
date: 2024-03-20T23:43:14+09:00
weight: #1
tags: ["tips", "springboot"]
categories: ["tinytips"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "단위테스트에서 간단하게 로그 레벨을 조정할 수 있습니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 로그레벨 변경하기

단위테스트에서 간단하게 로그 레벨을 변경할 수 있습니다.

> 통합테스트는 @SpringBootTest를 사용하면 /src/test/resources/application.properties에 있는 설정정보를 자동으로 불러오지만, 단위테스트에서는 해당 어노테이션이 너무 무겁기 때문에 사용할 수 없습니다.

바로 코드로 알아보겠습니다.

```java
// 단위테스트가 필요한 클래스 내부에 해당 코드를 추가하면 완료입니다.
import org.slf4j.LoggerFactory;
import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;

@BeforeAll
public void setLogLevel() {
    final Logger logger = (Logger)LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);
    logger.setLevel(Level.ALL);
}
```

간단히 코드를 설명드리자면, 단위테스트 시작 전 LoggerFactory로 새로운 loogger를 생성하고 레벨을 변경한 후 테스트를 수행하기 위한 코드입니다.

**반드시 logback[^1] 라이브러리**에 있는 Logger를 import받으셔야 합니다!

> Junit4에서는 @BeforeaAll 대신 @Before 를 사용하시면 됩니다.

감사합니다.

## References

| URL                                                                                               | 게시일자 | 방문일자 | 작성자 |
| :------------------------------------------------------------------------------------------------ | :------- | :------- | :----- |
| https://stackoverflow.com/questions/38778026/how-to-set-the-log-level-to-debug-during-junit-tests |
| 2016.08.04. 2024.03.20                                                                            | PedroD   |

[^1]: log4j의 후속 라이브러리입니다. 더 자세한 설명은 [해당 페이지](https://logback.qos.ch/)를 확인해주세요.
