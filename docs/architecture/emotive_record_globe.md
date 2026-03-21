# Emotive Record Globe

## Goal

`Record` 홈의 지구본은 지도 탐색 위젯이 아니라 앱의 대표 장면이어야 한다.  
하지만 단순한 static hero image로 가면 사용자가 지구본을 돌리고 나라를 선택하는 핵심 상호작용을 잃는다.

그래서 방향은 `감성 우선 3D globe`다.

- 라이트 모드: 종이, 수채화, 여행 수집물 같은 감성
- 다크 모드: 야경, 우주, 궤도, 항로 같은 감성
- 유지할 기능: 회전, 포커스, 나라 선택, 방문 경로 강조

## Design Principle

1. 인터랙션은 3D, 비주얼은 일러스트처럼 보이게 만든다.
2. 국가 경계선과 기술적인 메시 라인은 전면에서 드러나지 않게 한다.
3. 홈에서는 데이터 정확도보다 "여행을 다시 펼쳐보는 경험"을 우선한다.
4. 정확한 지리 정보 탐색은 플래너/상세 화면으로 넘긴다.

## Current Problem

현재 구현은 구 메시 위에 지구 텍스처를 직접 입히는 방식이라 회전과 드래그는 되지만, 감성 연출과 국가 선택 레이어가 섞여 있다.

- 렌더링 레이어와 인터랙션 레이어가 분리되어 있지 않다.
- 나라 선택을 위한 hit target 모델이 없다.
- 여행 경로가 감성적 arc로 설계되어 있지 않다.
- 라이트/다크 모드가 단순 색감 차이에 가까워서 장면의 성격이 분명하지 않다.

## Target Architecture

지구본을 4개 레이어로 나눈다.

### 1. Sphere Core

역할:
- 구 표면 렌더링
- yaw/pitch 회전
- 자동 회전 / 관성 / 드래그
- 앞면/뒷면 판정

구현:
- 현재 `RecordGlobe`의 회전 상태와 mesh 기반 투영 로직을 유지
- 다만 이 레이어는 "지구를 그리는 일"만 담당한다

### 2. Visual Skin

역할:
- 라이트/다크 모드의 감성 차별화
- 육지/해양/atmosphere/종이 질감/야경 발광 연출

라이트 모드:
- 수채화 해양
- 녹색 육지의 손그림 질감
- 흐린 paper grain
- 구름, 비행기, 여행 오브젝트는 sphere 밖 보조 연출

다크 모드:
- night earth base
- 도시광과 바깥 atmosphere glow
- 별과 항로선, 얇은 오로라 계열 glow

원칙:
- 국가 경계 overlay를 전면 노출하지 않는다
- 격자, border, hard stroke를 줄이고 silhouette 위주로 간다

### 3. Story Overlay

역할:
- 방문 국가 마커
- 여행 arc
- 선택된 국가 halo
- 최근 여행 포커스

구성:
- `Anchor`: 나라별 대표 지점
- `Arc`: 여행 흐름을 잇는 부드러운 연결선
- `Marker`: 도시/국가/현재 선택 상태

규칙:
- 홈에서는 모든 도시를 다 찍지 않는다
- 최근성, 방문 횟수, 대표성 기준으로 밀도를 제어한다
- 앞면에 있는 anchor만 강하게 보여주고 뒷면 것은 약하게 숨긴다

### 4. Interaction Layer

역할:
- drag rotate
- tap to select country
- focus to country
- selected country -> archive/detail 연결

원칙:
- 첫 단계에서는 `대표 anchor 기반 선택`으로 시작한다
- 이후 필요하면 `country polygon hit test`를 추가한다

이유:
- 감성 우선 홈에서는 polygon 정밀도보다 선택 안정성이 더 중요하다
- 방문 국가 중심 선택만으로도 UX의 80%를 확보할 수 있다

## Data Model

렌더러는 앱 상태를 직접 읽지 않는다.  
`recordGlobeSceneProvider`가 홈용 scene 모델을 만든다.

Scene은 다음 정보를 가진다.

- `style`: 라이트/다크 비주얼 스타일
- `initialCountryCode`: 첫 포커스 나라
- `anchors`: 국가 대표 포인트들
- `arcs`: 여행 흐름 연결선
- `selectableCountryCodes`: 선택 가능한 나라들

Anchor는 다음 정보를 가진다.

- 나라 코드/이름
- 대표 latitude/longitude
- 마커 개수
- 강조도
- 색상
- 예정 여행 여부

Arc는 다음 정보를 가진다.

- 시작/도착 국가
- 시작/도착 좌표
- 색상
- weight
- 예정/지난 여행 여부

## Scene Mapping Rule

### Anchor 생성

1. `RecordTrip.locations`에서 국가별 위치를 모은다.
2. 같은 나라의 좌표를 평균내거나 첫 대표 도시를 쓴다.
3. markerCount는 그 나라와 연결된 location 수를 쓴다.
4. emphasis는 다음 합으로 계산한다.

- 방문 횟수
- 최근성
- 현재/최근 trip 포함 여부
- upcoming 여부

### Arc 생성

trip 단위로 location 순서를 따라간다.

- 같은 trip 안에서 연속 location을 arc로 연결
- 같은 나라 연속은 생략
- 너무 많은 arc는 상위 N개만 유지
- 다크 모드에서는 glow를 강하게, 라이트 모드에서는 연필/잉크 같은 얇은 선으로 처리

## Visual Direction

### Light

- "수집한 여행 스크랩북"
- 파란 종이 하늘
- 종이 grain
- 부드러운 그림자
- marker는 작은 stamp나 pin처럼
- arc는 너무 기술적으로 보이지 않게 연한 잉크선으로

### Dark

- "우주에서 다시 읽는 여행 궤도"
- deep navy + black
- 도시광 중심
- 선택 국가 halo
- arc는 발광이 있지만 네트워크 데모처럼 과하지 않게

## Interaction Flow

1. 홈 진입 시 마지막/최근 나라로 부드럽게 포커스
2. idle 상태에서는 아주 느린 auto rotate
3. 사용자가 drag 하면 auto rotate 중지
4. 국가 anchor를 탭하면:
   - 해당 국가로 카메라 easing
   - halo/marker 강조
   - 하단 카드나 sheet로 해당 국가 요약 표시
5. 국가 카드 탭 시 archive/country detail로 이동

## Implementation Phases

### Phase 1

- Scene 모델 도입
- anchor/arc provider 분리
- 현재 globe 렌더러가 scene을 읽도록 변경

### Phase 2

- border overlay 제거 또는 극약화
- 라이트/다크 전용 skin 정리
- anchor marker와 selected halo 추가

### Phase 3

- arc 렌더링 추가
- 앞면/뒷면에 따른 alpha 조절
- country focus transition 추가

### Phase 4

- 선택 UI 연결
- country detail navigation
- 밀도 제한, marker clustering, 성능 튜닝

## Non-Goals

- 홈 지구본에서 모든 국가의 정확한 행정 경계를 완벽하게 클릭 가능하게 만드는 것
- Google Earth 수준의 zoom/tilt
- 플래너/상세 화면을 대체하는 정밀 지도 기능

## Recommendation

지금 이 프로젝트는 static으로 교체하지 않는다.  
대신 현재 globe를 `scene-driven emotive 3D hero`로 재구성한다.

즉:

- 기술 데모형 3D globe가 아니라
- 여행 무드 중심의 선택 가능한 지구본

이 방향이 제품 감성과 상호작용 둘 다 지킬 수 있는 최적해다.
