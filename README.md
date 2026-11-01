# Pixel Studio 3D

브라우저에서 기본 3D 메시를 조립하고, 사람이 직접 변형하거나 JSON 명령으로 모델을 편집하는 독립형 스튜디오입니다. Pixel Studio(2D 픽셀 편집기) 및 Pixel Motion Studio(GIF 편집기)와는 별도 서브프로젝트이며 서로의 코드나 데이터 형식을 공유하지 않습니다.

## 실행

Three.js와 OrbitControls/TransformControls를 같은 jsDelivr CDN 버전에서 가져옵니다. 따라서 Node나 빌드는 필요하지 않지만 네트워크 연결과 정적 HTTP 서버가 필요합니다. `index.html`을 `file://`로 직접 열지 마세요(브라우저 모듈/CORS 정책). Windows에서는 아래 PowerShell 서버를 실행하고 `http://127.0.0.1:8000/`으로 접속합니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\serve.ps1
```

## 현재 편집 기능

- 큐브, 구, 원기둥, 원뿔, 도넛 메시, 스무딩 윤곽 extrusion, 3D Catmull–Rom 튜브 추가
- 뷰포트에서 선택, 카메라 궤도/이동/확대, 이동·회전·크기 기즈모, 수치 기반 변환, 색상 편집
- 기본 메시 분할 수와 치수, 윤곽 점/스무딩, 튜브 경로/두께 조절(JSON)
- AI가 작성할 수 있도록 임의 정점·삼각형·정점별 색상을 직접 지정하는 `mesh` JSON과 브라우저 JavaScript API 제공
- PNG/JPG/WEBP 참조 이미지를 투명도 조절 오버레이로 표시. 참조는 모델 파일이나 내보내는 데이터에 삽입되지 않음
- 모델 단위, 작업 부피 경계, 그리드/축/배경 설정
- JSON 모델 내보내기/불러오기, 명령 JSON 붙여넣기, 로컬 자동 저장, Ctrl+Z/Ctrl+Y
- 다크 UI. 표시 전용 배경색은 배경 버튼을 눌러 순환

## 정확한 범위

기본 도형 외에 `mesh` 타입은 정점·삼각형·정점별 색상을 직접 정의하는 메시입니다. 이 토폴로지는 JSON으로 저장/불러오기하거나 `window.pixelStudio3D` API로 생성·교체할 수 있습니다. 별도의 브러시형 sculpt UI와 자동 이미지→3D AI 생성은 아직 없습니다. 다른 AI/웹 UI에 전달하는 독립 규격은 [`MESH_JSON_INTERFACE.md`](./MESH_JSON_INTERFACE.md)에 있습니다. 현재 AI 워크플로는 사용자가 참조 이미지를 표시하고, 이 계약을 외부 AI에 제공한 뒤 반환된 JSON을 적용하는 방식입니다.

모델의 부피는 `settings.bounds`에 기록되는 작업 기준 경계이며, 메시 치수/스케일과 구분됩니다. 여러 오브젝트가 겹치거나 경계 밖으로 나갈 수 있으므로 현재 경계가 자동으로 실제 솔리드 부피를 제한하거나 계산하지는 않습니다. 메시 밀도는 primitive 세그먼트, polygon 스무딩 곡선 분할, curve 튜브 분할로 표현됩니다. 화면의 삼각형 숫자는 렌더 메시의 근사 지표입니다.

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

`position`은 모델 좌표, `rotation`은 도(degree), `scale`은 signed 축별 배율이며 각 축의 절댓값은 0.01 이상이어야 합니다. 음수 축 배율은 좌우 반전 등에 사용합니다. 색상은 불투명 `#RRGGBB`입니다. 현재 도형별 geometry 키:

| type | geometry 치수 및 밀도 |
| --- | --- |
| `box` | `width`, `height`, `depth` |
| `sphere` | `radius`, `widthSegments`, `heightSegments` |
| `cylinder` | `radiusTop`, `radiusBottom`, `height`, `radialSegments` |
| `cone` | `radius`, `height`, `radialSegments` |
| `torus` | `radius`, `tube`, `radialSegments`, `tubularSegments` |
| `polygon` | `points`, `depth`, `bevelSize`, `bevelSegments`, optional `smooth`, `curveSegments` |
| `curve` | 3D 경로 `points3D`, `radius`, `tubularSegments`, `radialSegments` |
| `mesh` | 권장 체적 `sections` 단면 루프 또는 직접 표면 `vertices`/`triangles`; 각 방식에 맞는 선택 색상 배열 |

