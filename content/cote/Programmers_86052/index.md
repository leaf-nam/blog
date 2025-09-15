---
title: "[Java]Programmers 빛의 경로 사이클"
date: 2024-11-10T17:33:01+09:00
weight: #1
tags: ["codingtest", "programmers", "dfs"] # choose test platform
categories: ["algorithm"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "Programmers 빛의 경로 사이클 문제에 대한 해설입니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 출처

- https://school.programmers.co.kr/learn/courses/30/lessons/86052

## 접근

- 문제의 예시를 잘 살펴보면, 모든 위치에서 네 방향을 적어도 한번씩 방문하는 것을 볼 수 있습니다.
- 즉, 빛이 갈 수 있는 모든 경로를 탐색하면서 한번 탐색을 돌면서 방문한 경로는 같은 사이클이라고 할 수 있습니다.
- 이러한 사이클의 개수를 세서 정렬 후 출력하면 됩니다.
- 모든 경로를 탐색하는 점에서 DFS나 BFS 모두 구현이 가능합니다.
  > 저는 DFS를 통해 빛의 경로를 따라서 탐색하는 것이 문제를 이해하는데 더 직관적이라고 생각하여 DFS로 구현하였습니다.
- grid의 길이가 500 이하이므로 O(N^2) 알고리즘에서 4방향 탐색 시 최대 500 X 500 X 4 = 100,000의 시간복잡도가 필요해서 재귀적으로는 풀이할 수 없습니다.[^1]

### 구현

구현에 도움이 되는 두 가지 스킬을 설명드리겠습니다.

**1. 방향 전환**

- 'S'인 칸은 방향전환을 할 필요가 없으니 기존 진행방향으로 통과시키면 됩니다.
- 'R'인 칸은 시계방향으로 방향전환을 해야 하니, L -> U -> R -> D 순으로 방향을 전환해야 합니다.
- 'L'인 칸은 반시계방향으로 전환을 해야 하니, L -> D -> R -> U 순으로 방향을 전환해야 합니다.

이를 다음과 같이 구현할 수 있습니다.

```java
// d :  0 ->  1 ->  2 ->  3 (진입방향 int로 변경)
// D :  L ->  U ->  R ->  D (진입방향 좌 -> 상 -> 우 -> 하)
// R :  0 -> -1 ->  0 ->  1 (상하방향 움직임)
// C : -1 ->  0 ->  1 ->  0 (좌우방향 움직임)
int[] dr = {0, -1, 0, 1};
int[] dc = {-1, 0, 1, 0};
int d; // 초기 진입하는 방향
switch(g) { // g : 현재 격자 칸에 적힌 알파벳

    // 'S' : 그대로 진행
    case 'S': break;

    // 'R' : 현재 방향에서 1 증가시킴
    case 'R': d++; d %= 4; break;

    // 'L' : 현재 방향에서 1 감소시킴, 0보다 작아질 수 있으니 Modular로 회전
    case 'L': d--; d += 4; d %= 4; break;
}
```

**2. 격자 끝으로 이동 시 반대쪽으로 복귀**

- 다음 위치로 이동했을 때 격자 끝이면, 반대쪽으로 나와야 합니다.

이를 다음과 같이 구현할 수 있습니다.

```java
int nr = r + dr[d]; // 다음 위치로 이동
nr += R; nr %= R; // 벽 크기만큼 더해준 뒤, 모듈러 연산을 통해 반대쪽 위치로 이동
int nc = c + dc[d]; // 다음 위치로 이동
nc += C; nc %= C; // 벽 크기만큼 더해준 뒤, 모듈러 연산을 통해 반대쪽 위치로 이동
```

> Modular 연산을 통해 반대방향으로 이동하는 동작 원리는 [연속 부분 수열 합의 개수](https://leaf-nam.github.io/cote/programmers_%EC%97%B0%EC%86%8D_%EB%B6%80%EB%B6%84_%EC%88%98%EC%97%B4_%ED%95%A9%EC%9D%98_%EA%B0%9C%EC%88%98/) 풀이에 자세히 설명되어 있습니다.

## 풀이

```java
import java.util.*;

class Solution {

    // 격자 크기
    int R, C;

    // 정답을 담을 동적 배열
    List<Integer> answer = new ArrayList<>();

    public int[] solution(String[] grid) {

        // 격자 크기 초기화
        R = grid.length; C = grid[0].length();

        // String[] 배열로부터 char[][] 배열 생성
        char[][] grid_ = new char[R][C];
        for (int i = 0; i < R; i++) grid_[i] = grid[i].toCharArray();

        // 방문처리를 위한 배열 생성
        boolean[][][] visited = new boolean[R][C][4];

        // 각 격자 4방향 탐색
        for (int r = 0; r < R; r++) {
            for (int c = 0; c < C; c++) {
                for (int d = 0; d < 4; d++) {

                    // 방문한 방향의 빛은 재탐색하지 않음
                    if (visited[r][c][d]) continue;

                    // DFS 수행(현재 위치 및 방향에서 1번 이동한 후 다음위치부터 DFS)
                    dfs(new int[] {r, c, d}, move(grid_[r][c], r, c, d), grid_, visited);
                }
            }
        }

        // 동적배열 정렬 후 정적배열로 변환
        answer.sort(Comparator.naturalOrder());
        int[] ret = new int[answer.size()];
        for (int i = 0; i < answer.size(); i++) ret[i] = answer.get(i);
        return ret;
    }

    // 깊이우선 탐색
    void dfs(int[] start, int[] current, char[][] grid_, boolean[][][] visited) {

        // 스택을 활용한 깊이우선 탐색
        Stack<int[]> s = new Stack<>();

        // 처음 위치 방문처리 후 스택에 삽입
        visited[current[0]][current[1]][current[2]] = true;
        s.push(new int[] {current[0], current[1], current[2], 1});

        // 스택이 빌때까지 완전탐색 수행
        while (!s.isEmpty()) {
            current = s.pop();

            // 시작지점으로 돌아오면 DFS 종료
            if (start[0] == current[0] && start[1] == current[1] && start[2] == current[2]) {
                answer.add(current[3]);
                return;
            }

            // 다음위치로 이동
            int[] next = move(grid_[current[0]][current[1]], current[0], current[1], current[2]);

            // 방문처리 후 스택에 삽입
            visited[next[0]][next[1]][next[2]] = true;
            s.push(new int[] {next[0], next[1], next[2], current[3] + 1});
        }
    }

    // 빛의 이동 구현(현재위치, 방향, 알파벳을 토대로 다음 빛의 위치와 이동방향 반환)
    int[] dr = {0, -1, 0, 1};
    int[] dc = {-1, 0, 1, 0};
    int[] move(char g, int r, int c, int d) {

        // 방향 전환
        switch(g) {
            case 'S': break;
            case 'R': d++; d %= 4; break;
            case 'L': d--; d += 4; d %= 4; break;
        }

        // 벽에 닿을 때 처리
        int nr = r + dr[d]; nr += R; nr %= R;
        int nc = c + dc[d]; nc += C; nc %= C;

        return new int[] {nr, nc, d};
    }
}
```

## 결과

![result](result.png)

## 리뷰

- 완전탐색이라는 아이디어는 문제를 보자마자 바로 알 수 있어, 풀이방법을 생각하는건 어렵지 않은 문제인 것 같습니다.
- 구현이 까다로운 편인데, 배열을 탐색하면서 방향전환을 하는 부분이 처음 접하면 조금 힘들게 다가왔을 것 같습니다.
- 처음에 조건을 생각하지 않고 재귀적으로 DFS를 구현해서 StackOverflow가 발생했는데, 기본 조건을 잘 살펴보는 습관을 가져야겠습니다.

## References

| Link                                                                                           | 게시일자 | 방문일자    | 작성자  |
| :--------------------------------------------------------------------------------------------- | :------- | :---------- | :------ |
| [OpenJDK 14 공식문서](https://openjdk.org/projects/jdk/14/)                                    | -        | 2024.11.10. | OpenJDK |
| [Oracle Java 8 공식문서](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/java.html) | -        | 2024.11.10. | Oracle  |

[^1]:
    - 프로그래머스 컴파일 옵션을 확인해보면 다음과 같이 스택 크기는 별도 설정되어 있지 않아 기본값을 사용하는 것을 알 수 있습니다.
      {{<figure src="solve1.png" caption="프로그래머스 컴파일 옵션">}}
    - JVM의 -Xss 옵션을 지정하여 스택 크기를 증가시킬 수 있는데, 64비트에서 기본값은 1(MB)로 되어있습니다.
      {{<figure src="solve2.png" caption="Java 8의 기본 쓰레드 스택 사이즈">}}

      > [OpenJDK 14의 공식문서](https://openjdk.org/projects/jdk/14/)를 찾아보았지만, 기본 쓰레드 스택 사이즈 값을 찾을 수 없어 [Oracle Java 8 공식문서](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/java.html)를 확인했습니다. OpenJDK 14에서도 동일한 기본값을 사용할 것으로 보입니다.

    - 1MB(1,000,000Byte)의 스택 사이즈를 사용해 주어진 100,000번의 메서드를 호출하기 위해서는 메서드의 크기를 10Byte 이내로 사용해야 하지만 이는 불가능하므로 재귀 호출 시 StackOverflow가 발생합니다.
