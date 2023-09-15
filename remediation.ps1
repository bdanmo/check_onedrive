$scriptBlock = {    
    try {
        # Get the last logged on user's name and folder
        $lastUser = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.Special -eq $false } | Sort-Object LastUseTime -Descending | Select-Object -First 1 -ExpandProperty LocalPath | Split-Path -Leaf

        # if no last user, exit 1
        if ($null -eq $lastUser) {
            Write-Error "No last user found"
            exit 1
        }
        
        $lastUserFolder = "C:\users\" + ($lastUser.Split("\")[1])

        #check if one drive exe is in programfiles or $lastUserFolder\AppData\Local\Microsoft\OneDrive\OneDrive.exe, if not in either, exit 1
        $oneDriveExe = "$lastUserFolder\AppData\Local\Microsoft\OneDrive\OneDrive.exe"
        if (-Not (Test-Path $oneDriveExe)) {
            Write-Output "OneDrive.exe not found in $lastUserFolder, checking Program Files"
            $oneDriveExe = "C:\Program Files\Microsoft OneDrive\OneDrive.exe"
        } 
        
        if (-Not (Test-Path $oneDriveExe)) {
            Write-Error "OneDrive.exe not found"
            exit 1
        }

        Write-Output "OneDrive.exe: $oneDriveExe"
        Write-Output "Last User Folder: $lastUserFolder"

        # Check if the oneDriveExe exists for the last logged on user
        

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

        #write hostname and username and compliance state to Write-Output, which will be output to the agent log
        Write-Output "Hostname: $env:computername"
        Write-Output "Username: $env:username"
        Write-Output "Compliance: Non-Compliant"

        # Message to show to the user
        Add-Type -AssemblyName PresentationFramework
        [System.Windows.MessageBox]::Show('Please ensure that you are signed in to OneDrive and that your Desktop and Documents folders are syncing.', 'OneDrive Sync Reminder', 'OK', 'Warning')

        Exit 0
    } catch {
        Write-Error $_.Exception.Message
        exit 1
    }
}

# Ensure running in 64-bit PowerShell
if ($ENV:PROCESSOR_ARCHITECTURE -ne 'AMD64') {
    # Relaunch in 64-bit PowerShell
    Start-Process "$env:windir\syswow64\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command & {$scriptBlock}"
} else {
    & $scriptBlock
}
