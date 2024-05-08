---
title: 'MockMvc Object mapper nested class utf-8 인코딩 오류 해결하기'
date: 2024-05-07T17:03:40+09:00
weight: 2005
tags: [ "tips", "encoding", "object mapper" ]
categories: [ "tinytips" ]
author: "Leaf" # ["Me", "You"] multiple authors
description: "Object Mapper 사용 시 만날 수 있는 오류를 해결합니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 상황

- Controller 테스트 작성 시 mockMvc의 결과가 원하는 값과 일치하는지 확인하는 상황입니다.
    ```java
    @Test
    @DisplayName("[인수] 읽지 않은 알림 요청 시 전체응답(200)")
    void testAllNotifications200() throws Exception {
        // given
        Cookie[] followingUserLoginCookie = mockMvc.perform(get("/api/users/login").header(HttpHeaders.AUTHORIZATION, "Bearer valid_token_2")).andReturn().getResponse().getCookies();
        Cookie[] myLoginCookie = mockMvc.perform(get("/api/users/login").header(HttpHeaders.AUTHORIZATION, "Bearer valid_token")).andReturn().getResponse().getCookies();

        // when
        // following -> user 팔로우
        mockMvc.perform(post("/api/users/" + me.getId() + "/follows").cookie(followingUserLoginCookie));

        // notifications 전체 조회
        String responseBody = mockMvc.perform(get("/api/users/notifications").cookie(myLoginCookie))
                .andExpect(status().is(200)).andReturn().getResponse().getContentAsString();
        ListDto<List<NotificationDto>> notificationDtos = objectMapper.readValue(responseBody, new TypeReference<ListDto<List<NotificationDto>>>() {});

        // then
        assertThat(notificationDtos.getList()).hasSize(1);
        assertThat(notificationDtos.getList().get(0).getDescription()).isEqualTo("leaf2님이 당신을 팔로우합니다.");
    }
    ```
- 테스트 결과
  {{<figure src="test-result.png" caption="junit 테스트 결과(실패)">}}

## 원인

- 테스트 결과를 보면, 한글 인코딩이 깨져 있습니다.
- 기존에 MockMvc를 사용하면서 한글을 잘 검증하지 않았는데 이번 테스트에서는 한글을 검증하면서 이런 오류가 발생한 것 같습니다. 
- 기본적으로 [MockMVC는 *ISO-8859-1(Latin-1)*로 인코딩](https://github.com/spring-projects/spring-framework/issues/23219)된다고 합니다.
- objectMapper는 [UTF-8로만 디코딩](https://stackoverflow.com/questions/10004241/jackson-objectmapper-with-utf-8-encoding)하기 때문에 ISO-8859-1로 인코딩 된 값을 읽을 수 없습니다.

## 해결

- 다음 세가지 방법 중 하나를 사용하면 해결이 가능합니다.

### 1) UTF-8로 인코딩

- 결과값(content)을 UTF-8로 인코딩합니다.
    ```java
    String responseBody = mockMvc.perform(get("/api/users/notifications").cookie(myLoginCookie))
            .andExpect(status().is(200)).andReturn().getResponse().getContentAsString(StandardCharsets.UTF_8); // StandardCharset.UTF_8 추가
    ```

### 2) 결과값 byte 배열로 변환(인코딩 안하기)

- 다음과 같이 readValue 대상을 String 이 아닌 byte[]로 변경합니다.
    ```java
    // notifications 전체 조회
    byte[] responseBody = mockMvc.perform(get("/api/users/notifications").cookie(myLoginCookie))  // 기존 Return type : String
            .andExpect(status().is(200)).andReturn().getResponse().getContentAsByteArray(); // 기존 method : getContentAsString()
    ListDto<List<NotificationDto>> notificationDtos = objectMapper.readValue(responseBody, new TypeReference<ListDto<List<NotificationDto>>>() {});
    ```

### 3) Server Default Encoding 추가

- SpringBoot 서버의 기본 인코딩 설정을 변경합니다.
    ```yaml
    # application.yml
    server:
      servlet:
        encoding:
          charset: UTF-8
          force: true
    ```

- 테스트 결과
  {{<figure src="test-result-2.png" caption="junit 테스트 결과(성공)">}}

## References

| URL                                                                                   | 게시일자        | 방문일자        | 작성자      |
|:--------------------------------------------------------------------------------------|:------------|:------------|:---------|
| https://github.com/spring-projects/spring-framework/issues/23219                      | 2019.07.01. | 2024.05.07. | momega   |
| https://stackoverflow.com/questions/10004241/jackson-objectmapper-with-utf-8-encoding | 2012.04.04. | 2024.05.07. | Patricio |