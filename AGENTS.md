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
| `MESH_JSON_INTERFACE.md` | Portable low-poly character contract for volumetric sections and direct surfaces; keep synchronized with runtime validation and `schemaHelp` |

## Runtime architecture

- Buildless ES modules, served over HTTP. Do not recommend `file://`; module/CORS policy requires a local static server.
- Three.js and addons are pinned together to jsDelivr `three@0.180.0` via the import map in `index.html`. If upgrading, update all mappings together and verify `TransformControls` behavior (`getHelper()` is added to scene).
- `OrbitControls` owns camera orbit/pan/zoom; `TransformControls` attaches selected meshes. Coordinates use Y-up, +Z toward the default camera/front. Rotation JSON is degrees and converted to Three.js radians internally.
- Reference images are local object URLs in an HTML overlay above the viewport. They are never serialized, uploaded, or included in project files.
- State is in `model`; project autosave key is `pixel-studio-3d-project-v1`.

## Current model limits

- `FORMAT = pixel-studio-3d-project`, version 1.
- Supported types: `box`, `sphere`, `cylinder`, `cone`, `torus`, `polygon`, `curve`, `loft`, and custom `mesh`. For character geometry, `mesh.geometry.sections` defines 2–64 connected/capped 3D perimeter loops (6–32 matching points each); this builds low-poly volume along any axis. `vertices` + `triangles` remain available for authored surfaces and details, with optional section/per-vertex colors.
- `settings.renderStyle` chooses `soft` or `toon`; `settings.floorY` changes only the preview grid plane and does not transform model objects.
- Each mesh has stable unique `id`, name, six-digit opaque hex color, position/rotation/scale vectors, and type-specific geometry dimensions/segment counts.
- Segment counts validate/clamp to 3–128; project maximum 500 meshes; command max 10,000 operations.
- `settings.bounds` is a declared work volume only. It does not clip, constrain, or calculate true intersected solid volume.
- `mesh` supports either a closed cross-section volume (`geometry.sections`) or authored triangle surfaces (`vertices`/`triangles`). Selected mesh geometry is editable in the inspector JSON field or the command panel; object transforms use the gizmo. There is not yet a vertex sculpt brush, texture painting, Boolean operation, or image-to-3D reconstruction.
- Project files have no animation field yet; timeline playback and animation import/export do not exist.

## JSON contracts

The user-facing canonical schema, all geometry keys, example commands, validation limits and proposed animation extension are documented in `README.md`. Keep that as the source of truth.

- Project: `pixel-studio-3d-project` v1; fields `name`, `settings`, `objects`.
- Commands: `pixel-studio-3d-commands` v1; apply settings then run `commands` transactionally.
- Supported ops: `addPrimitive`, `addMesh`, `setMeshData`, `setTransform`, `setMaterial`, `setGeometry`, `removeObject`, `clear`.
- When modifying a contract, update `validateModel()`, `normalizeCommands()`, export/import paths, the copied schema (`schemaHelp` in `app.js`), UI help, and README together. Keep v1 for compatible optional fields; bump with migrations for breaking changes.
- `mesh.geometry.sections` accepts 2..64 loops, each with 6..32 equal-count finite XYZ points within ±1000; `sectionColors` has one hex color per loop, or `vertexColors` has one per ring point. Alternate direct surfaces use 3..32768 vertices and 1..65536 valid, nonzero-area triangles. Validation does not repair self-intersection, non-manifold topology, or incorrect winding.
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

- `examples/Dahlia/v6/` is an earlier pose study with crossed sleeves and rounded shoulder volumes. Keep it as an immutable historical iteration.
- `MESH_JSON_INTERFACE.md` is the portable low-poly authoring contract. Keep volume section/surface rules, limits, operations, and public API synchronized with `schemaHelp` and validation code.
- `examples/Dahlia/v7/` is the custom mesh contract fixture. Every scene object uses explicit indexed `mesh` vertices/triangles (no built-in primitive/curve/loft type); it is deliberately a low-poly prototype, not a completed avatar.
- `examples/Dahlia/v8/` demonstrates authored body volumes using cross-section loops, with triangle surfaces for facial and wing details. It is a cartoon blockout; inspect it from front/side/back. Its reference file is a similar local proxy, not the exact attached illustration.
