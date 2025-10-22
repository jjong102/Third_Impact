# 🚗 Highway Lane Following with RoadRunner Scenario Test Bench


> **MATLAB Simulink + RoadRunner Scenario 기반 차선 유지(Lane Following) 자율주행 시뮬레이션**

---

## 🧭 프로젝트 개요

이 프로젝트는 **MATLAB Simulink**와 **RoadRunner Scenario**를 이용해  
자율주행 차량의 **Lane Following Behavior(차선 유지 주행 알고리즘)**을 구현하고 테스트하기 위한 시스템입니다.  

기존의 고속도로 주행 시뮬레이션 환경을 확장하여, **Ego 차량이 도로 중심선을 따라 주행**하도록 제어하는 것을 목표로 합니다.

---

## 🧱 주요 구성 요소

### 🔹 RoadRunner 환경 구성
- `CurvedRoad.rrscene`, `StraightRoad.rrscene` : 곡선/직선 도로 시나리오
- `competition.rrscene` : 예선용 커스텀 시나리오
- `Assets/Markings` : 차선 및 도로 마킹 메타데이터
- `Assets/Behaviors` : Simulink에서 작성된 차량 행동 모델

### 🔹 Simulink 모델 구성 (`HighwayLaneFollowingRRTestBench.slx`)

| 블록 이름 | 역할 |
|------------|-------|
| **RoadRunner Scenario** | 시나리오 실행 및 Ego 차량·Actor 차량 관리 |
| **Ego Pose Reader / Actor Pose Reader** | 차량 위치 및 자세(Pose) 데이터 읽기 |
| **Lane Marker Detector** | 카메라 영상에서 차선 인식 |
| **Vision Vehicle Detector** | 카메라를 통한 차량 객체 탐지 |
| **Forward Vehicle Sensor Fusion** | 센서 융합(Fusion)을 통해 전방 차량 정보 통합 |
| **Lane Following Decision Logic** | 차선 유지/변경 등 판단 로직 수행 |
| **Lane Following Controller** | 조향각, 가속도 제어 등 실제 차량 제어 신호 계산 |
| **Vehicle Dynamics (Bicycle Model)** | 실제 차량 운동 방정식 기반 주행 시뮬레이션 |
| **Metrics Assessment** | 속도, 차선 이탈 여부, 가속도 등 성능 평가 |

---

## ⚙️ 동작 방식

1. **시나리오 로드 및 초기화**
   ```matlab
   rrApp = roadrunner(rrProjectPath);
   openScene(rrApp, "RoadRunner_Prelim");
   openScenario(rrApp, "RoadRunner_Prelim");
   ```

2. **시뮬레이션 설정**
   - 타임스텝(Ts = 0.01s)으로 설정

    -   Ego 차량의 목표 속도 v_set = 20 m/s
3. **시스템 연결 및 업데이트**
   ```matlab
    open_system("HighwayLaneFollowingRRTestBench")
    helperSLHighwayLaneFollowingWithRRSetup(rrApp, rrSim,   scenarioFileName="RoadRunner_Prelim")

    ```
4. **시뮬레이션 실행**
   ```matlab
    set(rrSim, SimulationCommand="Start")

    ```
5. **Ego 차량은 차선을 유지하며 주행**
- 차선 중심선(Lane Center)과 Ego 위치 비교
- Steering Angle 계산 → 차량 모델로 전달 → 주행 궤적 생성


## 🎯 목표 및 기대 효과

✅ **RoadRunner와 Simulink의 통합 이해 및 활용**  
✅ **자율주행 시스템의 센서 융합, 차선 인식, 차량 제어 전 과정 실습**  
✅ **예선용 RoadRunner 시나리오(`competition.rrscene`) 기반 차선 유지 제어 구현**  
✅ **향후 Lane Change, ACC(Adaptive Cruise Control) 등 확장 가능성 검증**

---

## 🖥️ 개발 환경

| 항목 | 내용 |
|------|------|
| **OS** | Windows 10 64-bit |
| **MATLAB** | R2025a |
| **Simulink** | Automated Driving Toolbox 포함 |
| **RoadRunner** | R2025a |
| **RoadRunner Project Path** | `C:\Matlab_RoadRunner_Scenario\competition` |

---

## 🏷️ Repository Tags

`MATLAB` `Simulink` `RoadRunner` `Autonomous Driving` `Lane Following`  
`Scenario Simulation` `Bicycle Model` `Sensor Fusion`

---
