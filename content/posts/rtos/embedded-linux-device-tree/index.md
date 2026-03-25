+++
title = 'Context Switch 중 Bus Fault 발생 원인 분석(STM32F429 + FreeRTOS)'
date = 2026-02-11T10:27:45+09:00
draft = false

+++

## 상황

- Windows11 CubeIDE
- STM32F429 + FreeRTOS 포팅
- context switch(이하 문맥전환) 수업 시간에 각 태스크에서 led를 켜고, delay 시 led를 끄도록 위 코드와 같이 작성함
- 디버깅 시 `첫번째, 두번째 문맥 전환`에서는 정상 동작
- `세번째 문맥 전환 발생 시` Bus Fault 발생

![situation1](situation1.png#center)

### 소스 코드

```c
void xPortPendSVHandler( void )
{
   /* This is a naked function. */
   ledoff();

   __asm volatile
   (
   "   mrs r0, psp                     \n"
   "   isb                           \n"
   "                              \n"
   "   ldr   r3, pxCurrentTCBConst         \n" /* Get the location of the current TCB. */
   "   ldr   r2, [r3]                  \n"
   "                              \n"
   "   tst r14, #0x10                  \n" /* Is the task using the FPU context?  If so, push high vfp registers. */
   "   it eq                        \n"
   "   vstmdbeq r0!, {s16-s31}            \n"
   "                              \n"
   "   stmdb r0!, {r4-r11, r14}         \n" /* Save the core registers. */
   "   str r0, [r2]                  \n" /* Save the new top of stack into the first member of the TCB. */
   "                              \n"
   "   stmdb sp!, {r0, r3}               \n"
   "   mov r0, %0                      \n"
   "   msr basepri, r0                  \n"
   "   dsb                           \n"
   "   isb                           \n"
   "   bl vTaskSwitchContext            \n"
   "   mov r0, #0                     \n"
   "   msr basepri, r0                  \n"
   "   ldmia sp!, {r0, r3}               \n"
   "                              \n"
   "   ldr r1, [r3]                  \n" /* The first item in pxCurrentTCB is the task top of stack. */
   "   ldr r0, [r1]                  \n"
   "                              \n"
   "   ldmia r0!, {r4-r11, r14}         \n" /* Pop the core registers. */
   "                              \n"
   "   tst r14, #0x10                  \n" /* Is the task using the FPU context?  If so, pop the high vfp registers too. */
   "   it eq                        \n"
   "   vldmiaeq r0!, {s16-s31}            \n"
   "                              \n"
   "   msr psp, r0                     \n"
   "   isb                           \n"
   "                              \n"
   #ifdef WORKAROUND_PMU_CM001 /* XMC4000 specific errata workaround. */
      #if WORKAROUND_PMU_CM001 == 1
   "         push { r14 }            \n"
   "         pop { pc }               \n"
      #endif
   #endif
   "                              \n"
   "   bx r14                        \n"
   "                              \n"
   "   .align 4                     \n"
   "pxCurrentTCBConst: .word pxCurrentTCB   \n"
   ::"i"(configMAX_SYSCALL_INTERRUPT_PRIORITY)
   );
}
/*-----------------------------------------------------------*/
```

## 원인(요약)

- xPortPendSVHandler()는 `naked 함수`로 선언되어 있음

- 해당 함수 상단에서 ledoff()라는 `일반 C 함수 호출`

- 이 과정에서 `LR(r14) 값이 오염`

- `오염된 LR 값이 TCB에 저장`되고, 이후 복귀 과정에서 사용되면서 Fault 발생

## 상세분석

> 다양한 원인이 함께 연관되어 발생한 문제이므로, 각각의 상황을 상세히 분석해 보겠습니다.

### STM32의 ISR(인터럽트 서비스 루틴)

- 인터럽트 진입 시, Cortex-M 하드웨어는 다음을 자동으로 수행

1. LR에 `EXC_RETURN` 값 저장

2. 스택에 `스택 프레임` 저장

- 스택 프레임 구성

```c
// 1 R0 ~ R3
// 2 R12
// 3 LR
// 4 PC
// 5 xPSR
```

3. 인터럽트 복귀 시 `LR의 EXC_RETURN` 값과 `스택 프레임`에 저장된 PC 값 확인

4. 복귀 모드 및 복귀 주소를 결정하여 복귀 수행

> 위 과정은 `하드웨어에 의해 자동`으로 처리됩니다.

### context switching(문맥 전환)

- FreeRTOS의 context switch는 위 하드웨어 스택 프레임과 별도로 태스크의 실행 상태를 저장해야 합니다.

- 이를 위해 `다음 레지스터를 소프트웨어적으로 저장`합니다.
  - `R4 ~ R11`
  - `R14 (LR)`

> 이는 태스크가 중단된 시점의 상태를 유지하기 위함입니다.

- 문맥 전환 후, 새로운 TCB + 기존 레지스터 값 활용해서 새로운 태스크로 복귀합니다.

### naked 함수

- assembly코드를 직접 사용하기 위해 프로토타입에 다음과 같이 선언합니다.

```c
void xPortPendSVHandler( void ) __attribute__ (( naked ));
```

- **naked 함수의 특징**
  - 컴파일러가 함수 `프롤로그 / 에필로그`를 생성하지 않음
  - 스택 프레임 자동 저장/복원이 이루어지지 않음
  - 레지스터 보존에 대한 ABI 보장이 없음

> PendSV(문맥 전환용 인터럽트) 핸들러는 `직접 레지스터를 제어`해야 하므로 naked 함수로 구현됩니다.

### assembly 분석

> 분석에 불필요한 값은 생략했습니다. 사실 영문 주석으로 잘 달려있긴 합니다.

```c

   /* 문맥 전환 전 현재 레지스터의 상태를 메모리와 기존 TCB에 저장 */
   "   stmdb r0!, {r4-r11, r14}      \n" /* Save the core registers. */
   "   str r0, [r2]                  \n" /* Save the new top of stack into the first member of the TCB. */

   /* 문맥 전환(가장 우선순위 높은 Task 가져옴) */
   "   bl vTaskSwitchContext         \n"

   /* 문맥 전환 후 새로운 TCB를 가져옴 */
   "   ldr r1, [r3]                  \n" /* The first item in pxCurrentTCB is the task top of stack. */

   /* 새로운 TCB의 주소로 복귀 */
   "   bx r14                        \n"

```

### 문제 상황 재정리

- 원래 상황으로 돌아가서, 위 코드 맨위에 다른 함수를 호출한 경우를 보겠습니다.

```c
void xPortPendSVHandler( void )
{   // 함수가 처음 호출되면 LR에 EXC_RETURN(0xFFFFFFF5) 저장

   // 다른 함수 호출된 후 복귀되면서 LR에 ledoff()의 복귀 주소가 저장(오염)
   ledoff();

   /* 문맥 전환 전 현재 레지스터의 상태를 메모리와 기존 TCB에 저장
        => r14에 EXC_RETURN이 아닌 주소값 저장 */
   "   stmdb r0!, {r4-r11, r14}         \n"
   "   str r0, [r2]                     \n"

   /* 문맥 전환(가장 우선순위 높은 Task 가져옴) */
   "   bl vTaskSwitchContext            \n"

   /* 문맥 전환 후 새로운 TCB를 가져옴
         => 첫번째 호출시에는 EXC_RETURN 정상적으로 가져옴, 두번째 호출부터 복귀주소(오염된 값) 가져옴 */
   "   ldr r1, [r3]                     \n"

   /* 새로운 TCB의 주소로 복귀 */
   "   bx r14                           \n"
}
```

- 첫 번째 문맥 전환
  - 오염된 태스크로 아직 복귀하지 않으므로 정상 동작

- 두 번째 문맥 전환 시 `오염된 LR 값을 가진 태스크로 복귀` 시도
  - EXC_RETURN 규칙에 맞지 않는 값 사용
  - Bus Fault 발생

![situation2](situation2.png#center)

## 결론

- `ISR` + `naked` + `context switch`라는 특수한 상황 조건이 겹쳐서 발생한 오류였습니다.
  | STM32의 문맥 전환을 전반적으로 이해할 수 있는 좋은 예제인 것 같습니다.

> naked가 선언된 곳에는 **`절대 C 함수를 호출하지 말자!`**
