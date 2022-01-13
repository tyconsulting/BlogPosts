@description('Specify the name of the failover cluster')
param existingFailoverClusterName string

@description('Specify the name of SQL Availability Group for which listener is being created')
param availabilityGroupName string

@description('Specify the AG replica configuration.')
param AGReplica array 

@description('List of SQL Virtual Machine names.')
param SQLVMNames array

@description('Specify a name for the listener for SQL Availability Group')
param Listener string = 'aglistener'

@description('Specify the port for listener')
param ListenerPort int = 1433

@description('Specify the available private IP address for the listener from the subnet the existing Vms are part of.')
param ListenerIp string

@description('Specify the resourcegroup for virtual network')
param vnetResourceGroup string = resourceGroup().name

@description('Specify the virtual network for Listener IP Address')
param vnetName string

@description('Specify the subnet under Vnet for Listener IP address')
param subnetName string

@description('Name of  internal load balancer for the AG listener. Choose Standard Sku if the VMs are not in an availability set.')
param loadBalancerName string

@description('Name of  internal load balancer for the AG listener. Choose Standard Sku if the VMs are not in an availability set.')
param loadBalancerSku string = 'Standard'

@description('The Load Balancer Private IP allocation method. - Static or Dynamic.')
param loadBalancerPrivateIPAllocationMethod string = 'Dynamic'

@description('Specify the load balancer port number (e.g. 59999)')
param ProbePort int = 59999

@description('Location for all resources.')
param location string = resourceGroup().location

var SubnetResourceId = resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets/', vnetName, subnetName)

var AGReplica_var = [for item in AGReplica: {
  commit: item.commit
  failover: item.failover
  readableSecondary: item.readableSecondary
  role: item.role
  sqlVirtualMachineInstanceId: resourceId('Microsoft.SqlVirtualMachine/sqlVirtualMachines', item.sqlVirtualMachineName)
}]

var SqlVmResourceIdList = [for item in SQLVMNames: resourceId('Microsoft.SqlVirtualMachine/sqlVirtualMachines', item)]

resource lb 'Microsoft.Network/loadBalancers@2020-05-01' = {
  name: loadBalancerName
  location: location
  sku: {
    name: loadBalancerSku
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontEnd'
        properties: {
          privateIPAllocationMethod: loadBalancerPrivateIPAllocationMethod
          subnet: {
            id: SubnetResourceId
          }
        }
      }
    ]
  }
}

resource listener 'Microsoft.SqlVirtualMachine/SqlVirtualMachineGroups/availabilityGroupListeners@2017-03-01-preview' = {
  name: '${existingFailoverClusterName}/${Listener}'
  properties: {
    availabilityGroupName: availabilityGroupName
    loadBalancerConfigurations: [
      {
        privateIpAddress: {
          ipAddress: ListenerIp
          subnetResourceId: SubnetResourceId
        }
        loadBalancerResourceId: lb.id
        probePort: ProbePort
        sqlVirtualMachineInstances: SqlVmResourceIdList
      }
    ]
    port: ListenerPort
    availabilityGroupConfiguration: {
      replicas: AGReplica_var
    }
  }
}

output listener_id string = listener.id
output load_balancer_id string = lb.id
