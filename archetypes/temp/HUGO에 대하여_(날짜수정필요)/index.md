---
title: "HUGO에 대하여"
date: 2024-03-02T07:28:40+09:00
weight: 998
tags: ["hugo", "setting", "blog management"]
categories: ["documentation"]
author: "Leaf"
description: "HUGO에 대해 알아보는 시간을 가집니다."
cover:
  image: "hugo.png" # image path/url
  alt: "hugo wide logo image" # alt text
  caption: "화려하고 컬러풀한 휴고의 로고" # display caption under cover
  relative: true # when using page bundles set this to true
  hidden: true # only hide on current single page
---

## 도입

이전 포스팅 참조 : [개발 블로그의 종류와 선택](https://leaf-nam.github.io/posts/blog/%EA%B0%9C%EB%B0%9C_%EB%B8%94%EB%A1%9C%EA%B7%B8%EC%9D%98_%EC%A2%85%EB%A5%98%EC%99%80_%EC%84%A0%ED%83%9D_240229/)

이제 깃허브 블로그를 쓰기로 마음먹었으니, 어떤 도구를 사용해서 블로그를 만들지에 대한 선택이 남았습니다. 인생도 그렇지만 개발도 항상 선택의 연속인 것 같습니다.

이번 포스팅에서는 SSG(Static Site Generator)의 개념, 종류와 특징에 대해 알아보고, SSG Framework 중 하나인 HUGO에 대해서 간단히 소개하고 설치까지 해보겠습니다.

## SSG

저는 최초 블로그를 작성하기 위해 어떻게 홈페이지를 만들어야 하는지 고민이 되었고, 여러 옵션들을 확인하던 중, SSG를 사용해 블로그를 만드는 것이 가장 좋아보여 이를 도입하게 되었습니다.

사실 SSG를 제대로 이해하기 위해서는 SSR, CSR, SPA 등의 개념에 대해 우선 설명해야 하지만, 이는 생각보다 양이 방대하고 개발의 역사와도 관련이 되는 내용이기에 나중에 별도의 포스팅으로 다루도록 하겠습니다. 지금은 블로그를 만들기 위한 필수개념 정도만 간단히 다루고 넘어가겠습니다.

> SSG(Static Site Generator)는 텍스트 입력 파일(ex. Markdown, reStructuredText, AsciiDoc 및 JSON)을 사용하여 정적 웹 페이지를 생성하는 엔진입니다.[^1]

즉, 간단한 텍스트 파일을 사용해 정적으로 웹 페이지를 빌드하고 배포하는 방식의 개발 방법입니다. 이러한 SSG는 다양한 장점을 갖고 있으며 SSG 프레임워크를 다루는 잼스택(JAMStack[^2]) 개발자가 별도로 등장할 정도로 최근 많이 주목받는 최신 트렌드 기술 중 하나입니다.

장점은 다음과 같습니다.

1. 확장성 : 이미 생성된 파일을 통해 서비스하므로, 기존에 빌드한 파일에 대해 더이상 추가적인 자원을 사용할 필요가 없습니다[^3]. 이는 기존 서비스에 대해 더이상 신경쓰지 않고 새로운 서비스를 확장할 수 있게 해줍니다.
2. 성능 : 이미 빌드가 되어있기에 생성된 파일을 전송하는 과정 자체도 빠른 응답이 가능하며, CDN[^4]과 같은 캐싱 서버에서 직접 해당 파일만 응답하면 되므로 더욱 빠른 성능을 기대할 수 있습니다.
3. 보안 : CDN을 통해 분리된 지역서버는 DB에 접근하지 않고 서비스가 가능하며, 해커에 의한 공격이 발생했을때 중앙 서버에 영향을 미치기 전에 해당 네트워크를 빠르게 분리하는 것이 가능합니다. 또한, 공격 대상인 서버를 다시 구성하여 CDN을 재구축하면 되기에 빠른 대응 또한 가능합니다.

이렇게 훌륭한 SSG이지만, 잼스택 개발자가 분리될 정도로 초기 구현 및 세팅이 복잡하고, 아직 많은 레퍼런스가 없기에 처음 공부하거나 도입하기가 어렵다는 단점이 있습니다.

제가 블로깅을 하면서 확장성이나 성능 등을 걱정할 일은 크게 없겠지만, 애초에 깃허브에서 제공하는 배포 도구를 사용하려면 단일 HTML이 필요했습니다. 매번 블로그에 글을 쓸때마다 HTML을 생성할 바에는 차라리 SSG를 공부해서 도입하는게 더 빠르겠다는 생각이었습니다.

## SSG의 종류

이어서

### Jekyll

### HUGO

## HUGO 소개

## HUGO 설치방법

## 결론

## References

[^1]: ["What is a Static Site Generator? How do I find the best one to use?"](https://www.netlify.com/blog/2020/04/14/what-is-a-static-site-generator-and-3-ways-to-find-the-best-one/). Netlify. 2020.04.14. Phil Hawksworth.
[^2]: ["What is Jamstack?"](https://jamstack.org/)
[^3]: CSR은 이와 다르게 매번 기존 파일을 빌드합니다.
[^4]: 지리적으로 분산된 서버들을 연결한 네트워크를 뜻합니다. 예를 들어 구글 서버는 미국에 있지만, 구글 코리아는 한국에 따로 서버를 구성해서 파일이 변경될 때만 미국의 구글서버와 동기화합니다. 이렇게 한국에 있는 구글서버를 통해 더욱 빠른 통신이 가능합니다.
