# Bicep template for Azure Management Groups

## Introduction

Bicep modules and sample templates for deploying standalone Azure SQL VMs as well as Azure SQL VM Clusters.

This is a part of the blog post **[Azure Bicep Module for Management Group Hierarchy](https://blog.tyang.org/2022/02/27/management-group-bicep-module)**

## Pre-requisites

Reference: [https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-to-tenant?tabs=azure-cli#required-access](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-to-tenant?tabs=azure-cli#required-access)

```bash
az role assignment create --assignee "[userId]" --scope "/" --role "Contributor"
```

## Deploy Management Group Hierarchy

```bash

# what-if
az deployment tenant what-if --location australiaeast --template-file main.bicep --parameters main.parameters.json

#deploy
az deployment tenant create --name 'mgmt-groups' --location australiaeast --template-file main.bicep --parameters main.parameters.json
```
