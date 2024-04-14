---
title: "Unit Testing"
date: 2024-04-14T19:37:37+09:00
weight: 3001
tags: ["review"]
categories: ["Unit Testing"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "Unit Testing 책에 대한 리뷰입니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 한줄평

> 테스트에서 오는 결정장애를 해소해주는 처방전

## 책을 읽게 된 계기

프로젝트에서 인터페이스를 단위테스트하려고 여기저기 찾아보다가 인터페이스를 테스트하는 것이 안티패턴이라는 여러 블로그 글을 보았습니다. 그 출처가 대부분 이 책이었고, 호기심이 생겨 책까지 읽어보게 되었습니다.

## 작가 소개

Vladimir Khorikov(블라디미르 코리코프)

> 블라디미르 코리코프(Vladimir Khorikov)는 'Unit Testing Principles, Practices, and Patterns'라는 책의 저자로, 이 책은 소프트웨어 개발에서 단위 테스팅에 대한 원칙, 실천 방법, 패턴을 다룹니다. 그는 15년 이상의 경력을 가진 소프트웨어 개발자로, 특히 팀을 지도하여 단위 테스팅의 모든 면을 가르치는 데 전문화되어 있습니다. 또한 그는 'Enterprise Craftsmanship' 블로그의 창시자로 매년 50만 명의 소프트웨어 개발자에게 접근합니다. 처음에는 일반 프로그래밍 주제에 대한 자문가로 시작했지만 최근에는 단위 테스팅에 중점을 두고 있으며, 주요 메시지는 소프트웨어 개발자들에게 단위 테스팅을 쉽게 만드는 방법을 가르치는 것입니다.[^1]

## 핵심요약

### 좋은 테스트의 속성

1. 회귀 방지 : 의도한 대로 기능이 동작하지 않는 것을 방지
2. 리팩터링 내성 : 리팩터링 시 쉽게 테스트가 깨지지 않는 것(거짓 양성 방지)
3. 빠른 피드백 : 빠른 실행과 결과 확인이 가능해야 함
4. 유지 보수성 : 테스트를 이해하기 쉽고, 실행하기 쉬워야 함(외부 종속 방지)

{{<figure src="diagram.png" caption="테스트의 속성과 테스트 종류 사이의 관계">}}

### 코드의 유형

1. 간단한 코드 : 테스트 작성할 필요 없음
2. 도메인 모델 및 알고리즘 : 단위 테스트 작성
3. 컨트롤러 : 통합 테스트 작성
4. 지나치게 복잡한 코드 : 도메인 모델과 컨트롤러로 리팩터링

{{<figure src="code_type.png" caption="코드의 유형 분류">}}

## 평가

테스트 코드를 작성하면서 애매했던 부분들을 명료하게 분류해주어서 좋았습니다. 특히 그래프 위주 설명과 용어에 대한 명확한 정의 이후 논리가 전개되어 생각의 흐름대로 이해하기 쉬웠습니다.

다만, C#과 .NET 프레임워크를 사용하여 일부 코드는 이해하기 어렵거나 해당 환경에 종속적인 부분이 있어 아쉬웠습니다.

## 느낀점

테스트를 작성하는 과정에서 막연하게 느꼈던 불편함과 무의미한 작업의 반복을 이론적으로 이해하게 되었습니다.

특히 **코드의 유형**에서 지금까지 컨트롤러나 너무 복잡한 코드를 단위테스트하려고 노력하다 보니, 위와 같은 불편함을 느꼈다는 것을 알게 되었습니다.

테스트를 짜면서 무언가 계속 잘못된 방향으로 가게 된다면, 우선 **원본 코드나 설계가 잘못되었는지**부터 의심하는 습관을 들여야겠습니다.

## 추천

조금 이해하기 어려운 추상적인 개념이나 예제가 있어 *처음 테스트를 접하거나 배워보고 싶은 분들*에게는 어려울 수 있을 것 같습니다. 반면 **실제로 테스트를 짜면서 답답한 기분을 느꼈던 분들**에게는 좋은 나침반이 되어 줄 수 있을 것 같아 강력 추천드립니다.

## References

| URL                                                                                                                                                                                                                         | 게시일자 | 방문일자    | 작성자            |
| :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------- | :---------- | :---------------- |
| https://www.pluralsight.com/authors/vladimir-khorikov?clickid=SNLXAPSJBxyPTuVxHH1vL11qUkHWyE09awR9R80&irgwc=1&mpid=1970485&aid=7010a000001xAKZAA2&utm_medium=digital_affiliate&utm_campaign=1970485&utm_source=impactradius | 미확인   | 2024.04.14. | Vladimir Khorikov |

[^1]: [Vladimir Khorikov is the author of the book Unit Testing Principles, Practices, and Patterns: https://amzn.to/2QXS2ch He has been professionally involved in software development for over 15 years, including mentoring teams on the ins and outs of unit testing. He's also the founder of the Enterprise Craftsmanship blog, where he reaches 500 thousand software developers yearly. He started as an adviser on general programming topics, but lately has shifted his focus to unit testing with a central message of teaching software developers how to make unit testing painless.](https://www.pluralsight.com/authors/vladimir-khorikov?clickid=SNLXAPSJBxyPTuVxHH1vL11qUkHWyE09awR9R80&irgwc=1&mpid=1970485&aid=7010a000001xAKZAA2&utm_medium=digital_affiliate&utm_campaign=1970485&utm_source=impactradius)
