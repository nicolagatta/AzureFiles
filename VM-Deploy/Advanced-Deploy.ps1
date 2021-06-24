####################################################
# Solution for INE Deploy Complex Virtual Machines Lab
# First section: Parameter settings
# Define user and password
    $VMLocalAdminUser = "LocalAdminUser"
    $VMLocalAdminSecurePassword = ConvertTo-SecureString Pa$$word1234! -AsPlainText -Force

# Define region (get-azlocation to find the names) and Resourcegroup name 
    $LocationName = "westeurope"
    $ResourceGroupName = "task-advm-rg"

# Define computer name VM name and VM Size
    $ComputerName = "advvm-vm"
    $VMName = "advvm-vm"
    $VMSize = "Standard_DS3"

# Network Setup: Vnet, Subnet, PublicIP, NIC
    $NetworkName = "advvm-vnet"
    
    $NICName_1 = "advvm-nic1"
    $NICName_2 = "advvm-nic2"
    
	  $PublicIPAddressName = "advvm-pip"
    
    $SubnetName_1 = "default"
    $SubnetAddressPrefix_1 = "10.0.0.0/24"
    
    $SubnetName_2 = "backend"
    $SubnetAddressPrefix_2 = "10.0.1.0/24"
    
    $VnetAddressPrefix = "10.0.0.0/16"
 
 ####################################################
 # Second section: elements creation
 
 # Create the subnet config
    $SingleSubnet_1 = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix_1
    
    $SingleSubnet_2 = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix_2
 
 # Create vnet with the associated subnet
    $Vnet = New-AzVirtualNetwork -Name $NetworkName -ResourceGroupName $ResourceGroupName -Location $LocationName -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet_1,$SingleSubnet_2
 
 # Create Public IP
    $PIP = New-AzPublicIpAddress -Name $PublicIPAddressName -DomainNameLabel $DNSNameLabel -ResourceGroupName $ResourceGroupName -Location $LocationName -AllocationMethod Dynamic
 
 # Create the NIC associated to The Subnet Defaultand to the Public IP
    $NIC_1 = New-AzNetworkInterface -Name $NICName_1 -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $Vnet.Subnets[0].Id -PublicIpAddressId $PIP.Id
 
 # Create the NIC associated to The Subnet backend 
    $NIC_2 = New-AzNetworkInterface -Name $NICName_2 -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $Vnet.Subnets[1].Id 

 # Create a credential objectc
    $Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

# Create VM config 
    $VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize

# Add OPerating system settings to the config (hostname, credentials etc)
    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
   
# Add NIC to the virtual machine config as secondary
    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC_1.Id -Primary
# Add NIC to the virtual machine config
    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC_2.Id
 
# Add the Image to deply  (Windows Server, Ubuntu, other... These information can be retrieved by 
# 1. Get-AzVMImagePublisher (using Location parameter) to find companies that published images
# 2. Get-AzVMImageOffer (using Location and PublisherName) to find the product Offer (es. windows server vs windows client, etc..)
# 3. Get-AzVMImageSku (using Location, Publisher and Offer) to find the SKU (ex windows server 2012 Datacenter)
# 4. Get-AzVMImage (using Location, Publisher, Offer and SKUs) to find the version of the product (latest)
# Take note of the values and then set the Image into the config
    $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter' -Version '2016.127.20190416'

####################################################
# Finally! Create the virtual machine using Resourcegroup, Location and VM configuration
    New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose
