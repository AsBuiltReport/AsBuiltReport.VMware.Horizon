# AsBuiltReport.VMware.Horizon
Repository for VMware Horizon AsBuilt Report


# Sample Reports

<Coming Soon>

# Getting Started

Below are the instructions on how to install, configure and generate a VMware Horizon As Built Report

## Pre-requisites
The following PowerShell modules are required for generating a VMware Horizon As Built report.

Each of these modules can be easily downloaded and installed via the PowerShell Gallery 

- [AsBuiltReport Module](https://www.powershellgallery.com/packages/AsBuiltReport/)

### Module Installation

Open a Windows PowerShell terminal window and install each of the required modules as follows;
```powershell
Install-Module AsBuiltReport
```

### Required Privileges

To generate a VMware Horizon report, a user account with the Read Only role or higher on the UAG is required.

## Configuration

The VMware Horizon As Built Report utilises a JSON file to allow configuration of report information, options, detail and healthchecks.

A VMware Horizon report configuration file can be generated by executing the following command;
```powershell
New-AsBuiltReportConfig -Report VMware.Horizon -Path <User specified folder> -Name <Optional>
```

Executing this command will copy the default Horizon report JSON configuration to a user specified folder.

All report settings can then be configured via the JSON file.

The following provides information of how to configure each schema within the report's JSON file.

### Info Level
The InfoLevel sub-schema allows configuration of each section of the report at a granular level. The following sections can be set

Schema  Sub-Schema  Default Setting Max Setting
InfoLevel	Entitlements	1   2
InfoLevel	HomeSiteAssignments	1   1
InfoLevel	UnauthenticatedAccess	1   1
InfoLevel	Desktop	1   2
InfoLevel	Applications    1   2
InfoLevel	Farms	1   2
InfoLevel	vCenterVM	1   2
InfoLevel	RDSHosts	1   2
InfoLevel	PersistentDisks 1   2
InfoLevel	ThinApps    0   Not used
InfoLevel	GlobalEntitlements  1   3
InfoLevel	vCenter	1   2
InfoLevel   ESXiHosts   1   2
InfoLevel   DataStores  1   2
InfoLevel   Composers   1   1
InfoLevel   ADDomains   1   2
InfoLevel   SecurityServers 1   2
InfoLevel   GatewayServers  1   2
InfoLevel   ConnectionServers   1   2
InfoLevel   InstantCloneDomainAccounts  1   1
InfoLevel   ProductLicensingandUsage    1   1
InfoLevel   GlobalSettings  1   1
InfoLevel   RegisteredMachines  1   2
InfoLevel   AdministratorsandGroups 1   2
InfoLevel   RolePrivileges  1   2
InfoLevel   RolePermissions 1   1
InfoLevel   AccessGroup 1   2
InfoLevel   CloudPodArchitecture    1   2
InfoLevel   Sites   1   2
InfoLevel   EventConfiguration  1   1
InfoLevel   GlobalPolicies  0   Not Used
InfoLevel   JMPConfiguration    1   1


There are 4 levels (0-3) of detail granularity for each section as follows;

Setting	InfoLevel	Description
0	Disabled	does not collect or display any information
1	Summary**	provides summarised information for a collection of objects
2	Informative	provides condensed, detailed information for a collection of objects
3	Detailed	provides detailed information for individual objects

## Examples
There is one example listed below on running the AsBuiltReport script against a VMware Horizon target. Refer to the `README.md` file in the main AsBuiltReport project repository for more examples.

- The following creates a VMware Horizon As-Built report in HTML & Word formats in the folder C:\scripts\.
```powershell
PS C:\>New-AsBuiltReport -Report VMware.horizon -Target 192.168.1.100 -Credential (Get-Credential) -Format HTML,Word -OutputPath C:\scripts\
```

## Known Issues
ThinApp Configuration is not built out. I dont know of any APIs to pull the ThinApp Info.

Global Policies are not built out in this release. Will be fixed in later update.
