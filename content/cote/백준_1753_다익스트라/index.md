---
title: "[Java]백준 1753 다익스트라"
date: 2024-06-21T09:55:27+09:00
weight: #1
tags: ["codingtest", "backjoon", "programmers", "dijkstra"] # choose test platform
categories: ["algorithm"]
author: "Leaf" # ["Me", "You"] multiple authors
description: "백준 1753 다익스트라 문제에 대한 해설입니다."
editPost:
  URL: "https://github.com/leaf-nam/blog/blob/main/content/"
  Text: "Suggest Changes" # edit text
  appendFilePath: false # to append file path to Edit link
# 참고 : https://github.com/adityatelange/hugo-PaperMod/wiki/Variables
---

## 출처

- https://www.acmicpc.net/problem/1753

## 접근

- 각 정점에서 다른 정점으로의 최솟값을 다익스트라[^1]를 통해 구합니다.
- 정점으로부터 최단거리의 간선으로만 이동하기 때문에 O(ElogV) ≈ 1,200,000[^2]으로 모든 간선을 확인하는 것이 가능합니다.
- 탐색하는 간선 개수를 최적화하기 위해 LinkedList로 저장합니다.[^3]
  {{<figure src="solve.jpeg" caption="문제에서 주어진 예제를 그래프로 표현했습니다.">}}
  | 그래프 | 1 | 2 | 3 | 4 | 5 |
  |---|---|---|---|---|---|
  | 초기화 | 0 | INF | INF | INF | INF |
  | 1 -> 2, 3 | 0 | 2 | 3 | INF | INF |
  | 2 -> 3, 4 | 0 | 2 | 3 | 7 | INF |
  | 3 -> 4 | 0 | 2 | 3 | 7 | INF |
  | 5 -> 1 | 0 | 2 | 3 | 7 | INF |
  > 위와 같이 거리 배열을 초기화한 후, 각 정점의 간선들을 탐색하며 배열을 채워나갑니다.
  > 이 때, Greedy 알고리즘인 다익스트라가 도입되는데, 각 지점에서 가중치의 최솟값인 경로만 선택하면서 목표지점까지 이동하면 최소 경로를 구할 수 있다는 것입니다.

## 풀이

```java
package solving;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.PriorityQueue;
import java.util.StringTokenizer;

/*
 * [조건]
 * 시간 제한 : 1초 / 메모리 제한 : 256MB
 * V <= 20,000 / E <= 300,000
 * [풀이]
 * 각 정점에서 다른 정점으로의 최솟값을 다익스트라를 통해 구한다.
 * 정점으로부터 최단거리의 간선으로만 이동하기 때문에 O(E * logV) ≈ 1,500,000으로, 모든 간선을 확인하는 것이 가능하다.
 * 탐색하는 간선 개수를 최적화하기 위해 linkedList로 저장한다.(V^2 >> E)
 */
public class bj_1753_다익스트라 {
    static int INF = Integer.MAX_VALUE;
    static int V, E, K;
    static Node[] adj;

    static class Node {
        int v;
        int w;
        Node next;

        public Node(int v, int w, Node next) {
            this.v = v;
            this.w = w;
            this.next = next;
        }
    }

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine());
        V = Integer.parseInt(st.nextToken());
        E = Integer.parseInt(st.nextToken());
        K = Integer.parseInt(br.readLine());

        // 간선 리스트 초기화
        adj = new Node[V + 1];
        for (int i = 0; i < E; i++) {
            st = new StringTokenizer(br.readLine());
            int from = Integer.parseInt(st.nextToken());
            int to = Integer.parseInt(st.nextToken());
            int w = Integer.parseInt(st.nextToken());
            adj[from] = new Node(to, w, adj[from]);
        }

        // 다익스트라
        int[] dijkstra = dijkstra();
        for (int i = 1; i <= V; i++) System.out.println(dijkstra[i] == INF? "INF" : dijkstra[i]);
    }

    // 각 목표지점까지의 다익스트라
    private static int[] dijkstra() {
        PriorityQueue<int[]> pq = new PriorityQueue<>((o1, o2) -> o1[1] - o2[1]); // 가중치의 최솟값 저장
        pq.offer(new int[] {K, 0}); // int[0] : 정점, int[1] : 현재까지의 최단경로
        int[] distance = new int[V + 1]; // 거리 배열 초기화
        Arrays.fill(distance, INF);
        distance[K] = 0;

        while (!pq.isEmpty()) {
            int[] now = pq.poll();
            if (distance[now[0]] < now[1]) continue;  // 현재 거리배열보다 작은값은 사용하지 않음(최적화)
            for (Node n = adj[now[0]]; n != null; n = n.next) {
               int total = now[1] + n.w;  // 이전 최단경로에서 가중치를 더하여 현재 최단경로를 구함
               if (total < distance[n.v]) {
                   distance[n.v] = total;  // 거리배열에 현재까지의 최솟값 저장
                   pq.offer(new int[] {n.v, total});  // 우선순위 큐에 현재 최단경로 추가
               }
            }
        }

        return distance;
    }
}
```

## 결과

![result](result.png)

## 리뷰

- 처음 문제를 보고 모든 지점까지의 경로를 계산하는 부분에서 플로이드-워샬 문제라고 생각했지만, 시간복잡도를 계산해보니 불가능함을 알았습니다.
- 보통은 다익스트라를 통해 특정 지점까지의 최솟값을 구하지만, 다익스트라의 특성상 한 정점에서 모든 탐색을 완료하면 나머지 지점까지의 최솟값을 얻을 수 있는 것을 활용한 문제였습니다.
- 다익스트라 문제를 오랜만에 풀다가 구현이 막혀서 다른 블로그의 개념을 참고했습니다. 항상 개념이 부족하면 구현이 안되는 것 같습니다.
- 각 노드의 최솟값을 저장하고, 방문배열처럼 사용하는 것과 이를 통해 최적화하는 부분의 로직을 잘 기억해야겠습니다.

## References

| URL                                                                                                   | 게시일자    | 방문일자    | 작성자   |
| :---------------------------------------------------------------------------------------------------- | :---------- | :---------- | :------- |
| https://velog.io/@panghyuk/%EC%B5%9C%EB%8B%A8-%EA%B2%BD%EB%A1%9C-%EC%95%8C%EA%B3%A0%EB%A6%AC%EC%A6%98 | 2022.02.07. | 2024.06.21. | PANGHYUK |

[^1]: 가중치가 있는 그래프에서 최단 경로를 Greedy로 탐색하는 알고리즘입니다. [다음 블로그](https://velog.io/@panghyuk/%EC%B5%9C%EB%8B%A8-%EA%B2%BD%EB%A1%9C-%EC%95%8C%EA%B3%A0%EB%A6%AC%EC%A6%98)에 잘 정리가 되어있습니다.
[^2]: 우선순위큐에 모든 간선을 집어넣어서 정렬을 해야하므로 O(E x logE)이지만, 중복 간선은 존재하지 않기 때문에 근사적으로 O(ElogE) = O(ElogV^2) = O(2ElogV)로 표현이 가능합니다.
[^3]: 간선을 매트릭스 형태로 저장하게 되면 V^2 = 20,000 x 20,000 이지만, 간선 리스트로 저장하면 E = 300,000으로 시간복잡도를 훨씬 절약할 수 있습니다.
