---
title: 'localhost_쿠키_도난사건'
date: 2024-05-06T18:08:44+09:00
weight: #1
tags: ["coldcase"]
categories: ["coldcase"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "브라우저 로컬에서 테스트하던 쿠키가 계속해서 사라졌습니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---
## 환경
### FrontEnd : Next.js
```javascript
{  // package.json
    "node.js" : "20.11"
    "react" : "^18",
    "next" : "14.2.1", 
    "cookie" : "^0.6.0",
    "js-cookie" : "^3.0.5"
}
```
### BackEnd : SpringBoot
```groovy
// build.gradle
java { sourceCompatibility = '17' }
plugins {
    id 'org.springframework.boot' version '3.2.4'
    id 'io.spring.dependency-management' version '1.1.4'
}
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-data-redis'
    implementation 'org.springframework.session:spring-session-data-redis'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.springframework.boot:spring-boot-starter-oauth2-client'
    implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.4.0'
}
```

## 상황

- 프로젝트 중 로그인을 구현하기 위해 로컬에서 E2E 테스트를 진행하고 있었습니다.
- 프론트엔드 : http://localhost:3000
- 백엔드 : http://localhost:8080
- 대략적인 시퀀스는 다음과 같습니다.

{{<figure src="login.png" caption="로그인 시퀀스 다이어그램">}}

- 등록되지 않은 회원이 회원가입 시 다시 구글에 회원정보를 조회하지 않으려면, 로그인 시에 받아온 회원정보를 저장해야 했습니다.
- 이를 위해 회원가입 시 302 응답에 쿠키로 회원정보[^1]를 저장해서 전송했고, 보안을 위해 Http-only, secure 옵션을 적용했습니다.

### 문제상황

- localhost에서 테스트하는 과정에서 프론트엔드의 로그인 요청 후 Redirect 시 정상적으로 쿠키가 브라우저에 저장되지 않았습니다.
- 더 이상한 점은 분명 개발자 도구에서 캡쳐한 네트워크 패킷에 쿠키가 있었는데도 이를 저장하지 못했다는 것입니다.

- [패킷 캡쳐 사진 추가]

## 시도

### 쿠키관련 설정 변경
- 세션쿠키 영속쿠키로 변경
- Cookie secure 해제
- Cookie path 명시
- Cookie domain 127.0.0.1 로 변경
```java
// 기존 쿠키 생성 코드
public ResponseCookie getTimeoutCookie(String key, String value) {
    return ResponseCookie.from(key, URLEncoder.encode(value, StandardCharsets.UTF_8))
            .path("/register")  // 기존 : path("/")
            .domain("127.0.0.1")  // 기존 : localhost
            .secure(false)  // 기존 : True  * sameSite 옵션과 함께 사용시 True 로 변경 
            .maxAge(sessionTimeout)  // 기존 : 미작성(세션 쿠키)
            .build();
}
```

### Cors 관련 설정 확인 및 변경
- Allow Origin 설정
- Allow Method 설정
- Credentials 설정
- HttpHeader 노출
```java
    public CorsConfigurationSource getSource() {
    CorsConfiguration configuration = new CorsConfiguration();

    // allow local
    configuration.addAllowedOrigin("http://localhost:3000");
    configuration.addAllowedHeader("*");
    configuration.setAllowedMethods(asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
    configuration.setAllowCredentials(true);

    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfuration("/**", configuration);

    return source;
}
```

### 프론트엔드 쿠키 전달

```javascript
    fetch(apiUrl + "/users/login", {
    headers: {
        Authorization: `Bearer ${accessToken}`,
    },
    })
    .then((response) => {
        switch (response.status) {
            case 200: {
                window.history.go(-1);
                break;
            }
            case 302: {
                let setCookie = response.headers.get('Set-Cookie');
                console.log(setCookie) // 애초에 여기에 안찍힘
                if (setCookie) {
                    const parsed = cookie.parse(setCookie);
                    cookies().set('needRegist', parsed['isRegist'], parsed);
                    cookies().set('snsId', parsed['snsId'], parsed);
                    cookies().set('snsType', parsed['snsType'], parsed);
                    cookies().set('email', parsed['email'], parsed);
                }
                location.href = `/${locale}/register`;
                break;
            }
        }
    }).catch((error) => console.log(error));
```

> 현재 진행경과는 여기까지입니다. 추후 사건이 해결되면 최신화하도록 하겠습니다.

## References

| URL | 게시일자 | 방문일자 | 작성자 |
| :-- | :------- | :------- | :----- |
| https://github.com/ZeroCho/next-app-router-z/blob/master/ch4/src/auth.ts#L56|2024.02.20.|2024.05.02|ZeroCho|

[^1]: 물론 민감한 회원정보가 아닌 이메일 주소, snsId, OAuth 에이전트 정보 정도만 쿠키로 전달했습니다.