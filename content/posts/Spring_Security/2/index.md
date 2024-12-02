---
title: "[Java]Spring Security 예외처리, 캐싱, 로깅"
date: 2024-11-11T21:36:48+09:00
weight: #1
tags: ["exception", "cache", "logging"]
categories: ["spring", "security"]
author: "Leaf"
description: "Spring Security의 기본 예외처리 및 캐싱, 로깅에 대해 알아봅니다."
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

- [[Java]Spring Security WebMVC 기본 구조](https://1eaf.site/posts/spring_security/1/)

지난 시간의 기본 구조(링크)에 이어, Spring Security에서 제공하는 예외처리와 캐싱, 로깅에 대해 자세히 알아보겠습니다.

> 현재 포스팅에서 다루는 부분이 로직상 핵심이 되는 것은 아니나, 이를 모르고 Spring Security를 사용하게 되면 다양한 기능을 제대로 활용할 수 없을 뿐 아니라 문제가 발생했을 때 디버깅하기 매우 어렵기 때문에 반드시 이해하고 구현으로 넘어가는 것을 추천드립니다.

## 예외처리

Spring Security에서 처리하는 예외는 크게 2가지입니다.

- AuthenticationException : 인증 예외(401)[^1]
- AccessDeniedException : 인가 예외(403)[^2]

이러한 오류를 받아서 처리하는 필터와 예외 객체에 대해 자세히 알아보도록 하겠습니다.

### ExceptionTranslationFilter

- [Security Filter Chain](https://1eaf.site/posts/spring_security/spring_security_webmvc_base_architecture/#spring-security-%ED%95%84%ED%84%B0)에는 ExceptionTranslationFilter가 기본으로 세팅되어 있습니다.

{{<figure src="exceptionTranslationFilter.png" caption="ExceptionTranslationFilter는 하위 필터의 오류를 처리합니다.">}}

해당 필터는 위와 같이 인증이 필요한 요청 이전에 선언되어 해당 필터 다음의 요청에서 인증 및 인가 오류가 발생하면 이를 잡아서 처리하는 역할을 합니다.

- **인증 객체가 없거나 AuthenticationException 오류 발생 시**

  1. SecurityContextHolder 초기화
  2. RequestCache에 현재 요청 저장
  3. AuthenticationEntryPoint 실행
     > 해당 처리과정이 복잡해서 [아래](#authenticationexception)에서 좀 더 자세히 다루겠습니다.

- **AccessDenialException 오류 발생 시**
  - 인증 객체가 있으면서 권한이 없는 경우입니다.
  - AccessDeniedHandler에게 요청을 처리하도록 위임합니다.
  - AccessDeniedHandler에서는 보통 403(Forbidden) 오류를 전송하여 권한이 부족함을 알립니다.[^3]
    > AccessDenialException은 간단히 403 오류를 처리하는 로직만 작성하면 됩니다.

### AuthenticationException

인증 관련 오류가 발생하면 다음과 같은 순서로 처리됩니다.

1. **SecurityContextHolder 초기화**

- SecurityContext는 하나의 요청에 하나씩만 생성되는 보안 관련된 문맥입니다. 인증 객체가 들어있는 Container라고 생각해도 좋을 것 같습니다.
- ContextHolder는 이러한 Context 객체를 요청 처리 전반에서 전역적으로 사용할 수 있도록 들고 있습니다.
  > 인증 객체 관련된 부분은 Spring Security에서 매우 핵심이기 때문에 다음 포스팅에서 다루겠습니다.
- 인증 관련 오류가 발생했기 때문에, 현재 ContextHolder를 초기화해서 인증 현재의 객체를 더이상 사용할 수 없도록 만듭니다.

2. **RequestCache에 현재 요청정보 저장**

- 사용자가 인증을 완료한 후, 현재 진행중이던 요청을 즉시 수행할 수 있도록 요청 정보를 캐시에 저장합니다.
- 캐싱 관련된 부분은 [아래](#캐싱)에서 자세히 다룰 예정입니다.

3. **AuthenticationEntryPoint 실행**

- 보통 사용자가 다시 인증을 받을 수 있도록 401 오류와 함께 인증 요청을 전송합니다.[^4]
- 예를 들어, 해당 사용자를 로그인 페이지로 Redirect하거나 토큰을 요청하는 등의 방식입니다.

### 캐싱

위에서 설명한 것처럼, 필터를 통과하는 과정에서 예외가 발생하면 현재 요청정보를 캐시에 저장합니다.

> HttpServletRequest 객체를 그대로 저장하기 때문에 원본 요청을 그대로 다시 수행할 수 있습니다.

- 기본적으로는 HttpSessionRequestCache를 사용하기 때문에 HttpSession에서 저장된 요청을 꺼내올 수 있습니다.[^5]
  > 즉, 세션의 구현방식(InMemory, Redis 등) 에 따라 다양하게 캐싱이 가능합니다.
- 세션에 저장하는 파라미터 이름은 다음과 같이 설정할 수 있습니다.(예시에서는 continue로 설정하고 있습니다.)
  ```java
  @Bean
  DefaultSecurityFilterChain springSecurity(HttpSecurity http) throws Exception {
  	HttpSessionRequestCache requestCache = new HttpSessionRequestCache();
  	requestCache.setMatchingRequestParameterName("continue");
  	http
  		// ...
  		.requestCache((cache) -> cache
  			.requestCache(requestCache)
  		);
  	return http.build();
  }
  ```
- 이후, 저장된 Request 객체를 RequestCacheAwareFilter에서 사용하여 요청을 처리하도록 할 수 있습니다.
- 다음과 같이 인증 과정에서 요청을 저장하지 않게 설정하는 것도 가능합니다.
  ```java
  @Bean
  SecurityFilterChain springSecurity(HttpSecurity http) throws Exception {
      RequestCache nullRequestCache = new NullRequestCache();
      http
          // ...
          .requestCache((cache) -> cache
              .requestCache(nullRequestCache)
          );
      return http.build();
  }
  ```

### 로깅

마지막으로, Spring Security는 DEBUG와 TRACE 레벨의 로깅을 지원하기 때문에, 디버깅에 많은 도움을 받을 수 있습니다.

> 통상 보안을 위해 401이나 403오류가 발생하더라도 응답에는 오류 원인을 포함시키지 않습니다.

만약 브라우저나 응답을 확인해도 인증관련 오류 원인을 찾기 힘들 때 로깅 레벨을 조정한 후 메시지를 확인하여 문제를 빠르게 해결하는 것이 가능합니다.

아래는 공식문서의 예제인데, **TRACE 메시지**를 통해 필터의 진행경과를 확인할 수 있으며 **DEBUG 메시지**를 통해 CSRF와 관련된 오류로 403이 발생하였다는 것을 즉시 확인할 수 있습니다.

```java
2023-06-14T09:44:25.797-03:00 DEBUG 76975 --- [nio-8080-exec-1] o.s.security.web.FilterChainProxy        : Securing POST /hello
2023-06-14T09:44:25.797-03:00 TRACE 76975 --- [nio-8080-exec-1] o.s.security.web.FilterChainProxy        : Invoking DisableEncodeUrlFilter (1/15)
2023-06-14T09:44:25.798-03:00 TRACE 76975 --- [nio-8080-exec-1] o.s.security.web.FilterChainProxy        : Invoking WebAsyncManagerIntegrationFilter (2/15)
2023-06-14T09:44:25.800-03:00 TRACE 76975 --- [nio-8080-exec-1] o.s.security.web.FilterChainProxy        : Invoking SecurityContextHolderFilter (3/15)
2023-06-14T09:44:25.801-03:00 TRACE 76975 --- [nio-8080-exec-1] o.s.security.web.FilterChainProxy        : Invoking HeaderWriterFilter (4/15)
2023-06-14T09:44:25.802-03:00 TRACE 76975 --- [nio-8080-exec-1] o.s.security.web.FilterChainProxy        : Invoking CsrfFilter (5/15)
2023-06-14T09:44:25.814-03:00 DEBUG 76975 --- [nio-8080-exec-1] o.s.security.web.csrf.CsrfFilter         : Invalid CSRF token found for http://localhost:8080/hello
2023-06-14T09:44:25.814-03:00 DEBUG 76975 --- [nio-8080-exec-1] o.s.s.w.access.AccessDeniedHandlerImpl   : Responding with 403 status code
2023-06-14T09:44:25.814-03:00 TRACE 76975 --- [nio-8080-exec-1] o.s.s.w.header.writers.HstsHeaderWriter  : Not injecting HSTS header since it did not match request to [Is Secure]
```

## 결론

**Spring Security는 예외 처리가 잘 분리되어 있고, 처리 과정에서 캐싱과 로깅이 잘 구현되어 있어 개발 및 디버깅하기 쉽다!**

### 다음 포스팅

- [[Java]Spring Security 인증(Authentication)과 인가(Authorization)](https://1eaf.site/posts/spring_security/3)

## References

| URL                                                                                                                         | 게시일자 | 방문일자    | 작성자 |
| :-------------------------------------------------------------------------------------------------------------------------- | :------- | :---------- | :----- |
| [HTTP Unauthorized](https://developer.mozilla.org/ko/docs/Web/HTTP/Status/401)                                              | -        | 2024.11.10. | MDN    |
| [HTTP Forbidden](https://developer.mozilla.org/ko/docs/Web/HTTP/Status/401)                                                 | -        | 2024.11.10. | MDN    |
| [Spring Session Management](https://docs.spring.io/spring-security/reference/servlet/appendix/faq.html#_session_management) | -        | 2024.11.11. | Spring |

[^1]:
    [Unauthorized](https://developer.mozilla.org/ko/docs/Web/HTTP/Status/401) : 인증 오류는 사용자를 확인할 수단(토큰, 아이디/패스워드, 세션ID 등)이 없거나, 잘못된 방법으로 요청을 시도했을 때 발생합니다.

    - Ex) 권한이 필요한 페이지에 권한 없는 사용자가 요청 시도
    - Ex) 잘못된 인증 토큰(서버에서 발행하지 않았거나, 만료 혹은 변조 등)으로 요청 시도

[^2]: [Forbidden](https://developer.mozilla.org/ko/docs/Web/HTTP/Status/403) : 인가 오류는 사용자가 해당 요청에 대한 권한이 불충분할 때 발생합니다.

    - Ex) 기본 유저가 관리자 권한이 필요한 요청을 시도

[^3]: 403 오류는 인증을 다시 시도하더라도 해소되지 않기 때문에, 401과는 다르게 로그인을 다시 시도할 필요가 없습니다.
[^4]: [MDN의 401 오류 공식문서](https://developer.mozilla.org/ko/docs/Web/HTTP/Status/401)를 보면, 401 오류 발생시에는 반드시 WWW-Authenticate 헤더에 인증 방법을 1가지 이상 명시하여 반환해야 한다고 설명되어 있습니다.
[^5]: 처음에 해당 단락을 보면서 요청이 저장된다고 해도 동일한 브라우저임을 어떻게 검증하는지가 궁금했는데, [해당 페이지](https://docs.spring.io/spring-security/reference/servlet/appendix/faq.html#_session_management)를 읽어보니 세션은 동일한 세션 ID(통상 JSESSIONID)를 저장하고 있기 때문에, 요청의 Cookie에 설정된 세션 ID를 통해 가져오기 때문에 동일한 브라우저임을 알 수 있다고 합니다.
