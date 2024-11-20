---
title: "[Vercel] 가비아 도메인으로 Vercel 홈페이지 배포 시 SSL 인증서 만료 해결"
date: 2024-11-20T23:24:10+09:00
weight: #1
tags: ["tips", "certificate", "ssl", "gabia"]
categories: ["tinytips", "vercel"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "가비아 도메인으로 Vercel로 배포 시 발생할 수 있는 SSL 인증서 만료 문제를 해결합니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 상황

최근, Vercel을 활용해서 배포한 홈페이지에서 SSL 인증서 만료 관련 문구가 발생했습니다.

{{<figure src="expired.jpeg" caption="인증서 만료일자가 오늘 이전이라 크롬으로 홈페이지 접속이 거부되었습니다.">}}

> 원래 [Vercel에서 자동으로 인증서를 갱신](https://vercel.com/guides/renewal-of-ssl-certificates-with-a-vercel-domain)하게 되어있는데, 갱신되지 않아서 만료가 되었습니다.

## 원인

[위 페이지](https://vercel.com/guides/renewal-of-ssl-certificates-with-a-vercel-domain) 하단에서 다음과 같은 문구를 발견할 수 있었습니다.

{{<figure src="renewal.png" caption="도메인 설정이 잘못되면, 갱신이 되지 않을 수 있습니다.">}}

> `도메인이 잘못 구성되어 있으면 인증서가 갱신되지 않을 가능성이 높습니다. 도메인의 구성 상태를 확인하려면 프로젝트 설정(Project settings)으로 이동한 후 도메인 섹션(Domains section)으로 이동하면 됩니다.`

### Try1 : 해당 도메인 삭제 후 재등록

[다음 페이지](https://github.com/vercel/next.js/discussions/49142)를 참고해서 도메인을 삭제 후 다시 등록하면 자동으로 설정이 가능하다고 하여 도메인 삭제 후 재등록을 시도했습니다.

{{<figure src="domain_remove.png" caption="도메인 삭제 후 재등록 로그">}}

- Vercel의 Project Settings - dommains 에서 도메인을 삭제 후 재등록해보았습니다.

{{<figure src="domains.png" caption="지금은 정상 등록되어 있습니다.">}}

> 지금은 정상이지만, 당시는 계속 Refresh가 반복되면서 Domain이 연결되지 않았습니다. 아마 인증서가 아직 남아있어서 그런 것 같았습니다.

### Try2 : 해당 프로젝트 삭제 후 재연결

아예 전체 프로젝트를 삭제하면 해당 SSL 인증서도 함께 삭제되지 않을까 하는 생각에 레포지토리를 완전히 삭제했습니다.

{{<figure src="project_remove.png" caption="프로젝트 삭제 후 재등록 로그">}}

> 그러나, 프로젝트를 삭제 후 다시 연결하고 원래 도메인을 설정하면 이전과 같이 Refresh가 반복되며 Domain이 연결되지 않았습니다. 아마 Vercel에서 해당 프로젝트 삭제 후에도 일정기간 SSL 인증서와 레포지토리 연결 정보를 보관하고 있어 재등록 시 해당 서버를 그대로 사용하는 것 같았습니다.

### Try3 : 가비아 TXT 도메인 변경

[다음 페이지](https://github.com/vercel/community/discussions/3654#discussioncomment-6755374)를 참고해서 가비아 DNS 관리 탭에서 레코드를 수정해보았습니다.

{{<figure src="gabia_dns_setting.png" caption="가비아 DNS Record 설정 변경">}}

> 동일하게 Refresh가 반복되면서 Domain이 연결되지 않았습니다.

## 해결!

[Vercel 공식문서](https://vercel.com/docs/projects/domains/working-with-nameservers)를 보면서 해결방법을 찾던 중 Vercel 네임서버를 사용하는 것을 권장한다는 것을 발견했습니다.

{{<figure src="use_vercel_nameserver.png" caption="vercel 네임서버 사용을 권장합니다.">}}

> `자동 DNS 레코드: 네임서버가 Vercel로 지정된 도메인의 경우, 최상위 도메인(apex domain)이나 1단계 서브도메인(first-level subdomains)에 대해 명시적으로 DNS 레코드를 생성할 필요가 없습니다. 이러한 레코드들은 자동으로 생성됩니다. 이는 도메인이나 서브도메인을 프로젝트에 추가할 때 DNS 레코드에 대해 신경 쓸 필요가 없음을 의미합니다. 따라서 실수를 줄일 수 있을 뿐만 아니라, 프로젝트에서 사용하려는 여러 서브도메인이 있는 경우 각 서브도메인마다 CNAME 레코드를 수동으로 입력할 필요도 없어집니다.`

위 페이지를 통해 네임서버를 Vercel로 변경하면 자동 설정이 되면서 문제가 해결되지 않을까 하는 생각에 다음 페이지에서 가비아 네임서버를 Vercel 네임서버로 변경하였습니다.

{{<figure src="gabia_nameserver_setting.png" caption="가비아 DNS Server 설정 변경">}}

이후 아래 페이지와 같이 자동으로 vercel 설정이 변경되면서 SSL인증서를 재발급받을 수 있었습니다.

{{<figure src="vercel_dns_record.png" caption="vercel DNS Record 자동 변경">}}

## 결론

1. 가비아와 Vercel을 연동할때는 **네임서버를 Vercel로 변경**하는 것이 좋다!
2. **공식문서를 잘보자!**

## References

| URL                                                                                                       | 게시일자    | 방문일자    | 작성자  |
| :-------------------------------------------------------------------------------------------------------- | :---------- | :---------- | :------ |
| [Vercel renewal certificates](https://vercel.com/guides/renewal-of-ssl-certificates-with-a-vercel-domain) | -           | 2024.11.19. | Vercel  |
| [Vercel working with nameservers](https://vercel.com/docs/projects/domains/working-with-nameservers)      | -           | 2024.11.19. | Vercel  |
| [Vercel Discussion 1](https://github.com/vercel/next.js/discussions/49142)                                | 2023.03.03. | 2024.11.19. | 3a1b2c3 |
| [Vercel Discussion 2](https://github.com/vercel/community/discussions/3654#discussioncomment-6755374)     | 2023.08.18. | 2024.11.19. | amyegan |