분할 수는 3–128, polygon은 3–512개의 유효한 XY 점, curve는 2–512개의 XYZ 점을 받습니다. 모델은 최대 500개 오브젝트, 명령 문서는 최대 10,000개 명령입니다. 화면 참조 이미지, 카메라 위치, 현재 선택, 실행 취소 기록은 모델 파일에 포함되지 않습니다.

## AI 명령 JSON: `pixel-studio-3d-commands` v1

명령 문서는 `format`, `version`, 선택 `name`, 선택 `settings`, `commands`로 구성됩니다. 적용 결과는 프로젝트 문서로 검증되어 JSON 패널/공개 API/실행 취소 기록과 같은 모델 상태에 반영됩니다.

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
| `addMesh` | `id`, `geometry.sections` 또는 `vertices` + `triangles` | 닫힌 체적 단면 또는 직접 표면 메시 추가 |
| `setTransform` | `id` | 지정된 위치/회전/크기 축만 변경 |
| `setMaterial` | `id`, `color` | 오브젝트 색상 변경 |
| `setGeometry` | `id`, `geometry` | 해당 primitive 치수 또는 분할 밀도 변경 |
| `setMeshData` | `id`, `geometry.sections` 또는 `vertices` + `triangles` | 기존 `mesh`의 체적/표면 위상과 색상을 통째로 교체 |
| `removeObject` | `id` | 오브젝트 삭제 |
| `clear` | 없음 | 모든 메시 삭제 |

모든 명령은 적용 전에 검증됩니다. 잘못된 명령은 장면에 부분 적용되지 않습니다. 작업 부피 `bounds`와 물체 위치/크기는 별도 설정입니다. AI에게 반복 수정을 맡길 때는 현재 모델 JSON을 함께 제공하고, 참조 이미지와 정면/측면 등 비교 관점을 알려 주며, 바뀔 오브젝트의 안정적인 `id`를 유지하도록 지시하세요.

### AI 작업 프롬프트 예

> 아래 Pixel Studio 3D v1 규격에 맞는 `pixel-studio-3d-commands` JSON을 작성해 주세요. 구/원통을 단순 조립하지 말고 머리, 몸통, 골반/치마, 팔다리의 주요 부위를 닫힌 3D 저폴리 체적으로 설계하세요. 권장 방식은 `geometry.sections`: 몸통은 어깨·가슴·허리·골반 높이의 단면 루프, 팔다리는 뿌리·관절·끝점 단면을 3D 좌표로 연결합니다. 정면은 +Z, 위쪽은 +Y이고 앞/옆/뒤 시점에서 깊이와 실루엣을 확인하세요. 눈·앞머리·깃털 등 얇은 디테일만 `vertices`/`triangles` 표면으로 둡니다. 기존 장면을 수정하면 id를 유지하고 변경할 메시를 `setMeshData`로 교체하세요. 반환 전 모든 루프의 점 개수/순서와 색상 배열 길이를 검증하세요.

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

Use simple non-self-intersecting outlines. `polygon` is intended for silhouette pieces such as hair, clothing panels, and wings. Set `smooth: true` for a rounded Catmull–Rom outline; keep it false for sharp forms such as stars. `curve` creates a volumetric tube through ordered local 3D control points, useful for hair strands, seams, and folds.

```json
{
  "op": "addPrimitive",
  "id": "hair-strand",
  "type": "curve",
  "name": "Flowing hair strand",
  "color": "#8bdcf2",
  "position": { "x": 0, "y": 0, "z": 0 },
  "rotation": { "x": 0, "y": 0, "z": 0 },
  "scale": { "x": 1, "y": 1, "z": 1 },
  "geometry": {
    "points3D": [[0,0,0],[0.4,0.7,0.1],[0.9,1.0,-0.1]],
    "radius": 0.04,
    "tubularSegments": 32,
    "radialSegments": 8
  }
}
```

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

The v1–v4 viewport captures and source/project version notes are stored together under `examples/Dahlia/<version>/`. Load them from the corresponding **Dahlia vN 열기** button in the left scene panel. The v2–v4 build scripts are in `examples/Dahlia/`.

