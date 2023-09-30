@description('Optional. Resource tags.')
param tags object = {}

@description('Optional. location.')
param location string = resourceGroup().location

@description('Required. Existing Log Analytics Workspace Resource Id.')
param logAnalyticsWorkspaceResourceId string

@description('Required. Alert Rule Name.')
param alertRuleName string

@description('Required. Alert Rule Display Name.')
param alertRuleDisplayName string

@description('Optional. Alert Rule Description.')
param alertRuleDescription string = ''

@description('Optional. Alert Rule Frequency Minutes. Default is 5 minutes.')
@minValue(1)
@maxValue(60)
param alertRuleFrequencyMinutes int = 5

@description('Optional. Alert Rule User Assigned Managed Identity Name.')
param alertRuleManagedIdentityName string = 'usmi-${alertRuleName}'

@description('Required. Alert Severity. Should be an integer between [0-4]. Value of 0 is severest.')
@minValue(0)
@maxValue(4)
param alertSeverity int

@description('Required. Azure Monitor Action Group Name.')
param actionGroupName string

@description('Required. Azure Monitor Action Group Short Name.')
@maxLength(12)
param actionGroupShortName string

@description('Required. Azure Monitor Action Group Email Receivers.')
param emailReceivers emailReceiverType[]

// ---Variables---
var argQueryTemplate = '''
arg("").PolicyResources
| where type =~ 'Microsoft.PolicyInsights/PolicyStates'
| extend
complianceState = tostring(properties.complianceState),
resourceId = tostring(properties.resourceId),
resourceType = tolower(tostring(properties.resourceType)),
resourceLocation = tostring(properties.resourceLocation),
policyAssignmentName = tostring(properties.policyAssignmentName),
policyAssignmentId = tostring(properties.policyAssignmentId),
policyDefinitionId = tostring(properties.policyDefinitionId),
policyDefinitionAction = tostring(properties.policyDefinitionAction),
policyDefinitionGroupNames = tostring(properties.policyDefinitionGroupNames),
policyDefinitionReferenceId = tostring(properties.policyDefinitionReferenceId),
policySetDefinitionId = tostring(properties.policySetDefinitioNId),
policySetDefinitionCategory = tostring(properties.policySetDefinitioNCategory),
dtTimeStamp = todatetime(tostring(properties.timestamp))
| where complianceState =~ 'noncompliant'
| where dtTimeStamp >  now(-15m)
| project complianceState, id, name, policyAssignmentName, resourceId, resourceType, policyAssignmentId, policyDefinitionId, policySetDefinitionId, policySetDefinitionCategory, policyDefinitionAction, policyDefinitionGroupNames, resourceGroup, resourceLocation,subscriptionId, tenantId, apiVersion, timeStamp=tostring(properties.timestamp)
'''
var argQuery = format(argQueryTemplate, alertRuleFrequencyMinutes)
var readerRoleId = '/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'

// ---User-Defined types---
type emailReceiverType = {
  name: string
  emailAddress: string
}

// ---Action Group---
resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'Global'
  tags: tags
  properties: {
    groupShortName: actionGroupShortName
    enabled: true
    emailReceivers: emailReceivers
  }
}
// ---User Assigned Managed Identity---
resource usmi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: alertRuleManagedIdentityName
  location: location
  tags: tags
}

// ---User Assigned Managed Identity Role Assignment---
module usmiRoleAssignment './modules/usmi_tenant_rbac.bicep' = {
  name: '${alertRuleManagedIdentityName}_reader'
  scope: tenant()
  params: {
    subscriptionId: subscription().subscriptionId
    resourceGroupName: resourceGroup().name
    managedIdentityName: alertRuleManagedIdentityName
    roleDefinitionId: readerRoleId
  }
}

// ---Alert Rule---
resource alertRule 'Microsoft.Insights/scheduledQueryRules@2023-03-15-preview' = {
  name: alertRuleName
  location: location
  tags: tags
  kind: 'LogAlert'
  dependsOn: [
    usmiRoleAssignment
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${usmi.id}': {}
    }
  }
  properties: {
    displayName: alertRuleDisplayName
    description: !empty(alertRuleDescription) ? alertRuleDescription : any(null)
    severity: alertSeverity
    enabled: true
    evaluationFrequency: format('PT{0}M', alertRuleFrequencyMinutes)
    scopes: [
      logAnalyticsWorkspaceResourceId
    ]
    targetResourceTypes: [
      'microsoft.operationalinsights/workspaces'
    ]
    windowSize: format('PT{0}M', alertRuleFrequencyMinutes)
    criteria: {
      allOf: [
        {
          query: argQuery
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'resourceId'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'policyAssignmentId'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'policyDefinitionId'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'timeStamp'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          resourceIdColumn: 'resourceId'
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    autoMitigate: false
    actions: {
      actionGroups: [
        actionGroup.id
      ]
    }
  }
}
