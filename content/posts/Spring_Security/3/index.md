---
title: "[Java]Spring Security 인증(Authentication)과 인가(Authorization)"
date: 2024-11-29T12:24:33+09:00
weight: #1
tags: ["authentication", "authorization"]
categories: ["spring", "security"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "Spring Security의 인가 로직에 대해 알아봅니다."
disableHLJS: true # to disable highlightjs
ShowReadingTime: true
ShowWordCount: true
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 도입

### 지난 포스팅

- [[Java]Spring Security WebMVC 기본 구조](https://1eaf.site/posts/spring_security/1)
- [[Java]Spring Security 예외처리, 캐싱, 로깅](https://1eaf.site/posts/spring_security/2)

Spring Security의 WebMVC와 기타 기능들에 이어 다양한 기능을 지원하는 인가 로직에 대해 알아보겠습니다.

> 이전의 포스팅들과 이번 포스팅까지 제대로 이해한다면, 기본적인 Spring Security의 기능들을 사용하는데 큰 어려움이 없으실 겁니다.

## 인증과 인가

너무 추상적이지만 Spring Security를 이해하는데 중요한 개념이므로 짚고 넘어가겠습니다.

- [인증(Authentication)](https://en.wikipedia.org/wiki/Authentication) : 데이터나 시스템의 접근 권한을 가졌는지 검증하는 것입니다.
- [인가(Authorization)](https://en.wikipedia.org/wiki/Authorization) : 특정 리소스의 접근 권한을 가졌는지 확인하여 허용 또는 거부하는 것입니다.

즉, 인증은 로그인하는 행위 그 자체인 반면, 인가는 로그인한 사용자의 권한을 확인해서 접근 제어를 하는 것입니다.

> 둘은 유사해 보이지만, 인증 오류(401)와 인가 오류(403)가 구분되어 있는 것처럼 보안에서 두 개념을 분리해서 생각하는 것은 중요합니다.[^1]

## Authentication

인증은 Spring Security의 핵심 로직입니다.

- 인증이 성공하면, 사용자의 자격을 확인하고, 권한을 부여합니다.
- 인증이 실패하면, 실패 메시지를 전송하거나 인증 URL로 Redirect를 하는 등의 작업을 수행합니다.

### SecurityContext

현재 요청(사용자)의 인증 객체(Authentication)를 담고 있는 문맥, 혹은 컨테이너입니다. 인증이 완료된 인증 객체를 저장하는 역할을 합니다.

- 이러한 Context는 쓰레드 로컬 저장소인 `SecurityContextHolder` 내부에 위치하고 있습니다.[^2]

### Authentication Object

사용자 식별자, 증명, 권한 등의 인증 정보를 담고 있는 객체입니다. 인증된 객체는 `SecurityContext`에 담아 요청 전역에서 사용할 수 있습니다.

- **principal** : 사용자 식별자입니다. 사용자를 구분할 수 있는 고유한 값이 필요합니다.
- **credentials** : 비밀번호와 같은 증명입니다. 인증이 완료된 이후 외부 노출을 막기 위해 초기화됩니다.
- **authorities** : 해당 사용자의 인증과 동시에 승인되는 권한입니다. [인가](#authorization)를 설명하면서 더 자세히 살펴보겠습니다.

### AuthenticationManager

인증을 관리하기 위한 API입니다. Spring Security는 해당 인터페이스를 사용해서 인증을 수행하기 때문에 이를 구현해야 활용할 수 있습니다.

- 만약 Spring Security를 사용하지 않고 `Filter`에서 직접 `SecurityContext`에 접근한다면 구현할 필요는 없습니다.

  > 다만, Spring Security에서 제공하는 다양한 캐싱과 로깅, 최적화 등의 기능을 잘 활용하려면 이를 구현하는게 좋습니다.

- **ProviderManager**

  `AuthenticationManager`를 구현한 구현체입니다. 인증 서비스를 제공하는 `AuthenticationProvider`들을 리스트로 담아서 관리하며 인증 필요 시 사용자 요청에서 Id, Password, Token등을 확인하여 인증을 시도합니다.

  - 만약 `AuthenticationProvider`가 등록되지 않은 상태로 `ProviderManager`를 사용한다면 인증 관련 오류인 `ProviderNotFoundException`이 발생합니다.

- **AuthenticationProvider**

  인증을 제공하는 객체입니다. `ProviderManager`에 등록되어 순서대로 실행됩니다.

  - 기본적으로 `AuthenticationProvider`는 증명(credentials)을 외부에 노출하지 않기 위해 인증과 동시에 비우게 됩니다.[^3]

### AbstractAuthenticationProcessingFilter

인증의 주요 흐름을 담고 있는 필터입니다. [ExceptionTranslationFilter](https://1eaf.site/posts/spring_security/2/#exceptiontranslationfilter)에서 이미 살펴보았던 `AuthenticationEntryPoint`를 통해 받은 요청에서 사용자 정보(principals) 및 증명(credentials)을 가져와서 인증을 시도합니다.

{{<figure src="abstractAuthenticationProcessingFilter.png" caption="인증 필터의 주요 흐름">}}

> 인증 오류를 처리한다는 점에서 `ExceptionTranslationFilter`와 동작이 유사합니다. 다만, 내부적으로 발생할 수 있는 오류들을 Try-Catch로 잡아서 처리하기 때문에 인증 과정에서 실패하더라도 `ExceptionTranslationFilter`까지 도달하지 않고 설정된 `AuthenticationFailureHandler`를 사용합니다.[^4]

## Authorization

인증된 객체는 권한을 인가받게 되는데, 권한에 따라 자원(URL) 별로 접근제어가 가능합니다.

### Authorities

[위](#authentication-object)에서 설명한 것처럼, 인증 객체는 생성과 동시에 권한(`authorities`)을 리스트로 갖게 됩니다.

- 승인된 권한이라는 뜻에서 `GrantedAuthority`라는 클래스의 객체로 저장됩니다.[^5]

### AuthorizationManager

`AuthorizationManager`(인가 관리자)는 이러한 권한을 바탕으로, 접근을 허용할지 아니면 거부할지를  

## 결론

## References

| URL                                                                                                                                                 | 게시일자    | 방문일자    | 작성자        |
| :-------------------------------------------------------------------------------------------------------------------------------------------------- | :---------- | :---------- | :------------ |
| [인증(Authorization)](https://en.wikipedia.org/wiki/Professional_certification#Computer_technology)                                                 | 2024.11.22. | 2024.11.29. | Wikipedia     |
| [인가(Authentication)](https://en.wikipedia.org/wiki/Authentication)                                                                                | 2024.11.6.  | 2024.11.29. | Wikipedia     |
| [Understanding 403 Forbidden](http://web.archive.org/web/20190904190534/https://www.dirv.me/blog/2011/07/18/understanding-403-forbidden/index.html) | 2011.7.18.  | 2024.11.29. | Daniel Irvine |

[^1]: 401은 인증 오류이지만, 영문명은 Unauthorized입니다. 이러한 [개념을 이해하기 좋은 문서](http://web.archive.org/web/20190904190534/https://www.dirv.me/blog/2011/07/18/understanding-403-forbidden/index.html)가 있어 첨부합니다.
[^2]: `SecurityContext`는 사용자 요청별로 관리되어야 하기 때문에 Thread-Safety하도록 `ThreadLocal 저장소`에 보관됩니다.

      > Thread-Safety가 보장되지 않는다면 현재 사용자가 아닌 다른 사용자의 인증 객체에 접근할 가능성이 있어 보안 이슈가 발생할 수 있습니다.

[^3]:
    만약 사용자 요청을 캐싱하여 반환할 경우, 증명(Credentials)이 지워진 상태로 저장될 수 있습니다. 따라서 캐싱된 요청을 다시 인증하는게 불가능하기 때문에 별도의 인증 로직을 구성하거나 이러한 옵션을 해제해야 합니다.
    
    {{<figure src="credential_remove.png" alt="자격증명 삭제 관련 문서" caption="캐싱된 인증은 자격증명이 삭제된 상태로 저장될 수 있습니다.">}}

[^4]:
    실제로 디버깅을 통해 로그인 요청 발생 시 `ExceptionTranslationFilter`의 `AuthenticationEntryPoint`가 아닌 `AbstractAuthenticationProcessingFilter`내부의 `AuthenticationFailureHandler`를 사용하는 것을 확인할 수 있었습니다.
    ![디버깅1](debug1.png)

[^5]: `GrantedAuthority`객체는 기본적으로 `SimpleGrantedAuthority` 구현체를 사용할 수 있는데, 권한 요청 메서드인 `getAuthority()`를 실행했을 때 `ROLE_`형태의 Prefix를 가지는 권한(String)을 가져올 수 있습니다.
      
      > 이러한 권한 객체의 Prefix는 다음과 같이 변경해서 사용할 수 있습니다.

      ```java
        @Bean
        static GrantedAuthorityDefaults grantedAuthorityDefaults() {
          return new GrantedAuthorityDefaults("MYPREFIX_");
        }
      ```