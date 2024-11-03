---
title: "[Java Alogorithm]백준 12904 A와 B"
date: 2024-06-02T05:51:58+09:00
weight: #1
tags: ["codingtest", "backjoon"] # choose test platform
categories: ["algorithm"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "백준 12904 A와 B 문제에 대한 해설입니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 출처

- https://www.acmicpc.net/problem/12904

## 접근

- 처음에는 DP문제인줄 알고 접근했으나, 시간 초과로 실패했습니다.[^1]
- S로부터 T로 갈때는 여러 경로가 존재해서 DP와 같은 최적화가 필요해보입니다.
  {{<figure src="solve1.jpeg" caption="S에서 시작할 경우 2^(T의 길이 - S의 길이) 만큼의 탐색이 필요합니다.">}}
- 그러나 반대로 T에서 S로 갈때는 경로가 1개만 존재하므로, (T의 길이 - S의 길이)만큼만 탐색하면 S를 구할 수 있습니다.
  {{<figure src="solve2.jpeg" caption="T에서 S로 갈때는 T의 맨뒤 값으로 이전 노드를 예측하는 것이 가능합니다.">}}
- 이를 활용하면 다음과 같은 접근을 통해 O(N)으로 해결이 가능합니다.

1. T의 맨뒤값을 확인하여 A일 경우, 맨끝을 제거합니다.
2. B일 경우, 맨끝을 제거하고 문자열을 뒤집습니다.
3. S의 길이가 될때까지 반복 후, 두 문자열이 같은지 비교합니다.

## 풀이

```java
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

public class bj_12904_A와_B_2트 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        String S = br.readLine();
        String T = br.readLine();

        if (solve(S, T)) System.out.print(1);
        else System.out.print(0);
    }

    /*
     * [조건]
     * 시간제한 : 2초 / 메모리제한 : 512MB
     * S.length() <= 999, T.length() <= 1000, S.length() < T.length()
     * [풀이]
     * T의 맨뒤를 보면 이전값을 유추할 수 있다.
     * T를 맨뒤에서부터 이전으로 돌려간다.
     */
    static boolean solve(String s, String t) {
        int l = s.length();
        String nt = t;
        while (nt.length() > l) {  // nt의 길이가 s가 될때까지 반복
            char[] tc = nt.toCharArray();
            char end = tc[nt.length() - 1];  // 맨뒤값 가져오기
            nt = nt.substring(0, nt.length() - 1);  // 맨뒤값 제거하기
            if (end == 'B') nt = new StringBuilder(nt).reverse().toString();  // B일 경우 뒤집기
        }
        if (nt.equals(s)) return true;  // nt와 s가 같으면 true
        else return false;  // nt와 s가 다르면 false
    }
}
```

## 결과

![result](solve3.png)

## 리뷰

- 한쪽 방향으로 생각했을때는 탐색 과정에서 자식이 2개씩 있는 이진 트리 형태라고 생각했는데, 반대로 생각하니 부모는 1개만 존재했습니다.
- 처음에 DP로 풀려고 하다가 시간을 1시간정도 써서 아쉬웠습니다.
- DP로 풀수있을지 약간 망설여졌는데, 지금 생각해보면 1000개나 되는 자식을 이진트리로 검색하는건 아무리 최적화해도 힘들 듯합니다.
- 앞으로는 코드 작성 전 더 많은 경우의 수를 고민하고, 충분히 해결 가능하다 싶을때 풀이에 들어가는 습관을 길러야 하겠습니다.

## References

| URL | 게시일자 | 방문일자 | 작성자 |
| :-- | :------- | :------- | :----- |

[^1]: 잘못된 풀이는 다음과 같습니다.

    ```java
    import java.io.BufferedReader;
    import java.io.IOException;
    import java.io.InputStreamReader;
    import java.util.ArrayList;
    import java.util.List;

    public class bj_12904_A와_B {

        public static void main(String[] args) throws IOException {
            BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
            String S = br.readLine();
            String T = br.readLine();

            if (solve(S, T)) System.out.print(1);
            else System.out.print(0);
        }

        /*
        * [조건]
        * 시간제한 : 2초 / 메모리제한 : 512MB
        * S.length() <= 999, T.length() <= 1000, S.length() < T.length()
        * [풀이]
        * DP를 통해 해당 길이에서 나올 수 있는 모든 경우의 수를 저장한다.
        * 해당 길이의 경우의 수는 이전 길이의 2배이므로 처음 주어진 S의 2배씩 저장공간이 필요하다.
        * 그대로 저장하려면 2^(T - S)개가 필요하므로 최대 2^999의 저장공간이 필요하므로 최적화해야 한다.
        * 최적화를 위해 T가 될 수 없는 경우의 수를 가지치기한다. / 될수없는 경우 : T의 일부가 아니면서 뒤집은 T의 일부가 아닐때
        */
        static boolean solve(String s, String t) {
            List<String> dp = new ArrayList<>(); // 이전값들 중 가능한 값들만 저장하는 dp 리스트
            dp.add(s);
            int l = s.length();

            while(l < t.length()) {
                getNs1(dp, t);  // 뒤에 A 추가하기
                getNs2(dp, t);  // 뒤집은 후 B 추가하기
                l++;
            }

            for (String ns : dp) if (ns.equals(t)) return true;
            return false;
        }

        static void getNs1(List<String> dp, String t) {
            List<String> addList = new ArrayList<>();
            for (String ns : dp) {
                StringBuilder sb = new StringBuilder(ns);
                ns = sb.append("A").toString();
                if (isPossible(dp, ns, t)) addList.add(ns);
            }
            dp.addAll(addList);
        }

        static void getNs2(List<String> dp, String t) {
            List<String> addList = new ArrayList<>();
            for (String ns : dp) {
                StringBuilder sb = new StringBuilder(ns);
                sb.reverse();
                ns = sb.append("B").toString();
                if (isPossible(dp, ns, t)) addList.add(ns);
            }
            dp.addAll(addList);
        }

        static boolean isPossible(List<String> dp, String ns, String t) {
            // dp에 이미 포함되어있는지 확인
            for (String d : dp) if (d.equals(ns)) return false;

            // Ns가 t의 부분문자열인지 확인
            int l = ns.length();
            String rt = new StringBuilder(t).reverse().toString();

            for (int i = 0; i <= t.length() - l; i++) {
                String nt = t.substring(i, i + l);
                String nrt = rt.substring(i, i + l);
                if (nt.equals(ns)) return true;
                if (nrt.equals(ns)) return true;
            }
            return false;
        }

    }
    ```
