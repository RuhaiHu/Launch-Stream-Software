#requires -version 5.1
<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  Stop Processes that are known to cause issues with game save files.
    Dropbox
    Google Backup and Sync    
  Switch Power Plan
    From any to HIGH
  Launch software for streaming
    StreamLabels
    StreamLabsChat
    HexChat
    Pretzel
    OBS
  After Software is closed manually
    Switch Power Plan
      From HIGH to Balanced
    Relaunch closed programs
  
.PARAMETER <Parameter_Name>
    None

.INPUTS
  None

.OUTPUTS
  None

.NOTES
  Version:        1.6
  Author:         Ruhai Hu
  Creation Date:  2018.09.06

  Last Modified by: Ruhai Hu
  Last Modifcation Date: 2020.02.04

  Purpose/Change: 
    Initial script development
    Clean up of paths
    Update Comments and Descriptions
    Updated environmental paramaters to use Powershell Params instead of Command Line since they were not working.
    Fix Logic that just wasn't working.
    Prevented some more extra output that wasn't desired

  Possible Changes / Ideas:
    Turn code chunks for stopping / starting programs in to functions/modules
    Change powerplan code so its looking at the id's of the plans and not names?
    Config file? For enable disable of stopping starting?


   C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -ExecutionPolicy Bypass -File "D:\GD\Twitch\Scripts\Launch-Stream-Software\stream_launch.ps1"

   FOR STREAM DECK
    C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Minimized -ExecutionPolicy Bypass -Command "Invoke-Item 'C:\\Users\\Ruhai Hu\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Launch Stream Software.lnk'" 
    
.EXAMPLE
  None
#>
Import-Module AudioDeviceCmdlets

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

# Run the Restart Audio Script
Start-Process -FilePath 'powershell.exe' -ArgumentList '-ExecutionPolicy Bypass -File "D:\GD\twitch\VAC Setup\RestartStreamAudio.ps1"' -Verb RunAs

# Set Default Recording device to not muted
Write-Output "Un-Muting microphone"
Set-AudioDevice -RecordingMute 0

# Read-Host "waiiiit!!!!"

# Stop list of programs that cause issues
# This should hopefully stop the processes gracefully
# List of processes to kill
$processes = 'dropbox', 'googledrivesync', 'VirtuaWin', 'TeamViewe*'
if(Get-Process -Name $processes){
  Get-Process -Name $processes | Stop-Process
}
else{
  Write-Output "$processes Not running!"
}

# Run the Stop services script
Write-Output "Stopping Services"
Start-Process -FilePath 'powershell.exe' -ArgumentList '-ExecutionPolicy Bypass -File "$PSScriptRoot\stream_StopServices.ps1"' -Verb RunAs

# Set powerplan to High Performance Plan while streaming if not already
# Found on https://facility9.com/2015/07/controlling-the-windows-power-plan-with-powershell/
# Also found on other sites
Try {
  $HighPerf = powercfg -l | %{if($_.contains("High performance")) {$_.split()[3]}}
  $CurrPlan = $(powercfg -getactivescheme).split()[3]
  if ($CurrPlan -ne $HighPerf) {powercfg -setactive $HighPerf}
} Catch {
  Write-Warning -Message "Unable to set power plan to high performance"
}

# Launch programs below with as variables
# Also check to see if they are already running

# Check then Launch Hexchat
if(!(Get-Process -Name 'hexchat')){
  Start-Process -FilePath "C:\Program Files\HexChat\hexchat.exe" -WorkingDirectory "C:\Program Files\HexChat" | Out-Null
  if(Get-Process -Name 'hexchat'){
  Write-Output "HexChat Started!"}
}
elseif(Get-Process -Name 'hexchat'){
  Write-Output "HexChat already running!"}
else{
  Write-Error "Hexchat Failed to Start!"
}

