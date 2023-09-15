# Get the last logged on user
$lastUser = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName
$lastUserFolder = "C:\users\" + ($lastUser.Split("\")[1])

# Check if the "OneDrive - Senneca Holdings" folder exists for the last logged on user
$oneDriveFolder = "$lastUserFolder\OneDrive - Senneca Holdings"
if (-Not (Test-Path $oneDriveFolder)) {
    exit 1
}

# Check if the "Documents" and "Desktop" directories exist and are populated
$documentsFolder = "$oneDriveFolder\Documents"
$desktopFolder = "$oneDriveFolder\Desktop"

if (-Not (Test-Path $documentsFolder) -Or (-Not (Test-Path $desktopFolder))) {
    exit 1
}

if ((Get-ChildItem -Path $documentsFolder).Count -eq 0 -Or (Get-ChildItem -Path $desktopFolder).Count -eq 0) {
    exit 1
}

exit 0
