# Pixel Studio 3D

브라우저에서 기본 3D 메시를 조립하고, 사람이 직접 변형하거나 JSON 명령으로 모델을 편집하는 독립형 스튜디오입니다. Pixel Studio(2D 픽셀 편집기) 및 Pixel Motion Studio(GIF 편집기)와는 별도 서브프로젝트이며 서로의 코드나 데이터 형식을 공유하지 않습니다.

## 실행

Three.js와 OrbitControls/TransformControls를 같은 jsDelivr CDN 버전에서 가져옵니다. 따라서 Node나 빌드는 필요하지 않지만 네트워크 연결과 정적 HTTP 서버가 필요합니다. `index.html`을 `file://`로 직접 열지 마세요(브라우저 모듈/CORS 정책). 저장소 루트에서 아래처럼 실행한 뒤 `http://localhost:8000/SubProjects/PixelStudio3D/`로 접속할 수 있습니다.

```powershell
python -m http.server 8000
```

## 현재 편집 기능

- 큐브, 구, 원기둥, 원뿔, 도넛 기본 메시 추가
- 뷰포트에서 선택, 카메라 궤도/이동/확대, 이동·회전·크기 기즈모, 수치 기반 변환, 색상 편집
- 구/원기둥/원뿔/도넛의 분할 수와 기본 도형 치수 조절
- PNG/JPG/WEBP 참조 이미지를 투명도 조절 오버레이로 표시. 참조는 모델 파일이나 내보내는 데이터에 삽입되지 않음
- 모델 단위, 작업 부피 경계, 그리드/축/배경 설정
- JSON 모델 내보내기/불러오기, 명령 JSON 붙여넣기, 로컬 자동 저장, Ctrl+Z/Ctrl+Y
- 다크 UI. 표시 전용 배경색은 배경 버튼을 눌러 순환

## 정확한 범위

이 버전은 **기본 메시 조립형 블록아웃 도구**입니다. 임의의 버텍스/엣지/면 토폴로지를 직접 깎는 sculpt/mesh 편집기, 2D 이미지로부터 자동 3D 재구성, 내장 AI 모델 호출, 텍스처 페인팅, 애니메이션 재생/내보내기는 아직 포함하지 않습니다. 현재의 AI 워크플로는 사용자가 참조 이미지를 표시하고, 이 문서의 JSON 명령 규격을 AI에게 제공한 다음 생성한 명령을 JSON 패널에 붙여 넣어 적용하는 방식입니다. 필요하면 사람이 같은 장면에서 직접 수정하고 다시 내보낼 수 있습니다.

모델의 부피는 `settings.bounds`에 기록되는 작업 기준 경계이며, 메시 치수/스케일과 구분됩니다. 여러 오브젝트가 겹치거나 경계 밖으로 나갈 수 있으므로 현재 경계가 자동으로 실제 솔리드 부피를 제한하거나 계산하지는 않습니다. polygon density는 primitive별 세그먼트 개수로 표현되며, 높은 숫자는 더 둥근 표면과 더 많은 삼각형을 만듭니다. 화면의 삼각형 숫자는 렌더 메시의 근사 지표입니다.

## 프로젝트 JSON: `pixel-studio-3d-project` v1

```json
{
  "format": "pixel-studio-3d-project",
  "version": 1,
  "name": "샘플 모델",
  "settings": {
    "unit": "unit",
    "bounds": { "x": 8, "y": 10, "z": 8 },
    "background": "#22242e",
    "grid": true,
    "axes": true
  },
  "objects": [
    {
      "id": "head",
      "name": "머리",
      "type": "sphere",
      "color": "#f3c8c8",
      "position": { "x": 0, "y": 2.5, "z": 0 },
      "rotation": { "x": 0, "y": 0, "z": 0 },
      "scale": { "x": 0.9, "y": 1, "z": 0.8 },
      "geometry": { "radius": 0.7, "widthSegments": 20, "heightSegments": 14 }
    }
  ]
}
```

`position`은 모델 좌표, `rotation`은 도(degree), `scale`은 양수 축별 배율입니다. 색상은 불투명 `#RRGGBB`입니다. 현재 도형별 geometry 키:

| type | geometry 치수 및 밀도 |
| --- | --- |
| `box` | `width`, `height`, `depth` |
| `sphere` | `radius`, `widthSegments`, `heightSegments` |
| `cylinder` | `radiusTop`, `radiusBottom`, `height`, `radialSegments` |
| `cone` | `radius`, `height`, `radialSegments` |
| `torus` | `radius`, `tube`, `radialSegments`, `tubularSegments` |

분할 수는 3–128, 모델은 최대 500개 오브젝트, 명령 문서는 최대 10,000개 명령입니다. 화면 참조 이미지, 카메라 위치, 현재 선택, 실행 취소 기록은 모델 파일에 포함되지 않습니다.

## AI 명령 JSON: `pixel-studio-3d-commands` v1

```json
{
  "format": "pixel-studio-3d-commands",
  "version": 1,
  "settings": {
    "unit": "unit",
    "bounds": { "x": 8, "y": 10, "z": 8 },
    "grid": true,
    "axes": true
  },
  "commands": [
    {
      "op": "addPrimitive",
      "id": "body",
      "name": "몸통",
      "type": "cone",
      "color": "#8db8e8",
      "position": { "x": 0, "y": 1, "z": 0 },
      "rotation": { "x": 0, "y": 0, "z": 0 },
      "scale": { "x": 1.2, "y": 1.5, "z": 0.8 },
      "geometry": { "radius": 0.7, "height": 1.5, "radialSegments": 12 }
    },
    { "op": "setMaterial", "id": "body", "color": "#7fa8d8" }
  ]
}
```

