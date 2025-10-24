# Third_Impact 자율주행 경진대회 기술발표 레포트

---

## 1. 기본 정보  
- **팀명:** Third_Impact  
- **소속:** 인천대학교 임베디드시스템공학과  
- **팀원:**  
  - 이원종 (3학년 / 학부) — leewon102@inu.ac.kr  
  - 이석빈 (4학년 / 학부) — lsbin11@inu.ac.kr  
  - 박소윤 (4학년 / 학부) — asz1218@inu.ac.kr  

---

## 2. 연구/개발 주제 개요  

- **프로젝트 제목:** RoadRunner 기반 자율주행 차량의 차선 유지 및 차선 변경 제어 시스템  
- **개발 목표:**  
  RoadRunner와 MATLAB/Simulink 환경을 연동하여,  
  Ego 차량이 전방 차량을 인식하고 차선이탈 없이 안전하게 추월 및 복귀할 수 있는 자율주행 제어 알고리즘을 구현한다.  

- **연구 배경 및 필요성:**  
  최근 자율주행 기술은 차선 유지(Lane Keeping)뿐 아니라 상황 인식 기반의 동적 의사결정(Lane Change, Merge 등)이 필수적으로 요구되고 있다.  
  특히, 제한된 가상 환경(RoadRunner) 내에서 안정적인 차량 제어와 실제 차량에 가까운 물리 모델을 구현하는 것은 차량 제어 알고리즘의 검증에 중요한 단계이다.  
  본 프로젝트는 이러한 목적을 위해, Pure Pursuit 기반 제어 구조를 확장하여 전방 차량 감지와 차선 변경을 결합한 시뮬레이션 시스템을 개발하였다.

---
## 3. 실행 영상 및 본선 단계별 상세 내용 안내 
https://github.com/user-attachments/assets/e5bf20b4-b53e-46cf-94a6-a1721da3aa57

본 프로젝트는 **본선 1차**와 **본선 2차** 두 단계로 나누어 개발 및 검증을 진행하였습니다.  
각 단계의 세부 구현 내용, Simulink 구조, 코드 설명은 아래 링크에서 확인할 수 있습니다.

