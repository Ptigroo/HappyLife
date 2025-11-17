# .NET 10 Upgrade Plan

## Execution Steps

Execute steps below sequentially one by one in the order they are listed.

1. Validate that a .NET 10 SDK required for this upgrade is installed on the machine and if not, help to get it installed.
2. Ensure that the SDK version specified in global.json files is compatible with the .NET 10 upgrade.
3. Upgrade HappyLifeModels\HappyLifeModels.csproj
4. Upgrade HappyLifeInterfaces\HappyLifeInterfaces.csproj
5. Upgrade HappyLifeRepository\HappyLifeRepository.csproj
6. Upgrade HappyLifeServices\HappyLifeServices.csproj
7. Upgrade HappyLife\HappyLife.csproj

## Settings

This section contains settings and data used by execution steps.

### Aggregate NuGet packages modifications across all projects

NuGet packages used across all selected projects or their dependencies that need version update in projects that reference them.

| Package Name                           | Current Version | New Version | Description                          |
|:---------------------------------------|:---------------:|:-----------:|:-------------------------------------|
| Microsoft.AspNetCore.OpenApi           | 9.0.10          | 10.0.0      | Recommended for .NET 10              |
| Microsoft.EntityFrameworkCore          | 9.0.10          | 10.0.0      | Recommended for .NET 10              |
| Microsoft.EntityFrameworkCore.Cosmos   | 9.0.0           | 10.0.0      | Recommended for .NET 10              |
| Microsoft.EntityFrameworkCore.InMemory | 9.0.10          | 10.0.0      | Recommended for .NET 10              |

### Project upgrade details

This section contains details about each project upgrade and modifications that need to be done in the project.

#### HappyLifeModels\HappyLifeModels.csproj modifications

Project properties changes:
  - Target framework should be changed from `net9.0` to `net10.0`

#### HappyLifeInterfaces\HappyLifeInterfaces.csproj modifications

Project properties changes:
  - Target framework should be changed from `net9.0` to `net10.0`

#### HappyLifeRepository\HappyLifeRepository.csproj modifications

Project properties changes:
  - Target framework should be changed from `net9.0` to `net10.0`

NuGet packages changes:
  - Microsoft.EntityFrameworkCore should be updated from `9.0.10` to `10.0.0` (*recommended for .NET 10*)
  - Microsoft.EntityFrameworkCore.Cosmos should be updated from `9.0.0` to `10.0.0` (*recommended for .NET 10*)
  - Microsoft.EntityFrameworkCore.InMemory should be updated from `9.0.10` to `10.0.0` (*recommended for .NET 10*)

#### HappyLifeServices\HappyLifeServices.csproj modifications

Project properties changes:
  - Target framework should be changed from `net9.0` to `net10.0`

#### HappyLife\HappyLife.csproj modifications

Project properties changes:
  - Target framework should be changed from `net9.0` to `net10.0`

NuGet packages changes:
  - Microsoft.AspNetCore.OpenApi should be updated from `9.0.10` to `10.0.0` (*recommended for .NET 10*)
