---
title: '[Java]Spring Security(With TDD) JWT oauth2-resource-server 활용헤서 간편하게 구현하기'
date: 2024-12-14T23:26:49+09:00
weight: #1
tags: ["authentication", "jwt"]
categories: ["spring", "security"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "JWT를 통한 인증을 oauth2-resource-server를 활용해서 간편하게 구현합니다."
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

저번 시간에는 `JWT`의 인증 필터를 직접 구현해서 인증 로직을 완성했습니다.

이번 시간에는 `Spring`에서 제공하는 `oauth2-resource-server` 라이브러리를 통해 동일한 인증 로직을 구현해보고, 두 방식의 차이점을 비교해 보도록 하겠습니다.

## 설계

### 요구사항 분석

### 통합 테스트

## 구현

### 라이브러리 가져오기

### SecurityFilterChain 구현

### Encoder, Decoder 구현

## 결론

### 직접 구현 VS 라이브러리 활용

### 다음 포스팅

## References

| URL | 게시일자 | 방문일자 | 작성자 |
| :-- | :------- | :------- | :----- |
