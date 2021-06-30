$myResourceGroup="task-vnet-rg"
$Location='westeurope'

$myVnetName="public-vnet"
$myVnetAddress="10.1.0.0/16"

$mySubnetName="edge-subnet"
$mySubnetAddress="10.1.0.0/24"

# Create resource group
New-AzResourceGroup -Name $myResourceGroup  -Location $Location

# Create subnet
$mySubnet = New-AzVirtualNetworkSubnetConfig -Name $mySubnetName -AddressPrefix $mySubnetAddress

#Create vnet
New-AzVirtualNetowrk -Name $myVnetName -ResourceGroupName $myResourceGroup -Location $Location -AddressPrefix $myVnetAddress  -subnet $mySubnet


#In case we need to add a gateway 




