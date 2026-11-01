# 예제 모델 아카이브

캐릭터별로 디렉터리를 나누고, 각 버전마다 참조 이미지와 `pixel-studio-3d-project` JSON, 제작 메모를 함께 보관합니다. 완성본을 덮어쓰지 말고 수정할 때는 `v2`, `v3` 폴더를 추가합니다.

```text
examples/
  README.md
  Dahlia/
    v1/
      README.md
      model.json
      studio-preview.png
      reference/
        angel-pixel-reference.png
    v2/ through v5/ keep their own version notes, JSON, preview and reference copy.
```

예제는 스튜디오의 기본 메시, 두께가 있는 곡선 윤곽, 3D 튜브로 구성한 블록아웃입니다. 원본 참조와 혼동하지 않도록 이미지 출처/대체 여부를 각 버전 README에 기록합니다.

## Latest Dahlia sample

`Dahlia/v5/` demonstrates cartoon cell shading plus lofted torso/skirt volumes and tapered curve geometry. The local preview is `Dahlia/v5/studio-preview.png`. It remains a stylized blockout built from independent meshes; see that version's README for limitations.

Dahlia/v6는 팔을 가슴 앞에서 교차시키고 소매·어깨 볼륨을 다듬은 toon 포즈 연구 예제입니다.


`Dahlia/v6/` is the latest in-app sample. It refines the chibi folded-arm pose and shoulder silhouette. Load it with the v6 button; its build script derives a reproducible JSON from v5.


Dahlia/v7 is the direct-mesh contract fixture: all character surfaces are explicit indexed vertex/triangle meshes with optional per-vertex colors. See MESH_JSON_INTERFACE.md and the version README for limits and scope.
