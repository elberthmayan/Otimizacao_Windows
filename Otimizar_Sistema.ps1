# Modulo de Remocao de Bloatwares - Limpeza do Sistema
# Requisito: Executar como Administrador

# ---------------------------------------------------------
# 1. Remocao Forcada de Bloatwares (Usando Curingas)
# ---------------------------------------------------------
$bloatwares = @(
    "BingWeather",
    "GetHelp",
    "Getstarted",
    "Microsoft3DViewer",
    "MicrosoftOfficeHub",
    "MicrosoftSolitaireCollection",
    "MixedReality.Portal",
    "SkypeApp",
    "WindowsFeedbackHub",
    "WindowsMaps",
    "YourPhone",
    "ZuneMusic",
    "ZuneVideo",
    "Xbox.TCUI",
    "XboxApp",
    "XboxGameCallableUI",
    "XboxGameOverlay",
    "XboxGamingOverlay",
    "XboxIdentityProvider",
    "XboxSpeechToTextOverlay",
    "windowscommunicationsapps",
    "MSPaint",
    "Office.OneNote",
    "549981C3F5F10",       # Cortana
    "Microsoft.People",    # Pessoas
    "WindowsCamera",       # Camera
    "WindowsSoundRecorder",# Gravador de Voz
    
    # --- Tranqueiras Patrocinadas (Third-Party) ---
    "Spotify",
    "Netflix",
    "Instagram",
    "Facebook",
    "TikTok",
    "CandyCrush",
    "PrimeVideo",
    "Disney",
    "MarchofEmpires"
    # LinkedIn FOI MANTIDO de fora, conforme solicitado.
)

Write-Host "Iniciando a varredura profunda e remocao dos pacotes UWP..." -ForegroundColor Cyan

foreach ($app in $bloatwares) {
    Write-Host "Cacando e limpando pacote que contem: $app" -ForegroundColor Yellow
    
    # O uso do asterisco (*) garante que ele encontre o pacote, nao importa o ID que a Microsoft coloque
    Get-AppxPackage -Name "*$app*" -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue 2>$null
    
    # Remove da base do Windows para nao reinstalar se criar outro usuario
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object {$_.DisplayName -match $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue 2>$null
}

# ---------------------------------------------------------
# 2. Remocao bruta do OneDrive
# ---------------------------------------------------------
Write-Host "Eliminando o OneDrive..." -ForegroundColor Cyan

# Encerra o processo se estiver em execucao
taskkill /f /im OneDrive.exe -ErrorAction SilentlyContinue 2>$null
Start-Sleep -Seconds 2

# Busca e executa o desinstalador nativo silenciosamente
if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
    Start-Process "$env:systemroot\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -NoNewWindow
} elseif (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
    Start-Process "$env:systemroot\SysWOW64\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -NoNewWindow
}

Write-Host "Rotina de Bloatwares concluida com sucesso!" -ForegroundColor Green

# ---------------------------------------------------------
# 3. Ajustes de Registro e Otimizacao do Sistema
# ---------------------------------------------------------
Write-Host "Aplicando ajustes avancados no Registro..." -ForegroundColor Cyan

# Proibir o Windows de baixar apps de terceiros patrocinados sozinho (Netflix, Spotify, Joguinhos)
Write-Host "-> Bloqueando a instalacao automatica de apps patrocinados..." -ForegroundColor Yellow
$CloudContentPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
if (-not (Test-Path $CloudContentPath)) { New-Item -Path $CloudContentPath -Force | Out-Null }
Set-ItemProperty -Path $CloudContentPath -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1 -Force

# Impedir que o Edge assuma o controle dos PDFs
Write-Host "-> Bloqueando o Edge como leitor de PDF padrao..." -ForegroundColor Yellow
$EdgePdfPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
if (-not (Test-Path $EdgePdfPath)) { New-Item -Path $EdgePdfPath -Force | Out-Null }
Set-ItemProperty -Path $EdgePdfPath -Name "AlwaysOpenPdfExternally" -Type DWord -Value 1 -Force