| op | 필수 필드 | 동작 |
| --- | --- | --- |
| `addPrimitive` | `type`, 선택 `id` | 기본 메시 추가. `geometry`, `position`, `rotation`, `scale`, `color`, `name`은 선택 |
| `setTransform` | `id` | 지정된 위치/회전/크기 축만 변경 |
| `setMaterial` | `id`, `color` | 오브젝트 색상 변경 |
| `setGeometry` | `id`, `geometry` | 해당 primitive 치수 또는 분할 밀도 변경 |
| `removeObject` | `id` | 오브젝트 삭제 |
| `clear` | 없음 | 모든 메시 삭제 |

모든 명령은 적용 전에 검증됩니다. 잘못된 명령은 장면에 부분 적용되지 않습니다. 작업 부피 `bounds`와 물체 위치/크기는 별도 설정입니다. AI에게 반복 수정을 맡길 때는 현재 모델 JSON을 함께 제공하고, 참조 이미지와 정면/측면 등 비교 관점을 알려 주며, 바뀔 오브젝트의 안정적인 `id`를 유지하도록 지시하세요.

### AI 작업 프롬프트 예

> 아래 Pixel Studio 3D v1 규격에 맞는 `pixel-studio-3d-commands` JSON만 작성해 주세요. 참조 이미지에서 읽을 수 있는 실루엣과 색 덩어리를 기본 메시들로 근사하고, 정면(+Z), 위(+Y) 기준을 사용합니다. 기존 장면이 있으면 기존 id를 유지하고 필요한 항목만 수정하세요. 좌표·회전·크기·세그먼트를 유효 범위로 쓰고 지원되지 않는 op나 메시 type은 만들지 마세요. 제가 뷰포트와 레퍼런스를 대조한 뒤 현재 모델 JSON과 수정 사항을 다시 주면 다음 수정 명령을 작성하세요.

## 애니메이션 확장 방향 (미구현)

후속 버전은 동일한 오브젝트 `id`와 transform 명령을 프레임별 키프레임에서 재사용하는 `pixel-studio-3d-animation` 형식을 추가할 수 있습니다. 제안 스키마는 `{format, version, fps, loop, frames:[{duration, commands:[...] }]}`입니다. 프레임 간 오브젝트 추가/삭제 정책, 보간, 재생 및 GLTF/영상 내보내기를 정한 뒤 별도 버전으로 구현합니다. 현재 프로젝트 JSON에는 애니메이션 필드가 없고, 타임라인 재생도 지원하지 않습니다.

## 파일 구성

- `index.html`: 편집기 구조와 Three.js CDN import map
- `app.js`: 3D scene, 메시 생성, UI 상호작용, 검증/JSON/저장
- `styles.css`: 스튜디오 UI와 반응형 레이아웃
- `README.md`: 사용자와 AI를 위한 인터페이스 규격
- `AGENTS.md`: 코드 유지보수용 에이전트 핸드오프

라이브러리: Three.js (MIT License), CDN은 jsDelivr. 네트워크 연결이 없으면 3D 런타임 모듈을 불러오지 못합니다. 프로젝트는 부모 Git 저장소에서 무시됩니다. 독립 저장소로 만들려면 이 폴더에서 별도 Git 저장소를 초기화하세요.

## Dahlia example and model versions

Character model experiments live under `examples/<Character>/vN/`, with `model.json`, a `reference/` image folder, and a version README. The first test is `examples/Dahlia/v1/`. Its reference PNG is the closest similar angel pixel-art asset already in the local archive, not the exact newly attached source image. A later original source image can be added as a separately named file without replacing this provenance record.

The editor now supports `polygon` as a thick extruded planar silhouette. Its `geometry` contains `points: [[x,y], ...]`, `depth`, `bevelSize`, and `bevelSegments`; coordinates are local XY, extrusion goes toward +Z. The inspector edits numeric depth/bevel values and JSON edits the outline. Polygon outlines validate at 3–512 finite points, local coordinate bounds -100..100, and nonzero signed area. Negative scale is permitted for mirrored parts, while near-zero scale is rejected.

Use simple non-self-intersecting outlines. `polygon` is intended for silhouette pieces such as hair, clothing panels, and wings. Its segment count changes bevel smoothness; the outline itself is defined by its ordered points.

AI command example for an extruded wing silhouette:

```json
{
  "format": "pixel-studio-3d-commands",
  "version": 1,
  "commands": [{
    "op": "addPrimitive",
    "id": "wing-left",
    "name": "Left wing",
    "type": "polygon",
    "color": "#dceaff",
    "position": { "x": -1.2, "y": 2.4, "z": -0.3 },
    "rotation": { "x": 0, "y": 0, "z": 15 },
    "scale": { "x": 1, "y": 1, "z": 1 },
    "geometry": {
      "points": [[0,0],[-0.5,0.3],[-1.6,0.9],[-1.2,0.3],[-1.8,0.2],[-1.1,-0.3],[-0.4,-0.6]],
      "depth": 0.18,
      "bevelSize": 0.04,
      "bevelSegments": 3
    }
  }]
}
```

The reviewed Dahlia v1 viewport capture is `examples/Dahlia/v1/studio-preview.png`.

Click **Dahlia v1 열기** in the left scene panel to load the model JSON, display its bundled reference overlay, and frame a front view. This is a model-blockout exercise with editable separate parts, not image-to-3D reconstruction.

## Windows local server

Run ./serve.ps1 from this folder and open http://127.0.0.1:8000/. If execution policy blocks the script, use powershell -NoProfile -ExecutionPolicy Bypass -File .\serve.ps1. On other platforms, use python -m http.server 8000 and open /SubProjects/PixelStudio3D/ from the parent project server.
