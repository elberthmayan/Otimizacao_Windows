# Modulo de Remocao de Bloatwares - Limpeza do Sistema
# Requisito: Executar como Administrador

$bloatwares = @(
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MixedReality.Portal",
    "Microsoft.SkypeApp",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameCallableUI",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "microsoft.windowscommunicationsapps",
    "Microsoft.MSPaint",
    "Microsoft.Office.OneNote",
    "Microsoft.549981C3F5F10",       # Cortana
    "Microsoft.People",              # Pessoas
    "Microsoft.WindowsCamera",       # Camera
    "Microsoft.WindowsSoundRecorder" # Gravador de Voz
)

Write-Host "Iniciando a varredura e remocao dos pacotes UWP..." -ForegroundColor Cyan

foreach ($app in $bloatwares) {
    Write-Host "Limpando pacote: $app" -ForegroundColor Yellow
    
    # Remove do usuario atual
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    
    # Remove do provisionamento do Windows (impede reinstalacao automatica)
    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------
# 2. Remocao bruta do OneDrive
# ---------------------------------------------------------
Write-Host "Eliminando o OneDrive..." -ForegroundColor Cyan

# Encerra o processo se estiver em execucao
taskkill /f /im OneDrive.exe -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Busca e executa o desinstalador nativo
if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
    Start-Process "$env:systemroot\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -NoNewWindow
} elseif (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
    Start-Process "$env:systemroot\SysWOW64\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -NoNewWindow
}

Write-Host "Rotina do Limpeza do Sistema concluida com sucesso!" -ForegroundColor Green

# ---------------------------------------------------------
# 3. Ajustes de Registro e Otimizacao do Sistema
# ---------------------------------------------------------

Write-Host "Aplicando ajustes avancados no Registro..." -ForegroundColor Cyan

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

# Definindo apenas as pastas de arquivos temporarios puros (Lixeira de fora!)
$pastasTemporarias = @(
    "$env:TEMP\*",
    "$env:WINDIR\Temp\*",
    "$env:WINDIR\SoftwareDistribution\Download\*" # Cache de atualizacoes do Windows
)

foreach ($pasta in $pastasTemporarias) {
    # Remove os arquivos forcadamente, ignorando os que estao em uso no momento
    Remove-Item -Path $pasta -Recurse -Force -ErrorAction SilentlyContinue
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

$UpgradePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OSUpgrade"
if (-not (Test-Path $UpgradePath)) { New-Item -Path $UpgradePath -Force | Out-Null }
Set-ItemProperty -Path $UpgradePath -Name "AllowOSUpgrade" -Type DWord -Value 0 -Force
Set-ItemProperty -Path $UpgradePath -Name "ReservationsAllowed" -Type DWord -Value 0 -Force

# Reiniciar o Windows Explorer para aplicar as mudancas do Menu Iniciar imediatamente
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

Write-Host "Limpeza de sistema e otimizacoes concluidas!" -ForegroundColor Green