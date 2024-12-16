---
title: '[Java]Spring Security(With TDD) JWT 직접 구현하기'
date: 2024-12-09T22:01:51+09:00
weight: #1
tags: ["authentication", "jwt"]
categories: ["spring", "security"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "JWT를 통한 인증을 직접 구현합니다."
disableHLJS: true # to disable highlightjs
ShowReadingTime: true
ShowWordCount: true
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: true # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 도입

### 지난 포스팅

- [[Java]Spring Security WebMVC 기본 구조](https://1eaf.site/posts/spring_security/1)
- [[Java]Spring Security 예외처리, 캐싱, 로깅](https://1eaf.site/posts/spring_security/2)
- [[Java]Spring Security 인증(Authentication)과 인가(Authorization)](https://1eaf.site/posts/spring_security/3)
- [[Java]Spring Security(With TDD) 기본 인증 및 인가 구현하기](https://1eaf.site/posts/spring_security/4)

지금까지 `Spring Security`의 기본 개념을 학습하고, 기본 인증 및 인가를 구현했습니다.

이번 시간에는 `JWT`의 기본 개념을 익히고, 프로젝트의 인증 및 인가 로직에 활용해보겠습니다.

### JWT

`JWT`는 `JSON Web Token`의 준말로 [RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519) 명세에 정의된 토큰입니다.
  
  - 위 명세에 따르면, JWT는 다음과 같이 정의할 수 있습니다.

  `JSON Web Token (JWT)는 두 당사자 간에 전송되는 클레임(claims)을 표현하기 위한 간결하고 URL에 안전한 수단입니다. JWT의 클레임은 JSON 객체로 인코딩되며, 이는 JSON Web Signature (JWS) 구조의 페이로드(payload)로 사용되거나 JSON Web Encryption (JWE) 구조의 평문(plaintext)으로 사용됩니다. 이를 통해 클레임은 디지털 서명되거나 메시지 인증 코드(Message Authentication Code, MAC)를 사용하여 무결성이 보호되거나 암호화될 수 있습니다.`

이러한 JWT 인증의 장단점을 살펴보면 다음과 같습니다.

- **장점**

  1. `stateless`[^1]한 특성이 있어 서버 부담을 줄일 수 있습니다.
      > 서버에 사용자의 정보들을 별도로 저장하지 않고도, JWT를 복호화함으로써 인증된 사용자임을 바로 파악할 수 있기 때문입니다.

  2. `Cookie 저장소`[^2]를 지원하지 않는 등 기존의 `Session - Cookie 방식`을 사용할 수 없는 환경에서도 인증이 가능합니다.
  
  3. 프론트엔드와 백엔드가 분리된 아키텍쳐로 개발되는 현대 웹앱에 적합한 형태입니다.
     > 특히, 백엔드 서버가 `Scale Out`[^3]이나 `MSA`[^4] 등으로 구조가 복잡해지면 필연적으로 인증 동기화의 어려움을 겪는데, JWT를 활용하면 토큰 유효성만 검사하면 되기 때문에 이러한 문제를 쉽게 해결할 수 있습니다. 

- **단점**
  
  1. 해당 방식을 사용하려면 프론트엔드에서 JWT를 어딘가에 보관했다가 요청 시 함께 전송해야 하는데, 이러한 과정에서 토큰을 탈취당할 수 있습니다.
  
  2. 토큰 탈취를 막기 위해 `Refresh Token`[^5]을 도입할 수 있지만, 이를 저장 및 검증하는 과정에서 추가적인 서버 부하가 발생합니다.
  
  3. 인코딩되는 토큰의 길이가 길기 때문에, 토큰 전송 과정에서 네트워크 부하가 발생합니다.

  4. Payload(Body)에 담기는 정보는 암호화되지 않기 때문에, 중요하거나 취약한 정보를 담을 수 없습니다.  
  
> `Session - Cookie`의 장단점은 `JWT`와 정반대라고 생각하시면 되겠습니다. `Session - Cookie` 방식을 사용할지 `JWT`를 사용할지는 요구사항에 따라 다를 수 있으니, 장단점을 따져보고 취사선택 하시면 되겠습니다. 

## 설계

JWT를 구현하는 두가지 방법이 있습니다.
1. **Filter 직접 구현**
2. **Spring Security oauth2-resource-server 활용**

> 실무나 실제 프로젝트에서는 2번 방식이 적절하겠지만[^6], JWT 인증의 내부 로직을 확인해보기 위해 1번 방식으로 우선 구현해보겠습니다.

### JWT 의존성 추가

다음과 같이 `build.gradle`에 [JWT 파싱을 위한 라이브러리](https://github.com/jwtk/jjwt)를 추가해줍니다.

   ```groovy
     // for jjwt
     implementation 'io.jsonwebtoken:jjwt-api:0.12.6'
     implementation 'io.jsonwebtoken:jjwt-impl:0.12.6'
     implementation 'io.jsonwebtoken:jjwt-jackson:0.12.6'
   ```

  ![JWT 의존성 추가](build_gradle.png)      
  
  > 저는 jjwt를 사용하겠습니다. 다양한 라이브러리가 있지만, 대부분 기능은 유사하니 사용이 편한 라이브러리를 사용하시면 되겠습니다.
     

### 요구사항 분석

JWT를 사용해서 달성하려는 요구사항을 정리해보면 다음과 같습니다.

1. 로그인 실패 시 jwt를 발행하지 않는다.
2. 정상 로그인 시 jwt를 발행한다.`(Happy Case)`
3. 잘못된 jwt로 인증할 수 없다.
4. 권한이 부족한 jwt에 인가할 수 없다.
5. 정상적인 jwt로 특정 권한의 api를 사용할 수 있다.`(Happy Case)`

### 통합테스트 작성

```java

/* 생략 */

@ExtendWith(SpringExtension.class)
@ContextConfiguration(classes = SecurityConfig.class)
@WebAppConfiguration
public class JWTIntegrationTest {

    MockMvc mockMvc;
    JwtUtil jwtUtil;

    @Autowired
    WebApplicationContext context;

    @BeforeEach
    void init() {
        jwtUtil = new JwtUtil();
        mockMvc = MockMvcBuilders.webAppContextSetup(context)
                .apply(springSecurity()).build();
    }

    @Test
    @DisplayName("1. 로그인 실패 시 jwt를 발행하지 않는다.")
    void testLoginFailure() throws Exception {
        // given : 정상 아이디와 잘못된 패스워드(user)
        String id = "user";
        String password = "badPassword";

        // when : 토큰 발급 시도
        mockMvc.perform(post("/jwt/token")
                        .param("username", id)
                        .param("password", password))

                // then : 401(Unauthenticated) 오류
                .andExpect(status().is(401));

        // given : 정상 아이디와 잘못된 패스워드(admin)
        id = "admin";
        password = "badPassword";

        // when : 토큰 발급 시도
        mockMvc.perform(post("/jwt/token")
                        .param("username", id)
                        .param("password", password))

                // then : 401(Unauthenticated) 오류
                .andExpect(status().is(401));
    }

    @Test
    @DisplayName("2. 정상 로그인 시 jwt를 발행한다.(Happy Case)")
    void testLoginSuccess() throws Exception {
        // given : 정상 아이디, 패스워드
        String id = "user";
        String password = "user1234";

        // when : 토큰 발급
        String token = mockMvc.perform(post("/jwt/token")
                        .param("username", id)
                        .param("password", password))
                .andExpect(status().is(200))
                .andReturn().getResponse().getContentAsString();

        // then : 정상 토큰여부 확인(JwtUtil)
        jwtUtil.validate(token);
    }

    @Test
    @DisplayName("3. 잘못된 jwt로 인증할 수 없다.")
    void testAuthentication() throws Exception {
        // given : 잘못된 jwt 토큰
        String badToken = "bearer asdf1234";

        // when : User API 접근
        mockMvc.perform(get("/jwt/user/resources")
                        .header(HttpHeaders.AUTHORIZATION, badToken))

                // then : 401 오류
                .andExpect(status().is(401));
    }

    @Test
    @DisplayName("4. 권한이 부족한 jwt에 인가할 수 없다.")
    void testAuthorization() throws Exception {
        // given : User JWT 획득
        String id = "user";
        String password = "user1234";
        String userToken = mockMvc.perform(post("/jwt/token")
                        .param("username", id)
                        .param("password", password))
                .andExpect(status().is(200))
                .andReturn().getResponse().getContentAsString();

        // when : Admin API 접근
        mockMvc.perform(get("/jwt/admin/resources")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + userToken))

                // then : 403(Forbidden) 오류
                .andExpect(status().is(403));
    }

    @Test
    @DisplayName("5. 정상적인 jwt로 특정 권한의 api를 사용할 수 있다.(Happy Case)")
    void testHappyCase() throws Exception {
        // given : Admin JWT 획득
        String id = "admin";
        String password = "admin1234";
        String adminToken = mockMvc.perform(post("/jwt/token")
                        .param("username", id)
                        .param("password", password))
                .andExpect(status().is(200))
                .andReturn().getResponse().getContentAsString();

        // when : 권한 없이 PUBLIC API 접근
        mockMvc.perform(get("/jwt/public/resources")
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().is(200))

                // then : Public 자원 획득
                .andExpect(content().encoding(StandardCharsets.UTF_8))
                .andExpect(content().string("PUBLIC 자원 획득"));

        // when : Admin 권한으로 USER API 접근
        mockMvc.perform(get("/jwt/user/resources")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .accept(MediaType.APPLICATION_JSON))

                // then : User 자원 획득
                .andExpect(status().is(200))
                .andExpect(content().encoding(StandardCharsets.UTF_8))
                .andExpect(content().string("USER 자원 획득"));

        // when : Admin 권한으로 Admin API 접근
        mockMvc.perform(get("/jwt/admin/resources")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .accept(MediaType.APPLICATION_JSON))

                // then : Admin 자원 획득
                .andExpect(status().is(200))
                .andExpect(content().encoding(StandardCharsets.UTF_8))
                .andExpect(content().string("ADMIN 자원 획득"));
        ;
    }
}
```

위 통합테스트를 작성하면서, JWT 발행 및 파싱을 위해 기존에 없던 `JWTUtil`이라는 클래스를 임시로 만들었습니다.

> `TDD`를 하는 만큼 테스트 과정에서 필요한 클래스는 그때그때 만들면서 대응하는 것이 좋습니다.

아직 세부사항은 전혀 구현되지 않았으나, 일단은 테스트를 실행할 수 있도록 컴파일 오류를 해결하기 위해 다음과 `utility` 패키지를 만들고, `JwtUtil` 클래스를 생성합니다.

```java
package com.springsecurity.jwt.utility;

public class JwtUtil {
    public void validate(String token) {
    }
}
```

통합테스트를 실행하면 다음과 같이 4개의 테스트가 실패합니다. 

![통합테스트 실패](integration_test_failure.png)


## 구현

### JwtUtil 단위테스트 작성

우선, 임시로 만든 `JwtUtil`클래스의 기능을 채우기 위해 단위테스트를 작성하겠습니다.

> 처음에는 어색할 수 있지만, **TDD를 위해서는 테스트를 먼저 작성하고 구현**하는 것에 익숙해져야 합니다.

- 이를 위해 요구사항을 분석하자면 다음과 같습니다.
  1. 유효하지 않은 토큰 검증 시 런타임 오류를 반환한다.
  2. 유효한 토큰 검증 시 오류가 발생하지 않는다.`(Happy Case)`
  3. 잘못된 권한의 토큰 발급 시 런타임 오류를 반환한다.
  4. 사용자 권한별 정상적인 토큰을 발급한다.`(Happy Case)`
  5. 유효하지 않은 토큰 파싱 시 런타임 오류를 반환한다.
  6. 정상적인 토큰을 파싱한다.`(Happy Case)`
  > **토큰 검증** 뿐 아니라, 토큰 API에서 사용할 **권한별 토큰을 만드는 로직**과 **파싱하는 로직**을 포함시켰습니다.

```java
package com.springsecurity.jwt.utility;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.*;

class JwtUtilTest {

    JwtUtil suit;

    // JWT 형식이 아닌 토큰
    String invalidToken1 = "INVALIDATE_TOKEN";

    // https://jwt.io 에서 만든 예제 토큰
    String invalidToken2 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";

    // sub : admin, role : admin 이지만 유효하지 않은 secret key 를 사용한 토큰
    String invalidToken3 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsInJvbGUiOiJhZG1pbiJ9.wpTc_a19-bJNZ7oeYghAmxks3tk2mjcP6xTqYe2u86c";

    // sub : admin, role : ADMIN, 유효한 secret key 를 사용한 토큰
    String validToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsInJvbGUiOiJBRE1JTiJ9.VYYrrkyu4kmM4zWtl_gFk9leBM8xu-XxxIYUtY9_2n0";

    @BeforeEach
    void init() {
        suit = new JwtUtil();
    }

    @Test
    @DisplayName("1. 유효하지 않은 토큰 검증 시 런타임 오류를 반환한다.")
    void testInvalidateToken() {
        assertThatThrownBy(() -> suit.validate(invalidToken1))
                .isInstanceOf(RuntimeException.class);
        assertThatThrownBy(() -> suit.validate(invalidToken2))
                .isInstanceOf(RuntimeException.class);
        assertThatThrownBy(() -> suit.validate(invalidToken3))
                .isInstanceOf(RuntimeException.class);
    }

    @Test
    @DisplayName("2. 유효한 토큰 검증 시 오류가 발생하지 않는다.(Happy Case)")
    void testValidateToken() {
        suit.validate(validToken);
    }

    @Test
    @DisplayName("3. 잘못된 권한의 토큰 발급 시 런타임 오류를 반환한다.")
    void testIllegalRoleIssue() {
        String userName = "test_user";
        String role = "ILLEGAL_ROLE";
        assertThatThrownBy(() -> suit.issue(userName, role))
                .isInstanceOf(RuntimeException.class);
    }

    @Test
    @DisplayName("4. 사용자 권한별 정상적인 토큰을 발급한다.(Happy Case)")
    void testLegalRoleIssue() {
        // given
        String userName = "user";
        String userRole = "USER";
        String adminName = "admin";
        String adminRole = "ADMIN";

        // when
        String userToken = suit.issue(userName, userRole);
        String adminToken = suit.issue(adminName, adminRole);

        // then
        suit.validate(userToken);
        suit.validate(adminToken);
    }

    @Test
    @DisplayName("5. 유효하지 않은 토큰 파싱 시 런타임 오류를 반환한다.")
    void testIllegalTokenParse() {
        assertThatThrownBy(() -> suit.parseName(invalidToken1))
                .isInstanceOf(RuntimeException.class);
        assertThatThrownBy(() -> suit.parseName(invalidToken2))
                .isInstanceOf(RuntimeException.class);
        assertThatThrownBy(() -> suit.parseName(invalidToken3))
                .isInstanceOf(RuntimeException.class);

        assertThatThrownBy(() -> suit.parseRole(invalidToken1))
                .isInstanceOf(RuntimeException.class);
        assertThatThrownBy(() -> suit.parseRole(invalidToken2))
                .isInstanceOf(RuntimeException.class);
        assertThatThrownBy(() -> suit.parseRole(invalidToken3))
                .isInstanceOf(RuntimeException.class);
    }

    @Test
    @DisplayName("6. 정상적인 토큰을 파싱한다.(Happy Case)")
    void testLegalTokenParse() {
        // given
        String userName = "user";
        String userRole = "USER";
        String userToken = suit.issue(userName, userRole);

        // when
        String name = suit.parseName(userToken);
        String role = suit.parseRole(userToken);

        // then
        assertThat(name).isEqualTo(userName);
        assertThat(role).isEqualTo(userRole);
    }
}
```

### JWTUtil 구현

우선 테스트를 실행하기 위해 다음과 같이 JwtUtil을 수정합니다.

```java
package com.springsecurity.jwt.utility;

public class JwtUtil {
    public void validate(String token) {
    }

    public String issue(String userName, String Role) {
        return null;
    }

    public String parseRole(String token) {
        return null;
    }

    public String parseName(String userToken) {
        return null;
    }
}
```

이후 단위테스트 결과는 다음과 같습니다.

![단위테스트 실패](unittest_failure.png)

> 우선 토큰 검증부터 차근차근 구현해 보겠습니다.

토큰 검증을 위해서 [맨 처음에 추가했던](#jwt-의존성-추가) `jjwt` 라이브러리를 활용하겠습니다.

> [`jjwt 깃허브의 Readme`](https://github.com/jwtk/jjwt?tab=readme-ov-file#verification-key)를 참고해서 다음과 같이 토큰을 검증하도록 했습니다.

```java
// JwtUtil.java

    /* 생략 */

    public void validate(String token) {
        Jwts.parser()
                .verifyWith(secretKey())
                .build()
                .parseSignedClaims(token);
    }

    private SecretKey secretKey() {
        // https://randomkeygen.com/ 에서 생성한 504-bit WPA Key
        return Keys.hmacShaKeyFor("+*jhLeu04kw7M~tQew<Ym<d%,\"{(PC$p64acJ}lH_;d:'nD/^s+y7O=j!FBia5b".getBytes(StandardCharsets.UTF_8));
    }
    
```
> 참고로 예제 프로젝트이므로 비밀키를 노출했지만, 실제 프로젝트라면 **별도의 환경변수로 분리해서 노출되지 않도록 주의**해야 합니다.

이후 다음과 같이 검증 로직 테스트가 정상 동작합니다.

![단위테스트 성공 1](unittest_success_1.png)

다음으로 토큰 발행 로직을 [다음 페이지](https://github.com/jwtk/jjwt?tab=readme-ov-file#creating-a-jwt)를 참고하여 구현하였습니다.

```java
// JwtUtil.java

    /* 생략 */

    public String issue(String userName, String Role) {
            return Jwts.builder()
                    .subject(userName)
                    .claim("role",Role)
                    .signWith(secretKey())
                    .compact();
    }
    
```
이후 다음과 같이 발행 테스트의 `Happy Case`가 정상 동작하지만, `ADMIN` 혹은 `USER` 권한을 제외한 다른 권한은 사용할 수 없다는 3번 테스트는 실패합니다.

![단위테스트 실패 2](unittest_failure_2.png)

단순히 String 값 비교로 구현할 수 있지만, 차후 확장성을 위해 `Role`을 담은 별도의 `enum`으로 분리하고 다음과 같이 메서드를 수정합니다.
```java
// Role.java
package com.springsecurity.jwt;

public enum Role {
    USER, ADMIN;
    
    public static boolean isValid(String role) {
        for (Role r : Role.values()) {
            if (r.name().equalsIgnoreCase(role)) return true;
        }
        return false;
    }
}

// JwtUtil.java

    /* 생략 */
    public String issue(String userName, String role) {
        if (!Role.isValid(role)) throw new EnumConstantNotPresentException(Role.class, role);
        return Jwts.builder()
                .subject(userName)
                .claim("role", role)
                .signWith(secretKey())
                .compact();
    }
    /* 생략*/
``` 

이제 발행 메서드에 관한 모든 테스트가 성공합니다.

![단위테스트 성공 2](unittest_success_2.png)

마지막으로 [다음 페이지를 참고](https://github.com/jwtk/jjwt?tab=readme-ov-file#reading-a-jwt)하여 토큰 파싱 로직을 작성합니다.

```java
// JwtUtil.java

    /* 생략 */
// JwtUtil.java

    /* 생략 */

    public String parseName(String token) {
        return getPayload(token).getSubject();
    }

    public String parseRole(String token) {
        return (String) getPayload(token).get("role");
    }

    private Claims getPayload(String token) {
        return Jwts.parser()
                .verifyWith(secretKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

```

이제 모든 단위 테스트가 성공합니다.

![단위테스트 성공 3](unittest_success_3.png)

또한, `JwtUtil`의 커버리지를 분석해보면, 다음과 같이 모든 메서드가 테스트되고 있음을 알 수 있습니다. 

![단위 테스트 커버리지](test_coverage.png)

> `JwtUtil`의 모든 메서드에 대한 단위테스트가 성공했기 때문에, 통합테스트에서는 해당 클래스에 대한 세부적인 테스트를 작성하지 않아도 됩니다.

### API 구현

이제 본격적으로 통합테스트를 성공시키기 위해, 우선 토큰과 자원을 반환하는 API를 다음과 같이 `JwtApiController`에 생성하겠습니다.

> 예제이므로, 사용자 정보를 검증하는 별도의 `Service`를 만들지 않고 `Controller`에서 요청 정보를 모두 검증하도록 하겠습니다.

```java
// JwtApiController.java
package com.springsecurity.jwt.api;

import com.springsecurity.jwt.Role;
import com.springsecurity.jwt.utility.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/jwt")
public class JwtApiController {

    private final JwtUtil jwtUtil;

    @GetMapping("/admin/resources")
    public String getAdminResources() {
        return "ADMIN 자원 획득";
    }

    @GetMapping("/user/resources")
    public String getUserResources() {
        return "USER 자원 획득";
    }

    @GetMapping("/public/resources")
    public String getPublicResources() {
        return "PUBLIC 자원 획득";
    }

    @PostMapping("/token")
    public ResponseEntity<String> getToken(@RequestParam String username, @RequestParam String password) {

        // USER 회원 로그인 시 USER 권한 토큰 발행
        if (username.equals("user") && password.equals("user1234"))
            return new ResponseEntity<>(jwtUtil.issue("user", Role.USER.name()), HttpStatus.OK);

        // Admin 회원 로그인 시 ADMIN 권한 토큰 발행
        if (username.equals("admin") && password.equals("admin1234"))
            return new ResponseEntity<>(jwtUtil.issue("admin", Role.ADMIN.name()), HttpStatus.OK);

        // 로그인 실패 시 401 오류
        return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }
}
```

하지만, 통합테스트를 실행해보면 여전히 3번 테스트를 제외하고는 모든 테스트가 실패하고 있습니다.

![통합테스트 실패](integration_test_failure_2.png)

> 테스트 실패 메시지를 확인해보면 `403` 오류가 발생하고 있는데, `SecurityFilterChain`에 해당 API와 관련된 설정을 해주지 않고 있어 `Spring Security`에서 해당 `EntryPoint`를 차단했기 때문입니다.

다음과 같이 `JWT` 관련된 설정을 `JwtSecurityConfig`에 작성 후 `Bean`으로 등록합니다.
- `SecurityMatcher URL` 설정 : [지난 시간](https://1eaf.site/posts/spring_security/4/#api%EB%B3%84-%EA%B6%8C%ED%95%9C-%EB%B6%80%EC%97%AC)에 작성했던 `SecurityConfig`와 `URL`기반으로 설정을 분리하기 위함입니다. 
- `CSRF` 토큰 해제 : 해당 옵션을 해제하지 않고 `JWT` 로그인 시 `CSRF` 토큰이 없으면 오류가 발생할 수 있습니다. `JWT`는 `stateless`한 인증 방식이기 때문에 **`CSRF`토큰을 구현하기가 제한**됩니다.
- `Session Management` 해제 : `JWT`는 `Session` 방식을 사용하지 않기 때문에 **이를 해제해주어야 세션 정보를 서버에 별도로 저장하지 않습니다.**
- 권한별 인가 로직 작성 : `API`별 필요한 권한을 명시합니다.
- `CustomAuthenticationEntryPoint` 등록 : [지난 시간](https://1eaf.site/posts/spring_security/4/#authenticationentrypoint-%EC%84%A4%EC%A0%95)에 생성한 해당 클래스를 `ExceptionHandler`로 등록해야 인증 실패 시 `302`오류가 발생하지 않습니다.

```java
// JwtSecurityConfig.java

package com.springsecurity.jwt.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class JwtSecurityConfig {

    @Bean  // CustomAuthenticationEntryPoint Bean 파라미터 주입(Spring DI)
    public SecurityFilterChain jwtFilterChain(HttpSecurity http, CustomAuthenticationEntryPoint customAuthenticationEntryPoint) throws Exception {
        return http
                .securityMatcher("/jwt/**")
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers("/jwt/public/**").permitAll()
                        .requestMatchers("/jwt/user/**").hasRole("USER")
                        .requestMatchers("/jwt/admin/**").hasRole("ADMIN")
                        .requestMatchers("/jwt/token").permitAll()
                        .anyRequest().authenticated())
                .exceptionHandling(handler -> handler
                        .authenticationEntryPoint(customAuthenticationEntryPoint))
                .build();
    }
}
```

또한, 지난 시간에 `SecurityConfig` 내부에 등록했던 `mvcHandlerMappingIntrospector`는 통합테스트에만 사용하기 때문에 `IntegrationTestConfig` 내부로 이동하겠습니다.

이와 함께 테스트에 필요한 의존성들(`JwtApiController`, `JwtUtil`, `CustomAuthenticationEntryPoint`)도 `@Import`어노테이션을 활용해 `IntegrationTestConfig` 내부에서 불러오겠습니다.

```java 
/* 테스트 경로(src > test > java > com > springsecurity > jwt > config)에 설정 클래스 생성 */
// IntegrationTestConfig.java

package com.springsecurity.jwt.config;

import com.springsecurity.jwt.api.JwtApiController;
import com.springsecurity.jwt.utility.JwtUtil;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.web.servlet.handler.HandlerMappingIntrospector;

@Configuration

// IntegrationTest에 필요한 의존성 불러오기
@Import({JwtApiController.class, 
        JwtUtil.class, 
        CustomAuthenticationEntryPoint.class})
public class IntegrationTestConfig {
    @Bean(name = "mvcHandlerMappingIntrospector")
    public HandlerMappingIntrospector mvcHandlerMappingIntrospector() {
        return new HandlerMappingIntrospector();
    }
}

// JwtIntegrationTest.java

/* 생략 */

@ExtendWith(SpringExtension.class)
@ContextConfiguration(classes = JwtSecurityConfig.class)
@WebAppConfiguration

// IntegrationTestConfig 불러오기
@Import({IntegrationTestConfig.class})
public class JWTIntegrationTest {

    MockMvc mockMvc;
    JwtUtil jwtUtil;

    @Autowired
    WebApplicationContext context;

    @BeforeEach
    void init() {

        // JwtUtil 객체 초기화
        jwtUtil = new JwtUtil();
        mockMvc = MockMvcBuilders.webAppContextSetup(context)
                .apply(springSecurity()).build();
    }

    /* 생략 */
}
```

위와 같이 수정 후 테스트를 돌려보면, 다음과 같이 1 ~ 3번 테스트가 성공합니다.

![통합테스트 성공](integration_test_success.png)

### JWTAuthenticationFilter 단위테스트 작성

4 ~ 5번 테스트가 실패하는 원인은 현재 `Authorization Header`의 `JWT`를 통해 권한 정보를 불러오는 기능을 만들지 않았기 때문입니다.

이를 구현하기 위해 `JWT`를 통해 권한을 가져오는 `AuthenticationFilter`를 `SecurityFilterChain`에 등록해야 합니다.[^7]

- 우선 다음과 같이 요구사항에 맞는 테스트를 작성합니다.

  ```java
  package com.springsecurity.jwt.config;
  
  import com.springsecurity.jwt.utility.JwtUtil;
  import jakarta.servlet.ServletException;
  import org.junit.jupiter.api.DisplayName;
  import org.junit.jupiter.api.Test;
  import org.springframework.http.HttpHeaders;
  import org.springframework.mock.web.MockFilterChain;
  import org.springframework.mock.web.MockHttpServletRequest;
  import org.springframework.mock.web.MockHttpServletResponse;
  import org.springframework.security.core.Authentication;
  import org.springframework.security.core.context.SecurityContextHolder;
  
  import java.io.IOException;
  
  import static org.assertj.core.api.Assertions.assertThat;
  
  class JwtAuthenticationFilterTest {
  
      @Test
      @DisplayName("Bearer 제거 테스트")
      void testDeleteBearer() {
          String header = "Bearer test";
          String token = header.split("Bearer ")[1];
          assertThat(token).isEqualTo("test");
      }
  
      @Test
      @DisplayName("Bearer 파싱 테스트")
      void testDeleteBearer2() throws ServletException, IOException {
          // given
          JwtUtil jwtUtil = new JwtUtil();
          JwtAuthenticationFilter suit = new JwtAuthenticationFilter(jwtUtil);
          MockHttpServletRequest request = new MockHttpServletRequest();
          request.addHeader(HttpHeaders.AUTHORIZATION, "Bearer " + jwtUtil.issue("user", "USER"));
  
          // when
          suit.doFilterInternal(request, new MockHttpServletResponse(), new MockFilterChain());
          Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
  
          // then
          assertThat(authentication.getAuthorities()).anySatisfy(auth -> assertThat(auth.getAuthority()).isEqualTo("ROLE_USER"));
      }
  }
  ```

### JWTAuthenticationFilter 구현
다음과 같이 `JwtAuthenticationFilter`를 구현합니다.
> 첫번째 단위테스트와 같은 방식으로 `split()`메서드를 통해 토큰의 `prefix`인 `Bearer `를 제거할 수 있습니다. 

  ```java
  package com.springsecurity.jwt.config;
  
  import com.springsecurity.jwt.Role;
  import com.springsecurity.jwt.utility.JwtUtil;
  import jakarta.servlet.FilterChain;
  import jakarta.servlet.ServletException;
  import jakarta.servlet.http.HttpServletRequest;
  import jakarta.servlet.http.HttpServletResponse;
  import lombok.RequiredArgsConstructor;
  import org.springframework.http.HttpHeaders;
  import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
  import org.springframework.security.core.authority.SimpleGrantedAuthority;
  import org.springframework.security.core.context.SecurityContextHolder;
  import org.springframework.stereotype.Component;
  import org.springframework.web.filter.OncePerRequestFilter;
  
  import java.io.IOException;
  import java.util.List;
  
  @Component
  @RequiredArgsConstructor
  public class JwtAuthenticationFilter extends OncePerRequestFilter {
  
      private final JwtUtil jwtUtil;
  
      @Override
      protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
          String header = request.getHeader(HttpHeaders.AUTHORIZATION);
          if (header != null && header.startsWith("Bearer ")) {
              String token = header.split("Bearer ")[1];
              String name = jwtUtil.parseName(token);
              String role = jwtUtil.parseRole(token);
              SecurityContextHolder.getContext().setAuthentication(
                      UsernamePasswordAuthenticationToken.authenticated(name, token,
                              List.of(new SimpleGrantedAuthority(Role.getAuthority(role)))));
          }
          filterChain.doFilter(request, response);
      }
  }
  
  // Role.class
  
    /* 생략 */
  
    public static String getAuthority(String role) {
        switch (Role.valueOf(role)) {
            case USER -> {
                return "ROLE_USER";
            }
            case ADMIN -> {
                return "ROLE_ADMIN";
            }
        }
        throw new EnumConstantNotPresentException(Role.class, role);
    }
    
  ```

> 해당 필터에서는 `request header`에 있는 토큰을 파싱하여 토큰에 명시된 권한이 있는 인증 객체를 생성하고, 이를 `SecurityContext`에 보관하는 역할을 수행합니다.

이제 모든 단위테스트가 통과합니다.

![단위테스트 성공 4](unittest_success_4.png)

이후 다음과 같이 `JwtSecurityFilter`와 테스트 설정에 해당 클래스를 등록합니다.

```java
// JwtSecurityFilter.class

/* 생략 */

    @Bean // CustomAuthenticationEntryPoint, JwtAuthenticationFilter Bean DI
    public SecurityFilterChain jwtFilterChain(HttpSecurity http, CustomAuthenticationEntryPoint customAuthenticationEntryPoint, JwtAuthenticationFilter jwtAuthenticationFilter) throws Exception {
        return http
                .securityMatcher("/jwt/**")
                .csrf(csrf -> csrf.ignoringRequestMatchers("/jwt/token"))
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                
                // UsernamePasswordAuthenticationFilter 이후에 JWT 인증 필터 실행
                .addFilterAfter(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
                
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers("/jwt/public/**").permitAll()
                        .requestMatchers("/jwt/user/**").hasRole("USER")
                        .requestMatchers("/jwt/admin/**").hasRole("ADMIN")
                        .requestMatchers("/jwt/token").permitAll()
                        .anyRequest().authenticated())
                .exceptionHandling(handler -> handler
                        .authenticationEntryPoint(customAuthenticationEntryPoint))
                .build();
    }
    
/* 생략 */

// JwtIntegrationTest.class

/* 생략 */
    
@Configuration

// JwtAuthenticationFilter 추가
@Import({JwtApiController.class, JwtUtil.class, JwtAuthenticationFilter.class, CustomAuthenticationEntryPoint.class})
public class IntegrationTestConfig {
    @Bean(name = "mvcHandlerMappingIntrospector")
    public HandlerMappingIntrospector mvcHandlerMappingIntrospector() {
        return new HandlerMappingIntrospector();
    }
}

/* 생략 */

```

이제 다음과 같이 모든 테스트케이스가 성공하는 것을 확인할 수 있습니다.

![통합테스트 성공 2](integration_test_success_2.png)

기존 테스트들도 모두 성공하는지 돌려보겠습니다.

![전체 테스트 실패](all_test_failure.png)

> 리팩토링하는 과정에서 `mvcHandlerMappingIntrospector`를 다른 경로로 옮기면서 기존 테스트가 실패했습니다. 이를 성공시키기 위해 다음과 같이 설정을 변경합니다.

```java
// AuthenticationTest.class

/* 생략 */

@ExtendWith(SpringExtension.class)
@ContextConfiguration(classes = SecurityConfig.class)
@WebAppConfiguration

// 통합테스트 설정(IntegrationConfig) 추가
@Import({ApiController.class, IntegrationTestConfig.class})
class AuthenticationTest {
    
    /* 생략 */
    
}
```

이제 모든 테스트가 성공합니다.

![전체 테스트 성공](all_test_success.png)

또한, 다음과 같이 테스트 코드가 모든 코드의 커버리지를 만족하고 있습니다.

![테스트 커버리지 100](test_coverage_100.png)
> 모든 로직을 검증하고 있으니, 리팩토링 시마다 버그가 발생할 가능성도 현저히 낮아집니다. 이게 `TDD`의 가장 큰 장점입니다! 

## 결론

이번 시간에는 TDD를 활용해 JWT 인증 필터를 구현해보았습니다.
> 분량이 너무 길어져서 한번 끊고 가야하나 생각했지만, TDD의 흐름이 끊기는 것 같아서 일단 한 포스트에 전부 작성했습니다. 다음부터는 개념적인 내용과 구현을 분리해서 분량을 잘 조절해보겠습니다.

- 해당 프로젝트의 전체 코드는 [다음 깃허브 링크](https://github.com/leaf-nam/spring_security_example)에서 확인하실 수 있습니다.

다음 시간에는 `Spring oauth2-resource-server`를 활용해서 JWT를 구현해보겠습니다.
> 필터를 직접 구현하는 것보다 훨--씬 간편합니다!

### 다음 포스팅

[[Java]Spring Security(With TDD) JWT oauth2-resource-server 활용헤서 간편하게 구현하기](https://1eaf.site/posts/spring_security/6)

## References

| URL                                                                                                    | 게시일자 | 방문일자        | 작성자    |
|:-------------------------------------------------------------------------------------------------------|:-----|:------------|:-------|
| [Spring 공식문서](https://docs.spring.io/spring-security/reference/servlet/authentication/passwords)       | -    | 2024.12.06. | Spring |
| [RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519)                                              |2015.05. | 2024.12.06. | IETF|

[^1]: [`stateless`](https://ko.wikipedia.org/wiki/%EB%AC%B4%EC%83%81%ED%83%9C_%ED%94%84%EB%A1%9C%ED%86%A0%EC%BD%9C)는 무상태 프로토콜을 뜻하며, 웹 통신의 기초인 HTTP 프로토콜도 이러한 특성을 가집니다. 서버에서 세션이나 기타 상태를 보관하지 않기 때문에 수평적인 확장(Scale-out)이 용이합니다.

[^2]: [`cookie 저장소`](https://developer.mozilla.org/ko/docs/Web/HTTP/Cookies)는 서버가 클라이언트에게 전송하는 작은 데이터 조각입니다. 웹 브라우저와 같은 대부분의 클라이언트는 이를 별도의 저장소에 저장하고 있다가, 서버의 응답에 이를 포함하여 전송합니다.

[^3]: [`Scale Out`](https://en.wikipedia.org/wiki/Scalability)은 수평적 확장을 뜻합니다. 많은 사용자(트래픽)들을 감당하기 위해 서버는 동일한 역할을 수행하는 여러 개의 작은 서버를 두고, 부하를 골고루 분산하여 이에 대응합니다.

[^4]: [`MSA`](https://ko.wikipedia.org/wiki/%EB%A7%88%EC%9D%B4%ED%81%AC%EB%A1%9C%EC%84%9C%EB%B9%84%EC%8A%A4)는 느슨하게 결합된 작은 서비스들을 구조화하여 큰 서비스를 수행하는 개발 기법입니다. 큰 애플리케이션을 작은 단위로 모듈화하여 작은 팀들이 독립적으로 서비스를 개발, 확장, 리팩터링 가능하게 합니다.

[^5]: [`refresh token`](https://auth0.com/docs/secure/tokens/refresh-tokens)은 `access token`의 탈취를 대비하여 함께 발행하는 토큰입니다. 

      `access token`이 탈취되면 해당 사용자의 권한이 모두 탈취되기 때문에, 이를 방지하기 위해 보통 토큰 만료시간을 짧게 설정합니다. 이러한 경우, 사용자는 매번 다시 인증과정을 거쳐 토큰을 발급받아야 하는데, 이러한 번거로움을 줄이기 위해 유효한 `Refresh Token`을 보유한 사용자는 즉시 `Access Token`을 재발급해줍니다.

[^6]: `Spring oauth2-resource-server`는 훌륭한 Spring 개발자분들이 Spring Security과 가장 호환성이 좋고 사용하기 간편한 방식으로 설계해 두었기 때문입니다.

[^7]: 해당 인증 로직의 구체적인 아키텍쳐는 [다음 포스트](https://1eaf.site/posts/spring_security/3/#authentication)를 참고하시기 바랍니다.