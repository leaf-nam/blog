---
title: "[Java]String에서 공백 제거하기"
date: 2024-11-16T23:23:44+09:00
weight: #1
tags: ["tips", "string", "empty space"]
categories: ["tinytips", "java"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "Java String에서 공백을 제거합니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 공백 제거의 필요성

자바로 웹개발을 하다 보면, 입력값에 들어온 공백(White space)을 제거해야 할 일이 심심치 않게 있습니다.
특히, **UTF-8에는 다음과 같은 다양한 공백**이 있기 때문에 모든 경우의 수에 대응해야 합니다.

```
U+0020 : 일반 스페이스
U+0009 : 탭(\t)
U+000A : 줄 바꿈(\n)
U+000D : 캐리지 리턴(\r)
U+000C : 폼 피드(\f)
U+3000 : 넓은 공백
```

## 공백 제거하기

### String.trim()

JDK 1.0부터 존재한 역사가 있는 메서드로, **문자열 앞뒤의 아스키 공백**[^1]을 내부 char배열에서 제거합니다.

> 문자열 가운데는 제거하지 않으며, 나머지 유니코드 공백도 제거하지 않습니다.

- 사용법

  ```java
  public class TrimExample {
      public static void main(String[] args) {
          String str = "   Hello, Java!   ";
          System.out.println("Before trim: [" + str + "]");
          System.out.println("After trim: [" + str.trim() + "]");
      }
  }

  /*
  * [결과]
  * Before trim: [ Hello, Java!　]
  * After trim: [Hello, Java!]
  */
  ```

### String.strip()

Java11에서 등장한 메서드로, `trim()`메서드와 다르게 **문자열 앞뒤의 모든 유니코드 공백**을 제거합니다.

> 모든 유니코드 공백을 제거하는 정규 표현식인 `\\s`를 사용합니다.

- 사용법

```java
public class StripExample {
    public static void main(String[] args) {
        String str = "\u2003Hello, Java!\u3000"; // 유니코드 공백 포함
        System.out.println("Before strip: [" + str + "]");
        System.out.println("After strip: [" + str.strip() + "]");
    }
}

/*
 * [결과]
 * Before strip: [ Hello, Java!　]
 * After strip: [Hello, Java!]
 */
```

### String.replaceAll()

정규표현식을 직접 사용해서 공백을 제거할 수 있습니다. 다만, `trim()`이나 `strip()`과는 다르게 **전체 문자열에서 공백을 제거**합니다.

- 사용법

```java
public class replaceAllExample {
    public static void main(String[] args) {
        String str = "안 녕 하 세 요   \t  여 기 는 UTF-8  공 백 입니다!   \u3000";
        System.out.println("Before replace: [" + str + "]");
        System.out.println("After replace: [" + str.replaceAll("\\s+", "") + "]");
    }
}

/*
 * [결과]
 * Before replace: ["안 녕 하 세 요   \t  여 기 는 UTF-8  공 백 입니다!       ]
 * After replace: [안녕하세요여기는UTF-8공백입니다!]
 */
```

## References

| URL                                                                                                                                       | 게시일자 | 방문일자    | 작성자 |
| :---------------------------------------------------------------------------------------------------------------------------------------- | :------- | :---------- | :----- |
| [String.trim()](<https://docs.oracle.com/javase/7/docs/api/java/lang/String.html#trim()>)                                                 | -        | 2024.11.16. | Oracle |
| [String.strip()](<https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/lang/String.html#strip()>)                            | -        | 2024.11.16. | Oracle |
| [String.replaceAll()](<https://docs.oracle.com/javase/7/docs/api/java/lang/String.html#replaceAll(java.lang.String,%20java.lang.String)>) | -        | 2024.11.16. | Oracle |

[^1]: 일반 스페이스(U+0020)를 뜻합니다.
