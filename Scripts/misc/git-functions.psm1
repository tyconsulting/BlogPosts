<#
.SYNOPSIS
Gets the root directory of the current Git repository.

.DESCRIPTION
The `Get-GitRoot` function retrieves the root directory of the current Git repository by running the `git rev-parse --show-toplevel` command. If the directory is found, it returns the absolute path of the Git root directory.

.EXAMPLE
PS C:\> Get-GitRoot
C:\path\to\git\repository

This command returns the root directory of the current Git repository.

#>
function Get-GitRoot {
  [CmdletBinding()]
  [OutputType([string])]
  $gitRootDir = git rev-parse --show-toplevel 2>&1
  if (Test-Path $gitRootDir) {
    Convert-Path $gitRootDir
  }
}

<#
.SYNOPSIS
Changes the current directory to the root directory of the current Git repository.

.DESCRIPTION
The `Enter-GitRoot` function changes the current directory to the root directory of the current Git repository by calling the `Get-GitRoot` function. If the Git root directory is found, it sets the location to that directory. Otherwise, it displays a warning message.

.EXAMPLE
PS C:\> Enter-GitRoot

This command changes the current directory to the root directory of the current Git repository.

#>
function Enter-GitRoot {
  [CmdletBinding()]
  $gitRoot = $(Get-GitRoot)
  if (test-path $gitRoot -ErrorAction SilentlyContinue) {
    set-location $gitRoot
  } else {
    Write-Warning "Unable to detect the git root dir."
  }
}

<#
.SYNOPSIS
Gets the default branch name from the specified remote Git repository.

.DESCRIPTION
The `Get-GitDefaultBranchFromRemote` function retrieves the default branch name from the specified remote Git repository by running the `git remote show` command and parsing the output. If the branch name is found, it returns the name of the default branch. Otherwise, it throws an error.

.PARAMETER remote
The name of the remote repository. The default value is 'origin'.

.EXAMPLE
PS C:\> Get-GitDefaultBranchFromRemote -remote origin
main

This command returns the default branch name of the 'origin' remote repository.

#>
function Get-GitDefaultBranchFromRemote {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $false, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]$remote = 'origin'
  )

  # Get remote
  $regex = 'HEAD branch: (.\S+)'
  $remoteDetails = git remote show $remote
  $headBranch = $remoteDetails -match $regex
  $defaultBranchNameMatch = $headBranch[0] -match $regex
  if ($defaultBranchNameMatch) {
    $defaultBranchName = $Matches[1]
  } else {
    Throw "Unable to extract the branch name from Remote '$remote'."
    Exit 1
  }

  $defaultBranchName
}

<#
.SYNOPSIS
Gets the name of the current Git branch.

.DESCRIPTION
The `Get-GitBranch` function retrieves the name of the current Git branch by running the `git branch --show-current` command. It returns the name of the branch as a string.

.EXAMPLE
PS C:\> Get-GitBranch
main

This command returns the name of the current Git branch.

#>
function Get-GitBranch {
  [CmdletBinding()]
  [OutputType([string])]
  param ()

  $branch = git branch --show-current
  $branch
}

<#
.SYNOPSIS
Gets the commit ID of the specified branch or tag.

.DESCRIPTION
The `Get-GitCommitId` function retrieves the commit ID of the specified branch or tag by running the `git rev-list -n 1` command. It returns the commit ID as a string.

.PARAMETER branchOrTagName
The name of the branch or tag for which to retrieve the commit ID. This parameter is mandatory.

.EXAMPLE
PS C:\> Get-GitCommitId -branchOrTagName main
a1b2c3d4e5f6g7h8i9j0

This command returns the commit ID of the 'main' branch.

#>
function Get-GitCommitId {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]$branchOrTagName
  )
  $commitId = git rev-list -n 1 $branchOrTagName
  $commitId
}

<#
.SYNOPSIS
Gets detailed information about all Git branches.

