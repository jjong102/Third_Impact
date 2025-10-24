# 본선 2차 — RoadRunner 자율주행 시뮬레이션 (final2)

> `Third_Impact_final2.mlx`(런처)와 `Third_Impact_final2.slx`(RoadRunner Behavior 제어 모델)를 **세세하게** 설명하고,  **차선이탈 방지 + 전방 차량 인식 + 자동 차선 변경**이 통합된 자율주행 시뮬레이션을 재현할 수 있도록 정리했습니다!

---
## 실행 영상
https://github.com/user-attachments/assets/e5bf20b4-b53e-46cf-94a6-a1721da3aa57

## 구현 사항
**RoadRunner 상에서 차선이탈 없이 주행하면서, 전방 차량을 감지할 경우 안전하게 차선을 변경하도록 구현**
| 항목 | 내용 |
|------|------|
| **시뮬레이션 환경** | RoadRunner `competition.rrscene` (2차선 도로) |
| **핵심 기능** | 차선 유지, 전방 차량 인식, 차선 변경 및 복귀 |
| **제어 알고리즘** | Pure Pursuit + PID Steering / Adaptive Speed 제어 |
| **추가 변수** | Adaptive Lookahead(`Ld`), 현재 차선 상태(`presentLane`) |
| **테스트 결과** | 전방 인식 및 차선 변경 성공, 복귀 구간에서 Steering Overshoot 관찰 |


## 구글 드라이브 파일 링크
https://drive.google.com/drive/folders/1MZrk5KygLa-TrtS4h8m7FX8dpd-CAfQZ?usp=sharing

## 1) Live Script (`Third_Impact_final2.mlx`) — 코드 라인별 설명

```matlab
clear all
clc
close all


load('map.mat')

global L Ld0 x_ref y_ref  x_ref2 y_ref2 presentLane count 
count = 0;
presentLane = 0;
L = 15;
Ld0 = 5;

x = trajectory_inside(:,1)';
y = trajectory_inside(:,2)';
t = [0, cumsum(sqrt(diff(x).^2 + diff(y).^2))]; 
t = t / t(end);
tq = linspace(0, 1, length(x)*10);
x_ref = interp1(t, x, tq, 'spline');
y_ref = interp1(t, y, tq, 'spline');

x2 = trajectory_outside(:,1)';
y2 = trajectory_outside(:,2)';
t2 = [0, cumsum(sqrt(diff(x2).^2 + diff(y2).^2))]; 
t2 = t2 / t2(end);
tq2 = linspace(0, 1, length(x2)*10);
x_ref2 = interp1(t2, x2, tq2, 'spline');
y_ref2 = interp1(t2, y2, tq2, 'spline');

rrAppPath = "C:\Program Files\RoadRunner R2025a\bin\win64";
rrProjectPath = "C:\Matlab_RoadRunner_Scenario\competition";

s = settings;
s.roadrunner.application.InstallationFolder.TemporaryValue = rrAppPath;
sceneName ='competition';
scenarioName = "competition";
% 로드러너에서의 behavior 이름
behaviorName = "behav";

rrApp = roadrunner(rrProjectPath);

openScene(rrApp, sceneName); % scene 파일명

openScenario(rrApp, scenarioName); % Scenario 파일명

rrSim = createSimulation(rrApp);
global Ts 
Ts = 0.01;
set(rrSim,StepSize=Ts)
open_system("Third_Impact_final2")
helperSLHighwayLaneFollowingWithRRSetup(rrApp,rrSim,scenarioFileName=scenarioName, behaviorName = behaviorName)
set_param("Third_Impact_final2",SimulationCommand="update")

presentLane = startLane;

set(rrSim, 'SimulationCommand','Start');
```

