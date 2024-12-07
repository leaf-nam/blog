---
title: '[Java]Spring Security(With TDD) JWT 구현하기'
date: 2024-12-05T19:58:51+09:00
weight: #1
tags: ["authentication", "jwt"]
categories: ["spring", "security"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "JWT를 통한 인증을 직접 구현합니다."
disableHLJS: true # to disable highlightjs
ShowReadingTime: true
ShowWordCount: true
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: true # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 도입

### 지난 포스팅

- [[Java]Spring Security WebMVC 기본 구조](https://1eaf.site/posts/spring_security/1)
- [[Java]Spring Security 예외처리, 캐싱, 로깅](https://1eaf.site/posts/spring_security/2)
- [[Java]Spring Security 인증(Authentication)과 인가(Authorization)](https://1eaf.site/posts/spring_security/3)
- [[Java]Spring Security(With TDD) 기본 인증 및 인가 구현하기](https://1eaf.site/posts/spring_security/4)

지금까지 Spring Security의 기본 개념을 학습하고, 기본 인증 및 인가를 구현했습니다.

이번 시간에는 JWT[^1]를 도입하여 인증 및 인가 로직에 활용해보겠습니다.

## 설계

### JWT 의존성 추가

다음과 같이 `build.gradle`에 [JWT 파싱을 위한 라이브러리](https://github.com/jwtk/jjwt)를 추가해줍니다.

   ```groovy
     // for jjwt
     implementation 'io.jsonwebtoken:jjwt-api:0.12.6'
     implementation 'io.jsonwebtoken:jjwt-impl:0.12.6'
     implementation 'io.jsonwebtoken:jjwt-jackson:0.12.6'
   ```

  ![JWT 의존성 추가](build_gradle.png)      
      > 저는 jjwt를 사용하겠습니다. 다양한 라이브러리가 있지만, 대부분 기능은 유사하니 사용이 편한 라이브러리를 사용하시면 되겠습니다.
     

### 요구사항 분석
JWT를 사용해서 달성하려는 요구사항은 간단하게 다음과 같이 4가지로 분석할 수 있습니다.
1. 로그인 시 JWT를 발행한다.`(인증)`
2. JWT가 없는 사용자는 인증이 필요한 요청을 수행할 수 없다.`(인증)`
3. JWT가 있지만 권한이 부족한 사용자는 인증이 필요한 요청을 수행할 수 없다.`(인가)`
4. JWT가 있고, 권한이 있는 사용자는 인증이 필요한 요청을 수행할 수 있다.`(Happy Case)`

### 통합테스트 작성
- 로그인 시 JWT를 발행한다.`(인증)`
- JWT가 없는 사용자는 인증이 필요한 요청을 수행할 수 없다.`(인증)`
- JWT가 있지만 권한이 부족한 사용자는 인증이 필요한 요청을 수행할 수 없다.`(인가)`
- JWT가 있고, 권한이 있는 사용자는 인증이 필요한 요청을 수행할 수 있다.`(Happy Case)`

## 결론


### 다음 포스팅

## References

| URL                                                                                                    | 게시일자 | 방문일자        | 작성자    |
|:-------------------------------------------------------------------------------------------------------|:-----|:------------|:-------|
| [Spring 공식문서](https://docs.spring.io/spring-security/reference/servlet/authentication/passwords)       | -    | 2024.12.06. | Spring |
| [RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519)                                              |2015.05. | 2024.12.06. | IETF|

[^1]: JSON Web Token의 준말로 [RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519) 명세에 정의된 토큰입니다.

      `JSON Web Token (JWT)는 두 당사자 간에 전송되는 클레임(claims)을 표현하기 위한 간결하고 URL에 안전한 수단입니다. JWT의 클레임은 JSON 객체로 인코딩되며, 이는 JSON Web Signature (JWS) 구조의 페이로드(payload)로 사용되거나 JSON Web Encryption (JWE) 구조의 평문(plaintext)으로 사용됩니다. 이를 통해 클레임은 디지털 서명되거나 메시지 인증 코드(Message Authentication Code, MAC)를 사용하여 무결성이 보호되거나 암호화될 수 있습니다.`

