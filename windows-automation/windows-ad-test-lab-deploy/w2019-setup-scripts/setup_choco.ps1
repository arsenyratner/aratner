# set execution policy bypass
Set-ExecutionPolicy -ExecutionPolicy bypass -Force:$true

# install chocolatey  
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Useful Choco installs (you may need to relaunch Powershell)
#choco install -y vscode git putty.install winscp microsoft-windows-terminal sysinternals wget mpc-hc openssl winbox puntoswitcher telegram zoom microsoft-teams virt-viewer 

restart-computer -Force