### 라인별 설명
  1. `clear all`
    - 워크스페이스 초기화.
  2. `clc`
    - 커맨드 윈도우 정리.
  3. `close all`
    - 열린 Figure 창 모두 닫기.
  6. `load('map.mat')`
    - 시뮬레이션에 필요한 데이터/맵 로드.
  8. `global L Ld0 x_ref y_ref  x_ref2 y_ref2 presentLane count`
    - 전역 변수 선언(제어 파라미터/참조 궤적 등).
 16. `t = [0, cumsum(sqrt(diff(x).^2 + diff(y).^2))];`
    - 아크길이/누적 거리 계산.
 18. `tq = linspace(0, 1, length(x)*10);`
    - 균일한 파라미터화/샘플 포인트 생성.
 19. `x_ref = interp1(t, x, tq, 'spline');`
    - 참조 경로를 보간하여 고해상도 궤적 생성.
 20. `y_ref = interp1(t, y, tq, 'spline');`
    - 참조 경로를 보간하여 고해상도 궤적 생성.
 24. `t2 = [0, cumsum(sqrt(diff(x2).^2 + diff(y2).^2))];`
    - 아크길이/누적 거리 계산.
 26. `tq2 = linspace(0, 1, length(x2)*10);`
    - 균일한 파라미터화/샘플 포인트 생성.
 27. `x_ref2 = interp1(t2, x2, tq2, 'spline');`
    - 참조 경로를 보간하여 고해상도 궤적 생성.
 28. `y_ref2 = interp1(t2, y2, tq2, 'spline');`
    - 참조 경로를 보간하여 고해상도 궤적 생성.
 30. `rrAppPath = "C:\Program Files\RoadRunner R2025a\bin\win64";`
    - — MATLAB 경로 설정
 31. `rrProjectPath = "C:\Matlab_RoadRunner_Scenario\competition";`
    - — Project파일 경로 설정
 40. `rrApp = roadrunner(rrProjectPath);`
    - RoadRunner 인스턴스 생성 및 연결.
 42. `openScene(rrApp, sceneName); % scene 파일명`
    - 지정한 Scene 열기.
 44. `openScenario(rrApp, scenarioName); % Scenario 파일명`
    - 지정한 Scenario 열기.
 46. `rrSim = createSimulation(rrApp);`
    - RoadRunner 시뮬레이션 컨텍스트 생성.
 47. `global Ts`
    - 전역 변수 선언(제어 파라미터/참조 궤적 등).
 48. `Ts = 0.01;`
    - — 샘플링 시간 설정
 49. `set(rrSim,StepSize=Ts)`
    - RoadRunner 시뮬레이션 스텝시간을 Ts로 설정.
 50. `open_system("Third_Impact_final2")`
    - Behavior Simulink 모델 열기.
 51. `helperSLHighwayLaneFollowingWithRRSetup(rrApp,rrSim,scenarioFileName=scenarioName, behaviorName = behaviorName)`
    - RR-Behavior 매핑/센서 경로 설정 헬퍼 호출.
 52. `set_param("Third_Impact_final2",SimulationCommand="update")`
    - 모델 업데이트(변경사항 적용).
 56. `set(rrSim, 'SimulationCommand','Start');`
    - RoadRunner 시뮬레이션 시작.
 62. `%set(rrSim, 'SimulationCommand', 'Start')`
    - RoadRunner 시뮬레이션 시작.
---

## 2️⃣ Simulink Behavior (`Third_Impact_final2.slx`) — Top-Level 구조
![alt text](images/main.png)
---

### 2.1 블록 인벤토리

| SID | Block Name | BlockType | MaskType | 역할 |
|------|-------------|------------|-----------|------|
| 4948 | RoadRunner Scenario | Reference |  | RR 시나리오 인터페이스 |
| 4946 | Ego Pose Reader | Reference |  | RR로부터 Ego Pose 수신 |
| 4271 | Receive | Receive |  | RR → Simulink 데이터 수신 |
| 4896 | Sensors and Vehicles | SubSystem |  | RR 차량/센서 정보 집약 |
| 5196 | Interpreted MATLAB Function | MATLABFcn |  | 차선 변경 판단 로직 |
| 5114 | speed | SubSystem |  | 종방향 제어 (가속/감속) |
| 5143 | steering | SubSystem |  | 횡방향 제어 (조향) |
| 5098 | Vehicle Dynamics | SubSystem |  | 차량 동역학 계산 |
| 4321 | Pack Ego Pose | SubSystem |  | 차량 상태 Bus 패킹 |
| 4949 | Ego Pose Writer | Reference |  | RR로 차량 명령 전송 |

---

### 2.2 신호 연결 (From → To)

| From (block:port) | To (block:port) | 설명 |
|--------------------|------------------|------|
| Ego Pose Reader:1 | Receive:1 | RR Ego Pose 수신 |
| Receive:1 | Sensors and Vehicles:1 | Ego Pose → 센서 입력 |
| Sensors and Vehicles | Mux | 주변 차량 데이터 병합 |
| Mux | Interpreted MATLAB Function | 전방 차량 거리 기반 차선 변경 판단 |
| Interpreted MATLAB Function | steering/speed | 제어 명령 생성 |
| speed/steering | Vehicle Dynamics | 가속/조향 입력 |
| Vehicle Dynamics | Pack Ego Pose | 차량 상태 갱신 |
| Pack Ego Pose | Send | RR로 전송 |
| Send | Ego Pose Writer | RR 시나리오 내 Behavior 반영 |

