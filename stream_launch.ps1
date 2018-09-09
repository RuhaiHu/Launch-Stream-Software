#requires -version 5.1
<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  Kill dropbox / google drive backup / etc
    These are known to cause issues with game save files
  Switch power plans
  Launch software for streaming
  After OBS and other software is closed relaunch killed application

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
  Last Modifcation Date: 2018.09.08

  Purpose/Change: 
    Initial script development
    Clean up of paths

  
.EXAMPLE
  None
#>

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

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

# Set powerplan to High Performance Plan while streaming if not already
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
if((Get-Process -Name 'hexchat') -eq $null){
  $hexchat = Start-Process -FilePath "C:\Program Files\HexChat\hexchat.exe" -WorkingDirectory "C:\Program Files\HexChat"
}

# Check then Launch Stream Labels
if((Get-Process -Name 'streamlabels') -eq $null){
  $streamlabels = Start-Process -FilePath "%LOCALAPPDATA%\Programs\streamlabels\StreamLabels.exe" -WorkingDirectory "%LOCALAPPDATA%\Programs\streamlabels"
}

# Check then Launch Chatbot
if((Get-Process -Name 'Streamlabs Chatbot') -eq $null){
  $streamlabschatbot = Start-Process -FilePath "%APPDATA%\Streamlabs\Streamlabs Chatbot\Streamlabs Chatbot.exe" -WorkingDirectory "%APPDATA%\Streamlabs\Streamlabs Chatbot"
}

# Check then Launch Pretzel
if((Get-Process -Name 'pretzel') -eq $null){
  $pretzel = Start-Process -FilePath "%LOCALAPPDATA%\Programs\PretzelDesktop\Pretzel.exe" -WorkingDirectory "%LOCALAPPDATA%\Programs\PretzelDesktop"
}

# Launch streaming program and wait for it to exit
# ofcourse make sure it is not running also
if((Get-Process -Name 'obs64') -eq $null){
  $obs = Start-Process -FilePath "C:\Program Files (x86)\obs-studio\bin\64bit\obs64.exe" -WorkingDirectory "C:\Program Files (x86)\obs-studio\bin\64bit" -Verb runAs
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
  if((Get-Process -Name 'obs64').length -gt 0){
      $running += (Get-Process -Name 'obs64').length
  }
  if((Get-Process -Name 'HexChat').length -gt 0){
      $running += (Get-Process -Name 'HexChat').length
  }
  if((Get-Process -Name 'streamlab*').length -gt 0){
      $running += (Get-Process -Name 'streamlab*').length
  }
  Write-OutPut " Number of running programs: $running"

}while($running -gt 0)

# Created the daily as a clone of my balance performance settings
# Because I couldn't get it to recognize just the balance plan
# Set power plan back to balanced/daily regular usage plan
Try {
  $DailyPerf = powercfg -l | %{if($_.contains("Daily")) {$_.split()[3]}}
  $CurrPlan = $(powercfg -getactivescheme).split()[3]
  if ($CurrPlan -ne $DailyPerf) {powercfg -setactive $DailyPerf}
} Catch {
  Write-Warning -Message "Unable to set power plan to Daily Performance"
}

# Relaunch killed process from above if not already running
if((Get-Process -Name 'dropbox') -eq $null){
  $hexchat = Start-Process -FilePath "C:\Program Files (x86)\Dropbox\Client\Dropbox.exe" -WorkingDirectory "C:\Program Files (x86)\Dropbox\Client" }
if((Get-Process -Name 'googledrivesync') -eq $null){
  $hexchat = Start-Process -FilePath "C:\Program Files\Google\Drive\googledrivesync.exe" -WorkingDirectory "C:\Program Files\Google\Drive\" }