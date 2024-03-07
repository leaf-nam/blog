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
> [개발 블로그의 종류와 선택](https://leaf-nam.github.io/posts/blog/%EA%B0%9C%EB%B0%9C_%EB%B8%94%EB%A1%9C%EA%B7%B8%EC%9D%98_%EC%A2%85%EB%A5%98%EC%99%80_%EC%84%A0%ED%83%9D_240229/) > [SSG에 대하여](https://leaf-nam.github.io/posts/blog/ssg%EC%97%90-%EB%8C%80%ED%95%98%EC%97%AC_240302/) > [HUGO 기본 설치 및 사용법](https://leaf-nam.github.io/posts/blog/hugo-%EA%B8%B0%EB%B3%B8-%EC%84%A4%EC%B9%98-%EB%B0%8F-%EC%82%AC%EC%9A%A9%EB%B2%95_240303/) > [Git 연동과 정적 페이지 배포](https://leaf-nam.github.io/posts/240229_%EC%A2%8C%EC%B6%A9%EC%9A%B0%EB%8F%8C_%EA%B9%83%ED%97%88%EB%B8%8C_%EB%B8%94%EB%A1%9C%EA%B7%B8_%EC%83%9D%EC%84%B1%EA%B8%B0/240304_git_%EC%97%B0%EB%8F%99%EA%B3%BC_%EC%A0%95%EC%A0%81_%ED%8E%98%EC%9D%B4%EC%A7%80_%EB%B0%B0%ED%8F%AC/)

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

Commento는 가벼움과 프라이버시에 초점을 맞춘 댓글 플랫폼입니다.
Commento와 Disqus 사이에 고민하는 포스팅을 많이 볼 수 있었습니다.[^3]

### Utterances

## utterances 설치방법

[어떤 템플릿이 렌더링될까?](https://gohugo.io/templates/views/#which-template-will-be-rendered)

## Canonical Path 설정

## 결론

## References

1. [Hugo 공식문서](https://gohugo.io/)
2. [Disqus 공식문서](https://disqus.com/)
3. [Commento 공식문서](https://commento.io/)

[^1]: [Hugo의 문서](https://gohugo.io/content-management/comments/)를 보면 공식적으로 Disqus를 지원하고 있습니다.
[^2]: [Disqus의 다양한 장점](https://disqus.com/platform/overview)은 해당 페이지에서 확인할 수 있습니다.
[^3]: [Commento vs Disqus](https://stackshare.io/stackups/commento-vs-disqus)
