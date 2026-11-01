$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$doc = Get-Content -Raw -Encoding utf8 (Join-Path $root 'v4/model.json') | ConvertFrom-Json
$doc.name = 'Dahlia - Toon character body v5'
$doc.settings | Add-Member -NotePropertyName renderStyle -NotePropertyValue 'toon' -Force
$doc.settings | Add-Member -NotePropertyName floorY -NotePropertyValue ([double]-1.4) -Force
$doc.settings.bounds = [pscustomobject]@{ x = 5.5; y = 6.5; z = 4 }
$objects = [Collections.ArrayList]::new()
$objects.AddRange([object[]]$doc.objects)
$removeIds = @('dahlia-arm-cross-upper','dahlia-arm-cross-lower')
foreach ($item in $objects) {
  switch ($item.id) {
    'dahlia-dress' {
      $item.type = 'loft'; $item.name = 'Dress - rounded fitted torso'; $item.color = '#8eaed8'
      $item.position = [pscustomobject]@{x=0;y=1.63;z=0.02}; $item.rotation = [pscustomobject]@{x=0;y=0;z=-5}; $item.scale = [pscustomobject]@{x=1;y=1;z=1}
      $item.geometry = ConvertFrom-Json '{"radialSegments":32,"rings":[[-0.92,0,0,0.38,0.28],[-0.6,0,0,0.45,0.31],[-0.18,0,0,0.42,0.3],[0.28,0,0,0.5,0.34],[0.72,0,0,0.68,0.36],[0.94,0,0,0.61,0.32],[1.08,0,0,0.42,0.27]]}'
    }
    'dahlia-skirt' {
      $item.type = 'loft'; $item.name = 'Dress - flared rounded skirt'; $item.color = '#dceaff'
      $item.position = [pscustomobject]@{x=0;y=0.92;z=0.08}; $item.rotation = [pscustomobject]@{x=0;y=0;z=5}; $item.scale = [pscustomobject]@{x=1;y=1;z=1}
      $item.geometry = ConvertFrom-Json '{"radialSegments":36,"rings":[[-0.78,0,0,1.06,0.62],[-0.65,0,0,1.12,0.66],[-0.42,0,0,1.0,0.61],[-0.16,0,0,0.78,0.52],[0.08,0,0,0.55,0.42],[0.28,0,0,0.43,0.34]]}'
    }
    'dahlia-apron' { $item.position.y = 0.82; $item.position.z = 0.71; $item.scale = [pscustomobject]@{x=0.72;y=0.6;z=0.22} }
    'dahlia-sleeve-left' {
      $item.type='curve';$item.name='Arm · tapered left sleeve';$item.position=[pscustomobject]@{x=0;y=0;z=0};$item.rotation=[pscustomobject]@{x=0;y=0;z=0};$item.scale=[pscustomobject]@{x=1;y=1;z=1}
      $item.geometry=ConvertFrom-Json '{"points3D":[[-0.52,2.38,0.36],[-0.47,2.15,0.63],[-0.22,1.97,0.89],[0.04,1.92,1.0]],"radius":0.2,"radiusStart":0.23,"radiusEnd":0.145,"tubularSegments":32,"radialSegments":12}'
    }
    'dahlia-sleeve-right' {
      $item.type='curve';$item.name='Arm · tapered folded sleeve';$item.position=[pscustomobject]@{x=0;y=0;z=0};$item.rotation=[pscustomobject]@{x=0;y=0;z=0};$item.scale=[pscustomobject]@{x=1;y=1;z=1}
      $item.geometry=ConvertFrom-Json '{"points3D":[[0.5,2.45,0.36],[0.45,2.2,0.68],[0.2,2.04,0.92],[-0.05,1.99,1.0]],"radius":0.2,"radiusStart":0.23,"radiusEnd":0.14,"tubularSegments":32,"radialSegments":12}'
    }
    'dahlia-thigh' {
      $item.type='curve';$item.name='Leg · seated foreground thigh';$item.position=[pscustomobject]@{x=0;y=0;z=0};$item.rotation=[pscustomobject]@{x=0;y=0;z=0};$item.scale=[pscustomobject]@{x=1;y=1;z=1}
      $item.geometry=ConvertFrom-Json '{"points3D":[[0.05,0.28,0.78],[0.42,0.43,0.86],[0.88,0.39,0.82],[1.3,0.2,0.68]],"radius":0.25,"radiusStart":0.24,"radiusEnd":0.16,"tubularSegments":36,"radialSegments":14}'
    }
    'dahlia-leg-left' {
      $item.type='curve';$item.name='Leg · left lower leg';$item.position=[pscustomobject]@{x=0;y=0;z=0};$item.rotation=[pscustomobject]@{x=0;y=0;z=0};$item.scale=[pscustomobject]@{x=1;y=1;z=1}
      $item.geometry=ConvertFrom-Json '{"points3D":[[-0.32,0.02,0.2],[-0.42,-0.35,0.3],[-0.61,-0.78,0.24],[-0.62,-0.98,0.18]],"radius":0.13,"radiusStart":0.145,"radiusEnd":0.09,"tubularSegments":28,"radialSegments":12}'
    }
    'dahlia-leg-right' {
      $item.type='curve';$item.name='Leg · right lower leg';$item.position=[pscustomobject]@{x=0;y=0;z=0};$item.rotation=[pscustomobject]@{x=0;y=0;z=0};$item.scale=[pscustomobject]@{x=1;y=1;z=1}
      $item.geometry=ConvertFrom-Json '{"points3D":[[0.65,0.04,0.25],[0.83,-0.34,0.34],[0.87,-0.74,0.27],[0.84,-0.96,0.18]],"radius":0.14,"radiusStart":0.15,"radiusEnd":0.09,"tubularSegments":28,"radialSegments":12}'
    }
  }
}
$kept = @($objects | Where-Object { $removeIds -notcontains $_.id })
$doc.objects = $kept
$targetDir = Join-Path $root 'v5'
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
[IO.File]::WriteAllText((Join-Path $targetDir 'model.json'), (ConvertTo-Json -InputObject $doc -Depth 30), [Text.UTF8Encoding]::new($false))
Write-Host "Wrote v5 with $($doc.objects.Count) parts; renderStyle=$($doc.settings.renderStyle)."
