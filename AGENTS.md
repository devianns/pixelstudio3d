# Pixel Studio 3D agent handoff

## Purpose and boundary

This is an independent 3D modeling subproject under `SubProjects/PixelStudio3D`. It is separate from root Pixel Studio (2D pixel editor) and Pixel Motion Studio (GIF tool). Do not edit either sibling project as part of work here unless explicitly requested. The parent repository ignores `SubProjects/`, so this app is not tracked by the root Git repository; a later standalone repository can be initialized inside this directory.

The application does not call an AI service. AI authors `pixel-studio-3d-commands` JSON externally, and the user pastes/imports it. Always state this accurately.

## Source files

| File | Responsibility |
| --- | --- |
| `index.html` | Three.js import map, studio layout, viewport, inspector and JSON panel |
| `app.js` | Three.js scene, primitive and indexed custom mesh geometry, transform controls, project state, command validation, public `window.pixelStudio3D` API, import/export and local persistence |
| `styles.css` | Studio UI, themes and responsive layout |
| `serve.ps1` | Optional PowerShell static HTTP server for Windows |
| `README.md` | User guide and complete public JSON interface contract |
| `MESH_JSON_INTERFACE.md` | Portable direct-vertex AI authoring contract; keep synchronized with runtime validation and `schemaHelp` |

## Runtime architecture

- Buildless ES modules, served over HTTP. Do not recommend `file://`; module/CORS policy requires a local static server.
- Three.js and addons are pinned together to jsDelivr `three@0.180.0` via the import map in `index.html`. If upgrading, update all mappings together and verify `TransformControls` behavior (`getHelper()` is added to scene).
- `OrbitControls` owns camera orbit/pan/zoom; `TransformControls` attaches selected meshes. Coordinates use Y-up, +Z toward the default camera/front. Rotation JSON is degrees and converted to Three.js radians internally.
- Reference images are local object URLs in an HTML overlay above the viewport. They are never serialized, uploaded, or included in project files.
- State is in `model`; project autosave key is `pixel-studio-3d-project-v1`.

## Current model limits

- `FORMAT = pixel-studio-3d-project`, version 1.
- Supported types: `box`, `sphere`, `cylinder`, `cone`, `torus`, `polygon` (extruded local XY outline), `curve` (smooth 3D tube along XYZ control points, optionally tapered with `radiusStart`/`radiusEnd`), `loft` (elliptical cross-section volume from Y profiles), and `mesh` (authored vertices, triangle indices, optional per-vertex colors).
- `settings.renderStyle` chooses `soft` or `toon`; `settings.floorY` changes only the preview grid plane and does not transform model objects.
- Each mesh has stable unique `id`, name, six-digit opaque hex color, position/rotation/scale vectors, and type-specific geometry dimensions/segment counts.
- Segment counts validate/clamp to 3–128; project maximum 500 meshes; command max 10,000 operations.
- `settings.bounds` is a declared work volume only. It does not clip, constrain, or calculate true intersected solid volume.
- `mesh` is the arbitrary indexed triangle surface contract. It is editable through full JSON replacement and `window.pixelStudio3D` API; there is not yet an interactive vertex/edge sculpt brush, texture painting, Boolean operation, or image-to-3D reconstruction.
- Project files have no animation field yet; timeline playback and animation import/export do not exist.

## JSON contracts

The user-facing canonical schema, all geometry keys, example commands, validation limits and proposed animation extension are documented in `README.md`. Keep that as the source of truth.

- Project: `pixel-studio-3d-project` v1; fields `name`, `settings`, `objects`.
- Commands: `pixel-studio-3d-commands` v1; apply settings then run `commands` transactionally.
- Supported ops: `addPrimitive`, `addMesh`, `setMeshData`, `setTransform`, `setMaterial`, `setGeometry`, `removeObject`, `clear`.
- When modifying a contract, update `validateModel()`, `normalizeCommands()`, export/import paths, the copied schema (`schemaHelp` in `app.js`), UI help, and README together. Keep v1 for compatible optional fields; bump with migrations for breaking changes.
- `mesh.geometry.vertices` is 3..32768 local finite XYZ triples within ±1000; `triangles` is 1..65536 zero-based integer triples with valid distinct indices and nonzero area. Optional `vertexColors` is empty/omitted or one `#RRGGBB` per vertex. Duplicate vertices to create hard normal/color boundaries. The validator does not repair non-manifold topology, holes, or winding.
- `window.pixelStudio3D` exposes `getJSONFormatHelp`, `getProject`, `getMesh`, `createMesh`, `setMeshData`, `applyCommands`, `exportProject`, and `exportCommandsHelp`. API edits go through the same validation, history and persistence path as JSON application.
- Validate all commands before installation, keep IDs unique, reject unsupported geometry/ops, and avoid partially applied documents.
- Undo/redo use model snapshots; whenever changing commits, preserve state before the edit, restore the UI and persisted model together, and do not serialize view-only reference image data.

