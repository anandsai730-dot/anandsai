$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()
Write-Host "Server started on http://localhost:8080/"

# Automatically open the Default Browser
Start-Process "http://localhost:8080/edited%20proposal.html"

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $localPath = $request.Url.LocalPath.TrimStart('/')
        if ($localPath -eq "") { $localPath = "edited proposal.html" }
        
        $filePath = Join-Path (Get-Location) ([uri]::UnescapeDataString($localPath))
        
        if (Test-Path $filePath -PathType Leaf) {
            $buffer = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $buffer.Length
            
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            if ($ext -eq ".css") { $response.ContentType = "text/css" }
            elseif ($ext -eq ".html") { $response.ContentType = "text/html" }
            elseif ($ext -eq ".jpeg" -or $ext -eq ".jpg") { $response.ContentType = "image/jpeg" }
            
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        } else {
            $response.StatusCode = 404
        }
        $response.Close()
    } catch {
        # ignore error and continue
    }
}
