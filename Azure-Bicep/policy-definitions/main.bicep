targetScope = 'managementGroup'

// ---------- Variables ----------
var policyDefinitions = [
  loadJsonContent('general/pol-deny-auto-approved-pe.json')
  loadJsonContent('general/pol-deny-general-allowed-locations.json')
  loadJsonContent('general/pol-deny-resource-type.json')
  loadJsonContent('storage-account/pol-audit-storage-account-should-prevent-shared-key-access.json')
  loadJsonContent('storage-account/pol-audit-storage-account-use-double-encryption.json')
  loadJsonContent('storage-account/pol-deny-storage-account-minimum-tls-version.json')
  loadJsonContent('storage-account/pol-deny-storage-account-prevent-cross-tenant-repl.json')
  loadJsonContent('storage-account/pol-deny-storage-account-public-endpoint.json')
  loadJsonContent('storage-account/pol-deny-storage-account-restrict-virtual-network-rules.json')
  loadJsonContent('storage-account/pol-deny-storage-account-secure-transfer.json')
  loadJsonContent('storage-account/pol-deny-storage-accounts-should-restrict-network-access.json')
  loadJsonContent('storage-account/pol-deploy-storage-account-advanced-threat-protection.json')
  loadJsonContent('storage-account/pol-deploy-storage-account-blob-soft-delete.json')
  loadJsonContent('tags/pol-inherit-tags-from-rg.json')
  loadJsonContent('tags/pol-inherit-tags-from-sub.json')
]

var mappedPolicyDefinitions = map(range(0, length(policyDefinitions)), i => {
    name: policyDefinitions[i].name
    displayName: contains(policyDefinitions[i].properties, 'displayName') ? policyDefinitions[i].properties.displayName : null
    description: contains(policyDefinitions[i].properties, 'description') ? policyDefinitions[i].properties.description : null
    metadata: contains(policyDefinitions[i].properties, 'metadata') ? policyDefinitions[i].properties.metadata : null
    mode: contains(policyDefinitions[i].properties, 'mode') ? policyDefinitions[i].properties.mode : 'All'
    parameters: contains(policyDefinitions[i].properties, 'parameters') ? policyDefinitions[i].properties.parameters : null
    policyRule: policyDefinitions[i].properties.policyRule
  })

var deploymentNameSuffix = last(split(deployment().name, '-'))

module policyDefs '../../BicepModules/authorization/policy-definition/main.bicep' = {
  name: take('policyDef-${deploymentNameSuffix}', 64)
  params: {
    policyDefinitions: mappedPolicyDefinitions
  }
}

output policyDefinitions array = policyDefs.outputs.policyDefinitions
