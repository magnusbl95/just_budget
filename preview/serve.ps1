param(
    [int]$Port = 8085,
    [string]$Root = "c:\code\just_budget\preview"
)

$endpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Loopback, $Port)
$listener = New-Object System.Net.Sockets.TcpListener($endpoint)

try {
    $listener.Start()
    Write-Host "=========================================================="
    Write-Host " Just Budget Live Preview running on http://localhost:$Port/"
    Write-Host "=========================================================="
} catch {
    Write-Error "Failed to start listener on port $($Port): $_"
    exit 1
}

# Open default browser
Start-Process "http://localhost:$Port/"

while ($true) {
    try {
        $client = $listener.AcceptTcpClient()
        $stream = $client.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $line = $reader.ReadLine()

        if ($line) {
            $parts = $line.Split(" ")
            $rawPath = if ($parts.Length -gt 1) { $parts[1] } else { "/" }
            $cleanPath = $rawPath.Split("?")[0].TrimStart('/')
            if ([string]::IsNullOrEmpty($cleanPath)) { $cleanPath = "index.html" }

            $filePath = Join-Path $Root $cleanPath

            if (Test-Path $filePath -PathType Leaf) {
                $bytes = [System.IO.File]::ReadAllBytes($filePath)
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                $mime = switch ($ext) {
                    ".html" { "text/html; charset=utf-8" }
                    ".css"  { "text/css" }
                    ".js"   { "application/javascript" }
                    default { "application/octet-stream" }
                }

                $header = "HTTP/1.1 200 OK`r`nContent-Type: $mime`r`nContent-Length: $($bytes.Length)`r`nAccess-Control-Allow-Origin: *`r`nConnection: close`r`n`r`n"
                $headerBytes = [System.Text.Encoding]::UTF8.GetBytes($header)
                $stream.Write($headerBytes, 0, $headerBytes.Length)
                $stream.Write($bytes, 0, $bytes.Length)
            } else {
                $notFound = "HTTP/1.1 404 Not Found`r`nContent-Length: 9`r`nConnection: close`r`n`r`nNot Found"
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($notFound)
                $stream.Write($bytes, 0, $bytes.Length)
            }
        }
        $stream.Flush()
        $client.Close()
    } catch {
        # ignore disconnects
    }
}