---

## 3️⃣ 주요 서브시스템
### Sensors and Vehicles Subsystem
- **구성 목적:** RoadRunner와 Simulink 간의 **Ego 및 주변 차량(Actors)** 위치, 자세(Pose)를 실시간 동기화  
- **핵심 역할:** Ego 차량과 5대의 주변 차량을 3D 시뮬레이션 공간에 배치하고, 각 차량의 좌표를 변환하여 시각화  
- **모델 개요:**
  - `Simulation 3D Scene Configuration` : 3D 환경 설정 및 Scene 로딩  
  - `HelperConvert DSPoseToSim3D` : RoadRunner 좌표계를 Simulink 3D 모델 좌표계로 변환  
  - `Simulation 3D Vehicle with Ground Following (1~6)` : Ego 및 주변 차량(총 6대)의 주행 모델  
  - 각 차량별 색상, 초기 위치, 회전 정보(`InitialPos`, `InitialRot`) 설정  
  - `poseOfEgoVehicle` : Ego 차량의 위치를 Vehicle Dynamics 블록으로 전달

### Steering Subsystem
- **제어 방식:** Pure Pursuit + PID 혼합 제어  
- **특징:** Adaptive Lookahead(`Ld`)로 곡선 구간 안정성 확보  
- **추가 기능:** 차선 변경 중 yaw rate 과도 억제  

---

### Speed Subsystem
- 전방 차량과의 거리(`front_vehicle_dist`)를 기반으로 속도 제어  
- Sigmoid 기반 가감속 적용 → **jerk 최소화 및 부드러운 추월 동작**  

---

### Vehicle Dynamics
- SAE J670 표준 **Bicycle Model** 기반  
- 입력: Steering Angle, Acceleration  
- 출력: Longitudinal / Lateral Velocity, Yaw Rate  
- 실제 차량과 유사한 동역학 반응 구현  

---

### Pack Ego Pose
- 차량 Pose를 Bus 신호(`BusVehiclePose`, `BusActorPose`)로 변환  
- RoadRunner `Ego Pose Writer`로 **실시간 전송 및 상태 반영**

---

## 실행 방법

1. `Third_Impact_final2.mlx` 파일에서 **프로젝트 경로(`rrProjectPath`)**를 환경에 맞게 수정  
2. `Third_Impact_final2.slx`를 RoadRunner의 **Behavior 설정**에 등록  
3. MATLAB에서 `.mlx` 전체 실행 → RoadRunner가 자동 실행되어 시뮬레이션 시작  

---

## 실험 결과 및 분석

| 항목 | 측정 결과 |
|------|------------|
| **차선 변경 성공률** | 80% (5회 중 4회 성공) |
| **복귀 안정성** | 1회 Overshoot 발생 (차선 가장자리에 근접) |
| **평균 FPS** | 약 45 |
| **횡오차 (Lateral Error)** | 정상 주행 시 0.3m 이하, 복귀 순간 최대 0.65m |

---

### 결과 분석
- 전방 차량 감지 및 차선 변경은 **모든 시나리오에서 정상 작동**  
- 복귀 시 곡률 급변 구간에서 **조향 포화로 인한 Overshoot 발생**  
- Pure Pursuit 제어의 **고정 Lookahead(`Ld0`) 한계**로 인한 것으로 분석됨  

---

## ⚠️ 테스트 중 관찰된 현상 및 개선 계획

### 현상
차선 변경 후 복귀 구간에서 steering overshoot로 인해  
차량이 차선 가장자리에 근접하거나 살짝 이탈  

### 분석
- 고정 Lookahead(`Ld0`)로 인해 곡률 변화에 따라 조향 과입력 발생  
- Vehicle Dynamics의 **inertia 반응 지연**으로 steering overshoot 확대  

### 개선 계획
- Adaptive Lookahead 적용 (커브 구간에서 `Ld` 자동 증가)  
- PID 제어기 **D항 감쇠** → Overshoot 완화  
- Reference 전환 구간에 **Smoothing Zone(보간 구간)** 추가  

> *이는 단순한 제어 실패가 아니라 실제 차량의 물리적 한계를 재현한 거동으로 해석됩니다.  
> 이후 Adaptive Steering 보정 로직을 적용하여 완전한 복귀 제어를 구현할 예정입니다.*

---

## 향후 개선 방향

- 다중 차량 인식 및 **Lane Merge 대응 기능 추가**  
- **강화학습 기반 차선 변경 의사결정 구조** 설계  
- RoadRunner **Radar Sensor 연동**으로 객체 감지 정밀도 향상  

---
