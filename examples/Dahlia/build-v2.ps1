$ErrorActionPreference = 'Stop'
$sourcePath = Join-Path $PSScriptRoot 'v1/model.json'
$targetPath = Join-Path $PSScriptRoot 'v2/model.json'
$doc = Get-Content -Raw -Encoding utf8 $sourcePath | ConvertFrom-Json
$doc.name = 'Dahlia · Celestial Angel v2'
$doc.settings.bounds = [pscustomobject]@{ x = 6; y = 6.5; z = 4 }
$objects = [Collections.ArrayList]::new()
$objects.AddRange([object[]]$doc.objects)

foreach ($item in $objects) {
  if ($item.type -eq 'polygon' -and $item.id -notlike '*star*') {
    $item.geometry | Add-Member -NotePropertyName smooth -NotePropertyValue $true -Force
    $item.geometry | Add-Member -NotePropertyName curveSegments -NotePropertyValue 28 -Force
  }
  switch ($item.id) {
    'dahlia-bangs' { $item.position.y = 4.22; $item.scale.y = 0.58 }
    'dahlia-bang-cyan' { $item.position.y = 4.52; $item.position.x = 0.38 }
    'dahlia-hair-cap' { $item.position.y = 4.05; $item.scale.x = 0.96 }
    'dahlia-eye-left' { $item.position.z = 0.67; $item.scale.x = 0.14; $item.scale.y = 0.21 }
    'dahlia-eye-right' { $item.position.z = 0.67; $item.scale.x = 0.14; $item.scale.y = 0.21 }
    'dahlia-pupil-left' { $item.position.z = 0.725; $item.scale.x = 0.052 }
    'dahlia-pupil-right' { $item.position.z = 0.725; $item.scale.x = 0.052 }
    'dahlia-eye-glint-l' { $item.position.z = 0.755 }
    'dahlia-eye-glint-r' { $item.position.z = 0.755 }
    'dahlia-wing-left' { $item.position.x = -0.72; $item.position.y = 2.88; $item.rotation.z = 12 }
    'dahlia-wing-right' { $item.position.x = 0.72; $item.position.y = 2.9; $item.rotation.z = -12 }
    'dahlia-wing-feather-left' { $item.position.z = -0.08 }
    'dahlia-wing-feather-right' { $item.position.z = -0.08 }
    'dahlia-thigh' { $item.position.x = 0.63; $item.position.y = 0.34; $item.rotation.z = -18; $item.scale.x = 1.38; $item.scale.y = 0.4; $item.scale.z = 0.42 }
    'dahlia-leg-left' { $item.position.x = -0.32; $item.position.y = -0.4; $item.rotation.z = 24 }
    'dahlia-leg-right' { $item.position.x = 0.94; $item.position.y = -0.53; $item.rotation.z = -34 }
    'dahlia-boot-left' { $item.position.x = -0.65; $item.position.y = -1.15; $item.rotation.z = 20 }
    'dahlia-boot-right' { $item.position.x = 0.77; $item.position.y = -1.13; $item.rotation.z = -28 }
    'dahlia-sleeve-left' { $item.position.x = -0.52; $item.position.y = 2.03; $item.rotation.z = -42; $item.scale.x = 0.5; $item.scale.y = 0.82 }
    'dahlia-sleeve-right' { $item.position.x = 0.48; $item.position.y = 2.1; $item.rotation.z = 42; $item.scale.x = 0.48; $item.scale.y = 0.78 }
    'dahlia-halo' { $item.position.y = 5.2; $item.rotation.z = -16 }
  }
}

