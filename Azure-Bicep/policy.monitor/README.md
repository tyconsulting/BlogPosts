# Azure Monitor Alert Rule for Azure Policy Compliance

## Overview

Blog Post: [Natively Monitoring Azure Policy Compliance States in Azure Monitor - 2023 Edition](https://blog.tyang.org/2023/09/30/natively0monitoring-azure-policy-compliance-states-in-azure-monitor-2023-edition/)


# Instruction

```powershell

New-AzResourceGroupDeployment -name 'policy-alert-rule' -ResourceGroupName 'rg-policy-alert-rule-01' -TemplateFile .\main.bicep -TemplateParameterFile .\main.parameters.json -Verbose

``````
