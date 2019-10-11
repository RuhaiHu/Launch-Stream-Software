#requires -version 5.1
<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  Stop services before stream starting
  
.PARAMETER <Parameter_Name>
    None

.INPUTS
  None

.OUTPUTS
  None

.NOTES
  Version:        1.0
  Author:         Ruhai Hu
  Creation Date:  2019.10.11

  Last Modified by: Ruhai Hu
  Last Modifcation Date: 2019.10.11

  Purpose/Change: 
    Initial script development

  Possible Changes / Ideas:

   C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -ExecutionPolicy Bypass -File "D:\Google Drive\Twitch\Scripts\Launch-Stream-Software\stream_launch.ps1"

   FOR STREAM DECK
    powershell.exe -WindowStyle Minimized -ExecutionPolicy Bypass -Command "Invoke-Item 'C:\\Users\\weber\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Launch Stream Software.lnk'" 


.EXAMPLE
  None
#>

# Stop Services
# Services require Admin elevation split out and run as separate script?
$services = 'Synergy', 'TeamViewer', 'DbxSvc'
if(Get-Service -Name $services | Where-Object {$_.Status -eq "Running"}){
  Get-Service -Name $services | Stop-Service
}
else{
  Write-Output "$services Not running!"
}