---
title: "Git 연동과 정적 페이지 배포"
date: 2024-03-04T16:50:39+09:00
weight: 996
tags: ["Git", "deploy", "hugo"]
categories: ["blog management"]
author: "Leaf"
description: "생성한 블로그와 깃을 연동 후 웹페이지를 등록합니다."
cover:
  image: "github_pages.png" # image path/url
  alt: "github pages logo" # alt text
  caption: "깃허브 페이지에 블로그를 올릴 수 있습니다." # display caption under cover
  relative: false # when using page bundles set this to true
  hidden: true # only hide on current single page
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
---

## 도입

> 이전 포스팅 참조 :
> [개발 블로그의 종류와 선택](https://leaf-nam.github.io/posts/blog/%EA%B0%9C%EB%B0%9C_%EB%B8%94%EB%A1%9C%EA%B7%B8%EC%9D%98_%EC%A2%85%EB%A5%98%EC%99%80_%EC%84%A0%ED%83%9D_240229/) > [SSG에 대하여](https://leaf-nam.github.io/posts/blog/ssg%EC%97%90-%EB%8C%80%ED%95%98%EC%97%AC_240302/) > [HUGO 기본 설치 및 사용법](https://leaf-nam.github.io/posts/blog/hugo-%EA%B8%B0%EB%B3%B8-%EC%84%A4%EC%B9%98-%EB%B0%8F-%EC%82%AC%EC%9A%A9%EB%B2%95_240303/)

지난 시간에 Hugo설치 및 간단한 사용법을 알아보았습니다. 이번에는 깃과 연동하여 버전관리 및 깃허브 페이지에 블로그를 띄워보겠습니다.

> [이 포스팅은 Git이 설치되어 있는 것을 전제로 합니다. 혹시 Git이 설치되지 않은 분들은 설치 후 진행해주세요.](https://git-scm.com/downloads)

## 블로그 디렉터리와 Git 연결하기

먼저 지난 시간에 생성한 디렉터리를 Git에 등록해야 합니다. 대부분 Git에 익숙하시겠지만, 아직 어려우신 분들을 위해 자세히 설명드리겠습니다.

### 블로그 레포지토리 생성

- Git에 특정 디렉터리를 올려 버전관리를 하기 위해서는 레포지토리를 생성해야 합니다.

{{<figure src="repository_create.png" caption="1.깃허브 메인 페이지에서 레포지토리 생성버튼을 클릭합니다.">}}

{{<figure src="new_repository.png" caption="2.레포지토리 이름을 작성하고 public을 선택한 후, Create repository 버튼을 클릭합니다.">}}

> 이제 깃허브에 블로그 레포지토리가 생성되었습니다.

### 블로그 레포지토리 연결

- 새로 생성한 레포지토리에 저번에 생성한 블로그 디렉터리를 연결합니다.
- 우선 git bash 혹은 zsh등의 쉘에서 'cd {디렉터리 경로}' 명령어를 통해 블로그의 최상위 디렉터리로 이동합니다.
  {{<figure src="git_root_directory.png" caption="git bash 혹은 zsh등의 쉘에서 블로그의 최상위 디렉터리로 이동합니다.">}}
- 다음 명령어를 통해 블로그 원격 레포지토리에 커밋합니다.

```py
# 새로운 로컬 레포지토리 생성
$ git init

# 원격 레포지토리 연결 : 원격 레포지토리 주소는 새로 생성된 레포지토리에 있습니다.(하단 이미지 참조)
$ git remote add origin {원격 레포지토리 주소}

# 로컬 브랜치 이름 변경(깃허브는 최초 브랜치가 main이고 깃은 master여서 이름을 main으로 변경해야 합니다.)
$ git branch -m main

# 로컬 레포지토리(블로그 디렉터리) → 원격 레포지토리로 커밋
$ git add .
$ git commit -m "first commit"
$ git push -u origin main
```

{{<figure src="repository_name_copy.png" caption="새로 생성된 레포지토리에서 위 버튼으로 원격 레포지토리 주소를 복사할 수 있습니다.">}}

> 이제 블로그 디렉터리와 레포지토리가 연결되어 변경사항을 커밋하면 깃허브에 저장할 수 있습니다.

## 배포용 레포지토리 생성하기

블로그 레포지토리를 성공적으로 등록하였으니, 이제 배포용 레포지토리를 생성해야 합니다.

이렇게 두 개의 레포지토리를 두는 이유는 다음과 같습니다.

1. Hugo로 빌드한 페이지를 별도의 레포지토리에서 관리하여 블로그 디렉터리와 소스코드 분리
2. 깃허브 계정의 정적페이지 주소와 동일한 이름의 레포지토리를 사용하여 메인 페이지 경로 단일화[^1]

그럼 배포용 레포지토리를 생성해서 연결해보겠습니다.

### 배포용 레포지토리 생성

- 본인의 깃허브 페이지 주소와 동일한 레포지토리를 생성합니다.
- 위의 [블로그 레포지토리 생성](https://leaf-nam.github.io/posts/240229_%EC%A2%8C%EC%B6%A9%EC%9A%B0%EB%8F%8C_%EA%B9%83%ED%97%88%EB%B8%8C_%EB%B8%94%EB%A1%9C%EA%B7%B8_%EC%83%9D%EC%84%B1%EA%B8%B0/240304_git_%EC%97%B0%EB%8F%99%EA%B3%BC_%EC%A0%95%EC%A0%81_%ED%8E%98%EC%9D%B4%EC%A7%80_%EB%B0%B0%ED%8F%AC/#1-%EB%B8%94%EB%A1%9C%EA%B7%B8-%EB%A0%88%ED%8F%AC%EC%A7%80%ED%86%A0%EB%A6%AC-%EC%83%9D%EC%84%B1)과 동일한 절차로 생성하되, 이름을 아래와 같이 설정하시면 됩니다.

```py
# 본인 깃허브 페이지 주소 : https://{본인 깃허브 계정명}.github.io
{본인 깃허브 계정명}.github.io
```

{{<figure src="github_pages_repository.png" caption="제가 현재 Github Pages에 등록해 사용중인 Repository입니다.">}}

> 배포용 레포지토리가 생성되었습니다.

### 블로그 레포지토리와 연결

- 새로 생성한 배포용 레포지토리는 블로그 레포지토리 내부의 public 경로에 submodule로 등록해야 합니다.
- 이렇게 등록 후 블로그 레포지토리에서 새로 페이지를 작성하면, 자동으로 배포용 레포지토리 내부 파일의 변경사항으로 잡히기 때문에 편하게 관리할 수 있습니다.
- submodule로 등록 및 확인하는 명령어는 다음과 같습니다.

```py
# git submodule add {서브모듈 레포지토리 주소} public
$ git submodule add https://github.com/leaf-nam/leaf-nam.github.io.git public

# 제대로 등록되었는지 확인해보려면, 아래 명령어를 실행합니다.
$ git submodule
# +72759664014b7a27ad069a24aa876836605e2d51 public (heads/main)
```

{{<figure src="github_submodule.png" caption="정상 등록 후 커밋 시 위와 같이 깃허브 경로 내부에 배포용 레포지토리가 submodule로 등록됩니다.">}}

> 이제 배포용 레포지토리가 서브모듈로 등록되어 배포할 준비를 마쳤습니다.

## 정적 사이트 배포하기

생성된 배포용 레포지토리에 정적파일들을 업로드 후 Github Pages를 사용하여 배포하겠습니다.

### 배포용 레포지토리에 정적파일 업로드

- git bash를 실행하여 블로그 레포지토리에서 정적파일들을 빌드합니다.

```py
# 블로그 레포지토리 메인 경로로 이동합니다.
$ cd {블로그 레포지토리 경로}

# 정적파일을 빌드합니다.
$ hugo
#Start building sites …
#hugo v0.123.4-21a41003c4633b142ac565c52da22924dc30637a+extended #darwin/arm64 BuildDate=2024-02-26T16:33:05Z VendorInfo=brew
#                   | KO
#-------------------+-----
#  Pages            | 67
#  Paginator pages  |  0
#  Non-page files   | 26
#  Static files     |  0
#  Processed images | 12
#  Aliases          | 25
#  Cleaned          |  0
```

- 배포용 레포지토리로 이동 후 해당파일들을 커밋합니다.

```py
# 배포용 레포지토리로 이동합니다.
$ cd public

# 해당 파일들을 커밋합니다.
$ git add .
$ git commit -m "blog 업로드"
$ git push origin main
```

> 이제 깃허브에 있는 레포지토리에 저희가 생성한 블로그 정적파일들이 업로드되었습니다.

### Github Pages 설정

- 배포용 레포지토리에 들어가서 다음 절차를 통해 Github Pages를 배포합니다.

{{<figure src="github_deploy_1.png" caption="1.레포지토리의 Settings로 이동합니다.">}}

{{<figure src="github_deploy_2.png" caption="2.사이드바의 Pages로 이동하면 현재 Branch의 배포 경로가 None으로 되어 있습니다.">}}

{{<figure src="github_deploy_3.png" caption="3.배포경로를 main-/(root)로 변경 후 Save합니다.">}}

{{<figure src="github_deploy_4.png" caption="4.상단바의 Actions로 들어가보면 배포가 진행되고 있습니다.">}}

{{<figure src="github_deploy_5.png" caption="5.배포가 완료된 후, 다시 Settings로 돌아오면 다음과 같이 배포중이라는 메시지가 보입니다.">}}

> 해당페이지로 들어가면 정상적으로 블로그가 배포됨을 확인할 수 있습니다.

## 결론

지금까지 블로그 페이지를 깃허브와 연동하고 Git Pages를 사용하여 배포까지 완료했습니다. 깃 사용이 익숙하신 분들이라면 금방 적용하셨을 것이라고 생각합니다.

> 직접 EC2와 같은 서버에 빌드해보신 분들이라면 아시겠지만, 별다른 세팅 없이 본인의 페이지를 빌드해서 즉시 웹에 게시할 수 있다는 점이 Git Pages의 강력한 점인 것 같습니다.

이제 블로그 배포까지 완료했으니, 다음 포스팅에서는 다른 사용자와 소통할 수 있는 댓글 기능을 utterances 라이브러리를 사용해 연결해보겠습니다.

## References

[^1]: 배포용 레포지토리의 이름을 깃허브 주소와 일치시키지 않으면, https://{깃허브 이름}.github.io/{레포지토리 이름} 형식으로 메인 페이지 URL이 구성됩니다.
