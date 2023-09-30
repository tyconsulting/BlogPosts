using './main.bicep'
param alertRuleName = 'ar-az-policy'
param alertRuleDescription = 'Alert rule for Azure Policy noncompliant resources.'
param alertSeverity = 1
param alertRuleDisplayName = 'Azure Policy noncompliant resources'
param actionGroupName = 'actgrp-az-policy'
param actionGroupShortName = 'azpolicy'
param alertRuleFrequencyMinutes = 15
param logAnalyticsWorkspaceResourceId = '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/xxxxxxxx/providers/microsoft.operationalinsights/workspaces/xxxxxxxx'
param emailReceivers = [
  {
    name: 'your name'
    emailAddress: 'email@contoso.com'
  }
]
