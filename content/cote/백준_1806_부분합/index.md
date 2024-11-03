---
title: "[Java Alogorithm]백준 1806 부분합"
date: 2024-06-12T09:03:34+09:00
weight: #1
tags: ["codingtest", "backjoon", "programmers"] # choose test platform
categories: ["algorithm"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "백준 1806 부분합 문제에 대한 해설입니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 출처

- https://www.acmicpc.net/problem/1806

## 접근

- 문제는 굉장히 심플하나, 시간제한이 0.5초이며 메모리 제한이 128MB인 것으로 보아 최적화 문제임을 알 수 있습니다.
- 주어지는 수열의 부분합을 구해야 하는데, 수열의 길이가 100,000이므로 O(N^2)으로는 시간 초과가 발생합니다.
- 부분합의 최대 크기를 100,000,000 ≒ 2^30 정도로 제한해주었기 때문에 int로 총합을 구해도 Overflow가 발생하지 않습니다.

## 풀이

- 포인터를 2개 두고 합이 S보다 커질때까지 부분수열의 크기를 늘리다가, S보다 커지는 시점부터 부분수열의 크기를 줄여나가면 됩니다.
  {{<figure src="solve1.jpeg" caption="①에서 점점 부분수열을 늘리다가 ②처럼 다시 15보다 작을때까지 사이즈를 줄여나갑니다.">}}
- 위와 같은 로직을 반복하면 각 숫자를 최대 2번씩 확인하기 때문에 O(2N) = O(N)의 시간복잡도로 해결이 가능합니다.

```java
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.StringTokenizer;

/*
 * [조건]
 * 시간 제한 : 1s / 메모리 제한 : 128MB
 * N < 100,000 / s <= 100,000,000 / 최대 O(Nlog(N)) / Int로 총합 구해도 Overflow 발생하지 않음
 * [풀이]
 * 합이 S보다 커질떄까지 앞에서부터 부분수열 더하기, S보다 클때의 길이 저장
 * 합이 S보다 커지면 S보다 작아질때까지 앞에서부터 부분수열 빼기, S보다 클때의 길이 저장
 * 길이의 최솟값 출력
 */
public class bj_1806_부분합 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine());
        int N = Integer.parseInt(st.nextToken());
        int S = Integer.parseInt(st.nextToken());
        int[] arr = new int[N];
        st = new StringTokenizer(br.readLine());
        for (int i = 0; i < N; i++) arr[i] = Integer.parseInt(st.nextToken());

        System.out.print(solve(N, S, arr));
    }

    private static int solve(int N, int S, int[] arr) {
        int min = N + 1, sum = arr[0], p0 = 0, p1 = 0;

        while (p1 < N) {
            if (sum >= S) {
                min = Math.min(p1 - p0 + 1, min);
                sum -= arr[p0++];
            } else {
                if (p1 == N - 1) break;
                sum += arr[++p1];
            }
        }

        return min != N + 1? min : 0;
    }
}
```

## 결과

![result](solve2.png)

## 리뷰

- 예전에 파이썬으로 풀었던 적이 있는 문제였습니다.
- 풀이는 금방 떠올렸는데 이를 구현하려고 하니 조금 복잡하게 느껴졌습니다.
- 설계한 로직을 빠르고 직관적으로 코드로 옮기는 과정을 좀더 연습해야겠다고 느꼈습니다.
- 동일한 로직을 파이썬으로 풀었을 때[^1] 전체 시간이 160ms정도로 더 작게 나왔는데, 자바에서는 최초 배열을 생성하고 loop를 한번 도는 로직이 추가되어 그런 듯 합니다.

## References

| URL | 게시일자 | 방문일자 | 작성자 |
| :-- | :------- | :------- | :----- |

[^1]: 아래는 파이썬 코드입니다.

    ```python
    import sys
    input = sys.stdin.readline

    N, S = map(int, input().split())
    arr = list(map(int, input().split()))
    min_sum_length = 100000000
    left, right = 0, 0
    judge = arr[0]
    while right < len(arr):
      if judge >= S:
          min_sum_length = min(min_sum_length, right - left + 1)
          judge -= arr[left]
          left += 1
      elif judge < S:
          if right == len(arr) - 1: break
          right += 1
          judge += arr[right]
    print(0 if min_sum_length == 100000000 else min_sum_length)
    ```
