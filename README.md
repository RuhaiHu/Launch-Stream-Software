# Launch-Stream-Software
Script for Launching streaming software

I became tired of manually launching my streaming software.
I also became tired of wondering if I need to stop backup/Sync software like "Dropbox" and "Google Backup and Sync", and then having to worry about manually opening them afterwords.

So I made this script.

Feel free to download and modify. 
Improvements welcome. 
Suggestions to improve my basic understanding of PowerShell welcome.

To run the script I created a shortcut for the script.
Follow this guide if you need help : https://www.tenforums.com/tutorials/97162-powershell-scripting-run-script-shortcut.html

Using this in the Target field of the shortcut:
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -WindowStyle Hidden -ExecutionPolicy Bypass -File "PATH TO SCRIPT\stream_launch.ps1"

I also grabbed a nice ICON for the shortcut and applied that.


Possible Changes / Ideas:
    Turn code chunks for stopping / starting programs in to functions/modules
    Change power plan code so its looking at the id's of the plans and not names?
    Config file? For enable disable of stopping starting?
