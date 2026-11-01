param([int]$Port = 8000)

$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath($PSScriptRoot)
$prefix = "http://127.0.0.1:$Port/"
$listener = [Net.HttpListener]::new()
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Host "Pixel Studio 3D: $prefix (Ctrl+C to stop)"

try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $relative = [Uri]::UnescapeDataString($context.Request.Url.AbsolutePath.TrimStart('/'))
    if ([string]::IsNullOrWhiteSpace($relative)) { $relative = 'index.html' }
    $file = [IO.Path]::GetFullPath((Join-Path $root $relative))
    $insideRoot = $file.StartsWith($root.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)

    if (-not $insideRoot -or -not (Test-Path -LiteralPath $file -PathType Leaf)) {
      $context.Response.StatusCode = 404
      $context.Response.Close()
      continue
    }

    $context.Response.ContentType = switch ([IO.Path]::GetExtension($file).ToLowerInvariant()) {
      '.html' { 'text/html; charset=utf-8' }
      '.js' { 'text/javascript; charset=utf-8' }
      '.css' { 'text/css; charset=utf-8' }
      '.json' { 'application/json; charset=utf-8' }
      '.png' { 'image/png' }
      '.jpg' { 'image/jpeg' }
      '.jpeg' { 'image/jpeg' }
      '.webp' { 'image/webp' }
      '.svg' { 'image/svg+xml' }
      default { 'application/octet-stream' }
    }
    $bytes = [IO.File]::ReadAllBytes($file)
    $context.Response.ContentLength64 = $bytes.Length
    if ($context.Request.HttpMethod -ne 'HEAD') {
      $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    }
    $context.Response.Close()
  }
} finally {
  $listener.Stop()
  $listener.Close()
}