# Check then Launch voicemeeterpro Banana
# if(!(Get-Process -Name 'voicemeeterpro')){
#   Start-Process -FilePath "C:\Program Files (x86)\VB\Voicemeeter\voicemeeterpro.exe" -WorkingDirectory "C:\Program Files (x86)\VB\Voicemeeter" -WindowStyle Minimized | Out-Null
#   if(Get-Process -Name 'voicemeeterpro'){
#   Write-Output "voicemeeterpro Started!"}
# }
# elseif(Get-Process -Name 'voicemeeterpro'){
#   Write-Output "voicemeeterpro already running!"}
# else{
#   Write-Error "voicemeeterpro Failed to Start!"
# }

# Check then Launch Cantabile
# if(!(Get-Process -Name 'Cantabile')){
#   Start-Process -WindowStyle Minimized -FilePath "C:\Program Files\Topten Software\Cantabile 3.0\Cantabile.exe" -WorkingDirectory "C:\Program Files\Topten Software\Cantabile 3.0" | Out-Null
#   if(Get-Process -Name 'Cantabile'){
#   Write-Output "Cantabile Started!"}
# }
# elseif(Get-Process -Name 'Cantabile'){
#   Write-Output "Cantabile already running!"}
# else{
#   Write-Error "Cantabile Failed to Start!"
# }

# Check then Launch Stream Labels
if(!(Get-Process -Name 'streamlabels')){
  # Annoyingly Stream Labs Labels outputs a bunch of connection information so sending it to $null
  Start-Process -FilePath "$env:LOCALAPPDATA\Programs\streamlabels\StreamLabels.exe" -WorkingDirectory "$env:LOCALAPPDATA\Programs\streamlabels"
  if(Get-Process -Name 'streamlabels'){
  Write-Output "StreamLabels Started!"}
}
elseif(Get-Process -Name 'streamlabels'){
  Write-Output "StreamLabels already running!"}
else{
  Write-Error "StreamLabels Failed to Start!"
}

# Check then Launch Chatbot
# if(!(Get-Process -Name 'Streamlabs*Chatbot*')){
#   Start-Process -FilePath "$env:APPDATA\Streamlabs\Streamlabs Chatbot\Streamlabs Chatbot.exe" -WorkingDirectory "$env:APPDATA\Streamlabs\Streamlabs Chatbot" -Verb RunAs
#   if(Get-Process -Name 'Streamlabs Chatbot'){
#   Write-Output "StreamLabs Chatbot Started!"}
# }
# elseif(Get-Process -Name 'Streamlabs Chatbot'){
#   Write-Output "StreamLabs Chatbot already running!"}
# else{
#   Write-Error "StreamLabs Chatbot Failed to Start!"
# }

# Check then Launch Pretzel OLD
# if(!(Get-Process -Name 'pretzel')){
#   Start-Process -FilePath "$env:LOCALAPPDATA\Programs\PretzelDesktop\Pretzel.exe" -WorkingDirectory "$env:LOCALAPPDATA\Programs\PretzelDesktop" | Out-Null
#   if(Get-Process -Name 'pretzel'){
#   Write-Output "Pretzel Started"}
# }
# elseif(Get-Process -Name 'pretzel'){
#   Write-Output "Pretzel already running!"}
# else{
#   Write-Error "Pretzel Failed to Start!"
# }

# Check then Launch Pretzel
if(!(Get-Process -Name 'Pretzel-Beta')){
  Start-Process -FilePath "$env:LOCALAPPDATA\Programs\@pretzel-auxpretzel-desktop\Pretzel-Beta.exe" -WorkingDirectory "$env:LOCALAPPDATA\Programs\@pretzel-auxpretzel-desktop" | Out-Null
  if(Get-Process -Name 'Pretzel-Beta'){
  Write-Output "Pretzel Started"}
}
elseif(Get-Process -Name 'Pretzel-Beta'){
  Write-Output "Pretzel already running!"}
else{
  Write-Error "Pretzel Failed to Start!"
}