Click a **Dahlia vN 열기** button in the left scene panel to load that version's model JSON and reference overlay. **Dahlia v4** is the latest sculpting pass. This is an editable model blockout, not image-to-3D reconstruction.

## Windows local server

Run `./serve.ps1` from this folder and open `http://127.0.0.1:8000/`. If execution policy blocks the script, use `powershell -NoProfile -ExecutionPolicy Bypass -File .\serve.ps1`. On other platforms, use `python -m http.server 8000` and open `/SubProjects/PixelStudio3D/` from the parent project server.

## Toon geometry and grid placement update

The studio now supports `settings.renderStyle` (`soft` or `toon`) and `settings.floorY` for the viewport grid plane. These are project/command settings and are imported/exported with the model. `floorY` changes only the preview grid; it does not move or deform objects. The home view frames a full-body chibi model more closely, and the default three-point lighting is tuned for readable toon colors.

The `loft` mesh uses elliptical cross-section rings `[y, centerX, centerZ, radiusX, radiusZ]` to create a continuous torso or skirt volume. Curves accept `radiusStart` and `radiusEnd` for tapered sleeves, hair locks, and limbs. See `examples/Dahlia/v5/model.json` for an applied sample.

These changes improve stylized blockout work but do not create a production avatar automatically. The editor still has no connected skin, bone rig, joint weights, UVs, texture painting, or facial expression system. An avatar with a VRChat-like silhouette can be built gradually from these tools, but would need those additional modeling and rigging systems for a complete game-ready character.

## Dahlia v6 pose sample

The latest in-app example is `examples/Dahlia/v6/`. It adjusts the oversized sleeve tubes and hand placement to create a visible folded-arm pose across the chest, adds rounded shoulder volumes, and keeps the v5 toon/loft foundation. Load it with **Dahlia v6 열기 · 포즈 다듬기** or `?example=Dahlia-v6`. `examples/Dahlia/build-v6.ps1` recreates the JSON from v5, and the version folder contains its local viewport screenshot and proxy reference. It is still a blockout of independent meshes; no rig or connected skin is included.

## Authored mesh contract

캐릭터 모델의 기본 구조는 구·원통 같은 기본 도형을 이어 붙이는 방식만을 전제로 하지 않습니다. `mesh.geometry.sections`에 순서가 일치하는 3D 닫힌 단면 루프를 넣으면 앱이 각 루프를 연결하고 양 끝을 막아 **실제 부피를 가진 저폴리 메시**를 생성합니다. 몸통·머리·치마·팔·다리처럼 단면이 변하는 부위에 권장합니다. 눈, 앞머리, 깃털처럼 얇은 표면 디테일에는 직접 `vertices`/`triangles`를 사용합니다.

선택한 `mesh` 오브젝트는 속성 패널의 메시 JSON 편집기에서 `sections` 또는 정점/삼각형 데이터를 직접 수정하고 적용할 수 있습니다. JSON 명령 패널과 `window.pixelStudio3D` API도 같은 검증·렌더링 경로를 사용합니다. 뷰포트에는 정면·측면·후면 카메라 버튼이 있어 두께와 실루엣을 확인할 수 있습니다. 사람이 오브젝트 단위 변환 도구를 사용하고, AI가 같은 계약의 JSON을 작성/수정하는 흐름입니다.

세부 규격과 인체형 단면 설계 지침은 [`MESH_JSON_INTERFACE.md`](./MESH_JSON_INTERFACE.md)를 보세요. 이 앱은 AI 엔드포인트나 자동 이미지→3D 변환을 포함하지 않으며, 전면 2D 레퍼런스만으로 보이지 않는 측후면 형태가 자동 추론된다고 보장하지 않습니다.

## Direct vertex mesh contract (surface form)

For hand-authored character surfaces, use `type: "mesh"`. Coordinates inside `geometry.vertices` are object-local `[x,y,z]` values. `geometry.triangles` contains zero-based `[a,b,c]` indices into that vertex array. Triangle winding sets face normals; reuse vertex indices for smoothly interpolated normals and duplicate vertices where you need hard edges. `vertexColors` is optional; when present, it must contain exactly one six-digit sRGB hex color per vertex. To assign a solid color per face, duplicate that face's vertices and give the duplicates one shared color. Omit it for the object's uniform `color`.

