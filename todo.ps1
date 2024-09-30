# 1. Solicitar el número de usuario
$number = Read-Host "Ingrese el número del usuario (por ejemplo, 1 para KD1)"
$username = "KD$number"

# 2. Descripción del nuevo usuario
$description = "Usuario $username creado por PowerShell script"

# 3. Identificar el grupo de usuarios estándar (Users o Usuarios)
$groupName = if (Get-LocalGroup -Name "Users" -ErrorAction SilentlyContinue) { "Users" } else { "Usuarios" }

# 4. Verificar si el usuario ya existe y eliminarlo si es necesario
if (Get-LocalUser -Name $username -ErrorAction SilentlyContinue) {
    Write-Host "El usuario $username ya existe. Eliminándolo..."
    Remove-LocalUser -Name $username
    Write-Host "Usuario $username eliminado."
}
else {
    Write-Host "El usuario $username no existe."
}

# 5. Crear el nuevo usuario con la contraseña igual al nombre de usuario
$password = ConvertTo-SecureString -String $username -AsPlainText -Force

Write-Host "Creando el nuevo usuario $username con la contraseña igual al nombre de usuario..."
New-LocalUser -Name $username -Password $password -FullName $username -Description $description
Write-Host "Usuario $username creado."

# 6. Agregar el nuevo usuario al grupo de usuarios estándar
Write-Host "Agregando el usuario $username al grupo $groupName..."
Add-LocalGroupMember -Group $groupName -Member $username
Write-Host "Usuario $username agregado al grupo $groupName."

# 7. Iniciar sesión con el nuevo usuario y verificar programas instalados
Write-Host "Iniciando sesión con el nuevo usuario $username..."
Start-Process -FilePath "C:\Windows\System32\runas.exe" -ArgumentList "/user:$username powershell.exe -Command `"Start-Process -FilePath 'powershell.exe' -ArgumentList 'Get-Package | Select-Object Name, Version | Format-Table -AutoSize' -NoNewWindow -Wait`"" -Wait
Write-Host "Verificación de programas instalados completada."

# Ruta donde se instalará Visual Studio Code
$vsCodePath = "C:\Program Files\Microsoft VS Code"

# URL para descargar el instalador de Visual Studio Code
$vsCodeInstallerUrl = "https://update.code.visualstudio.com/latest/win32-x64/stable"

# Ruta donde se descargará el instalador de Visual Studio Code
$vsCodeInstallerPath = "$env:TEMP\VSCodeSetup.exe"

# Verificar si Visual Studio Code ya está instalado
if (Test-Path $vsCodePath) {
    Write-Host "Visual Studio Code ya está instalado en el sistema."

    # Cambiar permisos de acceso para el nuevo usuario
    Write-Host "Ajustando permisos de acceso para el usuario $username..."
    $acl = Get-Acl $vsCodePath
    $permission = "$username", "ReadAndExecute"
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
    $acl.AddAccessRule($accessRule)
    Set-Acl -Path $vsCodePath -AclObject $acl
    Write-Host "Permisos de acceso para Visual Studio Code ajustados para el usuario $username."
}
else {
    Write-Host "Visual Studio Code no está instalado. Procediendo a descargar e instalar..."

    # Descargar el instalador de Visual Studio Code
    Write-Host "Descargando el instalador de Visual Studio Code..."
    Invoke-WebRequest -Uri $vsCodeInstallerUrl -OutFile $vsCodeInstallerPath
    Write-Host "Instalador de Visual Studio Code descargado."

    # Instalar Visual Studio Code en modo silencioso
    Write-Host "Instalando Visual Studio Code..."
    Start-Process -FilePath $vsCodeInstallerPath -ArgumentList "/verysilent /norestart" -Wait
    Write-Host "Visual Studio Code se ha instalado correctamente."

    # Eliminar el instalador descargado
    Write-Host "Eliminando el instalador de Visual Studio Code..."
    if (Test-Path $vsCodeInstallerPath) {
        Remove-Item $vsCodeInstallerPath
        Write-Host "El instalador de Visual Studio Code ha sido eliminado."
    }
}

# URL para descargar el instalador de Git
$gitInstallerUrl = "https://git-scm.com/download/win"

# Ruta donde se descargará el instalador de Git
$gitInstallerPath = "$env:TEMP\GitSetup.exe"

Write-Host "Descargando el instalador de Git..."
Invoke-WebRequest -Uri $gitInstallerUrl -OutFile $gitInstallerPath
Write-Host "Instalador de Git descargado."

Write-Host "Instalando Git..."
Start-Process -FilePath $gitInstallerPath -ArgumentList "/verysilent /norestart" -Wait
Write-Host "Git se ha instalado correctamente."

# Eliminar el instalador descargado
Write-Host "Eliminando el instalador de Git..."
if (Test-Path $gitInstallerPath) {
    Remove-Item $gitInstallerPath
    Write-Host "El instalador de Git ha sido eliminado."
}
