---
title: "깃허브 블로그 댓글 구현 : Utterances 도입기"
date: 2024-03-05T19:08:20+09:00
weight: 995
tags: ["comment", "utterances", "blog"]
categories: ["blog management"]
author: "Leaf"
description: "블로그 댓글을 구현할 수 있는 utterances를 적용합니다."
cover:
  image: "cover.png" # image path/url
  alt: "utterances logo" # alt text
  caption: "utterances는 '입 밖에 냄'이라는 뜻의 라틴어 'ut'에서 유래했습니다." # display caption under cover
  relative: false # when using page bundles set this to true
  hidden: true # only hide on current single page
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: true # to append file path to Edit link
---

## 도입

> 이전 포스팅 참조 :
> [개발 블로그의 종류와 선택](https://leaf-nam.github.io/posts/blog/%EA%B0%9C%EB%B0%9C_%EB%B8%94%EB%A1%9C%EA%B7%B8%EC%9D%98_%EC%A2%85%EB%A5%98%EC%99%80_%EC%84%A0%ED%83%9D_240229/) > [SSG에 대하여](https://leaf-nam.github.io/posts/blog/ssg%EC%97%90-%EB%8C%80%ED%95%98%EC%97%AC_240302/) > [HUGO 기본 설치 및 사용법](https://leaf-nam.github.io/posts/240229_%EC%A2%8C%EC%B6%A9%EC%9A%B0%EB%8F%8C_%EA%B9%83%ED%97%88%EB%B8%8C_%EB%B8%94%EB%A1%9C%EA%B7%B8_%EC%83%9D%EC%84%B1%EA%B8%B0/240303_hugo-%EA%B8%B0%EB%B3%B8-%EC%84%A4%EC%B9%98-%EB%B0%8F-%EC%82%AC%EC%9A%A9%EB%B2%95/) > [Git 연동과 정적 페이지 배포](https://leaf-nam.github.io/posts/240229_%EC%A2%8C%EC%B6%A9%EC%9A%B0%EB%8F%8C_%EA%B9%83%ED%97%88%EB%B8%8C_%EB%B8%94%EB%A1%9C%EA%B7%B8_%EC%83%9D%EC%84%B1%EA%B8%B0/240304_git_%EC%97%B0%EB%8F%99%EA%B3%BC_%EC%A0%95%EC%A0%81_%ED%8E%98%EC%9D%B4%EC%A7%80_%EB%B0%B0%ED%8F%AC/)

저번 포스팅까지 블로그를 만들어봤는데요, 댓글이 없으니 뭔가 허전한 느낌입니다. 원래 블로그는 다른 사람과의 소통을 위함이니까요.

이번 시간에는 블로그 댓글을 생성하는 라이브러리들을 비교해보고, 그중 utterances를 직접 블로그에 적용해 보겠습니다.

> 저도 처음에는 어떻게 댓글을 구현할까 하다가, 직접 기능을 만들어보려고도 생각했었습니다. 하지만, 그럼 로그인 기능이나 댓글을 저장하는 DB도 만들어야 하는데 블로그 만드는 것보다 더 많은 노력이 필요할 것 같았습니다. 여기저기 찾아보니 댓글을 구현해주는 다양한 라이브러리가 있어 다행히 쉽게 적용할 수 있었습니다.

## 블로그 댓글 구현방법 비교

블로그 종류가 다양한 만큼, 블로그 댓글을 구현하는 방법도 다양합니다.

그럼 댓글 구현방법에 대한 각각의 장단점을 알아보겠습니다.

### Disqus

![disqus](disqus.png#center)

Disqus는 댓글을 쉽게 구현하도록 도와주는 프레임워크입니다. Disqus 내부에 서버가 있어 댓글을 작성하면 해당 서버에 댓글을 작성하고 불러오는 방식으로 구현됩니다.

또한, Hugo에서 공식적으로 지원하는 댓글 기능이기도 합니다.[^1]

[Hugo 문서](https://gohugo.io/content-management/comments/#configure-disqus)에 나와있는 것처럼 config에 Disqus 이름(shortname)을 작성하면 쉽게 연동이 가능합니다.

```yaml
services:
  disqus:
    shortname: your-disqus-shortname
```

**장점**

1. Hugo에서 기본으로 지원하는 기능인 만큼 연동성이 좋습니다.
2. 다른 사이트에 남긴 댓글들을 모아서 한번에 조회가 가능하며, 댓글 추이나 통계에 대한 분석도 제공합니다.[^2]
3. 사용자가 많고 특히 해외에서는 해당 서비스 사용자가 많은 것 같습니다.

**단점**

1. 댓글을 남기기 위해서는 사용자가 해당 서비스에 가입해야 합니다.
2. 현재까지 유효한 정책인지는 모르겠지만, 과거에는 2년 이상 사용 시 과금을 했다고 합니다. 서비스 기업이다 보니 차후에 요금정책이 변경될 가능성도 있을 것 같습니다.
3. 마찬가지로 해당 서비스가 종료되면 댓글도 사라질 위험이 있습니다.

> 저는 다른것보다 사용자가 새로운 회원가입을 해야 하는 부분에 불편함이 있을 것 같아 다른 옵션을 찾아보게 되었습니다.

### Commento

Commento는 가벼움과 프라이버시에 초점을 맞춘 댓글 플랫폼입니다. Commento 또한 해외에서 많이 사용하는 옵션 중 하나입니다.
Commento와 Disqus 사이에 고민하는 포스팅을 많이 볼 수 있었습니다.[^3]

**장점**

1. 프라이버시를 보장하기 위한 익명 댓글 기능이 있습니다.
2. 클라우드 서버나 사용자 DB에 연결되어 댓글이 저장되기 때문에 유실 걱정이 없습니다.
3. 제 기준에서는 UI나 디자인이 제일 깔끔한 것 같습니다.
   {{<figure src="commento.png" caption="Comment Demo 페이지, 이미지를 누르면 해당 데모 페이지로 이동합니다." link="https://demo.commento.io/">}}

**단점**

1. 클라우드 서비스 사용시 요금 정책이 있습니다. 현재 날짜 기준 월 10$, 연 99$입니다.
2. 클라우드 서비스나 DB에 등록하는 과정이 조금 복잡합니다.
3. 도메인별로 클라우드 서버를 설정하기 때문에 댓글 공유는 되지 않습니다.

> 요금은 클라우드 서비스를 사용하기 위해 어쩔 수 없이 내야하는 부분인 것 같고, 직접 DB를 구현하면 무료라고 합니다. 저는 차후 블로그 유저가 많아지거나, utterances가 불편한 점이 생기면 commento를 도입해볼 생각도 있습니다.

### Utterances

제 블로그에 도입해서 사용하고 있는 Utterances 입니다(사진은 cover에 있으니 생략하겠습니다.).

작동 원리는 깃허브 issue에 댓글을 남기고 트래킹하는 방식으로 구현이 되어있습니다.(정말 똑똑한 사람들이 많습니다.)

코드 한 줄만 추가하면 바로 사용할 수 있어 가볍고 깃허브 아이디만 있으면 쉽게 댓글을 달 수 있습니다.

**장점**

1. 방문자도 깃허브 계정만 있으면 댓글을 남기는 것이 가능합니다.
2. script 기반으로 설치 및 구현이 쉽습니다.
3. 깃허브 이슈와 연동되기 때문에 별도의 저장공간이 불필요합니다.

**단점**

1. 이슈번호와 연결이 잘못되면 다른 글에 남긴 댓글이 보이는 등 이상현상이 발생한다고 하네요.(아직 댓글이 없어서 직접 확인은 못했습니다.)
2. 깃허브가 없는 일반 사용자는 댓글을 남길 수 없습니다.
3. css를 설정하지 못하고 정해진 테마(9개) 중 선택해야 합니다.(css 테마가 필요하면 직접 구현해서 오픈소스에 기여해달라고 하네요..)

> 어차피 깃허브 블로그인 이상 제 블로그의 생명주기는 깃허브와 같아졌으므로, utterances가 가장 합리적인 선택으로 보였습니다. ~~여담이지만 utteranc.es라는 url 정말 잘 만든 것 같습니다.~~
> 사용해보고 문제가 있다면 다른 댓글 플랫폼도 사용해보고 싶네요.

## Utterances 설치방법

### Utterances 기본설정

### Hugo 템플릿 설정

[어떤 템플릿이 렌더링될까?](https://gohugo.io/templates/views/#which-template-will-be-rendered)

### Canonical Path 설정

## 결론

## References

1. Hugo 공식문서, 수정일 미등록, 2024.03.07.접속, https://gohugo.io/
2. Disqus 공식문서, 수정일 미등록, 2024.03.07.접속, https://disqus.com/
3. Commento 공식문서, 수정일 미등록, 2024.03.07.접속, https://commento.io/
4. Commento vs Disqus, 수정일 미등록, 2024.03.07.접속, https://stackshare.io/stackups/commento-vs-disqus

[^1]: [Hugo의 문서](https://gohugo.io/content-management/comments/)를 보면 공식적으로 Disqus를 지원하고 있습니다.
[^2]: [Disqus의 다양한 장점](https://disqus.com/platform/overview)은 해당 페이지에서 확인할 수 있습니다.
[^3]: [Commento vs Disqus](https://stackshare.io/stackups/commento-vs-disqus)
