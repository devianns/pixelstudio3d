# Pixel Studio 3D - Direct Mesh JSON Interface

This document is the portable authoring contract for AI agents and external tools that create or revise character surfaces for Pixel Studio 3D. It describes data the current application actually validates. The app uses Three.js for rendering; this interface is the application's own stable model contract, independent of Three.js internals.

## Workflow

1. Read the supplied reference image and the current project JSON.
2. Build the character from authored indexed surfaces (`type: "mesh"`), not a stack of primitive proxies. Use separate stable mesh IDs for meaningful surface regions such as torso, face, hair masses, sleeves, skirt, and wings.
3. Apply a valid `pixel-studio-3d-commands` v1 document in the JSON panel or call `window.pixelStudio3D.applyCommands(...)`.
4. Compare the render against the reference from the front and side. Preserve existing IDs and submit `setMeshData` only for surfaces that need revision.
5. Keep each iteration as a separate versioned example JSON when requested. Never silently replace an earlier sample.

AI inference is external. Pixel Studio 3D does not send the reference or model to an AI service.

## Coordinate and mesh contract

- Right-handed, Y-up coordinates; +Z is the front/viewer side; +X is the character's left in a front view.
- Each vertex is an object-local finite `[x, y, z]` triple. Object `position`, `rotation`, and `scale` transform the complete mesh.
- Triangle indices are zero-based and refer to `geometry.vertices`. Every face is exactly `[a, b, c]`; order controls normal direction. Use consistent outward counter-clockwise winding as viewed from outside.
- Reuse indices where shading should interpolate smoothly. Duplicate vertices at hard edges or color boundaries.
- `vertexColors` is optional. If supplied, it has exactly one `#RRGGBB` sRGB color per vertex; colors interpolate across triangles. Omit it for uniform `color`. To make a flat-colored face, duplicate its vertices and assign the same color to each duplicate.
- The renderer computes vertex normals. It does not repair holes, non-manifold edges, self-intersections, or inconsistent winding.

## Limits

- 3 to 32,768 vertices per mesh.
- 1 to 65,536 triangles per mesh.
- Local vertex coordinates within `[-1000, 1000]` on each axis.
- Each triangle must use three distinct valid integer indices and have nonzero area.
- Optional `vertexColors` must be empty/omitted or exactly match the vertex count, with six-digit hex colors.
- 500 model objects and 10,000 commands per command document.
- These are validation ceilings, not recommended target sizes. Prefer a compact silhouette and deliberate topology, then refine in small reviewable steps.

## Command document

```json
{
  "format": "pixel-studio-3d-commands",
  "version": 1,
  "name": "Dahlia mesh draft",
  "settings": {
    "renderStyle": "toon",
    "bounds": { "x": 6, "y": 7, "z": 4 },
    "grid": true,
    "floorY": -1.4
  },
  "commands": [
    {
      "op": "addMesh",
      "id": "character-torso",
      "name": "Tunic surface",
      "color": "#ffffff",
      "position": { "x": 0, "y": 0, "z": 0 },
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
    }
  ]
}
```

### Supported operations

- Optional top-level `name` updates the project name; settings are applied before commands.
- `addMesh`: adds an authored `mesh` object. `id` must be unique. `geometry.vertices` and `geometry.triangles` are required; `vertexColors` is optional.
- `setMeshData`: replaces the full topology/color payload of an existing `mesh`. It cannot target a primitive.
- `setTransform`: changes `position`, `rotation` (degrees), and/or `scale` on an existing object.
- `setMaterial`: changes the uniform base `color`.
- `removeObject`: removes one object by `id`.
- `clear`: removes all objects.

All commands are validated before the updated scene is installed. Invalid documents leave the current scene untouched and display a validation error.

## Public JavaScript API

The app publishes `window.pixelStudio3D` after `app.js` initializes. Calls use the same validation, undo history, autosave, and render path as JSON application.

```js
const schema = window.pixelStudio3D.getJSONFormatHelp();
const currentProject = window.pixelStudio3D.getProject();

window.pixelStudio3D.createMesh({
  id: "test-triangle",
  name: "Test surface",
  color: "#ffffff",
  vertices: [[0,0,0], [1,0,0], [0,1,0]],
  triangles: [[0,1,2]],
  vertexColors: ["#ff6688", "#66ccff", "#ffee88"]
});

window.pixelStudio3D.setMeshData("test-triangle", {
  vertices: [[0,0,0], [1,0,0], [0,1,0]],
  triangles: [[0,1,2]]
});

const mesh = window.pixelStudio3D.getMesh("test-triangle");
const projectJson = window.pixelStudio3D.exportProject();
```

| Method | Behavior |
| --- | --- |
| `getJSONFormatHelp()` | Returns a copy of the JSON contract and limits |
| `getProject()` | Returns a deep copy of the current project |
| `getMesh(id)` | Returns a deep copy of a custom mesh or `null` |
| `createMesh(mesh)` | Adds and returns a validated custom mesh |
| `setMeshData(id, geometry)` | Replaces mesh topology and colors |
| `applyCommands(documentOrArray)` | Applies a wrapped command document or command array atomically |
| `exportProject()` | Returns the complete project as formatted JSON text |
| `exportCommandsHelp()` | Returns the command contract as formatted JSON text |

This contract exposes authored geometry to AI and external tools. It does not claim to provide an interactive sculpt brush, automatic image-to-3D generation, a skeleton rig, or texture painting.
