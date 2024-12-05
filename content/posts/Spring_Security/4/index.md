---
title: '[Java]4'
date: 2024-12-05T19:58:51+09:00
weight: #1
tags: ["not allocated"]
categories: ["not categorized"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "Desc Text."
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

## 설계

### 프로젝트 생성
1. **Springboot Project Setup**
2. **디렉터리 구조 생성**

### 요구사항 분석
1. 회원가입 및 로그인 시 JWT를 발행한다.`(인증)`
2. JWT가 없는 사용자는 인증이 필요한 요청을 수행할 수 없다.`(인증)`
3. JWT가 있지만 권한이 부족한 사용자는 인증이 필요한 요청을 수행할 수 없다.`(인가)`
4. JWT가 있고, 권한이 있는 사용자는 인증이 필요한 요청을 수행할 수 있다.`(Happy Case)`

> TDD를 할때는 Happy Case보다 예외상황과 경계값 등 놓치기 쉬운 테스트케이스를 먼저 작성하는게 좋습니다.

### 통합테스트 작성
- 회원가입 및 로그인 시 JWT를 발행한다.`(인증)`
- JWT가 없는 사용자는 인증이 필요한 요청을 수행할 수 없다.`(인증)`
- JWT가 있지만 권한이 부족한 사용자는 인증이 필요한 요청을 수행할 수 없다.`(인가)`
- JWT가 있고, 권한이 있는 사용자는 인증이 필요한 요청을 수행할 수 있다.`(Happy Case)`

## 구현(TDD)

### TODO 1

회원가입 및 로그인 시 JWT를 발행한다.`(인증)`

### TODO 2

JWT가 없는 사용자는 인증이 필요한 요청을 수행할 수 없다.`(인증)`

### TODO 3

JWT가 있지만 권한이 부족한 사용자는 인증이 필요한 요청을 수행할 수 없다.`(인가)`

### TODO 4

JWT가 있고, 권한이 있는 사용자는 인증이 필요한 요청을 수행할 수 있다.`(Happy Case)`

## 결론

### 다음 포스팅

## References

| URL | 게시일자 | 방문일자 | 작성자 |
| :-- | :------- | :------- | :----- |
