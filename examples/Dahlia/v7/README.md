# Dahlia - v7 direct mesh prototype

This version verifies the new authoring contract: all 15 scene objects use `type: "mesh"` with explicit indexed `vertices`, `triangles`, and per-vertex colors. No built-in sphere, box, cone, curve, or loft geometry is used in this model.

- Open **Dahlia v7 열기 · 직접 메시** or navigate to `?example=Dahlia-v7`.
- `model.json` is both a project import example and a compact validation fixture for mesh payloads.
- `build-v7.ps1` generates the indexed surfaces as plain JSON data; the application validates and renders the same mesh interface AI tools use.
- `studio-preview.png` shows the current low-poly custom-surface blockout.
- `reference/angel-pixel-reference.png` is a local similar proxy asset, not the exact reference attached in chat.

The silhouette is still a deliberately simple prototype. The important change is that each displayed region is now authored as vertex/triangle data and can be replaced through `setMeshData`, rather than being generated from a primitive type. A vertex/edge sculpt UI, mesh repair/remeshing, skeleton, and skinning are not implemented.