.DESCRIPTION
The `Get-AllGitBranchDetail` function retrieves detailed information about all Git branches by running the `git branch -va` command. It fetches the latest branch information, parses the output, and returns an array of custom objects containing branch details such as name, commit ID, commit message, and whether the branch is current, default, remote, or local.

.EXAMPLE
PS C:\> Get-AllGitBranchDetail

This command returns detailed information about all Git branches.

#>
function Get-AllGitBranchDetail {
  [CmdletBinding()]
  [OutputType([System.Array])]
  param ()

  #git fetch
  git fetch | out-null
  $branches = @()
  $allBranches = git branch -va

  # find default branch name
  $defaultBranchName = Get-GitDefaultBranchFromRemote
  foreach ($line in $allBranches) {
    # Trim leading and trailing whitespace
    $line = $line.Trim()

    # Skip empty lines
    if ([string]::IsNullOrEmpty($line)) {
      continue
    }
    #
    # Extract the branch/tag name and commit ID
    if ($line -match '^(\*)?\s*(.+?)\s+([0-9a-f]{7,})\s+(.+)$') {
      if ($Matches[1] -ieq '*') {
        $isCurrent = $true
      } else {
        $isCurrent = $false
      }
      $name = $matches[2].Trim()
      $commitId = $matches[3]
      $commitMessage = $matches[4]
      $isRemoteBranch = $branchOrTagName -match '^remotes\/origin\/\S+'
      # Create a PSCustomObject and add it to the array
      $branches += [PSCustomObject]@{
        name            = $name
        IsCurrent       = $isCurrent
        IsDefaultBranch = $name -imatch $defaultBranchName
        IsRemoteBranch  = $isRemoteBranch
        IsLocalBranch   = !$isRemoteBranch
        ShortCommitId   = $commitId
        CommitMessage   = $commitMessage
      }
    }
  }

  # Output the parsed objects
  , $branches
}

<#
.SYNOPSIS
Tests if a branch with the specified name exists.

.DESCRIPTION
The `Test-BranchName` function checks if a branch with the specified name exists by retrieving detailed information about all Git branches using the `Get-AllGitBranchDetail` function. It returns a boolean value indicating whether the branch exists.

.PARAMETER branchName
The name of the branch to test. This parameter is mandatory.

.EXAMPLE
PS C:\> Test-BranchName -branchName main
True

This command checks if a branch named 'main' exists and returns True if it does.

