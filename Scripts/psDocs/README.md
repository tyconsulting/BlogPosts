# PSDocs Related scripts

* [**generateTemplateReadme.ps1**](./generateBicepReadme.ps1) - Script to generate `README.md` for the bicep template

## generateTemplateReadme.ps1

To execute `generateBicepReadme.ps1`, make sure the `metadata.json` file exists in the same directory as the bicep file, and run:

```PowerShell
./generateBicepReadme.ps1 -templatePath <path-to-bicep-file>
```

The metadata.json file must contain the following attributes:

* itemDisplayName
* description
* summary

For example:

```json
{
  "itemDisplayName": "Management Group Hierarchy Template",
  "description": "This template deploys the Management Group Hierarchy in an Azure tenant. It is used to create all child management groups under the tier-1 management group 'ABCD'.",
  "summary": "Deploys the Management Group Hierarchy in an Azure tenant."
}
```