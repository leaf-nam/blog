---
title: "블로그를 쓰게 된 계기와 앞으로의 방향성"
date: 2024-02-28T21:06:14+09:00
weight: 2
tags: ["diary", "plan"]
categories: ["diary"]
author: "Leaf"
description: "내 첫번째 블로그 포스팅"
---

## 도입

미루고 미루던 블로그를 이제야 만들었다. 사실 내가 블로그를 쓰게 될 것이라고는 전혀 생각지도 못했지만, 이왕 시작한거 열심히 써보려고 한다.

## 첫 협업과 위키페이지 작성

블로그를 쓰게 된 가장 큰 계기는 첫 프로젝트에서 처음으로 협업을 하면서 느꼈던 생각들이었다.

같은 팀원들끼리 공유해야 할 것도 많았고, 팀장으로서 소통의 창구가 필요한 것도 느끼고 있었기에 처음에는 짧은 지식으로나마 직접 위키페이지를 만들었다.

(~~Vue.js로 로컬에서 라이브 서버를 띄워놓음...~~)

처음에는 나름 잘 만들었다고 뿌듯해 했지만,

1. 로컬에서만 작동하는 부분(같은 네트워크 대역을 쓸때만 접속이 가능)
2. 수정사항이나 새로운 요구사항이 발생할 때마다 변경이 힘듦
3. 팀원들도 사실 많이 이용하지는 않았는지 별로 피드백이 없었음

위의 이유(~~핑계~~)들로 프로젝트가 바빠지면서 점차 소홀히 관리하게 되었다.

## 첫 실패와 다짐

EC2 서버에 별도로 포트를 잡아 해당 페이지를 올려버릴까도 생각했었지만, 변경내역 관리나 빌드 등에 공수가 너무 들 것 같아 포기했었다.

하지만 프로젝트가 진행되면서 전역적인 설정이나 참고할만한 내용들을 올리는 창구는 통일되지 않았고, 비슷한 문제를 여러 번 설명하는 과정에서 확실히 시행착오들을 한군데에 정리해 둘 필요성이 있겠다는 생각이 들었다.

또한, 나중에 어떤 기술을 잘 모르는 사람들에게 내가 쓴 블로그의 글과 함께 설명한다면, 훨씬 이해를 도울 수 있겠다는 것도 이유 중 하나였다.

당시의 생각들과 실패를 반면교사 삼아, 이번에 마음먹고 며칠 고생해서 깃블로그를 만들었다. 아직 부족한 부분이 많지만 개선해나가는 과정에서 많이 배울 수 있을 것 같아 기대도 된다.
그리고 이렇게 내 지식을 정리하면서 느끼는 것은, 정리하거나 누군가에게 설명해보지 않고서는 내가 어떤 걸 알고 어떤 걸 정말 모르는지 판단하기 어렵다는 것이다.

## 앞으로의 계획

### 기술 블로그

우선, 개발자로 진로를 굳힌 만큼 내 기술과 지식, 시행착오들을 잘 정리해두려고 한다. 나도 물론 참고하겠지만, 다른 사람들에게도 조금이나마 도움이 되기를 바라는 마음이다. 오픈소스의 첫 발걸음을 뗀 것 같아 설레는 마음도 있다.

1. `Languages`

- `JAVA`

  자바에 대해 기초를 배우기는 했지만, java8 이후부터 변경된 사항과 좀더 깊은 부분들은 아직 많이 부족하다는 것을 코드를 짜면서도 많이 느낀다. 가급적 많은 사람들에게 도움이 될 수 있도록 시행착오나, 정말 필요한 내용들에 대해서 정리해보려고 한다.

- `Others`

  패러다임은 바뀌고 프로그래밍 언어는 계속 출시된다. 언젠가 자바와 스프링도 도태될 것이고, 더욱 멋지고 빠른 언어들이 계속 등장할 것이다. 다양한 언어가 있겠지만, 당장 알아보고 싶은건 Kotlin과 Elixir이다. 지금까지 배운 언어들도 정말 훌륭하고 멋진 기능들을 제공했지만, 똑똑한 개발자들이 만든 다른 언어들이 얼마나 대단한 기능을 제공할지 벌써 기대가 된다.

