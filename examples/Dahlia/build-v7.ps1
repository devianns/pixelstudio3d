$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$doc = Get-Content -Raw -Encoding utf8 (Join-Path $root 'v6/model.json') | ConvertFrom-Json
$doc.name = 'Dahlia - authored low-poly surfaces v7'
$doc.settings.renderStyle = 'toon'
$doc.objects = @()
function Add-VertexMesh([string]$id,[string]$name,[object[]]$outline,[double]$front,[double]$back,[string]$frontColor,[string]$backColor,[double]$centerX=0,[double]$centerY=0) {
  $pts = @($outline | ForEach-Object { ,@([double]$_[0],[double]$_[1]) })
  $area = 0.0
  for($i=0;$i -lt $pts.Count;$i++){ $n=($i+1)%$pts.Count; $area += $pts[$i][0]*$pts[$n][1]-$pts[$n][0]*$pts[$i][1] }
  if($area -lt 0){ [array]::Reverse($pts) }
  $n=$pts.Count; $vertices=[Collections.Generic.List[object]]::new();$colors=[Collections.Generic.List[string]]::new();$triangles=[Collections.Generic.List[object]]::new()
  foreach($p in $pts){$vertices.Add(@($p[0],$p[1],$front));$colors.Add($frontColor)}
  foreach($p in $pts){$vertices.Add(@($p[0],$p[1],$back));$colors.Add($backColor)}
  $frontCenter=$vertices.Count;$vertices.Add(@($centerX,$centerY,$front));$colors.Add($frontColor)
  $backCenter=$vertices.Count;$vertices.Add(@($centerX,$centerY,$back));$colors.Add($backColor)
  for($i=0;$i -lt $n;$i++){$next=($i+1)%$n;$triangles.Add(@($frontCenter,$i,$next));$triangles.Add(@($backCenter,($n+$next),($n+$i)));$triangles.Add(@($i,($n+$i),($n+$next)));$triangles.Add(@($i,($n+$next),$next))}
  $geometry=[pscustomobject]@{vertices=@($vertices.ToArray());triangles=@($triangles.ToArray());vertexColors=@($colors.ToArray())}
  $doc.objects += [pscustomobject]@{id=$id;name=$name;type='mesh';color='#ffffff';position=[pscustomobject]@{x=0;y=0;z=0};rotation=[pscustomobject]@{x=0;y=0;z=0};scale=[pscustomobject]@{x=1;y=1;z=1};geometry=$geometry}
}
function Add-RingMesh([string]$id,[string]$name,[double]$cx,[double]$cy,[double]$major,[double]$tube,[double]$z,[string]$color) {
  $vertices=[Collections.Generic.List[object]]::new();$colors=[Collections.Generic.List[string]]::new();$triangles=[Collections.Generic.List[object]]::new();$around=32;$section=8
  for($i=0;$i -lt $around;$i++){ $a=2*[Math]::PI*$i/$around; for($j=0;$j -lt $section;$j++){ $b=2*[Math]::PI*$j/$section;$radialDistance=[double]$major+([double]$tube*[Math]::Cos($b));$vx=[double]$cx+($radialDistance*[Math]::Cos($a));$vy=[double]$cy+($radialDistance*[Math]::Sin($a));$vz=[double]$z+([double]$tube*[Math]::Sin($b));$vertices.Add(@($vx,$vy,$vz));$colors.Add($color) } }
  for($i=0;$i -lt $around;$i++){for($j=0;$j -lt $section;$j++){ $ni=($i+1)%$around;$nj=($j+1)%$section;$a=$i*$section+$j;$b=$ni*$section+$j;$c=$ni*$section+$nj;$d=$i*$section+$nj;$triangles.Add(@($a,$b,$c));$triangles.Add(@($a,$c,$d)) }}
  $doc.objects += [pscustomobject]@{id=$id;name=$name;type='mesh';color='#ffffff';position=[pscustomobject]@{x=0;y=0;z=0};rotation=[pscustomobject]@{x=0;y=0;z=0};scale=[pscustomobject]@{x=1;y=1;z=1};geometry=[pscustomobject]@{vertices=@($vertices.ToArray());triangles=@($triangles.ToArray());vertexColors=@($colors.ToArray())}}
}
# Back hair silhouette and the two wing planes are authored outlines, then explicitly triangulated into indexed meshes.
Add-VertexMesh 'dahlia-hair-back' 'Hair - long back silhouette' @(@(-0.98,4.25),@(-0.72,4.85),@(0.15,5.08),@(0.88,4.62),@(1.04,3.25),@(0.72,2.65),(0.35,3.12),@(0.0,2.8),@(-0.38,3.18),@(-0.78,2.82),@(-1.05,3.55)) -0.12 -0.36 '#91d9ed' '#4d89b4'
Add-VertexMesh 'dahlia-wing-left' 'Wing - left custom silhouette' @(@(-0.55,3.0),@(-1.15,3.42),@(-1.72,3.82),@(-1.58,3.48),@(-2.25,3.72),@(-1.9,3.34),@(-2.42,3.38),@(-1.82,3.12),@(-2.12,2.9),@(-1.35,2.82)) -0.22 -0.38 '#edf5ff' '#8daed8'
Add-VertexMesh 'dahlia-wing-right' 'Wing - right custom silhouette' @(@(0.55,3.0),@(1.15,3.42),@(1.72,3.82),@(1.58,3.48),@(2.25,3.72),(1.9,3.34),(2.42,3.38),(1.82,3.12),(2.12,2.9),(1.35,2.82)) -0.22 -0.38 '#edf5ff' '#8daed8'
Add-VertexMesh 'dahlia-skirt' 'Skirt - flared custom surface' @(@(-1.02,1.2),@(-0.78,2.0),@(-0.42,2.16),@(0.42,2.16),@(0.78,2.0),@(1.02,1.2),@(0.72,0.88),@(0.35,1.0),(0.0,0.84),@(-0.35,1.0),@(-0.72,0.88)) 0.16 -0.32 '#d9e9ff' '#829fc8' 0 1.5
Add-VertexMesh 'dahlia-torso' 'Tunic - fitted custom surface' @(@(-0.56,2.0),@(-0.48,2.72),@(-0.24,2.94),@(0.24,2.94),@(0.48,2.72),@(0.56,2.0),@(0.3,1.77),@(-0.3,1.77)) 0.24 -0.18 '#91afd8' '#5d79a7' 0 2.35
Add-VertexMesh 'dahlia-face' 'Face - shaped low-poly surface' @(@(-0.62,4.48),@(-0.52,3.8),@(-0.26,3.52),(0.0,3.43),(0.26,3.52),(0.52,3.8),(0.62,4.48),(0.42,4.82),(0.0,4.94),@(-0.42,4.82)) 0.47 0.0 '#ffe1dc' '#c6929c' 0 4.18
Add-VertexMesh 'dahlia-hair-cap' 'Hair - crown mesh' @(@(-0.76,4.38),@(-0.7,4.82),@(-0.42,5.08),(0.05,5.15),(0.52,4.99),(0.77,4.63),(0.46,4.42),(0.2,4.58),@(-0.1,4.4),@(-0.42,4.58)) 0.56 0.1 '#f7fbff' '#9cb5d5' 0 4.83
Add-VertexMesh 'dahlia-bang-left' 'Hair - left bang mesh' @(@(-0.69,4.8),@(-0.42,4.94),@(-0.16,4.7),@(-0.25,4.25),@(-0.49,4.02),@(-0.45,4.43),@(-0.72,4.21)) 0.68 0.52 '#e7f2ff' '#9cb5d5' -0.43 4.52
Add-VertexMesh 'dahlia-bang-right' 'Hair - right bang mesh' @(@(-0.15,4.92),@(0.15,5.0),@(0.48,4.79),@(0.54,4.38),(0.28,4.15),(0.18,4.55),@(-0.05,4.3)) 0.7 0.54 '#d9ebff' '#91abc9' 0.2 4.6
Add-VertexMesh 'dahlia-eye-left' 'Eye - left custom color mesh' @(@(-0.4,4.05),@(-0.34,4.16),@(-0.21,4.16),@(-0.15,4.05),@(-0.21,3.94),@(-0.34,3.94)) 0.76 0.71 '#217cae' '#143c68' -0.275 4.05
Add-VertexMesh 'dahlia-eye-right' 'Eye - right custom color mesh' @(@(0.15,4.05),@(0.21,4.16),(0.34,4.16),(0.4,4.05),(0.34,3.94),(0.21,3.94)) 0.76 0.71 '#217cae' '#143c68' 0.275 4.05
Add-VertexMesh 'dahlia-apron' 'Apron - front panel mesh' @(@(-0.48,1.75),@(-0.3,1.96),(0.3,1.96),(0.48,1.75),(0.38,1.08),(0.0,1.02),@(-0.38,1.08)) 0.42 0.36 '#fff8f2' '#a7bddd' 0 1.47
Add-VertexMesh 'dahlia-arm-left' 'Sleeve - left folded arm mesh' @(@(-0.49,2.72),@(-0.22,2.76),(0.03,2.35),@(-0.28,2.22),@(-0.58,2.42)) 0.57 0.32 '#b7d0ef' '#7592bc' -0.28 2.5
Add-VertexMesh 'dahlia-arm-right' 'Sleeve - right folded arm mesh' @(@(0.49,2.72),(0.22,2.76),@(-0.03,2.35),(0.28,2.22),(0.58,2.42)) 0.62 0.37 '#c5dcf5' '#819dc5' 0.28 2.5
Add-RingMesh 'dahlia-halo' 'Halo - authored ring mesh' 0 5.38 0.74 0.035 -0.18 '#ffe2a2'
$target=Join-Path $root 'v7';New-Item -ItemType Directory -Force -Path (Join-Path $target 'reference')|Out-Null
[IO.File]::WriteAllText((Join-Path $target 'model.json'),(ConvertTo-Json -InputObject $doc -Depth 30),[Text.UTF8Encoding]::new($false))
Copy-Item (Join-Path $root 'v6/reference/angel-pixel-reference.png') (Join-Path $target 'reference/angel-pixel-reference.png') -Force
Write-Host "Wrote v7 direct-vertex model with $($doc.objects.Count) authored mesh objects."