# Check for and then launch OBS
if(!(Get-Process -Name 'obs*')){
  Start-Process -FilePath "C:\Program Files\obs-studio\bin\64bit\obs64.exe" -WorkingDirectory "C:\Program Files\obs-studio\bin\64bit" -Verb RunAs
  if(Get-Process -Name 'obs64'){
  Write-Output "OBS Started"}
}
elseif(Get-Process -Name 'obs64'){
  Write-Output "OBS already running"}
else{
  Write-Error "OBS Failed to Start!"
}

# While needed stoftware for streaming running
# reason for doing this is I might be restarting OBS for some reason
# Personaly excluding Pretzel
Start-Sleep -seconds 10
do{
  Clear-Host
  $running = 0
  # If the check programs are still running 
  # sleep for 2 minutes
  Write-Output " Waiting for streaming software to close.
  `n Before relaunching closed programs.
  `n Sleep will repeat until programs close."
  
  $sleepTime = 10

  # Determine if processes are running and add them to count
  # So we can determine if we want to continue to wait
  $processCheckToEnd = 'obs64','HexChat','streamlab*'
  foreach ($item in $processCheckToEnd) {
    if(Get-Process -Name $item){
      $running += (Get-Process -Name $item).length
      # Write-Output $item
      $sleepTime += 10
    }
  }
  if ($running -eq 0) {
    $sleepTime = 10
  }

  $minutes = $sleepTime / 60
  Write-OutPut " Number of running programs: $running , Sleeping for $minutes minutes."
  
  Start-Sleep -seconds $sleepTime
}while($running -gt 0)

# Created the daily as a clone of my balance performance settings
# Because I couldn't get it to recognize just the balance plan
# Set power plan back to balanced/daily regular usage plan
# Found on https://facility9.com/2015/07/controlling-the-windows-power-plan-with-powershell/
# Also found on other sites
Try {
  $BalancePerf = powercfg -l | %{if($_.contains("Balanced")) {$_.split()[3]}}
  $CurrPlan = $(powercfg -getactivescheme).split()[3]
  if ($CurrPlan -ne $BalancePerf) {powercfg -setactive $BalancePerf}
} Catch {
  Write-Warning -Message "Unable to set power plan to Balanced Performance"
}

# Stop some started programs
# As Things are ending I dont need them running
$processes = 'voicemeeterpro', 'Cantabile', 'pretzel'
if(Get-Process -Name $processes){
  Get-Process -Name $processes | Stop-Process
}
else{
  Write-Output "$processes Not running!"
}

# Run the Start services script
Write-Output "Re-Starting Services"
Start-Process -FilePath 'powershell.exe' -ArgumentList '-ExecutionPolicy Bypass -File "$PSScriptRoot\stream_StartServices.ps1"' -Verb RunAs

# Relaunch killed process from above if not already running
if(!(Get-Process -Name 'dropbox')){
  Start-Process -FilePath "C:\Program Files (x86)\Dropbox\Client\Dropbox.exe" -WorkingDirectory "C:\Program Files (x86)\Dropbox\Client"
}
if(!(Get-Process -Name 'googledrivesync')){
  Start-Process -FilePath "C:\Program Files\Google\Drive\googledrivesync.exe" -WorkingDirectory "C:\Program Files\Google\Drive\"
}
if(!(Get-Process -Name 'VirtuaWin')){
  Start-ScheduledTask -TaskPath "\Mine" -TaskName "VirtualWin"
}
if(!(Get-Process -Name 'TeamViewe*')){
  Start-Process -FilePath "C:\Program Files (x86)\TeamViewer\TeamViewer.exe" -WorkingDirectory "C:\Program Files (x86)\TeamViewer\"
}

# Run the Restart Audio Script
Start-Process -FilePath 'powershell.exe' -ArgumentList '-ExecutionPolicy Bypass -File "D:\GD\Twitch\VAC Setup\RestartBasicAudio.ps1"' -Verb RunAs

# Set Default Recording device to muted
Write-Output "Muting microphone"
Set-AudioDevice -RecordingMute 1
