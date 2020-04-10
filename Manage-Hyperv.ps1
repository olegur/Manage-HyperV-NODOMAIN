#GATHER INFO ABOUT HYPER-V HOST
$ipHyperv = Read-Host "what is the ip of the hyper-v server?"
$dnsHyperv = Read-Host "what is the DNS-name of the hyper-v server?"
$hostsValue = "`n$ipHyperv`t$dnsHyperv"
$wsmanHyperv = "wsman/$dnsHyperv"

#SET CONNECTIONPROFILE TO PRIVATE
Get-NetConnectionProfile
$activeInterface = Read-Host "what is the interface index for the active interface?"
Set-NetConnectionProfile -InterfaceIndex "$activeInterface" -NetworkCategory Private

echo "----Enabling hyper-v features and adding server to hosts file----"
sleep 3
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Tools-All -All
Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value $hostsValue

echo "----Enabling and configuring WinRM----"
sleep 3
winrm quickconfig
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$dnsHyperv"
Enable-WSManCredSSP -Role client -DelegateComputer "$dnsHyperv"
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\" -Name 'CredentialsDelegation' 
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\" -Name 'AllowFreshCredentialsWhenNTLMOnly' -PropertyType DWord -Value "00000001" 
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\" -Name 'ConcatenateDefaults_AllowFreshNTLMOnly' -PropertyType DWord -Value "00000001" 
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\" -Name 'AllowFreshCredentialsWhenNTLMOnly' 
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly\" -Name '1' -Value "$wsmanHyperv"

echo "----You should now be able to connect to Hyper-V server----"
sleep 10