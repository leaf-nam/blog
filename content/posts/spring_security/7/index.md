---
title: '[Java]Spring Security(With TDD) OAuth2 로그인 테스트 설계하기'
date: 2024-12-19T10:38:16+09:00
weight: #1
tags: [ "authentication", "oauth2" ]
categories: [ "spring", "security" ]
author: "Leaf" # ["Me", "You"] multiple authors
description: "oauth2-client를 활용해서 OAuth2 로그인 로직을 설계합니다."
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
- [[Java]Spring Security(With TDD) JWT 직접 구현하기](https://1eaf.site/posts/spring_security/5)
- [[Java]Spring Security(With TDD) JWT 라이브러리 활용해서 간편하게 구현하기](https://1eaf.site/posts/spring_security/6)

저번 시간까지 기본적인 `JWT`를 구현하고, 이를 `Spring`에서 제공하는 `oauth2-resource-server` 라이브러리로 구현했습니다.
> `Spring Security`의 기본 아키텍처가 궁금하거나, `JWT`를 활용한 기본적인 인증 로직을 구현하실 분들은 이전 포스트를 참고해주세요.

이번 시간에는 `oauth2-client` 라이브러리를 활용해서 서드파티[^1] 로그인을 구현하기 위한 설계를 선행하겠습니다.
> 여러 서드파티가 있지만, 그 중 대표적인 구글 로그인을 예시로 진행합니다.

> 이전까지는 설계 이후 바로 구현까지 이어서 진행했지만, 테스트 작성에 대한 설명이 빈약한 점과 한 포스트가 너무 길어지는 경향을 고려해 앞으로는 설계와 구현을 분리겠습니다.

## 요구사항 분석

- [이전 JWT 로그인](https://1eaf.site/posts/spring_security/5/#%EC%9A%94%EA%B5%AC%EC%82%AC%ED%95%AD-%EB%B6%84%EC%84%9D)의 요구사항은 다음과 같았습니다.

  > 다만, 기존의 `JWT`라는 용어 대신 실제 인증에 사용된다는 의미에서 `Access Token`이라는 용어를 사용하겠습니다.[^2]

  1. 로그인 실패 시 `Access Token`을 발행하지 않는다.
  2. 정상 로그인 시 `Access Token`을 발행한다.`(Happy Case)`
  3. 잘못된 `Access Token`으로 인증할 수 없다.
  4. 권한이 부족한 `Access Token`에 인가할 수 없다.
  5. 정상적인 `Access Token`으로 특정 권한의 `API`를 사용할 수 있다.`(Happy Case)`

- 그러나 서드파티 로그인을 사용한다는 것은, 로그인에 대한 부분을 해당 서버에 위임한다는 뜻이 됩니다. 
  > 즉, 1 ~ 2번 테스트는 해당 서버가 하는 역할이기 때문에 수행할 필요가 없습니다.

- 따라서 테스트해야 할 로직은 다음과 같이 3가지만 남게 됩니다. 
  1. 잘못된 `Access Token`으로 인증할 수 없다.
  2. 권한이 부족한 `Access Token`에 인가할 수 없다.
  3. 정상적인 `Access Token`으로 특정 권한의 `API`를 사용할 수 있다.`(Happy Case)`

## MockMVC 테스트

- 위 테스트를 작성하려고 하면 바로 벽에 부딪치는데, 바로 통합테스트 시에는 `외부 API를 통해 토큰을 받아올 수 없다`는 것입니다.

- 억지로 `RestTemplate` 등의 클래스로 `외부 API`를 호출한다고 해도, `테스트 속도가 너무 느려질` 뿐 아니라 `통제할 수 없는 외부 API`의 영향을 받아 깨지기 쉬운 테스트가 됩니다.[^3]

- 이러한 문제를 해결하기 위해 `Spring`의 통합테스트 모듈인 `MockMVC`에서는 `OAuth2 서버`를 쉽게 `Mocking`할 수 있는 메서드를 제공합니다.

- 주요 메서드는 다음과 같습니다.
  - `oauth2Login()` : 가짜(Mock) OAuth2 서버에 로그인된 요청으로 변경합니다.
  - `oauth2Client()` : 가짜(Mock) OAuth2 클라이언트를 통해 획득한 값(`Access Token`, `Client Registration` 등)을 활용합니다.
  > 더 자세한 사용법은 [다음 링크](https://docs.spring.io/spring-security/reference/servlet/test/mockmvc/oauth2.html)를 참고하시기 바랍니다.
  
## 통합 테스트

위 메서드를 활용해서 다음과 같이 테스트를 작성할 수 있습니다.

## 결론

### 다음 포스팅

## References

| URL                                                                | 게시일자  | 방문일자        | 작성자  |
|:-------------------------------------------------------------------|:------|:------------|:-----|
| [Access Token](https://auth0.com/docs/secure/tokens/access-tokens) | 2024. | 2024.12.19. | Okta |

[^1]: 구글, 애플, 네이버, 카카오 등 OAuth2 로그인을 지원하는 외부 인증 서버들을 가리킵니다.

[^2]: `Access Token`의 보다 자세한 개념은 [다음 문서](https://auth0.com/docs/secure/tokens/access-tokens)를 참고하시기 바랍니다.

[^3]: 테스트가 깨지기 쉬운 정도를 [리팩토링 내성](https://1eaf.site/review/unit_testing/#%EC%A2%8B%EC%9D%80-%ED%85%8C%EC%8A%A4%ED%8A%B8%EC%9D%98-%EC%86%8D%EC%84%B1) 이라고 합니다.
      
      이를 방지하기 위해 `통제할 수 없는 외부 API`는 **Mock으로 대체**하는 기법을 사용할 수 있습니다.