$extraJson = @'
[
  {"id":"dahlia-hair-strand-a","name":"Hair strand · left sweep","type":"curve","color":"#f6fbff","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[-0.82,4.35,0.68],[-0.72,4.08,0.73],[-0.49,3.83,0.76],[-0.24,3.72,0.77]],"radius":0.018,"tubularSegments":28,"radialSegments":6}},
  {"id":"dahlia-hair-strand-b","name":"Hair strand · center sweep","type":"curve","color":"#c4e8fb","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[-0.55,4.48,0.67],[-0.28,4.22,0.74],[0.04,3.96,0.77],[0.2,3.76,0.77]],"radius":0.016,"tubularSegments":28,"radialSegments":6}},
  {"id":"dahlia-hair-strand-c","name":"Hair strand · right fringe","type":"curve","color":"#ffffff","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[0.02,4.48,0.69],[0.3,4.24,0.75],[0.45,3.98,0.77],[0.43,3.79,0.76]],"radius":0.017,"tubularSegments":28,"radialSegments":6}},
  {"id":"dahlia-lock-curve-left","name":"Hair curl · left side","type":"curve","color":"#d5eaff","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[-0.72,3.66,0.56],[-0.9,3.22,0.53],[-0.88,2.75,0.45],[-0.7,2.38,0.34],[-0.82,2.18,0.24]],"radius":0.045,"tubularSegments":36,"radialSegments":8}},
  {"id":"dahlia-lock-curve-right","name":"Hair curl · right side","type":"curve","color":"#bcecf7","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[0.69,3.65,0.5],[0.89,3.24,0.48],[0.86,2.78,0.39],[0.7,2.5,0.28],[0.91,2.32,0.18]],"radius":0.04,"tubularSegments":36,"radialSegments":8}},
  {"id":"dahlia-mouth","name":"Face · soft smile","type":"curve","color":"#c77c91","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[-0.11,3.17,0.704],[0,3.13,0.713],[0.1,3.17,0.704]],"radius":0.014,"tubularSegments":12,"radialSegments":6}},
  {"id":"dahlia-wing-feather-l2","name":"Wing feather · left outer","type":"sphere","color":"#f6f8ff","position":{"x":-1.63,"y":3.18,"z":-0.14},"rotation":{"x":0,"y":0,"z":34},"scale":{"x":0.19,"y":0.58,"z":0.1},"geometry":{"radius":0.5,"widthSegments":12,"heightSegments":8}},
  {"id":"dahlia-wing-feather-l3","name":"Wing feather · left middle","type":"sphere","color":"#d4e6ff","position":{"x":-1.72,"y":2.82,"z":-0.12},"rotation":{"x":0,"y":0,"z":76},"scale":{"x":0.17,"y":0.56,"z":0.1},"geometry":{"radius":0.5,"widthSegments":12,"heightSegments":8}},
  {"id":"dahlia-wing-feather-l4","name":"Wing feather · left lower","type":"sphere","color":"#eef4ff","position":{"x":-1.48,"y":2.48,"z":-0.1},"rotation":{"x":0,"y":0,"z":112},"scale":{"x":0.16,"y":0.5,"z":0.1},"geometry":{"radius":0.5,"widthSegments":12,"heightSegments":8}},
  {"id":"dahlia-wing-feather-r2","name":"Wing feather · right outer","type":"sphere","color":"#f6f8ff","position":{"x":1.63,"y":3.18,"z":-0.14},"rotation":{"x":0,"y":0,"z":-34},"scale":{"x":0.19,"y":0.58,"z":0.1},"geometry":{"radius":0.5,"widthSegments":12,"heightSegments":8}},
  {"id":"dahlia-wing-feather-r3","name":"Wing feather · right middle","type":"sphere","color":"#d4e6ff","position":{"x":1.72,"y":2.82,"z":-0.12},"rotation":{"x":0,"y":0,"z":-76},"scale":{"x":0.17,"y":0.56,"z":0.1},"geometry":{"radius":0.5,"widthSegments":12,"heightSegments":8}},
  {"id":"dahlia-wing-feather-r4","name":"Wing feather · right lower","type":"sphere","color":"#eef4ff","position":{"x":1.48,"y":2.48,"z":-0.1},"rotation":{"x":0,"y":0,"z":-112},"scale":{"x":0.16,"y":0.5,"z":0.1},"geometry":{"radius":0.5,"widthSegments":12,"heightSegments":8}},
  {"id":"dahlia-hand-left","name":"Hand · left","type":"sphere","color":"#f7d7d5","position":{"x":-0.1,"y":1.73,"z":0.92},"rotation":{"x":0,"y":0,"z":-18},"scale":{"x":0.22,"y":0.14,"z":0.11},"geometry":{"radius":0.5,"widthSegments":14,"heightSegments":10}},
  {"id":"dahlia-hand-right","name":"Hand · right","type":"sphere","color":"#f7d7d5","position":{"x":0.12,"y":1.68,"z":0.94},"rotation":{"x":0,"y":0,"z":12},"scale":{"x":0.22,"y":0.14,"z":0.11},"geometry":{"radius":0.5,"widthSegments":14,"heightSegments":10}},
  {"id":"dahlia-cheek-left","name":"Face · blush left","type":"sphere","color":"#f4b5c6","position":{"x":-0.48,"y":3.27,"z":0.57},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":0.13,"y":0.065,"z":0.025},"geometry":{"radius":0.5,"widthSegments":12,"heightSegments":8}},
  {"id":"dahlia-cheek-right","name":"Face · blush right","type":"sphere","color":"#f4b5c6","position":{"x":0.48,"y":3.27,"z":0.57},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":0.13,"y":0.065,"z":0.025},"geometry":{"radius":0.5,"widthSegments":12,"heightSegments":8}},
  {"id":"dahlia-dress-fold-1","name":"Dress fold · left","type":"curve","color":"#d7eaff","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[-0.46,1.08,0.51],[-0.27,0.86,0.55],[-0.16,0.62,0.55]],"radius":0.018,"tubularSegments":16,"radialSegments":6}},
  {"id":"dahlia-dress-fold-2","name":"Dress fold · right","type":"curve","color":"#b8d1ee","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[0.36,1.0,0.53],[0.22,0.78,0.55],[0.32,0.56,0.53]],"radius":0.022,"tubularSegments":16,"radialSegments":6}},
  {"id":"dahlia-skirt-ruffle-1","name":"Skirt ruffle · left","type":"sphere","color":"#f9fbff","position":{"x":-0.84,"y":0.34,"z":0.58},"rotation":{"x":0,"y":0,"z":-32},"scale":{"x":0.31,"y":0.12,"z":0.07},"geometry":{"radius":0.5,"widthSegments":12,"heightSegments":8}},
  {"id":"dahlia-skirt-ruffle-2","name":"Skirt ruffle · left center","type":"sphere","color":"#f9fbff","position":{"x":-0.43,"y":0.12,"z":0.62},"rotation":{"x":0,"y":0,"z":-12},"scale":{"x":0.29,"y":0.1,"z":0.07},"geometry":{"radius":0.5,"widthSegments":12,"heightSegments":8}},
  {"id":"dahlia-skirt-ruffle-3","name":"Skirt ruffle · right center","type":"sphere","color":"#f9fbff","position":{"x":0.38,"y":0.08,"z":0.62},"rotation":{"x":0,"y":0,"z":14},"scale":{"x":0.3,"y":0.1,"z":0.07},"geometry":{"radius":0.5,"widthSegments":12,"heightSegments":8}},
  {"id":"dahlia-skirt-ruffle-4","name":"Skirt ruffle · right","type":"sphere","color":"#f9fbff","position":{"x":0.84,"y":0.29,"z":0.58},"rotation":{"x":0,"y":0,"z":32},"scale":{"x":0.31,"y":0.12,"z":0.07},"geometry":{"radius":0.5,"widthSegments":12,"heightSegments":8}}
]
'@
$extra = ConvertFrom-Json -InputObject $extraJson
$objects.AddRange([object[]]$extra)
$doc.objects = @($objects)
New-Item -ItemType Directory -Force -Path (Split-Path $targetPath) | Out-Null
$json = ConvertTo-Json -InputObject $doc -Depth 30
[IO.File]::WriteAllText($targetPath, $json, [Text.UTF8Encoding]::new($false))
Write-Host "Wrote $targetPath with $($doc.objects.Count) parts."
