# Run the following in Powershell first
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Variables - Following variables are for example only and will not work in production
$AzureSubscription = "82a8207e-4145-4f98-9200-d2c6d1fd2d9c" 
$TenentId = "01b6d252-9808-415f-bb26-5f4898cf8d29"
$ResourceGroupName = "rg-groupname"
$StorageAccountName = "storageaccountname"
$Username = "Azure\username"
$FileShareURL = "\\storageaccountname.file.core.windows.net\containername"
$FreeFileSync = "C:\Program Files\FreeFileSync\FreeFileSync.exe"
$BatchPath = "C:\Users\bsmith\FreeFileSync\"
$BatchConfigFile = "AzureOffsiteBackup.ffs_batch"

# Connect to Azure Account
Connect-AzAccount -Subscription $AzureSubscription -TenantId $TenentId

# Get Key1 for Storage Account
$StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName) | Where-Object { $_.KeyName -eq "key1" }

$connectTestResult = Test-NetConnection -ComputerName sthomebackupuksp.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    $Password = ConvertTo-SecureString $StorageAccountKey.Value -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential ($Username, $Password)
    New-PSDrive -Name W -PSProvider FileSystem -Root $FileShareURL -Credential $Credentials -Persist
}
else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}

# Start sync
& $FreeFileSync $BatchPath$BatchConfigFile

# Loop until Sync finishes
while ((get-process "FreeFileSync" -ea SilentlyContinue)) {
    Write-Output "Synchronizing..."
    Start-Sleep -Seconds 10
}

Write-Output "Synchronization completed"

# Unmap drive
Write-Output "Unmapping drive"
Remove-PSDrive -Name W

# Clear login context
Write-Output "Clearing Login tokens"
Clear-AzContext -Force

# Used to sign out of MS auth
Connect-AzAccount