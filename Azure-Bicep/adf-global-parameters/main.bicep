@description('Required. The name of the Azure Data Factory.')
param name string

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Optional. Boolean to define whether or not to configure git during template deployment.')
param gitConfigureLater bool = true

@description('Optional. Repository type - can be \'FactoryVSTSConfiguration\' or \'FactoryGitHubConfiguration\'. Default is \'FactoryVSTSConfiguration\'.')
param gitRepoType string = 'FactoryVSTSConfiguration'

@description('Optional. The account name.')
param gitAccountName string = ''

@description('Optional. The project name. Only relevant for \'FactoryVSTSConfiguration\'.')
param gitProjectName string = ''

@description('Optional. The repository name.')
param gitRepositoryName string = ''

@description('Optional. The collaboration branch name. Default is \'main\'.')
param gitCollaborationBranch string = 'main'

@description('Optional. The root folder path name. Default is \'/\'.')
param gitRootFolder string = '/'

@description('Optional. List of Global Parameters for the factory.')
param globalParameters object = {}

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@description('Optional. Tags of the resource.')
param tags object = {}

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: name
  location: location
  tags: tags
  identity: identity
  properties: {
    repoConfiguration: bool(gitConfigureLater) ? null : union({
        type: gitRepoType
        accountName: gitAccountName
        repositoryName: gitRepositoryName
        collaborationBranch: gitCollaborationBranch
        rootFolder: gitRootFolder
      }, (gitRepoType == 'FactoryVSTSConfiguration' ? {
        projectName: gitProjectName
      } : {}), {})
    globalParameters: !empty(globalParameters) ? globalParameters : null
    publicNetworkAccess: publicNetworkAccess
  }
}

@description('The Name of the Azure Data Factory instance.')
output name string = dataFactory.name

@description('The Resource ID of the Data factory.')
output resourceId string = dataFactory.id

@description('The name of the Resource Group with the Data factory.')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(dataFactory.identity, 'principalId') ? dataFactory.identity.principalId : ''

@description('The location the resource was deployed into.')
output location string = dataFactory.location
