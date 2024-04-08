# Use the Windows Server Core image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set metadata for the container
LABEL maintainer="Albin <magmacraft424@gmail.com>"

# Set environment variables
ENV USERNAME user
ENV PASSWORD password

# Install Chocolatey package manager
RUN powershell -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install RDP feature
RUN powershell -Command \
    choco install -y mstsc

# Create user and set password
RUN powershell -Command \
    net user $env:USERNAME $env:PASSWORD /add ; \
    net localgroup administrators $env:USERNAME /add

# Expose RDP port
EXPOSE 3389

# Start RDP server
CMD powershell -Command \
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 ; \
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop" ; \
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop - RemoteFX" ; \
    netsh advfirewall firewall set rule group="Remote Desktop" new enable=Yes ; \
    netsh advfirewall firewall set rule group="Remote Desktop - RemoteFX" new enable=Yes ; \
    Start-Service TermService ; \
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