2.  `Spring`

    이 블로그 이름에서도 알 수 있듯이, 스프링은 나에게 많은 영감과 배움의 기회를 주었다. 스프링을 좀 더 깊이 알면 알수록, 객체지향에도 한발짝 다가가는 기분이 든다.

    스프링의 내부적인 동작들도 궁금하고, 특히 요즘은 스프링이 제공하는 어노테이션의 한계  
    (ex. bean은 최대 얼마나 등록 가능한지, 이떄 어플리케이션에 부하가 어느정도 되는지)  
    도 궁금해져서 언젠가 연구하고 정리해보고 싶다.

3.  `Database`

    아직 데이터베이스에 대한 지식은 정말 부족하다. JPA가 정말 너무 많이 도와주다보니 오히려 DB에 대해 너무 모르게 된 것이 아닌가 하는 생각도 든다.

    어차피 백엔드 개발자라면 결국 데이터와의 싸움을 하게 될 텐데, 나중에 후회하기 전에 미리 공부해두고 싶다.

4.  `Algorithm`

    결국 컴퓨터와 대화를 잘하려면 그들의 생각을 배울 필요가 있다. 아직 부족하지만, 조금씩 알고리즘 문제도 풀면서 논리적인 사고를 하는 습관을 계속 익혀야겠다. 가능할지는 모르겠지만, 객체지향적으로 인터페이스를 설계하고 클래스를 구현하는 방식으로 알고리즘 문제를 푸는 시도도 해보고 싶다.

5.  `Design Pattern`

    구조와 패턴을 잘 아는것은 그만큼 코드를 보는 눈을 넓혀주는 것 같다. 디자인 패턴에 대해 공부하고, 특히 실제로 어디에서 쓰이고 있는지 정리해보고 싶다.

6.  `Architecture`

    코드를 짜면서 항상 잘 짜고 있는지 의구심이 들었다. 좋은 코드와 좋은 설계가 무엇인지 공부하고 실제로 코드에 적용하면서 배우는 시간을 가져볼 예정이다.

7.  `Communications`

    군에 있을때부터 지독하게 얽혀있던 통신, 항상 어렵고 항상 모르겠지만 이제는 뭔가 익숙하다못해 친밀한 느낌마저도 든다. 나름 내 인생에 많은 부분을 차지했던 분야인만큼 잘 정리해두면 많은 사람들에게 도움이 될 수 있을 것 같다.

8.  `Infrastructure`

    인프라는 모든 서비스들이 제대로 동작하는 토대가 된다. 그만큼 중요한 분야이기 때문에 소홀히 할 수 없고, 트렌드도 자주 바뀌는만큼 계속 관심갖고 지켜볼 필요가 있을 것 같다.

9.  `Security`

    보안도 군에서부터 많이 따라다녔던 녀석이지만, 바쁘고 귀찮다는 핑계로 많이 소홀히 한적도 있었다. 배우면 배울수록 절대 소홀히 할 수 없는 부분이라고 생각해서 계속 공부해 나가려고 한다.

10. `Etc`

    더 많은 분야들이 있겠지만, 우선 위의 분야들 위주로 정리해나가고자 한다. 하지만 스스로도 너무 여기저기 기웃거리는 타입임을 잘 아는지라 언제 새로운 태그가 생길런지는 모르겠다.

### 취미 블로그

1. `Diary or Plan`

   매일 일기를 쓰는건 힘들겠지만, 주에 1번 혹은 달에 한번이라도 일기를 적어보려고 한다. 내 생각을 정리하는데 글쓰기 만큼 좋은것도 없는 것 같다. 그리고 앞으로의 계획이나 생각 등도 한곳에 정리해두고 싶다.

2. `Cube`

   요새 왜인지는 모르겠는데 어려서 했던 큐브가 재미있어서 조금씩 정리해보려고 한다. 너무 많은 시간을 뺏는 취미는 아니니까 시간날때 조금씩 하는 정도는 괜찮겠지..

## 결론

프로젝트를 하면서 블로그의 필요성을 진득하게 느껴서 다양한 분야의 기술을 한곳에 정리하는 개발 블로그를 운영해보려 한다.

**🔥 시작은 미미하지만 많은 사람들이 믿고 찾아볼 수 있는 위키가 될 수 있도록 꾸준히 노력하자.**
