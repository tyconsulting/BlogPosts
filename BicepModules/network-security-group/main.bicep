metadata name = 'Bicep Module - Network Security Group'
metadata description = 'This module deploys a standardised Network security Group (NSG).'
metadata owner = 'Tao Yang'

@description('Required. Name of the Network Security Group.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Array of Security Rules to deploy to the Network Security Group. When not provided, an NSG including only the built-in roles will be deployed.')
param securityRules securityRuleType

@description('Optional. When enabled, flows created from Network Security Group connections will be re-evaluated when rules are updates. Initial enablement will trigger re-evaluation. Network Security Group connection flushing is not available in all regions.')
param flushConnection bool = false

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments roleAssignmentType

@description('Optional. Tags of the NSG resource.')
param tags object?

var mergedTags = union(tags ?? {}, {
    'hidden-module_name': 'network/network-security-group'
    'hidden-module_version': loadJsonContent('./version.json').version
  })

var formattedSecurityRules = [
for item in (securityRules ?? []): {
  name: item.name
  properties: {
    access: item.access
    description: item.?description
    destinationAddressPrefix: length(item.destination) == 1 && !contains(toLower(string(item.destination)), '/subscriptions/') ? item.destination[0] : null
    destinationAddressPrefixes: length(item.destination) > 1 && !contains(toLower(string(item.destination)), '/subscriptions/') ? item.destination : null
    destinationApplicationSecurityGroups: contains(toLower(string(item.destination)), '/subscriptions/') ? map((item.destination ?? []), (id) => { id: '${id}' }) : null
    destinationPortRange: length(item.destinationPort) == 1 ? item.destinationPort[0] : null
    destinationPortRanges: length(item.destinationPort) > 1 ? item.destinationPort : null
    direction: item.direction
    priority: item.priority
    protocol: item.protocol
    sourceAddressPrefix: length(item.source) == 1 && !contains(toLower(string(item.source)), '/subscriptions/') ? item.source[0] : null
    sourceAddressPrefixes: length(item.source) > 1 && !contains(toLower(string(item.source)), '/subscriptions/') ? item.source : null
    sourceApplicationSecurityGroups: contains(toLower(string(item.source)), '/subscriptions/') ? map((item.source ?? []), (id) => { id: '${id}' }) : null
    sourcePortRange: length(item.sourcePort) == 1 ? item.sourcePort[0] : null
    sourcePortRanges: length(item.sourcePort) > 1 ? item.sourcePort : null
  }
}
]

module networkSecurityGroup 'br/public:avm/res/network/network-security-group:0.1.2' = {
  name: take('networkSecurityGroup-${name}', 64)
  params: {
    name: name
    location: location
    securityRules: !empty(formattedSecurityRules) ? formattedSecurityRules : null
    flushConnection: flushConnection
    roleAssignments: roleAssignments
    tags: mergedTags
    enableTelemetry: false
  }
}

@description('The resource group the network security group was deployed into.')
output resourceGroupName string = networkSecurityGroup.outputs.resourceGroupName

@description('The resource ID of the network security group.')
output resourceId string = networkSecurityGroup.outputs.resourceId

@description('The name of the network security group.')
output name string = networkSecurityGroup.outputs.name

@description('The location the resource was deployed into.')
output location string = networkSecurityGroup.outputs.location

// =============== //
//   Definitions   //
// =============== //

type roleAssignmentType = {
  @description('Required. The name of the role to assign. If it cannot be found you can specify the role definition ID instead.')
  roleDefinitionIdOrName: string

  @description('Required. The principal ID of the principal (user/group/identity) to assign the role to.')
  principalId: string

  @description('Optional. The principal type of the assigned principal ID.')
  principalType: ('ServicePrincipal' | 'Group' | 'User' | 'ForeignGroup' | 'Device' | null)?

  @description('Optional. The description of the role assignment.')
  description: string?

  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container"')
  condition: string?

  @description('Optional. Version of the condition.')
  conditionVersion: '2.0'?

  @description('Optional. The Resource Id of the delegated managed identity resource.')
  delegatedManagedIdentityResourceId: string?
}[]?

type securityRuleType = {

  @sys.description('Required. The name of the security rule.')
  name: string

  @sys.description('Required. Whether network traffic is allowed or denied.')
  access: ('Allow' | 'Deny')

  @sys.description('Optional. A description for this rule.')
  @maxLength(140)
  description: string?

  @sys.description('Required. The destination can be one or more CIDR, IP ranges or Application Security Group resource Ids. Asterisk "*" can also be used to match all source IPs. Default tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used.')
  destination: string[]

  @sys.description('Required. One or more destination ports or ranges. Integer or range between 0 and 65535. Asterisk "*" can also be used to match all ports.')
  destinationPort: string[]

  @sys.description('Required. The direction of the rule. The direction specifies if rule will be evaluated on incoming or outgoing traffic.')
  direction: ('Inbound' | 'Outbound')

  @sys.description('Required. The priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule.')
  @minValue(100)
  @maxValue(4096)
  priority: int

  @sys.description('Required. Network protocol this rule applies to.')
  protocol: ('*' | 'Ah' | 'Esp' | 'Icmp' | 'Tcp' | 'Udp')

  @sys.description('Required. The source can be one or more CIDR, IP ranges or Application Security Group resource Ids. Asterisk "*" can also be used to match all source IPs. Default tags such as "VirtualNetwork", "AzureLoadBalancer" and "Internet" can also be used.')
  source: string[]

  @sys.description('Required. One or more source ports or ranges. Integer or range between 0 and 65535. Asterisk "*" can also be used to match all ports.')
  sourcePort: string[]
}[]?