# Desativar a Telemetria do Windows (Envio de dados em segundo plano)
Write-Host "-> Cortando a telemetria da Microsoft..." -ForegroundColor Yellow
$TelemetryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (-not (Test-Path $TelemetryPath)) { New-Item -Path $TelemetryPath -Force | Out-Null }
Set-ItemProperty -Path $TelemetryPath -Name "AllowTelemetry" -Type DWord -Value 0 -Force

# ---------------------------------------------------------
# 4. Limpeza de Arquivos Temporarios (Protegendo a Lixeira)
# ---------------------------------------------------------
Write-Host "Limpando arquivos temporarios do sistema..." -ForegroundColor Cyan

$pastasTemporarias = @(
    "$env:TEMP\*",
    "$env:WINDIR\Temp\*",
    "$env:WINDIR\SoftwareDistribution\Download\*"
)

foreach ($pasta in $pastasTemporarias) {
    Remove-Item -Path $pasta -Recurse -Force -ErrorAction SilentlyContinue 2>$null
}

# ---------------------------------------------------------
# 5. Ajustes de Usabilidade e Remocao de Avisos (Nags)
# ---------------------------------------------------------
Write-Host "Desativando avisos chatos e pesquisa web no Menu Iniciar..." -ForegroundColor Cyan

# Desativar pesquisa na Web (Bing) no Menu Iniciar (Pesquisa apenas arquivos locais)
Write-Host "-> Desativando pesquisa Bing no Menu Iniciar..." -ForegroundColor Yellow
$SearchPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
if (-not (Test-Path $SearchPath)) { New-Item -Path $SearchPath -Force | Out-Null }
Set-ItemProperty -Path $SearchPath -Name "BingSearchEnabled" -Type DWord -Value 0 -Force
Set-ItemProperty -Path $SearchPath -Name "CortanaConsent" -Type DWord -Value 0 -Force

$ExplorerPolicyPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
if (-not (Test-Path $ExplorerPolicyPath)) { New-Item -Path $ExplorerPolicyPath -Force | Out-Null }
Set-ItemProperty -Path $ExplorerPolicyPath -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1 -Force

# Desativar aviso "Termine de configurar seu dispositivo" (Aviso de Conta Microsoft)
Write-Host "-> Bloqueando tela de 'Termine de configurar seu dispositivo'..." -ForegroundColor Yellow
$UserProfileEngagement = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement"
if (-not (Test-Path $UserProfileEngagement)) { New-Item -Path $UserProfileEngagement -Force | Out-Null }
Set-ItemProperty -Path $UserProfileEngagement -Name "ScoobeSystemSettingEnabled" -Type DWord -Value 0 -Force

$ContentDelivery = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
if (-not (Test-Path $ContentDelivery)) { New-Item -Path $ContentDelivery -Force | Out-Null }
Set-ItemProperty -Path $ContentDelivery -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0 -Force

# Desativar avisos de Upgrade para Windows 11 e Fim de Suporte
Write-Host "-> Bloqueando avisos de atualizacao para Windows 11..." -ForegroundColor Yellow
$WUPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
if (-not (Test-Path $WUPath)) { New-Item -Path $WUPath -Force | Out-Null }
Set-ItemProperty -Path $WUPath -Name "TargetReleaseVersion" -Type DWord -Value 1 -Force
Set-ItemProperty -Path $WUPath -Name "TargetReleaseVersionInfo" -Type String -Value "22H2" -Force

# Reiniciar o Windows Explorer para limpar o cache do Menu Iniciar e aplicar as mudancas imediatamente
Write-Host "Reiniciando a interface gráfica..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

Write-Host "=====================================================" -ForegroundColor Green
Write-Host " Limpeza de sistema e otimizacoes concluidas 100%!" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
