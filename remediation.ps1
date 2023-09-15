try {
    # Get the last logged on user's name and folder
    $lastUser = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName
    $lastUserFolder = "C:\users\" + ($lastUser.Split("\")[1])
    $oneDriveExe = "C:\Program Files\Microsoft OneDrive\OneDrive.exe"

    #write last user folder path to console
    Write-Host "Last User Folder: $lastUserFolder"

    # Check if the oneDriveExe exists for the last logged on user
    if (-Not (Test-Path $oneDriveExe)) {
        Write-Error "OneDrive.exe not found for user $lastUser"
        exit 1
    }

    # Define the scheduled task action to start OneDrive
    $action = New-ScheduledTaskAction -Execute $oneDriveExe

    # Set the task to run as the logged-in user, and run immediately
    $principal = New-ScheduledTaskPrincipal -UserId $lastUser -LogonType Interactive

    # Define the trigger to start at 2pm and repeat every 24 hours for 7 days
    # Define the trigger to start daily at 2pm
    $endDate = (Get-Date).AddDays(7).ToString('s')
    $trigger = New-ScheduledTaskTrigger -Daily -At 2pm
    $trigger.EndBoundary = $endDate

    # Register (create) the scheduled task
    Register-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -TaskName "LaunchOneDriveForUser" -Force

    # Start the scheduled task
    Start-ScheduledTask -TaskName "LaunchOneDriveForUser"

    #write hostname and username and compliance state to write-host, which will be output to the agent log
    Write-Host "Hostname: $env:computername"
    Write-Host "Username: $env:username"
    Write-Host "Compliance: Non-Compliant"

    # Message to show to the user
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show('Please ensure that you are signed in to OneDrive and that your Desktop and Documents folders are syncing.', 'OneDrive Sync Reminder', 'OK', 'Warning')

    Exit 0
} catch {
    Write-Error $_.Exception.Message
    exit 1
}