#>
function Test-BranchName {
  [CmdletBinding()]
  [OutputType([bool])]
  param (
    [parameter(Mandatory = $true, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]$branchName
  )
  $allBranches = Get-AllGitBranchDetail
  if ($allBranches.name -contains $branchName) {
    $result = $true
  } else {
    $result = $false
  }
  $result
}

<#
.SYNOPSIS
Gets the current Git reference (branch or tag).

.DESCRIPTION
The `Get-CurrentGitRef` function retrieves the current Git reference, which can be either a branch or a tag. It first attempts to get the branch name using the `git branch --show-current` command. If no branch name is found, it tries to get the tag name using the `git describe --tags --exact-match` command. If neither is found, it checks for pre-defined environment variables from GitHub Actions or Azure DevOps to determine the reference. It returns a custom object containing the reference name and its type (branch or tag).

.EXAMPLE
PS C:\> Get-CurrentGitRef

This command returns the current Git reference, including its name and type.

#>
function Get-CurrentGitRef {
  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param ()

  # Get branch name from Git
  $BranchOrTagName = git branch --show-current

  #if branch name is null, try get the tag name instead
  if ([string]::IsNullOrEmpty($BranchOrTagName)) {
    $BranchOrTagName = git describe --tags --exact-match
    #if tag is detected, set the type to tag
    if (![string]::IsNullOrEmpty($BranchOrTagName)) {
      $type = 'tag'
    }
  } else {
    $type = 'branch'
  }

  #if can't detect branch or tag via git command, try the pre-defined environment variables from GitHub Action or Azure DevOps
  # try GitHub variable
  if ([string]::IsNullOrEmpty($BranchOrTagName) -and (Test-Path env:GITHUB_REF)) {
    $GitHubRef = $env:GITHUB_REF
    if ($GitHubRef -match 'refs/heads/(.*)') {
      $BranchOrTagName = $Matches[1]
      $type = 'branch'
    } elseif ($GitHubRef -match 'refs/tags/(.*)') {
      $BranchOrTagName = $Matches[1]
      $type = 'tag'
    }
  }

  # try Azure DevOps variable
  if ([string]::IsNullOrEmpty($BranchName) -and (Test-Path env:BUILD_SOURCEBRANCH)) {
    $ADOSourceBranch = $env:BUILD_SOURCEBRANCH
    if ($ADOSourceBranch -match 'refs/heads/(.*)') {
      $BranchOrTagName = $Matches[1]
      $type = 'branch'
    } elseif ($ADOSourceBranch -match 'refs/tags/(.*)') {
      $BranchOrTagName = $Matches[1]
      $type = 'tag'
    }
  }
  $objOutput = [PSCustomObject]@{
    BranchOrTagName = $BranchOrTagName
    Type            = $type
  }
  $objOutput
}

<#
.SYNOPSIS
Gets the source branch of the specified Git tag.

.DESCRIPTION
The `Get-GitTagSourceBranch` function retrieves the source branch of the specified Git tag by running the `git branch --contains` command. It filters out any lines indicating a detached HEAD state and validates the branch names. It returns an array of branch names that contain the specified tag.

.PARAMETER tag
The name of the tag for which to retrieve the source branch. This parameter is mandatory.

.EXAMPLE
PS C:\> Get-GitTagSourceBranch -tag v1.0.0
main

This command returns the source branch of the 'v1.0.0' tag.

#>
function Get-GitTagSourceBranch {
  [CmdletBinding()]
  [OutputType([System.Array])]
  param (
    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$tag
  )
  $arrBranchName = @()
  Write-Verbose "Get source branch of the tag '$tag'"
  $branchName = git branch --contains $tag
  #Remove the line "(HEAD detached at {tag})" from output
  If ($branchName -is [System.Array]) {
    foreach ($line in $branchName) {
      $line = $line -replace '\* ', ''
      $line = $line.trim()
      if (!($line -match 'Head detached at')) {
        Write-Verbose "Validate branch '$line'"
        $isValidBranch = Test-BranchName -branchName $line
        if ($isValidBranch)
        { $arrBranchName += $line }
      }
    }
  }
  #remove the "* " prefix from the branch name
  $arrBranchName += $branchName -replace '\* ', ''

  , $arrBranchName
}

<#
.SYNOPSIS
Checks if a specified commit ID exists in a given branch.

.DESCRIPTION
The `Find-CommitIdInBranch` function checks if a specified commit ID exists in a given branch by retrieving all commit IDs of the branch using the `git rev-list` command. It returns a boolean value indicating whether the commit ID is found in the branch.

.PARAMETER branchName
The name of the branch to check. This parameter is mandatory.

.PARAMETER commitId
The commit ID to check for in the branch. This parameter is mandatory.

.EXAMPLE
PS C:\> Find-CommitIdInBranch -branchName main -commitId a1b2c3d4e5f6g7h8i9j0
True

This command checks if the commit ID 'a1b2c3d4e5f6g7h8i9j0' exists in the 'main' branch and returns True if it does.

#>
function Find-CommitIdInBranch {
  [CmdletBinding()]
  [OutputType([System.Boolean])]
  Param (
    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$branchName,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$commitId
  )

  #Get all commit Ids of the branch

  $commitIds = git rev-list $branchName
  Write-Verbose "Total $($commitIds.count) commits found in the branch '$branchName'."
  #check if the specified commit Id is in the commit Ids
  if ($commitIds -contains ($commitId)) {
    Write-Verbose "Commit Id '$commitId' found from all the commit Ids."
    $isValid = $true
  } else {
    Write-Verbose "Commit Id '$commitId' not found from the commit Ids."
    $isValid = $false
  }
  $isValid
}

Set-Alias -Name cdgr -Value Enter-GitRoot
