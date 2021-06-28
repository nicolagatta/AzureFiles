#This lab requires 
# 1. virtual machine 
# 2. Key vault es Retrieve required key vault properties:

$VmName='my-vm'
$KeyVaultName='myencryptionvault'
$KEK_Name='myKEK'

#Get Key vault resource id
$myKeyVaultId =  (Get-AzKeyVault -Name $KeyVaultName).ResourceId

# Get the Key vault Url
$myKeyVaultURL =  (Get-AzKeyVault -Name $KeyVaultName).VaultUri

# Create a KEK (key encryption Key) in the key vault:
Add-AzKeyVaultKey -Name $KEK_Name -VaultName $KeyVaultName -Destination "Software"

# Get the KEK Url
$myKEKVaultUrl = (Get-AzKeyVaultKey -Name "myKEK" -VaultName $KeyVaultName).id

# Get the KEK Id
$myKEKVaultid = (Get-AzKeyVaultKey -Name "myKEK" -VaultName $KeyVaultName).Key.Kid

# Encrypt the OS disk
# Requires: Vmnane, keyvault id and URL, KEK Id and URL
set-azVMDiskEncryptionExtension -ResourceGroupName "task-diskencrypt" -VMName $VmName -DiskEncryptionKeyVaultUrl $myKeyVaultURL -DiskEncryptionKeyVaultId  $myKeyVaultId -KeyEncryptionKeyUrl  $myKEKVaultURL -KeyEncryptionKeyVaultId $myKEKVaultid
