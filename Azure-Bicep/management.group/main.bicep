targetScope = 'tenant'

@description('Tier 1 management groups')
param tier1MgmtGroups array = []

@description('Tier 2 management groups')
param tier2MgmtGroups array = []

@description('Tier 3 management groups')
param tier3MgmtGroups array = []

@description('Tier 4 management groups')
param tier4MgmtGroups array = []

@description('Tier 5 management groups')
param tier5MgmtGroups array = []

@description('Tier 6 management groups')
param tier6MgmtGroups array = []

@description('Optional. Default Management group for new subscriptions.')
param defaultMgId string = ''

@description('Optional. Indicates whether RBAC access is required upon group creation under the root Management Group. Default value is true')
param authForNewMG bool = true

@description('Optional. Indicates whether Settings for default MG for new subscription and permissions for creating new MGs are configured. This configuration is applied on Tenant Root MG.')
param configMGSettings bool = false

module mg_hierarchy './module/managementGroupHierarchy.bicep' = {
  name: 'management_groups'
  params: {
    tier1MgmtGroups: tier1MgmtGroups
    tier2MgmtGroups: tier2MgmtGroups
    tier3MgmtGroups: tier3MgmtGroups
    tier4MgmtGroups: tier4MgmtGroups
    tier5MgmtGroups: tier5MgmtGroups
    tier6MgmtGroups: tier6MgmtGroups
    defaultMgId: defaultMgId
    authForNewMG: authForNewMG
    configMGSettings: configMGSettings
  }
}

output managementGroups array = mg_hierarchy.outputs.managementGroups
output root_mg_settings object = mg_hierarchy.outputs.root_mg_settings
output tier_1_mgs array = mg_hierarchy.outputs.tier_1_mgs
output tier_2_mgs array = mg_hierarchy.outputs.tier_2_mgs
output tier_3_mgs array = mg_hierarchy.outputs.tier_3_mgs
output tier_4_mgs array = mg_hierarchy.outputs.tier_4_mgs
output tier_5_mgs array = mg_hierarchy.outputs.tier_5_mgs
output tier_6_mgs array = mg_hierarchy.outputs.tier_6_mgs
