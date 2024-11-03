---
title: "[Java Alogorithm]백준 16927 배열 돌리기 2"
date: 2024-05-31T20:57:13+09:00
weight: #1
tags: ["codingtest", "backjoon"] # choose test platform
categories: ["algorithm"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "백준 16927 배열 돌리기 2 문제에 대한 해설입니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 출처

- https://www.acmicpc.net/problem/16927

## 접근

- 돌려야 하는 배열을 1차원 배열로 만들어서 R만큼 이동하면 다음 배열 값을 얻을 수 있습니다.

1. 1차원 배열과 2차원 배열을 변환하는게 조금 귀찮은데, 저는 하 -> 우 -> 상 -> 좌(반시계) 순으로 이동하도록 설계했습니다.
   {{<figure src="solve1.jpeg" caption="2차원 배열을 위 순서로 탐색해서 1차원 배열로 만듭니다.">}}

   > 이 때, 1차원 배열의 크기는 2차원 배열의 (가로 + 세로) \* 2 에서 네 귀퉁이(위 사진에서 (1) ~ (4))가 중복되므로 4를 빼주어야 합니다.

2. 이렇게 구한 배열값을 R만큼 이동시키는데, 이때 R < 10^9[^1] 이므로 최적화를 위해 해당 배열의 크기로 나머지를 구합니다.
   {{<figure src="solve2.jpeg" caption="빨간색 화살표(포인터)만큼 배열을 이동시켜야 합니다.">}}

3. 다시 그래프를 탐색하면서 이번에는 역순으로 1차원 배열의 원소로 2차원 배열을 채워넣습니다.

4. 1 ~ 3 과정을 행 / 열 중 하나가 1보다 작아질 때까지 depth를 1씩 이동하며 수행합니다.
   {{<figure src="solve3.jpeg" caption="행 / 열 중 하나가 1보다 작아지면 행렬을 돌릴 수 없으므로 종료합니다.">}}

## 풀이

```java
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.StringTokenizer;

public class Main {

    static int N;
    static int M;
    static int R;

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine());
        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());
        R = Integer.parseInt(st.nextToken());

        int[][] NM = new int[N][M];
        for (int i = 0; i < N; i++) {
            st = new StringTokenizer(br.readLine());
            for (int j = 0; j < M; j++) {
                NM[i][j] = Integer.parseInt(st.nextToken());
            }
        }

        for (int d = 0; d < Math.min(M, N) / 2; d++) { // M, N 중 최솟값의 절반만큼 수행
            rotate(d, N - d, d, M - d, NM);
        }

        System.out.print(toStringInt2(NM));  // 정답 출력
    }

    /*
     * [조건]
     * 시간제한 : 1초 / 메모리 제한 : 512MB
     * N, M < 300, R < 10^9, 1 < 원소 < 10^8
     * min(N, M) % 2 = 0(M + N은 짝수)
     * [풀이]
     * 2(m + n) 크기의 배열에 원소들을 담고, R % 2(m + n)의 값만큼 반시계 방향으로 이동하면 해당위치 값을 구할 수 있다.
     * 모든 깊이에서 해당 로직을 수행하기 위해 (n / 2 <= 1)가 될때까지 위 로직을 수행한다.
     */
    static void rotate(int n0, int n1, int m0, int m1, int[][] NM) {


        // 배열 크기는 전체 길이에서 네 귀퉁이를 한번씩 빼주기
        int[] arr = new int[(n1 - n0 + m1 - m0) * 2 - 4];

        // 배열에 반시계방향으로 원소 담기
        getArrElement(n0, n1, m0, m1, arr, NM);

        // 배열 값 이동시키기
        int l = arr.length;
        int[] newArr = new int[l];
        int p = R % l;  // 최적화를 위해 R을 행렬의 길이로 나눈 나머지를 구해서 이동시키기
        for (int i = 0; i < l; i++) {  //
            int np = i - p >= 0? i - p : i - p + l;
            newArr[i] = arr[np];
        }

        // 이동한 값 배열에 넣기
        setArrElement(n0, n1, m0, m1, newArr, NM);
    }

    static int[] dr = {1, 0, -1, 0};  // d = 0 : 하 -> d = 1 : 상 -> d = 2 : 좌 -> d = 3 : 우
    static int[] dc = {0, 1, 0, -1};

    /*
     * 1차원 배열로 하 -> 우 -> 상 -> 좌 순으로 2차원 배열 채우기
     */
    static void setArrElement(int n0, int n1, int m0, int m1, int[] arr, int[][] NM) {
        // 시작점에서부터 하 -> 우 -> 상 -> 좌 순으로 탐색
        int[] p = {n0, m0};
        NM[n0][m0] = arr[0];  // 1차원 배열로 2차원 배열 채우기
        int l = 1;
        int d = 0;
        while (l < arr.length) {  // 1차원 배열의 길이가 다 채워질때까지 수행
            int[] np = {p[0] + dr[d], p[1] + dc[d]};
            if (n0 > np[0] || np[0] >= n1 || m0 > np[1] || np[1] >= m1) {  // 해당 꼭지점을 벗어날 경우 방향 전환
                d++;  // 방향 전환
                np = new int[] {p[0] + dr[d], p[1] + dc[d]};  // 방향 전환 후 np 덮어쓰기
            }
            NM[np[0]][np[1]] = arr[l];  // 1차원 배열로 2차원 배열 채우기
            l++;  // while문 탈출조건
            p = np;  // 위치 다음으로 변경
        }
    }

    /*
     * 2차원 배열로 하 -> 우 -> 상 -> 좌 순으로 1차원 배열 채우기
     */
    static void getArrElement(int n0, int n1, int m0, int m1, int[] arr, int[][] NM) {
        // 시작점에서부터 하 -> 우 -> 상 -> 좌 순으로 탐색
        int[] p = {n0, m0};
        arr[0] = NM[n0][m0];  // 2차원 배열로 1차원 배열 채우기
        int l = 1;
        int d = 0;
        while (l < arr.length) {
            int[] np = {p[0] + dr[d], p[1] + dc[d]};
            if (n0 > np[0] || np[0] >= n1 || m0 > np[1] || np[1] >= m1) {
                d++;
                np = new int[] {p[0] + dr[d], p[1] + dc[d]};
            }
            arr[l] = NM[np[0]][np[1]];  // 2차원 배열로 1차원 배열 채우기
            l++;
            p = np;
        }
    }

    /*
     * 2차원 배열 출력하기
     */
    static String toStringInt2(int[][] int2) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < int2.length; i++) {
            for (int j : int2[i]) sb.append(j + " ");
            if (i != int2.length - 1) sb.append("\n");
        }
        return sb.toString();
    }
}
```

## 결과

![result](result.png)

## 리뷰

- 문제 접근은 바로 떠올렸는데, 오랜만에 구현하려고 하니 생각보다 시간이 많이걸렸습니다.
- 그리고 2차원 행렬 탐색을 할 때 어줍짢게 for문으로 상하좌우 돌려보려고 했는데 1시간 정도 해보다가 포기했습니다.
- 구현방법이 직관적으로 떠오르지 않으면 바로 다른 대안을 찾아 시간을 줄여야겠습니다.
- 지금 생각해보니 2차원 <-> 1차원 변환하는 메서드가 중복이 많은데, 플래그를 하나 넣으면 짧게 줄일수도 있을 것 같습니다.
- 그리고 매개변수에 각 지점을 하나씩 넣지말고 행과 열을 묶어서 배열로 넣는게 더욱 코드를 이해하기 좋아보입니다.

  - 개선 코드

  ```java
  /*
    * 1차원 배열 <-> 2차원 배열 변환
    */
  static void changeArrElement(int[] n, int[] m, int[] arr, int[][] NM, boolean isTwoToOne) {
      // 시작점에서부터 하 -> 우 -> 상 -> 좌 순으로 탐색
      int[] p = {n[0], m[0]};
      if (isTwoToOne) arr[0] = NM[n[0]][m[0]]; // 2차원 배열로 1차원 배열 채우기
      else NM[n[0]][m[0]] = arr[0];  // 1차원 배열로 2차원 배열 채우기
      int l = 1;
      int d = 0;
      while (l < arr.length) {  // 1차원 배열의 길이가 다 채워질때까지 수행
          int[] np = {p[0] + dr[d], p[1] + dc[d]};
          if (n[0] > np[0] || np[0] >= n[1] || m[0] > np[1] || np[1] >= m[1]) {  // 해당 꼭지점을 벗어날 경우 방향 전환
              d++;  // 방향 전환
              np = new int[] {p[0] + dr[d], p[1] + dc[d]};  // 방향 전환 후 np 덮어쓰기
          }
          if (isTwoToOne) arr[l] = NM[np[0]][np[1]];  // 2차원 배열로 1차원 배열 채우기
          else NM[np[0]][np[1]] = arr[l];  // 1차원 배열로 2차원 배열 채우기
          l++;  // while문 탈출조건
          p = np;  // 위치 다음으로 변경
      }
  }
  ```

## References

| URL | 게시일자 | 방문일자 | 작성자 |
| :-- | :------- | :------- | :----- |

[^1]: R = 10^9이면 원소를 순차적으로 하나씩 이동시켰을때 원소 1개의 시간복잡도가 10^9 이므로 문제에 주어진 10^8개의 원소를 이동시키는데 O(N) = 10^9 \* 10^8 = 10^17 이 걸리게 됩니다.
