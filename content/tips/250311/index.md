---
title: 'NGinX 심볼릭 링크 트러블슈팅'
date: 2025-03-11T15:40:09+09:00
weight: #1
tags: ["tips", "nginx", "linux", "symbolic link"]
categories: ["tinytips", "infra"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "NGinX 심볼릭 링크 생성 중 발생한 오류를 해결합니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: true # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 문제 상황
- 절대 경로에서 `NGinX`를 재부팅하면 정상 동작했지만, 심볼릭 링크를 통해 

## 기존 설정
- 서버 내부 `NGinX`의 설정(Config)에 특정 Server를 추가하는 작업을 수행중이었습니다.
- 다음과 같이 같이 `NGinX`의 Server 별로 `sites-available`파일을 생성 후, `sites-enabled`에 심볼릭 링크를 생성 후 연결하였습니다.
```shell
# NGinX 파일서버 블록 생성 
vi sites-available/file-server

# 파일서버 블록 내용 작성

# 심볼릭 링크 연결
ln -s sites-enabled ./sites-available
```
- 이후 다음과 같이 `nginx.conf` 파일에 링크 파일(`sites-enabled`)을 추가했습니다.
```shell
http {
  
  # ..(생략)..
  
  include sites-enabled/*;
}
```

## 문제 해결
- [다음 스택오버플로우 게시글](https://stackoverflow.com/questions/18089525/nginx-sites-enabled-sites-available-cannot-create-soft-link-between-config-fil)을 보고 문제 상황을 유추해볼 수 있었습니다.


## 심볼릭 링크 이해


## References
| URL                                                                                                                                                                                                                          | 게시일자        | 방문일자        | 작성자            |
|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------|:------------|:---------------|
| [Stack Overflow](https://stackoverflow.com/questions/18089525/nginx-sites-enabled-sites-available-cannot-create-soft-link-between-config-fil)                                                                                | 2013.08.06. | 2025.01.10  | iamyojimbo     |
| [GeeksForGeeks](https://www.geeksforgeeks.org/difference-between-relative-and-absolute-symlinks/)                                                | 2020.10.09. | 2025.01.10. | GeeksForGeeks  |
