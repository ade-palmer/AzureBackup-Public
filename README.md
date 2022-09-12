# Azure Backup

This PowerShell can be used to sync / backup files to an Azure Storage Container. You will need to create the container in Azure to obtain the required values for the varaibles used in the PowerShell. The script will ask for a valid account to connect to your Azure Tenent and I'd recommend using one that requires 2FA. Once validated it will retreive the required key to access the storage account. This means the sensitive key is never stored in the script or on the local machine. The script will then map a drive to the container and run a preconfigured ‘FreeFileSync’ batch file to sync the files. Once the sync has completed, you will be asked to log-off to remove access to the storage account.

**Software:** https://freefilesync.org

You will need to configure a Free File Sync batch file to syncronise files.

## TODO

Look at using Azure Key Vault.
