---
title: "[Java]HackerRank Non Divisible Subset"
date: 2024-11-12T10:33:05+09:00
weight: #1
tags: ["codingtest", "hackerrank", "greedy"] # choose test platform
categories: ["algorithm"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "HackerRank Non Divisible Subset 문제에 대한 해설입니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 출처

- [해커 랭크 : Non Divisible Subset](https://www.hackerrank.com/challenges/non-divisible-subset/problem)

## 문제 설명

- 영문 사이트이므로 문제를 간단히 설명하겠습니다.

1. 중복되지 않는 정수 배열(집합)이 주어집니다.
   > 문제 예시에는 10이 중복되어 있는데 오타인 것 같습니다.
2. K가 주어졌을 때, 두 수의 합이 k로 나누어 떨어지지 않는 부분 집합을 찾는 문제입니다.
3. 부분 집합에서 임의의 두 수를 골라도 k로 나누어 떨어지지 않아야 하며, 부분 집합이 여러개가 있을 때는 최대 길이를 구해야 합니다.

## 접근

### 완전탐색

- 부분 집합을 만들 수 있는 각각의 경우에서 2개씩 고른 뒤 K로 나누어 떨어지는지를 일일히 확인하면 시간복잡도를 초과합니다.
  > O(N! x nC_2)

### 시간복잡도 줄이기

{{<figure src="solve1.png" caption="Modular 연산을 통해 시간복잡도 줄이기">}}

- Greedy한 접근을 위해 Modular연산을 통해 문제를 단순화할 수 있습니다.
  - 두 수의 합이 k로 나누어 떨어진다면,
  - 두 수를 각각 k로 나머지 연산을 한 뒤, 나머지끼리 더했을 때 k가 된다.
- 이렇게 Modular 연산을 통해 두 수의 합이 k로 나누어 떨어지는지 확인하면, 집합의 원소를 K크기의 배열로 줄일 수 있습니다.
  > S[i] <= 10^9, k <= 100 이므로 시간복잡도를 크게 줄일 수 있습니다.
- 따라서 각 배열의 원소를 k로 나눈 뒤, 이러한 나머지가 몇 개 있는지 세면 Greedy하게 푸는 것이 가능합니다.

### Greedy

{{<figure src="solve2.png" caption="나머지 원소들끼리 합해서 k가 되는 경우 찾기">}}

- 위와 같이 나머지들을 정렬하면 나머지가 k/2인 값을 기준으로 **두 수의 합이 k가 될 때 더 큰 값만 부분집합에 추가**하는 방식으로 구현할 수 있습니다.
- 이 때, 주의해야 할 원소는 나머지가 0이거나 k/2와 같을 때입니다. 이 때는 부분집합에 최대 1개만 추가하는 것이 가능합니다.
  > 나머지가 0인 원소가 2개 모이면 k로 나누어 떨어지고, 마찬가지로 k/2인 원소가 2개 모이면 k로 나누어 떨어지기 때문입니다.

## 풀이

```java
public static int nonDivisibleSubset(int k, List<Integer> s) {

    // 나머지 연산 후 각 나머지의 개수를 저장할 배열
    int[] cnt = new int[k];
    for (int i : s) cnt[i % k]++;

    int ret = 0;

    // 나머지가 0인 원소가 1개 이상이면 1개 추가
    if (cnt[0] > 0) ret++;

    // 나머지가 k/2인 원소가 1개 이상이면 1개 추가
    if (k % 2 == 0 && cnt[k / 2] > 0) ret++;

    // k가 홀수일 때와 짝수일 때 모두 적용하기 위해 k-1 이후 2로 나눔
    for (int i = 1; i <= (k - 1) / 2; i++) {

        // Greedy하게 부분집합의 크기 추가
        ret += Math.max(cnt[i], cnt[k - i]);
    }

    return ret;
}
```

## 결과

![result](result.png)

## 리뷰

나머지 연산을 통해 시간복잡도를 줄이는 기법도 상당히 자주 보이는 것 같습니다.

> 완전탐색같은 문제인데 주어진 N이 크다는 것은 대부분 Greedy혹은 DP문제로 풀라는 힌트이니, 해당 부분을 잘 착안해야겠습니다.

## References

| URL | 게시일자 | 방문일자 | 작성자 |
| :-- | :------- | :------- | :----- |