```json
{
  "format": "pixel-studio-3d-commands",
  "version": 1,
  "commands": [{
    "op": "addMesh",
    "id": "tunic-front",
    "name": "Tunic custom surface",
    "color": "#ffffff",
    "position": { "x": 0, "y": 1, "z": 0 },
    "rotation": { "x": 0, "y": 0, "z": 0 },
    "scale": { "x": 1, "y": 1, "z": 1 },
    "geometry": {
      "vertices": [
        [-0.5, 0, 0.25], [0.5, 0, 0.25], [0.4, 1, 0.25], [-0.4, 1, 0.25],
        [-0.5, 0, -0.25], [0.5, 0, -0.25], [0.4, 1, -0.25], [-0.4, 1, -0.25]
      ],
      "triangles": [
        [0, 1, 2], [0, 2, 3], [4, 6, 5], [4, 7, 6],
        [0, 4, 5], [0, 5, 1], [1, 5, 6], [1, 6, 2],
        [2, 6, 7], [2, 7, 3], [3, 7, 4], [3, 4, 0]
      ],
      "vertexColors": ["#819fc7", "#819fc7", "#c6dcf2", "#c6dcf2", "#617da8", "#617da8", "#a4bddb", "#a4bddb"]
    }
  }]
}
```

The validator checks 3–32,768 finite vertices, 1–65,536 non-degenerate triangles, local coordinates within ±1000, valid indices, and optional color count/format. It does not fix non-manifold topology, holes, self-intersections, or incorrect winding. The built-in limit is a safety bound, not a target; AI should generally create a lightweight mesh and refine it in iterations.

### Public JavaScript API

The app exposes `window.pixelStudio3D` after loading `app.js`:

```js
const contract = window.pixelStudio3D.getJSONFormatHelp();
const current = window.pixelStudio3D.getProject();
window.pixelStudio3D.createMesh({
  id: "torso", name: "Torso volume", color: "#91afd8",
  geometry: { sections: [ringAtHip, ringAtWaist, ringAtChest] }
});
window.pixelStudio3D.setMeshData("torso", {
  sections: [ringAtHip, ringAtWaist, ringAtChest],
  sectionColors: ["#7794c3", "#91afd8", "#b8d0ed"]
});
const mesh = window.pixelStudio3D.getMesh("torso");
const projectJson = window.pixelStudio3D.exportProject();
```

Methods are `getJSONFormatHelp()`, `getProject()`, `getMesh(id)`, `createMesh(mesh)`, `setMeshData(id, geometry)`, `applyCommands(documentOrArray)`, `exportProject()`, and `exportCommandsHelp()`. API edits use the same validation and undo/persistence path as JSON application. The API provides model data/rendering, not an AI endpoint.

다른 AI/툴에 전달할 수 있는 독립 규격은 [`MESH_JSON_INTERFACE.md`](./MESH_JSON_INTERFACE.md)입니다. 체적 단면 및 표면 메시 규칙, 제한, 명령 연산, API를 함께 설명합니다.


### Direct mesh example

examples/Dahlia/v7/ is the current implementation proof: 15 custom indexed meshes and no built-in primitive shapes. It is intentionally a low-poly fixture for the mesh JSON contract, not a finished avatar.

### Dahlia v8: volumetric low-poly character

`examples/Dahlia/v8/`는 머리, 뒤쪽 머리카락, 몸통, 치마, 팔, 다리, 날개 기초를 단면 기반 폐쇄 체적으로 구성하고 눈/앞머리/깃털은 직접 표면 메시로 얹은 카툰풍 예제입니다. **Dahlia v8 열기 · 체적 메시** 또는 `?example=Dahlia-v8`로 불러온 뒤 정면·측면·후면을 확인할 수 있습니다. URL에 `&view=side` 또는 `&view=back`을 붙이면 해당 시점으로 바로 열립니다. 참조 파일은 워크스페이스에 있던 유사 픽셀아트 프록시이며 첨부한 정확한 원본이 아닙니다. v8은 닫힌 캐릭터 부피를 만드는 인터페이스 실증용 블록아웃이고, 완성된 아바타/리깅 모델이 아닙니다.
