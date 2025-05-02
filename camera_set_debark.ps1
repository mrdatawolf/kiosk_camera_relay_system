$name = "Camera Set Debarker"
$serverIP = "192.168.10.0"
$serverPort = 8081
$source = "debark"

# Except for grid-template-columns and grid-template-rows you shouldn't need to edit below here
$iframeURLs = @(
    "http://${serverIP}:1984/webrtc.html?src=${source}_1&media=video"
)
$host.UI.RawUI.WindowTitle = $name
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://${serverIP}:${serverPort}/")
$listener.Start()
Write-Output "Listening on http://${serverIP}:${serverPort}/"

# Extract the titles from the URLs and replace underscores with spaces
$iframeTitles = $iframeURLs | ForEach-Object {
    if ($_ -match "src=([^&]+)") {
        ($matches[1] -replace "_", " ") -replace '\b\w', { $_.Value.ToUpper() }
    }
}

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    # Define the HTML content
    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<title>${name}</title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="description" content="A test page for displaying camera feeds in a grid layout.">
<meta name="keywords" content="camera, feed, grid, layout, test">
<meta name="author" content="Your Name">
<style>
    html, body {
        height: 100%;
        margin: 0;
        background-color: black; /* Set the background color to black */
        color: white; /* Set the text color to white */
    }
    .grid-container {
        display: grid;
        grid-template-columns: repeat(1, 1fr);
        grid-template-rows: repeat(1, 1fr);
        gap: 10px; /* Adjust the gap between the grid items as needed */
        height: 100vh; /* Full viewport height */
        padding: 10px;
    }
    .card {
        /* Add shadows to create the "card" effect */
        box-shadow: 0 4px 8px 0 rgba(0,0,0,0.2);
        transition: 0.3s;
        display: flex;
        flex-direction: column;
        background-color: black; /* Set the card background color to black */
        color: white; /* Set the card text color to white */
        height: 100%; /* Ensure the card takes up the full height */
    }
    .card:hover {
        box-shadow: 0 8px 16px 0 rgba(0,0,0,0.2);
    }
    .container {
        padding: 2px 16px;
    }
    iframe {
        flex-grow: 1;
        width: 100%;
        height: 100%; /* Ensure the iframe takes up the full height */
        border: none; /* Remove any default border */
    }
    video {
	height: 99%;
    }
</style>
</head>
<body>
    <div class="grid-container">
"@

    for ($i = 0; $i -lt $iframeURLs.Length; $i++) {
        $html += @"
        <div class="card">
            <iframe src="$($iframeURLs[$i])" name="$($iframeURLs[$i])_Frame" id="$($iframeURLs[$i])_Frame"></iframe>
            <div class="container">
                <h4><b>$($iframeTitles[$i])</b></h4>
            </div>
        </div>
"@
    }

    $html += @"
    </div>
</body>
</html>
"@

    # Convert the HTML content to bytes
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
    $response.ContentLength64 = $buffer.Length
    $response.ContentType = "text/html"
    $response.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate")
    $response.Headers.Add("X-Content-Type-Options", "nosniff")
    $response.Headers.Add("Server", ${name})
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
    $response.OutputStream.Close()
}
$listener.Stop()
