---
title: "[Java]백준 1976 여행 가자"
date: 2024-06-20T08:29:30+09:00
weight: #1
tags: ["codingtest", "backjoon", "programmers"] # choose test platform
categories: ["algorithm"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "백준 1976 여행 가자 문제에 대한 해설입니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 출처

- https://www.acmicpc.net/problem/1976

## 접근

- 일반적인 DFS로 구현하면 각 여행경로를 확인하는데 O(N^3)[^1]가 소요됩니다.

> 도시가 1000개이므로 200 x 200 x 200 x 1000 = 8,000,000,000(80억)으로 시간초과가 발생합니다.

- 해당 문제에서는 다른 도시를 몇번이든 방문할 수 있기 때문에, 일일히 경로를 방문하는 것은 시간초과를 유발합니다.
- 이를 최적화하기 위해 모든 여행계획이 같은 네트워크(루트를 공유)에 포함되는지 확인하기만 하면 됩니다.
- 이는 유니온 파인드(Union-find)로 구현할 수 있습니다.

## 풀이

```java
package solving;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.StringTokenizer;

/*
 * [조건]
 * 시간 제한 : 2초, 메모리 제한 : 128MB
 * N <= 200, M <= 1000
 * [구현]
 * 유니온 파인드를 통해 연결그래프를 구하고, 주어지는 여행계획이 같은 루트에 속하는지 확인한다.
 */
public class bj_1976_여행_가자 {
    static int N, M;
    static int[] root;

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st;
        N = Integer.parseInt(br.readLine());
        M = Integer.parseInt(br.readLine());

        root = new int[N + 1]; // 유니온 초기화
        for (int i = 1; i <= N; i++) root[i] = i;

        for (int i = 1; i <= N; i++) {
            st = new StringTokenizer(br.readLine());
            for (int j = 1; j <= N; j++) {
                // 두 도시를 같은 집합(루트)에 소속
                if (st.nextToken().equals("1")) union(i, j);
            }
        }

        int[] plan = new int[M + 1];
        st = new StringTokenizer(br.readLine());
        for (int i = 1; i <= M; i++) plan[i] = Integer.parseInt(st.nextToken());

        System.out.println(solve(plan));
    }

    private static void union(int i, int j) {
        int ri = find(i);
        int rj = find(j);
        if (ri != rj) root[rj] = ri;
    }

    private static int find(int i) {
        if (i != root[i]) root[i] = find(root[i]);
        return root[i];
    }

    private static String solve(int[] plan) {
        int r = find(plan[1]);
        for (int i = 2; i <= M; i++) {
            if (find(plan[i]) != r) return "NO";
        }
        return "YES";
    }
}
```

## 결과

![result](result.png)

## 리뷰

### 시행착오

- 마지막에 각 도시의 root를 비교할때 find로 안찾고 root를 그대로 사용하는 시행착오가 있었습니다.

```java
    /* ...생략 */

    private static String solve(int[] plan) {
        int r = root[plan[1]];
        for (int i = 2; i <= M; i++) {
            if (root[plan[i]] != r) return "NO";
        }
        return "YES";
    }
```

> 경로압축[^2]을 통해 모든 도시가 같은 루트를 바라보게 될 것이라고 생각했는데, 다시 생각해보니 경로압축이 되지 않은 도시가 충분히 존재할 수 있어 보입니다.

- 주어진 조건에서 DFS로는 구현이 안될 것 같다고 예상했는데, 이렇게 실제 구현 전에 시간복잡도 및 메모리를 잘 고려하여 많은 시간을 절약할 수 있었습니다.
- 유니온 파인드 알고리즘은 이제 어느정도 이해하는 것 같은데, 매번 다시 구현하는데 시간이 걸리는 것 같습니다. 다음에 유사한 문제를 만나면 좀더 빨리 풀 수 있기를 기대합니다.

## References

| URL | 게시일자 | 방문일자 | 작성자 |
| :-- | :------- | :------- | :----- |

[^1]: 가장 멀리 떨어진 도시까지 모든 도시를 돌면서(N) 연결여부를 확인(N^2)하므로 총 O(N x N^2) = O(N^3) 입니다.
[^2]: 아래 코드를 통해 find() 메서드를 실행하며 만나는 **모든 도시들의 root를 최종 root로 변경**합니다.

    ```java
        private static int find(int i) {
           // 현재 메서드의 root[i]를 재귀적으로 다음에서 찾은 root로 변경
            if (i != root[i]) root[i] = find(root[i]);
            return root[i];
        }
    ```
