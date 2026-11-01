$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$doc = Get-Content -Raw -Encoding utf8 (Join-Path $root 'v5/model.json') | ConvertFrom-Json
$doc.name = 'Dahlia - Toon pose study v6'
$left = $doc.objects | Where-Object id -eq 'dahlia-sleeve-left'
$left.geometry.points3D = @(@(-0.56,2.42,0.58),@(-0.58,2.2,0.86),@(-0.26,2.04,1.12),@(0.18,2.12,1.18))
$left.geometry.radiusStart = 0.28; $left.geometry.radiusEnd = 0.2
$right = $doc.objects | Where-Object id -eq 'dahlia-sleeve-right'
$right.geometry.points3D = @(@(0.56,2.44,0.58),@(0.58,2.2,0.9),@(0.25,2.14,1.16),@(-0.16,2.02,1.2))
$right.geometry.radiusStart = 0.28; $right.geometry.radiusEnd = 0.2
$leftHand = $doc.objects | Where-Object id -eq 'dahlia-hand-left'
$leftHand.position = [pscustomobject]@{x=-0.12;y=2.04;z=1.36}; $leftHand.scale = [pscustomobject]@{x=0.24;y=0.15;z=0.12}
$rightHand = $doc.objects | Where-Object id -eq 'dahlia-hand-right'
$rightHand.position = [pscustomobject]@{x=0.12;y=2.08;z=1.38}; $rightHand.scale = [pscustomobject]@{x=0.23;y=0.15;z=0.12}
$doc.objects += @(
  [pscustomobject]@{id='dahlia-shoulder-puff-left';name='Sleeve - left shoulder volume';type='sphere';color='#b7d2f2';position=[pscustomobject]@{x=-0.54;y=2.39;z=0.54};rotation=[pscustomobject]@{x=0;y=0;z=-20};scale=[pscustomobject]@{x=0.31;y=0.34;z=0.3};geometry=[pscustomobject]@{radius=0.5;widthSegments=20;heightSegments=14}},
  [pscustomobject]@{id='dahlia-shoulder-puff-right';name='Sleeve - right shoulder volume';type='sphere';color='#c8dcf5';position=[pscustomobject]@{x=0.54;y=2.41;z=0.54};rotation=[pscustomobject]@{x=0;y=0;z=20};scale=[pscustomobject]@{x=0.31;y=0.34;z=0.3};geometry=[pscustomobject]@{radius=0.5;widthSegments=20;heightSegments=14}}
)
$target = Join-Path $root 'v6'
New-Item -ItemType Directory -Force -Path (Join-Path $target 'reference') | Out-Null
[IO.File]::WriteAllText((Join-Path $target 'model.json'),(ConvertTo-Json -InputObject $doc -Depth 40),[Text.UTF8Encoding]::new($false))
Copy-Item (Join-Path $root 'v5/reference/angel-pixel-reference.png') (Join-Path $target 'reference/angel-pixel-reference.png') -Force
Write-Host "Wrote v6 with $($doc.objects.Count) objects."
