$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$doc = Get-Content -Raw -Encoding utf8 (Join-Path $root 'v3/model.json') | ConvertFrom-Json
$doc.name = 'Dahlia · Flowing hair and tilted pose v4'
$objects = [Collections.ArrayList]::new()
$objects.AddRange([object[]]$doc.objects)
$headIds = @(
  'dahlia-face','dahlia-ear-left','dahlia-ear-right','dahlia-eye-left','dahlia-eye-right',
  'dahlia-pupil-left','dahlia-pupil-right','dahlia-eye-glint-l','dahlia-eye-glint-r',
  'dahlia-hair-cap','dahlia-hair-back','dahlia-lock-left','dahlia-lock-right','dahlia-bangs',
  'dahlia-bang-cyan','dahlia-star-pink','dahlia-star-blue','dahlia-mouth','dahlia-cheek-left',
  'dahlia-cheek-right','dahlia-hair-strand-a','dahlia-hair-strand-b','dahlia-hair-strand-c',
  'dahlia-lock-curve-left','dahlia-lock-curve-right'
)
$angle = -14.0
$radians = $angle * [Math]::PI / 180
$cos = [Math]::Cos($radians)
$sin = [Math]::Sin($radians)
foreach ($item in $objects) {
  if ($headIds -contains $item.id) {
    $x = [double]$item.position.x
    $y = [double]$item.position.y - 3.55
    $item.position.x = [Math]::Round($x * $cos - $y * $sin, 4)
    $item.position.y = [Math]::Round($x * $sin + $y * $cos + 3.55, 4)
    $item.rotation.z = [Math]::Round([double]$item.rotation.z + $angle, 2)
  }
  switch ($item.id) {
    'dahlia-wing-left' { $item.position.y = 2.96; $item.rotation.z = 7 }
    'dahlia-wing-right' { $item.position.x = 0.62; $item.position.y = 3.08; $item.rotation.z = -39; $item.scale.y = 1.16 }
    'dahlia-wing-feather-right' { $item.rotation.z = -38; $item.position.y = 2.78 }
    'dahlia-wing-feather-r2' { $item.rotation.z = -48; $item.position.x = 1.56; $item.position.y = 3.26 }
    'dahlia-wing-feather-r3' { $item.rotation.z = -70; $item.position.x = 1.74; $item.position.y = 3.1 }
    'dahlia-wing-feather-r4' { $item.rotation.z = -98; $item.position.x = 1.84; $item.position.y = 2.82 }
    'dahlia-dress' { $item.rotation.z = -5 }
    'dahlia-skirt' { $item.rotation.z = 5 }
    'dahlia-apron' { $item.rotation.z = 4 }
  }
}
$extraJson = @'
[
  {"id":"dahlia-flow-lock-right-a","name":"Hair flow · right ribbon A","type":"curve","color":"#eef8ff","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[0.66,4.15,0.42],[1.02,4.25,0.25],[1.34,4.08,0.05],[1.52,3.82,-0.08]],"radius":0.06,"tubularSegments":36,"radialSegments":8}},
  {"id":"dahlia-flow-lock-right-b","name":"Hair flow · cyan ribbon","type":"curve","color":"#75dff3","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[0.68,4.3,0.22],[1.08,4.52,0.02],[1.44,4.48,-0.12],[1.7,4.28,-0.2]],"radius":0.075,"tubularSegments":36,"radialSegments":8}},
  {"id":"dahlia-flow-lock-right-c","name":"Hair flow · fine silver strand","type":"curve","color":"#c5e7fb","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[0.55,4.42,0.34],[0.92,4.58,0.16],[1.28,4.59,-0.04],[1.58,4.49,-0.18]],"radius":0.025,"tubularSegments":36,"radialSegments":6}},
  {"id":"dahlia-flow-lock-left-a","name":"Hair flow · left long tail","type":"curve","color":"#e9f5ff","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[-0.68,3.6,0.36],[-1.0,3.2,0.18],[-1.1,2.65,0.03],[-1.34,2.24,-0.1],[-1.58,2.05,-0.16]],"radius":0.065,"tubularSegments":40,"radialSegments":8}},
  {"id":"dahlia-flow-lock-left-b","name":"Hair flow · left blue strand","type":"curve","color":"#81dff1","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[-0.7,3.45,0.3],[-0.96,3.0,0.16],[-0.92,2.55,0.02],[-1.15,2.16,-0.08]],"radius":0.035,"tubularSegments":36,"radialSegments":7}},
  {"id":"dahlia-hair-tip-highlight","name":"Hair highlight · long contour","type":"curve","color":"#ffffff","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[-0.82,3.9,0.71],[-0.94,3.42,0.59],[-0.93,2.9,0.43],[-1.18,2.38,0.12]],"radius":0.014,"tubularSegments":36,"radialSegments":5}},
  {"id":"dahlia-wing-gold-accent","name":"Wing · warm glint","type":"curve","color":"#ffe5b4","position":{"x":0,"y":0,"z":0},"rotation":{"x":0,"y":0,"z":0},"scale":{"x":1,"y":1,"z":1},"geometry":{"points3D":[[1.18,3.2,-0.01],[1.48,3.48,-0.01],[1.73,3.64,-0.02]],"radius":0.018,"tubularSegments":20,"radialSegments":5}}
]
'@
$objects.AddRange([object[]](ConvertFrom-Json -InputObject $extraJson))
$doc.objects = @($objects)
$targetDir = Join-Path $root 'v4'
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
[IO.File]::WriteAllText((Join-Path $targetDir 'model.json'), (ConvertTo-Json -InputObject $doc -Depth 30), [Text.UTF8Encoding]::new($false))
Write-Host "Wrote v4 with $($doc.objects.Count) parts."
