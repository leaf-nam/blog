---
title: "SSG에 대하여"
date: 2024-03-02T07:28:40+09:00
#weight: 9
tags: ["ssg", "concept", "hugo", "next.js", "jekyll", "jamstack", "blog"]
categories: ["blog management"]
author: "Leaf"
description: "SSG에 대해 알아보는 시간을 가집니다."
cover:
  image: "jamstack.png" # image path/url
  alt: "jamstack image" # alt text
  caption: "jamstack.org에 들어가면 볼 수 있는 첫 문구" # display caption under cover
  relative: true # when using page bundles set this to true
  hidden: true # only hide on current single page
---

## 도입

이전 포스팅 참조 : [개발 블로그의 종류와 선택](https://leaf-nam.github.io/posts/blog/%EA%B0%9C%EB%B0%9C_%EB%B8%94%EB%A1%9C%EA%B7%B8%EC%9D%98_%EC%A2%85%EB%A5%98%EC%99%80_%EC%84%A0%ED%83%9D_240229/)

이제 깃허브 블로그를 쓰기로 마음먹었으니, 어떤 도구를 사용해서 블로그를 만들지에 대한 선택이 남았습니다. 인생도 그렇지만 개발도 항상 선택의 연속인 것 같습니다.

이번 포스팅에서는 SSG(Static Site Generator)의 개념, 종류와 특징에 대해 알아보고, SSG Framework 중 하나인 HUGO에 대해서 간단히 소개하겠습니다.

## SSG

저는 최초 블로그를 작성하기 위해 어떻게 홈페이지를 만들어야 하는지 고민이 되었고, 여러 옵션들을 확인하던 중, SSG를 사용해 블로그를 만드는 것이 가장 좋아보여 이를 도입하게 되었습니다.

사실 SSG를 제대로 이해하기 위해서는 SSR, CSR, SPA 등의 개념에 대해 우선 설명해야 하지만, 이는 생각보다 양이 방대하고 개발의 역사와도 관련이 되는 내용이기에 나중에 별도의 포스팅으로 다루도록 하겠습니다. 지금은 블로그를 만들기 위한 필수개념 정도만 간단히 다루고 넘어가겠습니다.

> SSG(Static Site Generator)는 텍스트 입력 파일(ex. Markdown, reStructuredText, AsciiDoc 및 JSON)을 사용하여 정적 웹 페이지를 생성하는 엔진입니다.[^1]

즉, 간단한 텍스트 파일을 사용해 정적으로 웹 페이지를 빌드하고 배포하는 방식의 개발 방법입니다.

이러한 SSG는 다양한 장점을 갖고 있으며 SSG 프레임워크를 다루는 잼스택(JAMStack[^2]) 개발자가 별도로 등장할 정도로 최근 많이 주목받는 최신 트렌드 기술 중 하나입니다.

장점은 다음과 같습니다.

1. **확장성** : 이미 생성된 파일을 통해 서비스하므로, 기존에 빌드한 파일에 대해 더이상 추가적인 자원을 사용할 필요가 없습니다[^3]. 이는 기존 서비스에 대해 더이상 신경쓰지 않고 새로운 서비스를 확장할 수 있게 해줍니다.
2. **성능** : 이미 빌드가 되어있기에 생성된 파일을 전송하는 과정 자체도 빠른 응답이 가능하며, CDN[^4]과 같은 캐싱 서버에서 직접 해당 파일만 응답하면 되므로 더욱 빠른 성능을 기대할 수 있습니다.
3. **보안** : CDN을 통해 분리된 지역서버는 DB에 접근하지 않고 서비스가 가능하며, 해커에 의한 공격이 발생했을때 중앙 서버에 영향을 미치기 전에 해당 네트워크를 빠르게 분리하는 것이 가능합니다. 또한, 공격 대상인 서버를 다시 구성하여 CDN을 재구축하면 되기에 빠른 대응 또한 가능합니다.

이렇게 훌륭한 SSG이지만, 잼스택 개발자라는 직군이 따로 분리될 정도로 초기 구현 및 세팅이 복잡하고 아직 많은 레퍼런스가 없기에 처음 공부하거나 도입하기가 어렵다는 단점이 있습니다.

> 제가 블로깅을 하면서 확장성이나 성능 등을 걱정할 일은 크게 없겠지만, 애초에 깃허브에서 제공하는 배포 도구를 사용하려면 단일 HTML이 필요했습니다.
> 매번 블로그에 글을 쓸때마다 HTML을 생성할 바에는 차라리 SSG를 공부해서 도입하는게 더 빠르겠다는 생각에 SSG를 사용하기로 마음먹었습니다.

## SSG의 종류

이러한 SSG에도 종류가 많습니다. SSR(Server Side Rendering)[^5] 프레임워크로 알고있던 Next.js도 SSG를 지원했고, 국내 개발 블로그에서 많이 사용하는 jekyll과 제가 사용하는 Hugo 또한 SSG입니다. 이러한 SSG의 특징과 장단점에 대해 알아보겠습니다.

~~(어째 저번 포스팅과 흐름이 똑같네요..)~~

### Next.js

![Next JS image](next.png#center)

국내 프론트엔드 시장의 대부분을 점유하고 있는 React를 사용해 SSR을 구현한 프레임워크입니다. Vercel에서 개발하고 관리하고 있습니다.~~(React를 만든 Meta에서 개발한게 아니었네요!)~~

제가 생각한 장점 및 특징은 다음과 같습니다.

1. **많은 레퍼런스와 개발 생태계**

   - 아래 그래프[^6]에서 보시는 것처럼 국내 프레임워크의 높은 순위를 차지하고 있는 React + Next.js인 만큼 수많은 레퍼런스와 학습자료를 쉽게 찾아볼 수 있습니다.
   - 또한, 개발자가 많다는 것은 그만큼 에러가 발생했을 때 여기저기에 질문을 통해 쉽게 해결할 수 있다는 뜻이기도 합니다.
     {{< figure src="next_survey.png" caption="프로그래머스 통계 : 주로 사용하는 웹 프레임워크 또는 라이브러리는 무엇인가요?">}}

2. **안정성과 다양한 오픈소스 지원**

   - 우선 메타에서 지원 및 유지보수를 하는 React 기반의 프레임워크인 점에서 매우 안정성이 높다고 할 수 있습니다.
   - 또한, 위에서 본 것처럼 많은 사용자들을 보유하다 보니 관련된 오픈소스 라이브러리도 많습니다.
   - 저도 프론트엔드 라이브러리를 도입하기 위해 오픈소스를 찾아보면 체감상 80% 이상은 React기반으로 생성되어 있는 것 같습니다.
   - ~~(부끄럽지만 아직 Vue.js만 조금 다루는 수준이라 React로 되어있는 오픈소스는 그림의 떡처럼 아쉬운 적도 많았습니다.)~~

3. **Vercel과 연동한 손쉬운 배포**

   - 개발사인 vercel은 클라우드 컴퓨팅을 제공하는 회사입니다.
   - 즉, 기본적인 웹사이트 배포를 위한 인프라가 이미 완성되어 있기에 웹페이지만 완성하면 빌드 및 배포하는 것은 정말 쉽다고 합니다.
   - 이러한 호환성을 무기로 하기 위해 Vercel에서 React를 활용한 Next.js 생태계를 구축하지 않았나 싶습니다.

> 원래도 React는 한번 공부해보고는 싶었고, React만 알면 쉽게 웹페이지를 제작할 수 있다는 부분은 정말 매력적으로 다가왔습니다.

> 하지만 React를 단시간에 배울 수 있을지도 조금 걱정되었고, 너무 큰 생태계인지라 블로그를 작성하는 것보다 프레임워크를 배우는데 더 많은 시간을 쓸까 우려가 되었습니다. 자칫 배보다 배꼽이 커질 수도 있겠다는 생각이 들어 다른 옵션을 찾아보게 되었습니다.

### Jekyll

![Jekyll image](jekyll.png#center)

지킬은 Ruby[^7]로 개발된 SSG입니다.

깃허브의 공동 설립자 Tom Preston-Werner에 의해 개발되었으며, 깃허브가 나온 2008년에 함께 출시되었으니 깃허브와 거의 역사를 함께했습니다.

위 내용만 봐도 깃허브와 아주 친할 것 같은 느낌이네요. 실제로 국내 대부분의 깃허브 블로그는 Jekyll을 활용하고 있고 같은 언어를 사용하기에 호환성이 좋습니다.

그럼 특장점을 살펴보겠습니다.

1. **깃허브 연동성**

   - 애초에 깃허브 블로그를 만들기 위해 나온 SSG이기 때문에, 별다른 설치없이 Ruby만 설치하면 RubyGems[^8]를 통해 쉽게 설치가 가능합니다.
   - 아마 깃허브나 지킬 둘중 하나가 망하지 않는 한 깃허브와의 연동은 별다른 이슈가 없을 것 같습니다.

2. **다양한 레퍼런스와 테마**

   - Next.js만큼은 아니지만 국내의 많은 블로그가 Jekyll로 만들어져 있기 때문에 참고할 만한 사이트가 많습니다.
   - 테마도 많아서 다양한 테마를 직접 설치하고 커스터마이징 하는 것이 가능합니다.[^9]

3. **가벼움**

   - 처음에는 RubyGems의 라이브러리 중 하나가 아닌가 생각할 정도로 가볍고 간편합니다.
   - 저도 개발 경험이 많지는 않지만 지킬과 같이 가볍고 최소한의 필요한 기능만 제공하는 프레임워크가 금방 손에 익고 편했습니다.

> 저도 Jekyll을 찾아보면서 Ruby라는 언어가 매우 흥미롭게 다가와서 공부해보고 싶다는 생각도 많이 들었습니다. 그리고 Jekyll은 굳이 Ruby의 내부 동작을 몰라도 간단한 쉘스크립트만 실행하면 되기에 배우는데는 큰 무리가 없어 보였습니다.

> 하지만 좀더 찾아보니 Ruby만 설치하면 된다는게 말이 쉽지, 사실 쉽지많은 않다는 이야기도 많았고, ~~(Ruby환경세팅이 악명 높기로 유명하다고 합니다)~~ 테마를 적용하는 과정에서도 RubyGem의 번들링하는 과정이 상대적으로 번거롭다는 글도 확인했습니다.[^10]

> 마지막으로 깃허브에 많이 의존하고 있다는 것은 반대로 생각하면 깃허브와 생명주기를 함께한다는 것이고, 나중에 다른 사이트나 클라우드를 통해 배포를 하고 싶을때 걸림돌이 되지 않을까 하는 생각도 들었습니다.

### Hugo

드디어 오늘의 주인공 Hugo입니다. 이름에서 알 수 있듯이 go언어로 만들어진 SSG입니다. 공식 웹사이트에 들어가면 자세한 설명을 보실 수 있습니다.[^11]

해외에는 비교적 인기가 많은 것 같은데, 국내에는 레퍼런스가 많이 없습니다. 저도 블로그 환경세팅을 하면서 많은 애를 먹고 있는데, 그래도 세계공용어인 영어가 있으니 대부분의 문제는 어찌저찌 해결이 되긴 합니다..

그래도 레퍼런스가 없다는 것을 모두 상쇄할 만큼 좋은 장점들이 많아 결국 Hugo를 선택하게 되었습니다.

1. **성능**

   - 공식 홈페이지에 나와있는 유튜브만 보더라도 성능 면에서 압도적입니다.

   {{< youtube CdiDYZ51a2o >}}

   - 영상을 다 보시기 귀찮은 분들을 위해 요약하자면, 하루에 2개씩 5000개의 포스트를 작성하면 대략 6.8년이 걸리는데, 이정도 되는 양도 Hugo로 생성시 6~7초면 빌드가 완료된다는 영상입니다.

   - (반면, Jekyll은 1000개 빌드하는데 4~5분 걸린다고 하네요. 공식 페이지에도 빌드관련 이슈가 상당히 많습니다.[^12])

2. **Go**

   - 구글에서 사용하는 Go(Golang) 기반이라는 점도 매력적이라고 생각합니다.
   - 컴파일 언어이지만 정말 빨라서 마치 인터프리터 언어처럼 사용이 가능하다고 하는데, 구글에서 지원하고 개발하는만큼 향후에도 많은 발전이 이루어지지 않을까 기대가 됩니다.
   - 문법도 점점 쉽게 개선되고 있고, 특히 html 템플릿은 이중 중괄호 문법으로 마치 Vue.js나 백엔드에서 익숙한 Mustache처럼 간편하게 사용이 가능합니다.

   {{< figure src="gogopher.jpeg" caption="Go의 마스코트인 Go gopher. 이름을 좀 대충 지은 티가 나는 것 같기도...?">}}

   ```go
   // 위 그림을 불러오기 위한 템플릿 문법입니다.
   // 원래는 {{와 <를 붙여야 하지만, 예시를 위해 띄어쓰기 했습니다.
   {{ <figure src="gogopher.jpeg" caption="Go의 마스코트인 Go gopher. 이름을 좀 대충 지은 티가 나는 것 같기도...?"> }}

   ```

3. **테마 적용과 확장의 용이성**

   - 지킬과 함께 블로그 SSG의 양대산맥인 가장 큰 이유 중 하나는 바로 방대한 양의 테마입니다.
   - 고르는 게 힘들 정도로 다양한 테마가 있고[^13], 이러한 테마를 적용하거나 커스터마이징 하는게 매우 간편합니다.
   - 저도 시작한지 얼마 되지 않았지만 확실히 테마를 만들거나 불러오는 기능이 간편하고 적용하기도 쉬웠습니다.

```python
 # 테마를 다운로드받은 후 이 한줄이면 테마가 변경됩니다.
 hugo -t "테마이름"
```

> Go와 테마도 좋지만, 아무래도 성능이 가장 끌리는 부분인 것 같습니다. 애초에 SSG를 사용하는 부분도 빠르고 간편하기 때문인데, 빌드하는 과정에서 너무 많은 시간이 소요되면 원래의 목적과 멀어질 우려가 듭니다. ~~백엔드는 역시 성능!~~

## 결론

지금까지 SSG의 특징과 종류, 그리고 제가 Hugo를 선택하게 된 이유에 대해 알아보았습니다. 사실 Hugo 말고 다른 SSG도 정말 훌륭하고, 블로깅 정도로 사용하기에는 전혀 무리가 없다고 생각합니다.

다들 장단점을 잘 찾아보시고 고민해서 본인의 상황에 맞는 최적의 스택을 고르셨으면 좋겠습니다!

> 블로그 경험이 없다보니 분량조절이 힘드네요.. 사실 이번 포스팅에서 hugo 설치 및 적용까지 하려고 했는데 내용이 자꾸 길어져서 해당 포스팅은 다음번에 작성하는 것으로 하겠습니다. 그리고 앞으로는 하루 1시간 정도에 작성할 수 있는 분량으로 포스팅을 이어나가려고 합니다.

## References

[^1]: ["What is a Static Site Generator? How do I find the best one to use?"](https://www.netlify.com/blog/2020/04/14/what-is-a-static-site-generator-and-3-ways-to-find-the-best-one/). Netlify. 2020.04.14. Phil Hawksworth.
[^2]: ["What is Jamstack?"](https://jamstack.org/)
[^3]: CSR은 이와 다르게 매번 기존 파일을 빌드합니다.
[^4]: 지리적으로 분산된 서버들을 연결한 네트워크를 뜻합니다. 예를 들어 구글 서버는 미국에 있지만, 구글 코리아는 한국에 따로 서버를 구성해서 파일이 변경될 때만 미국의 구글서버와 동기화합니다. 이렇게 한국에 있는 구글서버를 통해 더욱 빠른 통신이 가능합니다.
[^5]: 서버에서 페이지를 렌더링하는 방식입니다. SSG와 유사하지만, SSR은 요청 시마다 페이지를 렌더링해서 전송하는 방식이고 SSG는 서버 빌드 시점에 이미 해당 페이지를 생성합니다.
[^6]: [Programmers Dev Survey 2023](https://programmers.co.kr/pages/2023-dev-survey).Programmers. 2022.12.05. ~ 2022.12.31.
[^7]: 마츠모토 유키히로가 1995년 만든 스크립트 언어입니다. Ruby On Rails(ROR)라는 프레임워크를 사용하면 풀스택 개발도 가능하며, 깃허브도 ROR로 만들어져 있습니다.
[^8]: Ruby에서 사용하는 패키지 관리자입니다. 'gem'으로 시작하는 쉘스크립트는 해당 패키지 관리자를 호출하는 스크립트입니다. (~~보석 컨셉이 확실하네요!~~)
[^9]: [Jekyll 테마 사이트](http://jekyllthemes.org/)
[^10]: [GitHub Pages를 이용한 기술 블로그 제작 후기](https://techblog.yogiyo.co.kr/github-pages%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%9C-%EA%B8%B0%EC%88%A0-%EB%B8%94%EB%A1%9C%EA%B7%B8-%EC%A0%9C%EC%9E%91-%ED%9B%84%EA%B8%B0-77ce4b5e5564).Yogiyo. 2019.01.23. Yogiyo Tech Blog
[^11]: [What is Hugo](https://gohugo.io/about/what-is-hugo/)
[^12]: [Build Time Performance Issues](https://talk.jekyllrb.com/t/build-time-performance-issues/7042)
[^13]: [Hugo 테마 사이트](https://themes.gohugo.io/)
