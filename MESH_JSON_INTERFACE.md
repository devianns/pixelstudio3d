# Pixel Studio 3D — Low-poly character mesh contract

This portable contract describes the geometry the app validates and renders. Three.js is the renderer; `pixel-studio-3d-project` and `pixel-studio-3d-commands` are the app's own data formats. An external AI can read a reference and author these JSON documents, then a person can inspect and revise the same geometry in the studio. There is no built-in AI endpoint or automatic image-to-3D reconstruction.

## Modeling intent

This interface is for authored low-poly/cartoon characters, not only primitive blockouts. Build the torso, pelvis/skirt, head, limbs and major hair masses as actual closed volumes. Use thin triangle meshes for genuinely surface-like details such as eyes, bangs, feather plates, ornaments and cloth accents. Use several purposeful mesh objects with stable IDs rather than one giant surface or a pile of spheres/cylinders.

A single 2D reference only constrains one projection. Compare front, side and back views, and make a deliberate depth design from the reference. A model cannot infer unseen anatomy from the front image alone; side/back shapes are authored design choices and should be revised against those views.

## Coordinate and object contract

- Right-handed coordinates; +Y is up, +Z faces the viewer/front, +X is the character's left in a front view.
- Every mesh object has `type: "mesh"`, `geometry`, a uniform `color`, and optional position/rotation/scale. Geometry coordinates are object-local and transforms apply after geometry creation.
- Project format is `pixel-studio-3d-project` v1. AI edits can use `pixel-studio-3d-commands` v1 with `addMesh` and `setMeshData`.

## Preferred geometry: closed cross-section volume

`geometry.sections` is an ordered sequence of closed 3D perimeter loops. Each loop has 6–32 `[x,y,z]` points; every loop has the same point count and corresponding points retain the same order. Loops can lie in any orientation. The renderer triangulates between adjacent loops and caps both ends. This is the preferred compact contract for low-poly volumes such as a torso, head, skirt, arm or leg. Use enough stations to describe anatomical changes: shoulder, chest, waist, pelvis; or limb root, bend, wrist/ankle.

For a vertical torso, each loop can be an octagonal/decagonal ring around Y. For an arm extending along a bent path, each loop is a perimeter around a station on that path, oriented perpendicular to the local direction. Keep loops non-crossing and consistently ordered. `sectionColors` optionally supplies one `#RRGGBB` color per loop. Alternatively, `vertexColors` supplies one color per point across all loops (`sections.length * pointsPerLoop`). Do not supply both color arrays.

```json
{
  "op": "addMesh",
  "id": "dahlia-torso",
  "name": "Torso volume",
  "color": "#91afd8",
  "geometry": {
    "sections": [
      [[-0.30,1.45,0.15],[-0.21,1.45,0.31],[0,1.45,0.37],[0.21,1.45,0.31],[0.30,1.45,0.15],[0.21,1.45,-0.01],[0,1.45,-0.07],[-0.21,1.45,-0.01]],
      [[-0.42,1.95,0.12],[-0.30,1.95,0.32],[0,1.95,0.40],[0.30,1.95,0.32],[0.42,1.95,0.12],[0.30,1.95,-0.08],[0,1.95,-0.16],[-0.30,1.95,-0.08]],
      [[-0.52,2.30,0.10],[-0.37,2.30,0.30],[0,2.30,0.38],[0.37,2.30,0.30],[0.52,2.30,0.10],[0.37,2.30,-0.10],[0,2.30,-0.18],[-0.37,2.30,-0.10]]
    ],
    "sectionColors": ["#7794c3", "#91afd8", "#b8d0ed"]
  }
}
```

The loop point ordering above is an example perimeter, not a required anatomical convention. Keep the order consistent between adjacent loops. When creating surfaces with severe taper, use a small but nonzero end loop instead of coincident points.

## Alternate geometry: authored triangle surface

Use `geometry.vertices` (3–32,768 finite local XYZ triples, each coordinate in `[-1000,1000]`) and `geometry.triangles` (1–65,536 zero-based `[a,b,c]` integer indices). Triangles must reference distinct valid vertices and have nonzero area. Winding controls normals. `vertexColors` is omitted or has one six-digit hex color per vertex. Reuse vertices for interpolated normals; duplicate them for hard edges or flat color boundaries. This form is useful for hair clumps, face features, wings/feathers, and deliberately shaped silhouettes. A front-only surface does not add body volume.

The validator checks input shape, range, indices and direct triangle area. It does not repair self-intersections, holes, non-manifold edges, bad loop correspondence, or bad winding.

## Limits

- Sections: 2–64 loops, each with 6–32 points; resulting geometry remains under 32,768 vertices / 65,536 triangles.
- Section loop coordinates: finite values in `[-1000,1000]`.
- Direct mesh: 3–32,768 vertices and 1–65,536 triangles.
- At most 500 objects and 10,000 commands per document.
- These are validation ceilings, not suggested densities. A stylized character usually benefits more from intentional silhouette and volume stations than from a high polygon count.

## Command operations

- `addMesh`: add a mesh using either `geometry.sections` or `geometry.vertices` + `geometry.triangles`.
- `setMeshData`: replace the complete geometry/color data of an existing `mesh`; use the same two geometry alternatives.
- `setTransform`: set position/rotation-in-degrees/scale.
- `setMaterial`: set uniform base color.
- `removeObject`, `clear`.

All commands validate before the scene changes. Invalid command documents leave the current scene intact. A complete project can also be imported/exported as JSON. Past sample versions should remain immutable.

## Human and AI workflow

1. Load a reference and establish the overall height, width and front silhouette.
2. Author closed volumes for skull/head, chest/torso, pelvis or skirt, upper/lower arms, and upper/lower legs. Keep depth in +Z/-Z explicit; do not collapse every ring to one Z plane.
3. Add authored surface meshes for face, hair locks, wings and ornaments, checking their offsets against the volume.
4. Inspect the front, side and back views. Correct the side silhouette and balance before adding small details.
5. Preserve object IDs between iterations and return only affected `setMeshData` operations where practical. Save each reviewable version separately.

The studio's object inspector includes an editable JSON field for selected mesh geometry. Edit `sections` or `vertices` there and apply; the regular JSON command panel and public API use the same validation and render path. Transform gizmos remain available for object-level human editing. There is no vertex drag/sculpt brush, rig, skinning, or texture paint system yet.

## Public API

```js
window.pixelStudio3D.createMesh({
  id: "body",
  name: "Torso",
  color: "#91afd8",
  geometry: { sections: [ring0, ring1, ring2], sectionColors: ["#7794c3", "#91afd8", "#b8d0ed"] }
});

window.pixelStudio3D.setMeshData("body", { sections: [ring0, ring1, ring2] });
const mesh = window.pixelStudio3D.getMesh("body");
const contract = window.pixelStudio3D.getJSONFormatHelp();
```

`getProject()`, `exportProject()`, `applyCommands()`, and `exportCommandsHelp()` are also available. API calls use the same validation, history, persistence and rendering path as the UI.
