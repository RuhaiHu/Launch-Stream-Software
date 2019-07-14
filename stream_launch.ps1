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
  Version:        1.1
  Author:         Ruhai Hu
  Creation Date:  2018.09.06

  Last Modified by: Ruhai Hu
  Last Modifcation Date: 2018.09.09

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

.EXAMPLE
  None
#>
Import-Module AudioDeviceCmdlets

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

# Write-Output "Setting Wireless Headphones as Default Audio Device"

# $articsGame = Get-AudioDevice -List | Where-Object -Property Name -eq "Headphones (Arctis Pro Wireless Game)"
# Set-AudioDevice -ID $articsGame.ID


# Stop list of programs that cause issues
# This should hopefully stop the processes gracefully
if(Get-Process -Name 'dropbox'){
  Get-Process -Name 'dropbox' | Stop-Process
}
else{
  Write-Output "Dropbox Not running!"
}
if(Get-Process -Name 'googledrivesync'){
  Get-Process -Name 'googledrivesync' | Stop-Process
}
else{
  Write-Output "Google Drive Not running!"
}

<# if(Get-Service -Name 'synergy' | Where-Object {$_.Status -eq "Running"}){
  Get-Service -Name 'synergy' | Stop-Service
}
else{
  Write-Output "Synergy Not running!"
} #>

if(Get-Process -Name 'VirtuaWin'){
  Stop-ScheduledTask -TaskPath "\Mine" -TaskName "VirtualWin"
}
else{
  Write-Output "VirtuaWin Not running!"
}


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

# Check then Launch Stream Labels
if(!(Get-Process -Name 'streamlabels')){
  # Annoyingly Stream Labs Labels outputs a bunch of connection information so sending it to $null
  Start-Process -FilePath "$env:LOCALAPPDATA\Programs\streamlabels\StreamLabels.exe" -WorkingDirectory "$env:LOCALAPPDATA\Programs\streamlabels" | Out-Null
  if(Get-Process -Name 'streamlabels'){
  Write-Output "StreamLabels Started!"}
}
elseif(Get-Process -Name 'streamlabels'){
  Write-Output "StreamLabels already running!"}
else{
  Write-Error "StreamLabels Failed to Start!"
}

# Check then Launch Chatbot
if(!(Get-Process -Name 'Streamlabs*Chatbot*')){
  Start-Process -FilePath "$env:APPDATA\Streamlabs\Streamlabs Chatbot\Streamlabs Chatbot.exe" -WorkingDirectory "$env:APPDATA\Streamlabs\Streamlabs Chatbot" -Verb runAs
  if(Get-Process -Name 'Streamlabs Chatbot'){
  Write-Output "StreamLabs Chatbot Started!"}
}
elseif(Get-Process -Name 'Streamlabs Chatbot'){
  Write-Output "StreamLabs Chatbot already running!"}
else{
  Write-Error "StreamLabs Chatbot Failed to Start!"
}

# Check then Launch Pretzel
if(!(Get-Process -Name 'pretzel')){
  # Seems Pretzel also outputs some extra stuff that I don't want to see on the output

  # "$env:LOCALAPPDATA\Programs\PretzelDesktop\Pretzel.exe" >$null

  # $pretzel = $env:LOCALAPPDATA + "\Programs\PretzelDesktop\Pretzel.exe"
  # $pretzelWorkingDirectory = $env:LOCALAPPDATA + "\Programs\PretzelDesktop"
  
  
  #   Start-Process -FilePath $pretzel -WorkingDirectory $pretzelWorkingDirectory *>$nul
  # Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "C:\Users\weber\AppData\Local\Programs\PretzelDesktop\Pretzel.exe" *>$null


  Start-Process -FilePath "$env:LOCALAPPDATA\Programs\PretzelDesktop\Pretzel.exe" -WorkingDirectory "$env:LOCALAPPDATA\Programs\PretzelDesktop" | Out-Null
  if(Get-Process -Name 'pretzel'){
  Write-Output "Pretzel Started"}
}
elseif(Get-Process -Name 'pretzel'){
  Write-Output "Pretzel already running!"}
else{
  Write-Error "Pretzel Failed to Start!"
}

# Check for and then launch OBS
if(!(Get-Process -Name 'obs*')){
  Start-Process -FilePath "C:\Program Files\obs-studio\bin\64bit\obs64.exe" -WorkingDirectory "C:\Program Files\obs-studio\bin\64bit" -Verb runAs
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
do{
  $running = 0
  # If the check programs are still running 
  # sleep for 2 minutes
  Write-Output " Waiting for streaming software to close.
  `n Sleeping for 2 minutes.
  `n Before relaunching closed programs.
  `n Sleep will repeat until programs close."
  Start-Sleep -seconds 120

  # Determine if processes are running and add them to count
  # So we can determine if we want to continue to wait
  if(Get-Process -Name 'obs64'){
      $running += (Get-Process -Name 'obs64').length
  }
  if(Get-Process -Name 'HexChat'){
      $running += (Get-Process -Name 'HexChat').length
  }
  if(Get-Process -Name 'streamlab*'){
      $running += (Get-Process -Name 'streamlab*').length
  }
  Write-OutPut " Number of running programs: $running"
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
  Write-Warning -Message "Unable to set power plan to Daily Performance"
}

# Relaunch killed process from above if not already running
if(!(Get-Process -Name 'dropbox')){
  Start-Process -FilePath "C:\Program Files (x86)\Dropbox\Client\Dropbox.exe" -WorkingDirectory "C:\Program Files (x86)\Dropbox\Client"
}

if(!(Get-Process -Name 'googledrivesync')){
  Start-Process -FilePath "C:\Program Files\Google\Drive\googledrivesync.exe" -WorkingDirectory "C:\Program Files\Google\Drive\"
}

<# if(Get-Service -Name 'synergy' | Where-Object {$_.Status -eq "Stopped"}){
  Start-Service -Name 'synergy'
} #>

if(!(Get-Process -Name 'VirtuaWin')){
  Start-ScheduledTask -TaskPath "\Mine" -TaskName "VirtualWin"
}

VirtuaWin