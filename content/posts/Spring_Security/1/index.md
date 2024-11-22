---
title: "[Java]Spring Security WebMVC 기본 구조"
date: 2024-11-06T19:19:20+09:00
#weight: 1
tags: ["architecture"]
categories: ["spring", "security"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "Spring Security의 기본 구조인 필터에 대해서 알아봅니다."
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

- **작성 배경** :
  이번 토이프로젝트에서 Spring Security를 다루고 있는데, 기본 개념을 제대로 이해하지 못해서 많은 어려움을 겪었습니다. 이렇게 정리해두지 않으면 분명 나중에 또 까먹기 때문에, 공식 문서를 보면서 이해한 부분을 정리해두고 나중에 찾아보기 위해 기본 구조와 함께 예제들을 정리해볼 계획입니다.
  > 사실 제가 내부구조를 정확히 아는 것도 아니고, 제 지식의 수준이 매우 얕기 때문에 Spring Security 공식문서에 적혀 있지 않은 내용은 잘못된 정보를 재생산 할 수 있다고 생각했습니다. 따라서 본 포스팅은 거의 [Spring Security 6.3.4](https://docs.spring.io/spring-security/reference/index.html) 레퍼런스 문서를 한글로 의역? 해석? 하는 수준에서 가볍게 봐주시면 좋을 것 같습니다.
- **Filter** :
  공식문서에서도 [Spring Security WebMVC의 구조와 관련된 페이지](https://docs.spring.io/spring-security/reference/servlet/architecture.html)를 가보면, 대부분 필터에 대한 내용입니다. 결국 필터가 어떻게 동작하는지 이해하면 WebMVC에서 Spring Security의 기본 구조와 동작순서를 이해할 수 있기 때문에, 제목은 구조이지만 필터에 대한 설명 위주로 작성했습니다.
  > Spring Reactive에서는 Servlet(WebMVC)에서와 전혀 다르게 동작한다고 하는데, 이 부분은 차후에 다루도록 하겠습니다.

## 필터

{{<figure src="servlet_filter.png" caption="Java servlet container의 필터 처리과정">}}

- 필터는 WebMVC 형태의 WAS를 다뤄보신 분들이라면 다들 사용해 보셨을 것 같습니다.
- 사용자의 요청이 Controller(Spring에서는 DispatcherServlet)로 이동하기 전, 해당 요청을 검증하기 위한 단계를 나타냅니다.
- 일종의 AOP[^1]라고 할 수 있겠네요.
- 필터는 스프링에서만 제공하는게 아닌, 자바 표준으로서 WAS(Servlet Container)에서 사용하기 위한 표준 스펙입니다.
- 실제로 [자바 표준 스펙](https://docs.oracle.com/javaee/5/api/javax/servlet/Filter.html)에서 기본 제공하는 Filter 인터페이스의 형태는 다음과 같습니다.

  ```java
  public interface Filter {
    default void init(FilterConfig filterConfig) throws ServletException {}

    void doFilter(ServletRequest request,
                  ServletResponse response,
                  FilterChain filterChain) throws IOException, ServletException;

    default void destroy() {}
  }

  ```

- doFilter 메소드의 인자를 보시면, 필터 인터페이스를 통해 가능한 역할은 크게 3가지입니다.
  - ServletRequest : 사용자 요청 검증(URL, Header 등)
  - ServletResponse: 서버 응답 조작(status code, message body 등)
  - FilterChain : 다음 필터로 요청 전송할지, 현재 필터에서 필터링할지 여부 결정
- 즉, 필터는 사용자 요청을 검증하고, 사전에 응답이 필요하면 세팅한 후 다음 필터로 요청을 전송하거나 필터링하는 일련의 과정이 반복됩니다. 이를 **Filter Chaining**이라고 표현합니다.

## Spring Security 필터

Spring에서는 자바 표준 필터를 Spring Container[^2]에 호환하기 위해 다양한 기법을 사용합니다.

> 아래 DelegatingFilterProxy와 FilterChainProxy는 AOP와 객체지향의 프록시 패턴[^3]을 이해하지 않고 있다면, 조금 이해가 어려울 수 있습니다.

### DelagatingFilterProxy

{{<figure src="delegatingFilterProxy.png" caption="Bean으로 등록된 Filter를 품고 있는 DelegatingFilterProxy">}}

- Spring이 Servlet Container(Java 표준)에서 사용하는 Filter를 Bean으로 등록 및 동작시키기 위한 프록시 객체입니다.

  > 여기서 Filters 내부의 Filter0, Filter2는 Spring이 관리하는 필터가 아닌 Servlet Container의 필터입니다.

- 내부에 Spring Bean으로 등록된 Filter를 가지고 있으며, 해당 Bean에게 요청을 위임하여 동작시킵니다.
- Servlet Container에서 사용하는 필터 인터페이스의 동작 사이에 Spring의 Bean을 끼워넣을 수 있는 일종의 JoinPoint[^4]를 만들었다고 생각하시면 좋을 것 같습니다.

### FilterChainProxy

- Spring에서는 위의 DelegatingFilterProxy에 위임된 Bean Filter를 여러개 묶어서 Chain으로 연결한 것처럼 동작시킵니다.
  > 해당 체인이 Spring Security에서 가장 핵심 로직인 SecurityFilterChain입니다.
- FilterChainProxy은 DelegatingFilterProxy로부터 위임된 필터 작업을 다음에 나올 SecurityFilterChain에게 요청을 위임하기 위한 프록시 객체입니다.

### SecurityFilterChain

{{<figure src="securityFilterChain.png" caption="Proxy를 통해 SecurityFilterChain에게 요청이 위임됩니다.">}}

- 공식문서에서 위의 Proxy들을 언급한 이유는 결국 SecurityFilterChain의 구조를 설명하기 위함입니다.
  > 위의 그림에서처럼 두 개의 proxy 객체 덕분에 SecurityFilterChain에게 필터링을 위임할 수 있습니다.
- 또한, 이러한 요청은 Matcher 로직을 통해 URI Path 기반으로 특정 패턴의 필터에게 요청을 위임하며, 패턴 별로 다른 로직의 필터를 동작시킬 수 있습니다.[^5]

  > 앞의 필터에서 처리되지 않은 요청들은 모두 마지막 필터(/\*\*)가 처리하겠죠?

- 이러한 필터가 적용되는 순서 또한 중요합니다.
  > 예를 들어, 인가 관련 로직을 처리하기 전에 반드시 인증을 통해 해당 사용자에게 어떤 권한이 있는지를 확인해야 합니다.
  - [다음 소스코드](https://github.com/spring-projects/spring-security/blob/6.3.4/config/src/main/java/org/springframework/security/config/annotation/web/builders/FilterOrderRegistration.java)를 참고하면 각각의 필터들이 내부적으로 어떤 순서로 동작하는지 확인할 수 있습니다.

### Custom Filter 등록하기

- Filter를 구현하는 방법은 다음과 같습니다.

  1. **필터를 상속받는 Bean을 구현합니다.**
     - 이 때, Spring Security에서 제공하는 추상 클래스인 OncePerRequestFilter를 상속받아 사용할 것을 권장하고 있습니다.
     - 해당 추상 클래스의 추상 메서드인 doFilterInternal를 구현하면, 템플릿 메서드 패턴[^6]으로 하나의 요청에서 한번만 실행되는 필터를 생성할 수 있습니다.
       > 당연히 하나의 요청에 한번만 실행되는거 아닌가..?하는 생각이 들어 찾아보니 [servlet들끼리 dispatch를 하는 과정에서 여러번 실행될 수 있어](https://stackoverflow.com/questions/50410901/genericfilterbean-vs-onceperrequestfilter-when-to-use-each) 이런 필터를 통해 이번 요청에 이미 필터링을 거쳤는지 확인한다고 합니다.
  2. **SecurityConfig에 등록합니다.**

     ```java
     @Bean
     SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
         http
             // ...
             .addFilterBefore(new TenantFilter(), AuthorizationFilter.class);
         return http.build();
     }
     ```

> 차후 포스팅에서 실제로 Custom Filter로 JWT 인증 필터를 구현해서 등록해볼 예정입니다.

## 결론

**스프링에서 사용하는 필터는 자바 표준스펙과 호환되며, 중간에 다양한 기능을 끼워넣기 위해 잘 설계되어 있어 Custom Filter를 쉽게 등록할 수 있다!**

> 예외처리, 캐싱 관련된 내용도 한번에 작성하려고 했는데, 분량이 너무 길어져서 다음 포스트로 넘기겠습니다.

### 다음 포스팅

- [[Java]Spring Security 예외처리, 캐싱, 로깅](https://1eaf.site/posts/spring_security/2)

## References

| Link                                                                                                                                                                                                                    | 게시일자    | 방문일자    | 작성자        |
| :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :---------- | :---------- | :------------ |
| [Spring Security Docs](https://docs.spring.io/spring-security/reference/index.html)                                                                                                                                     | -           | 2024.11.05. | Spring        |
| [Java Servlet Filter Docs](https://docs.oracle.com/javaee/5/api/javax/servlet/Filter.html)                                                                                                                              | -           | 2024.11.05. | Oracle        |
| [Spring Security Filter Order Source Code](https://github.com/spring-projects/spring-security/blob/6.3.4/config/src/main/java/org/springframework/security/config/annotation/web/builders/FilterOrderRegistration.java) | -           | 2024.11.05. | Spring        |
| [Once Per Request Filter When to Use](https://stackoverflow.com/questions/50410901/genericfilterbean-vs-onceperrequestfilter-when-to-use-each)                                                                          | 2018.03.18. | 2024.11.05. | StackOverflow |

[^1]:
    [Aspect Orient Programming](https://ko.wikipedia.org/wiki/%EA%B4%80%EC%A0%90_%EC%A7%80%ED%96%A5_%ED%94%84%EB%A1%9C%EA%B7%B8%EB%9E%98%EB%B0%8D) - 관점 지향 프로그래밍 : 특정 로직의 핵심 관점(종단 관심사)과 부가 관점(횡단 관심사)을 나눈 뒤 각각을 모듈화하는 기법을 말합니다.
    필터는 핵심 비즈니스 로직 전단계의 전처리 과정을 모듈화하는 Aspect(횡단 관심사)의 일종입니다.

[^2]: Application Context, Bean Factory, Bean Container 혹은 IOC Container라고도 합니다.
[^3]: [Proxy Pattern](https://ko.wikipedia.org/wiki/%ED%94%84%EB%A1%9D%EC%8B%9C_%ED%8C%A8%ED%84%B4) - 프록시 패턴 : 본인 내부에 다른 객체의 참조를 갖고 있다가, 특정 작업의 요청을 내부 객체에 위임하는 형태의 디자인 패턴입니다. 이를 통해 접근 제어를 하거나 특정 부가기능을 수행할 수 있습니다.
[^4]: [AspectJ](https://ko.wikipedia.org/wiki/AspectJ)에서 사용하는 개념으로, 횡단 관심사를 처리할 로직을 끼워넣을 지점을 결정합니다.
[^5]:
    - Spring에서는 이러한 SecurityFilterChain을 DelegatingFilterChain이 아닌 FilterChainProxy로 등록하는데, 이는 DelegatingFilterChain을 그대로 사용하면 기존 필터와 동일한 구조로 동작해야 하기 때문이라고 합니다.
    - FilterChainProxy로 등록함으로써 스프링의 다양한 성능 최적화나 메모리 누수 방지 등등의 다양한 동작을 적용할 수 있고, 무엇보다 URL을 보고 필터 동작여부를 결정하는 것이 아니라, RequestMatcher를 활용할 수 있는 것도 FilterChainProxy로서 등록되기 때문이라고 하네요!
      > 기존 로직에 부가기능을 추가한 뒤 다른 객체에게 위임하여 동작시킨다는 측면에서 일종의 데코레이터 패턴이라고 볼 수 있겠네요.

[^6]: [Template Method Pattern](https://ko.wikipedia.org/wiki/%ED%85%9C%ED%94%8C%EB%A6%BF_%EB%A9%94%EC%86%8C%EB%93%9C_%ED%8C%A8%ED%84%B4) - 템플릿 메소드 패턴 : 상위 객체의 알고리즘을 하위 객체에서 구현하도록 설계하여 전체 구조를 변경하지 않고 특정 단계의 로직만 변경할 수 있게 합니다.
