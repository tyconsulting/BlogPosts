targetScope = 'managementGroup'

@description('Policy Definition Source Management Group Id')
param managementGroupId string = managementGroup().id

var deploymentNameSuffix = last(split(deployment().name, '-'))
// ------Read policy initiative definitions from json files------
var policySetDefinitions = [
  loadJsonContent('polset-storage-account-test.json')
  loadJsonContent('polset-tags-test.json')
]

var mappedPolicySetDefinitions = map(range(0, length(policySetDefinitions)), i => {
    name: policySetDefinitions[i].name
    displayName: contains(policySetDefinitions[i].properties, 'displayName') ? policySetDefinitions[i].properties.displayName : null
    description: contains(policySetDefinitions[i].properties, 'description') ? policySetDefinitions[i].properties.description : null
    metadata: contains(policySetDefinitions[i].properties, 'metadata') ? policySetDefinitions[i].properties.metadata : null
    parameters: contains(policySetDefinitions[i].properties, 'parameters') ? policySetDefinitions[i].properties.parameters : null
    policyDefinitionGroups: contains(policySetDefinitions[i].properties, 'policyDefinitionGroups') ? policySetDefinitions[i].properties.policyDefinitionGroups : null
    policyDefinitions: map(range(0, length(policySetDefinitions[i].properties.policyDefinitions)), c => {
        policyDefinitionReferenceId: contains(policySetDefinitions[i].properties.policyDefinitions[c], 'policyDefinitionReferenceId') ? policySetDefinitions[i].properties.policyDefinitions[c].policyDefinitionReferenceId : null
        policyDefinitionId: replace(policySetDefinitions[i].properties.policyDefinitions[c].policyDefinitionId, '{policyLocationResourceId}', managementGroupId)
        parameters: contains(policySetDefinitions[i].properties.policyDefinitions[c], 'parameters') ? policySetDefinitions[i].properties.policyDefinitions[c].parameters : null
        groupNames: contains(policySetDefinitions[i].properties.policyDefinitions[c], 'groupNames') ? policySetDefinitions[i].properties.policyDefinitions[c].groupNames : null
      })
  })

//------Deploy Policy Initiatives------
module policyInitiatives '../../BicepModules/authorization/policy-set-definition/main.bicep' = {
  name: take('policySetDef-${deploymentNameSuffix}', 64)
  params: {
    policySetDefinitions: mappedPolicySetDefinitions
  }
}

//------ Outputs ------
output policySetDefinitions array = policyInitiatives.outputs.policySetDefinitions
