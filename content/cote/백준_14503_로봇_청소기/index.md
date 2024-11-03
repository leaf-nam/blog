---
title: "[Java]백준 14503 로봇 청소기"
date: 2024-06-19T10:32:37+09:00
weight: #1
tags: ["codingtest", "backjoon", "programmers"] # choose test platform
categories: ["algorithm"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "백준 14503 로봇 청소기 문제에 대한 해설입니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 출처

- https://www.acmicpc.net/problem/14503

## 접근

- N, M <= 50, O(N^5) = 312,500,000 이므로 시간복잡도는 여유롭게 구현 가능합니다.
- 로봇 청소기의 이동 방식을 BFS로 구현했습니다.
  > 다시 생각해보니 BFS형태가 아니더라도 구현 가능한데 습관적으로 BFS를 사용한 것 같습니다.
- 문제에서 주어진 방향설정이 중요합니다.
  > 북(-1, 0), 동(0, 1), 남(1, 0), 서(0, -1)
- 친절하게 방의 둘레는 모두 벽(1)로 채워져 있기 때문에 ArrayIndexOutOfBoundsException[^1]은 처리하지 않아도 됩니다.

## 풀이

```java
package solving;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayDeque;
import java.util.Queue;
import java.util.StringTokenizer;

/*
 * N, M이 50 이하이므로, 시간복잡도와 메모리제한은 고려하지 않음
 * [풀이]
 * 로봇 청소기의 이동 방식을 bfs로 구현한다.
 * 방향 : 북(-1, 0), 동(0, 1), 남(1, 0), 서(0, -1)
 * 청소를 마치면 0 -> -1로 변경
 * 로봇의 동작은 각각 별도의 메서드로 분리
 */
public class bj_14503_로봇_청소기 {
    static int N;
    static int M;
    static int[][] room;
    static int[] dr = {-1, 0, 1, 0};
    static int[] dc = {0, 1, 0, -1};

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine());
        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());
        room = new int[N + 1][M + 1];

        st = new StringTokenizer(br.readLine());
        int[] start = {Integer.parseInt(st.nextToken()), Integer.parseInt(st.nextToken())};
        int direction = Integer.parseInt(st.nextToken());

        for (int i = 0; i < N; i++) {
            st = new StringTokenizer(br.readLine());
            for (int j = 0; j < M; j++) room[i][j] = Integer.parseInt(st.nextToken());
        }

        solve(start, direction);
    }

    private static void solve(int[] start, int direction) {
        Queue<int[]> q = new ArrayDeque<>();
        q.offer(new int[]{start[0], start[1], direction});
        int count = 0;

        while (!q.isEmpty()) {
            int[] cur = q.poll();
            int r = cur[0], c = cur[1], d = cur[2];

            // 현재 칸이 청소되지 않은 경우
            if (room[r][c] == 0) {
                count++;
                room[r][c] = -1;
            }

            // 주변 4칸 중 빈칸이 없을 경우
            if (!findDirty(r, c)) {
                int[] back = moveBack(r, c, d);
                if (back == null) break;
                q.offer(back);
            }

            // 주변 4칸 중 빈칸이 있을 경우
            else {
                for (int i = 0; i < 4; i++) {
                    d = d == 0 ? 3 : d == 3 ? 2 : d == 2 ? 1 : 0;
                    int[] forward = moveForward(r, c, d);
                    if (forward != null) {
                        q.offer(forward);
                        break;
                    }
                }
            }
        }

        System.out.println(count);
    }

    private static int[] moveForward(int r, int c, int nd) {
        int nr = r + dr[nd];
        int nc = c + dc[nd];

        // 더이상 이동할 수 없을 때
        if (room[nr][nc] != 0) return null;
        else return new int[]{nr, nc, nd};
    }

    private static int[] moveBack(int r, int c, int d) {
        int nd = d == 0 ? 2 : d == 1 ? 3 : d == 2 ? 0 : 1;
        int nr = r + dr[nd];
        int nc = c + dc[nd];

        // 더이상 물러날 곳이 없을때
        if (room[nr][nc] == 1) return null;
        else return new int[]{nr, nc, d};
    }

    private static boolean findDirty(int r, int c) {
        for (int i = 0; i < 4; i++) {
            int nr = r + dr[i];
            int nc = c + dc[i];
            if (room[nr][nc] == 0) return true;
        }
        return false;
    }
}
```

## 결과

![result](result.png)

## 리뷰

- 문제에 주어진 로직을 그대로 구현하는 문제여서 난이도는 높지 않았습니다.
- 로직을 메서드 단위로 분리해서 구현하니 좀더 직관적으로 구현이 가능했습니다.
- BFS를 구현하기 위해 불필요한 Queue 객체를 추가로 생성한 것 같아 아쉽습니다.
- BFS나 DFS를 사용하기에 앞서 탐색 시 기존 경로를 저장할 필요가 있는지를 따져보고 도입하는게 좋을 것 같습니다.

## References

| URL | 게시일자 | 방문일자 | 작성자 |
| :-- | :------- | :------- | :----- |

[^1]: 유효하지 않은 배열 인덱스에 접근할때 발생하는 오류입니다.
