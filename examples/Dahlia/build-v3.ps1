$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$doc = Get-Content -Raw -Encoding utf8 (Join-Path $root 'v2/model.json') | ConvertFrom-Json
$doc.name = 'Dahlia · Seated pose refinement v3'
$objects = [Collections.ArrayList]::new()
$objects.AddRange([object[]]$doc.objects)
foreach ($item in $objects) {
  switch ($item.id) {
    'dahlia-thigh' { $item.position.x = 0.78; $item.position.y = 0.24; $item.position.z = 0.88; $item.scale.x = 1.5; $item.scale.y = 0.43; $item.scale.z = 0.43; $item.rotation.z = -12 }
    'dahlia-apron' { $item.position.z = 0.34 }
    'dahlia-sleeve-left' { $item.position.z = 0.75; $item.position.x = -0.43; $item.position.y = 2.12 }
    'dahlia-sleeve-right' { $item.position.z = 0.78; $item.position.x = 0.4; $item.position.y = 2.18 }
    'dahlia-hand-left' { $item.position.z = 1.0; $item.position.x = -0.08; $item.position.y = 1.97 }
    'dahlia-hand-right' { $item.position.z = 1.02; $item.position.x = 0.12; $item.position.y = 1.9 }
    'dahlia-eye-left' { $item.scale.x = 0.16; $item.scale.y = 0.235; $item.position.y = 3.55 }
    'dahlia-eye-right' { $item.scale.x = 0.16; $item.scale.y = 0.235; $item.position.y = 3.55 }
    'dahlia-pupil-left' { $item.scale.y = 0.13 }
    'dahlia-pupil-right' { $item.scale.y = 0.13 }
    'dahlia-cheek-left' { $item.position.z = 0.64 }
    'dahlia-cheek-right' { $item.position.z = 0.64 }
  }
}
$extraJson = @'
[
  {"id":"dahlia-eye-white-left","name":"Eye · left soft white","type":"sphere","color":"#f8f5ff","position":{"x":-0.3,"y":3.55,"z":0.635},"rotation":{"x":0,"y":0,"z":-8},"scale":{"x":0.175,"y":0.245,"z":0.035},"geometry":{"radius":0.5,"widthSegments":16,"heightSegments":12}},
  {"id":"dahlia-eye-white-right","name":"Eye · right soft white","type":"sphere","color":"#f8f5ff","position":{"x":0.3,"y":3.55,"z":0.635},"rotation":{"x":0,"y":0,"z":-8},"scale":{"x":0.175,"y":0.245,"z":0.035},"geometry":{"radius":0.5,"widthSegments":16,"heightSegments":12}},
  {"id":"dahlia-arm-cross-upper","name":"Sleeve · crossing forearm","type":"sphere","color":"#b7d2f2","position":{"x":0.02,"y":2.12,"z":0.92},"rotation":{"x":0,"y":0,"z":-17},"scale":{"x":0.72,"y":0.22,"z":0.19},"geometry":{"radius":0.5,"widthSegments":20,"heightSegments":12}},
  {"id":"dahlia-arm-cross-lower","name":"Sleeve · folded forearm","type":"sphere","color":"#d3e3f7","position":{"x":-0.11,"y":1.88,"z":0.95},"rotation":{"x":0,"y":0,"z":13},"scale":{"x":0.62,"y":0.2,"z":0.17},"geometry":{"radius":0.5,"widthSegments":20,"heightSegments":12}},
  {"id":"dahlia-cuff-left","name":"Sleeve cuff · left","type":"torus","color":"#f8fbff","position":{"x":-0.53,"y":2.13,"z":0.76},"rotation":{"x":72,"y":0,"z":-42},"scale":{"x":0.55,"y":0.55,"z":0.48},"geometry":{"radius":0.34,"tube":0.08,"radialSegments":8,"tubularSegments":20}},
  {"id":"dahlia-cuff-right","name":"Sleeve cuff · right","type":"torus","color":"#f8fbff","position":{"x":0.52,"y":2.18,"z":0.78},"rotation":{"x":72,"y":0,"z":42},"scale":{"x":0.53,"y":0.53,"z":0.48},"geometry":{"radius":0.32,"tube":0.08,"radialSegments":8,"tubularSegments":20}},
  {"id":"dahlia-arm-highlight","name":"Sleeve fold · highlight","type":"curve","color":"#e7f4ff","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[-0.46,2.21,1.04],[-0.15,2.25,1.08],[0.18,2.2,1.08],[0.42,2.08,1.04]],"radius":0.018,"tubularSegments":20,"radialSegments":6}},
  {"id":"dahlia-thigh-highlight","name":"Leg · soft highlight","type":"curve","color":"#ffe6e3","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[0.18,0.28,1.26],[0.62,0.39,1.29],[1.08,0.37,1.25],[1.42,0.24,1.18]],"radius":0.018,"tubularSegments":20,"radialSegments":6}},
  {"id":"dahlia-skirt-hem","name":"Skirt · curved hem piping","type":"curve","color":"#a9c8eb","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[-0.9,0.22,0.61],[-0.48,-0.02,0.66],[0.02,-0.1,0.67],[0.49,-0.01,0.64],[0.91,0.25,0.58]],"radius":0.018,"tubularSegments":28,"radialSegments":6}},
  {"id":"dahlia-boot-strap-left","name":"Boot strap · left","type":"curve","color":"#c4d9f4","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[-0.93,-1.12,0.5],[-0.73,-1.08,0.55],[-0.52,-1.13,0.5]],"radius":0.035,"tubularSegments":12,"radialSegments":6}},
  {"id":"dahlia-boot-strap-right","name":"Boot strap · right","type":"curve","color":"#c4d9f4","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[0.51,-1.1,0.56],[0.75,-1.05,0.58],[0.96,-1.12,0.52]],"radius":0.035,"tubularSegments":12,"radialSegments":6}},
  {"id":"dahlia-sock-rim-left","name":"Boot · left sock rim","type":"torus","color":"#ffffff","position":{"x":-0.42,"y":-0.88,"z":0.06},"rotation":{"x":90,"y":0,"z":22},"scale":{"x":0.33,"y":0.33,"z":0.75},"geometry":{"radius":0.35,"tube":0.055,"radialSegments":8,"tubularSegments":20}},
  {"id":"dahlia-sock-rim-right","name":"Boot · right sock rim","type":"torus","color":"#ffffff","position":{"x":1.0,"y":-0.86,"z":0.06},"rotation":{"x":90,"y":0,"z":-34},"scale":{"x":0.33,"y":0.33,"z":0.75},"geometry":{"radius":0.35,"tube":0.055,"radialSegments":8,"tubularSegments":20}}
]
'@
$objects.AddRange([object[]](ConvertFrom-Json -InputObject $extraJson))
$doc.objects = @($objects)
$targetDir = Join-Path $root 'v3'
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
[IO.File]::WriteAllText((Join-Path $targetDir 'model.json'), (ConvertTo-Json -InputObject $doc -Depth 30), [Text.UTF8Encoding]::new($false))
Write-Host "Wrote v3 with $($doc.objects.Count) parts."