## Extension plan

1. Add structured low-poly parts and material controls before attempting unrestricted mesh sculpting.
2. Consider GLTF export/import as an interoperable 3D format while preserving the native JSON as editable project source.
3. Add parent/group transforms and a separate interactive vertex/edge/face editor over the `mesh` contract; keep the same indexed data as the single source of truth.
4. For animation, use stable mesh IDs and per-frame transform overrides with fps, loop, and durations; document whether omitted objects inherit, hide, or interpolate. Add a timeline UI only when playback behavior is implemented.
4. Any AI refinement flow should provide the current model document, reference image to the external AI, and a diff/validation step; this application currently has no model connection.

## Editing and validation

- Keep user-facing UI copy in Korean; stable JSON keys and operation names stay English.
- `app.js` is an ES module, unlike the root 2D app. Maintain valid import specifiers.
- No package manifest or automated test runner is configured. Do not invent test commands. If asked to verify, inspect syntax and run the browser through a local HTTP server if a browser is available; report when runtime validation is unavailable.
- Read `README.md` before changing user-facing modeling or JSON behavior.

## Polygon silhouettes and example archive

- `defaults.polygon` and `defaults.curve`, `geometryFor()`, the wrappers in `validateModel()`, and the type selector implement smoothed extruded XY outlines and 3D Catmull–Rom tube paths.
- Keep `geometry.points` out of scalar geometry-number validation; `validateModel()` strips points for numeric validation and restores normalized points afterward. Keep the same IDs for mirrored left/right parts and use negative X scale where helpful. Mesh materials are double-sided to display mirrored extrusions.
- The shape outline must contain 3–512 finite `[x,y]` points, each within ±100 local units, and nonzero signed area. Segment fields remain 3–128. Self-intersection detection is not implemented; avoid crossing outlines in generated JSON.
- `examples/<Character>/vN/` stores a project JSON, reference images and provenance/iteration notes. Never overwrite past versions. Mention whether a reference is the user's exact source or a similar substitute.
- Dahlia version buttons fetch matching `examples/Dahlia/vN/model.json` and reference images. Preserve these version paths if moving examples.
- For any future curve/mesh changes, update `schemaHelp`, `validateModel()`, `geometryFor()`, README geometry table and the relevant AI example together.

## Toon character modeling additions (2026-11)

- Studio settings include `renderStyle: soft | toon` and `floorY` (grid display plane only); both are saved in project JSON and accepted in command settings.
- `loft` builds an elliptical-ring volume from `geometry.rings: [[y,cx,cz,rx,rz], ...]`.
- `curve` can use `radiusStart` and `radiusEnd` to taper the tube across its path.
- `examples/Dahlia/v5/` is the current cartoon blockout sample. Earlier versions remain intact. v5 has 77 mesh parts and uses toon shading, shaped torso/skirt volumes, and tapered sleeves/legs.
- Lights and the home camera are tuned for clearer full-body review; the grid can be lowered through `floorY` so it does not cut through a posed character.
- Built-in primitives remain useful for blockouts, but the new `mesh` contract allows directly authored connected surfaces. The v1-v6 Dahlia samples still use independent mesh parts; do not describe them as export-ready or VRChat-compatible avatars. Connected skin, bone rig, weight painting, UV/texture painting, and facial expression rig are still future work.
- Keep the explicit distinction between “VRChat-like visual direction” and using VRChat SDK/code/libraries. The app does not use those technologies.

- `examples/Dahlia/v6/` is the latest pose study: the two tapered sleeves are wider and cross visibly in front of the chest, hands are brought together, and rounded shoulder pieces improve the arm silhouette. `examples/Dahlia/build-v6.ps1` regenerates it from v5.
- `MESH_JSON_INTERFACE.md` is the portable direct-vertex authoring contract. Keep its coordinates, limits, operations, and public API synchronized with `schemaHelp` and validation code.
- `examples/Dahlia/v7/` is the custom mesh contract fixture. Every scene object uses explicit indexed `mesh` vertices/triangles (no built-in primitive/curve/loft type); it is deliberately a low-poly prototype, not a completed avatar.