| 단계 | 내용 | 링크 |
|------|------|------|
| **본선 1차** | 기본 차선 유지 및 Ego 차량 안정 주행 구현 (RoadRunner–Simulink 연동 기반) | [👉 본선 1차 기술 설명 보기](https://github.com/jjong102/Third_Impact/tree/main/final(1)) |
| **본선 2차** | 전방 차량 인식 + 차선 변경 + 복귀 통합 자율주행 시스템 | [👉 본선 2차 기술 설명 보기](https://github.com/jjong102/Third_Impact/tree/main/final(2)) |


## 4. 시스템 구조 및 설계  

- **전체 시스템 블록 다이어그램:**  
  RoadRunner – Simulink 연동 구조로 구성  
  1. RoadRunner Scenario에서 Ego 및 주변 차량 데이터 생성  
  2. Simulink `Third_Impact_final2.slx`에서 제어 알고리즘 수행  
  3. Vehicle Dynamics 블록에서 실제 차량 물리 반응 계산  
  4. Ego Pose Writer를 통해 RoadRunner 내 차량 거동 반영  

- **사용 툴박스/프레임워크:**  
  - MATLAB R2025a  
  - RoadRunner R2025a  
  - Automated Driving Toolbox  
  - Vehicle Dynamics Blockset  

- **알고리즘 설계 개요:**  
  - **차선 인식 및 유지 방법:**  
    Pure Pursuit 기반으로 Lane Centerline을 참조 궤적으로 설정, Lateral Error를 최소화하는 조향 제어 구현  
  - **차선 변경 / Planner 로직:**  
    전방 차량의 거리(`front_vehicle_dist`)를 지속적으로 계산하여 일정 임계값 이하일 경우 차선 변경 요청 신호 생성  
    Interpreted MATLAB Function 블록에서 판단 수행  
  - **장애물 회피 및 경로 재계산 방법:**  
    차선 변경 시 보조 참조 궤적(`x_ref2`, `y_ref2`)으로 전환, 경로 보간(`spline`)을 통해 자연스러운 궤적 전환 구현  
  - **Cut-in 대응 전략:**  
    차선 변경 후 일정 시간 동안 Lookahead Distance를 확장하여 급격한 조향 변화 억제  
  - **기타 구현 기능:**  
    Adaptive Lookahead, Sigmoid 속도 제어, Overshoot 억제 PID 조정  

---

## 5. 실험 환경 및 시뮬레이션 설정  

- **RoadRunner 시뮬레이션 환경:**  
  - 맵: `competition.rrscene`  
  - 시나리오: 직선 및 완만한 곡선 구간 포함  
  - Ego 차량 1대, 주변 Actor 차량 5대 배치 (정적/동적 혼합)  
  - 각 차량은 색상 및 위치가 다르게 초기화되어 시각적 식별 가능  

- **차량 모델 및 센서 구성:**  
  - Vision Sensor 기반 Actor Pose Reader 사용  
  - RoadRunner Scenario Reader/Writer를 통해 Ego 및 Actor Pose 송수신  
  - Sensor 및 Dynamics 데이터는 Simulink Bus 신호로 변환  

- **주요 시뮬레이션 시나리오:**  
  - **시나리오 1:** 직선 구간 차선 유지  
  - **시나리오 2:** 전방 차량 추월 및 차선 변경  
  - **시나리오 3:** 차선 복귀 및 안정화  

---

## 6. 성능 평가  

- **평가 지표 및 기준:**  
  - 차선 유지 정확도 (Lateral Error, ±m 단위)  
  - 차선 변경 성공률 (%)  
  - 주행 안정성 (Yaw Rate Overshoot 여부)  
  - 평균 FPS (시뮬레이션 실시간성)  

- **실험 결과 표:**  

| 항목 | 결과 |
|------|------|
| 차선 유지 오차 | ±0.3 m (평균) |
| 차선 변경 성공률 | 80% (5회 중 4회 성공) |
| 복귀 구간 안정성 | Overshoot 1회 발생 (차선 가장자리에 근접) |
| 평균 FPS | 약 45 |
| 시뮬레이션 시간 | 약 60초 내외 / 1회 |

- **결과 분석:**  
  전방 차량 감지 및 차선 변경 판단은 정상적으로 작동하였으며, 복귀 구간에서 Steering Overshoot가 한 차례 발생하였다.  
  이는 고정된 Lookahead Distance의 한계와 Vehicle Dynamics의 반응 지연으로 분석된다.  
  Adaptive Lookahead와 PID D항 감쇠를 적용함으로써 추후 복귀 안정성을 개선할 수 있음을 확인하였다.

---

## 7. 기술적 기여 및 차별점  

- **기존 기본 예제와의 차별성:**  
  - 기본 Highway Lane Following 예제는 차선 유지만 수행  
  - 본 프로젝트는 차선 유지 + 전방 차량 인식 + 차선 변경 및 복귀까지 확장  

- **제안 알고리즘의 장점:**  
  - Pure Pursuit 기반 구조 유지 → 실시간성 및 단순성 확보  
  - Adaptive Lookahead 적용으로 곡선 구간 안정성 향상  
  - Sigmoid 가속 프로파일을 통한 부드러운 추월 구현  

- **한계점 및 개선 방향:**  
  - 복귀 구간에서 Steering Overshoot가 발생함  
  - 강화학습 기반 동적 Lookahead 조정 알고리즘 도입 필요  
  - Radar 센서 연동으로 객체 인식 정확도 향상 예정  

---

## 8. 결론 및 향후 계획  

- **최종 성과 요약:**  
  RoadRunner와 Simulink를 연동하여 차선 유지, 전방 인식, 차선 변경이 통합된 자율주행 제어 시스템을 구현하였다.  
  주행 중 차선 이탈 없이 전방 차량을 회피하며 안정적인 궤적 복귀를 확인하였다.  

- **대회 이후 연구 확장 가능성:**  
  - 강화학습 기반 Adaptive Steering 보정 알고리즘 적용  
  - 실제 차량 플랫폼(Arduino/ROS2)으로의 이식 실험  
  - 다양한 시나리오(곡선, 교차로, merging)에 대한 테스트 확장  

---

## 9. 참고문헌 및 자료  

1. MathWorks Documentation — [Highway Lane Following with RoadRunner Scenario (R2025a)](https://kr.mathworks.com/help/driving/ug/highway-lane-following-with-roadrunner-scenario.html)  
2. MathWorks Documentation — [Automated Driving Toolbox User’s Guide (R2025a)](https://kr.mathworks.com/help/driving/index.html)  


---
