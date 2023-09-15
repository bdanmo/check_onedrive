# Get the last logged on user's name and folder
$lastUser = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName
$lastUserFolder = "C:\users\" + ($lastUser.Split("\")[1])
$oneDriveExe = "$lastUserFolder\AppData\Local\Microsoft\OneDrive\OneDrive.exe"

# Define the scheduled task action to start OneDrive
$action = New-ScheduledTaskAction -Execute $oneDriveExe

# Set the task to run as the logged-in user, and run immediately
$principal = New-ScheduledTaskPrincipal -UserId $lastUser -LogonType Interactive

# Define the trigger to start daily at 2pm and repeat for 7 days
$trigger = New-ScheduledTaskTrigger -Daily -At 2pm -RepetitionInterval ([TimeSpan]::FromDays(1)) -RepetitionDuration ([TimeSpan]::FromDays(7))

# Register (create) the scheduled task
Register-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -TaskName "LaunchOneDriveForUser" -Force

# Start the scheduled task
Start-ScheduledTask -TaskName "LaunchOneDriveForUser"

# Message to show to the user
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show('Please ensure that you are signed in to OneDrive and that your Desktop and Documents folders are syncing.', 'OneDrive Sync Reminder', 'OK', 'Warning')

#write hostname and username and compliance state to write-host, which will be output to the agent log
Write-Host "Hostname: $env:computername"
Write-Host "Username: $env:username"
Write-Host "Compliance: Non-Compliant"

Exit 0
