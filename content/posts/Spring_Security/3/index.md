---
title: "[Java]Spring Security 인가(Authentication)"
date: 2024-11-22T19:53:33+09:00
weight: #1
tags: ["authentication"]
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

## 인가란?

## SecurityContext

현재 요청(사용자)의 인증 객체(Authentication)를 담고 있는 문맥, 혹은 컨테이너입니다.

### SecurityContextHolder

SecurityContext를 담고 있는 쓰레드 로컬 저장소입니다.

### Authentication

사용자 식별자, 증명, 권한 등의 인증 정보를 담고 있는 객체입니다. SecurityContext에 담아 요청 전역에서 사용할 수 있습니다.

### GrantedAuthority

사용자 인증과 동시에 승인되는 권한들입니다.

## AuthenticationManager

Spring Security의 필터와 통신하기 위한 API입니다. 인터페이스이므로 이를 구현해야 합니다.

### ProviderManager

AuthenticationManager를 구현한 구현체입니다. 인가 서비스를 제공하는 Provider들을 리스트로 담아서 관리하며 인가 필요 시 사용자 요청에서 Id, Password, Token등을 꺼내서 Provider를 통해 인가를 시도합니다.

### AuthenticationProvider

### AuthenticationEntryPoint

### AbstractAuthenticationProcessingFilter

## 결론

## References

| URL | 게시일자 | 방문일자 | 작성자 |
| :-- | :------- | :------- | :----- |
