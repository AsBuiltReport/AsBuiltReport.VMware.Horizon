<!-- ********** DO NOT EDIT THESE LINKS ********** -->
<p align="center">
    <a href="https://www.asbuiltreport.com/" alt="AsBuiltReport"></a>
            <img src='https://avatars.githubusercontent.com/u/42958564' width="8%" height="8%" /></a>
</p>
<p align="center">
    <a href="https://www.powershellgallery.com/packages/AsBuiltReport.VMware.Horizon/" alt="PowerShell Gallery Version">
        <img src="https://img.shields.io/powershellgallery/v/AsBuiltReport.VMware.Horizon.svg" /></a>
    <a href="https://www.powershellgallery.com/packages/AsBuiltReport.VMware.Horizon/" alt="PS Gallery Downloads">
        <img src="https://img.shields.io/powershellgallery/dt/AsBuiltReport.VMware.Horizon.svg" /></a>
    <a href="https://www.powershellgallery.com/packages/AsBuiltReport.VMware.Horizon/" alt="PS Platform">
        <img src="https://img.shields.io/powershellgallery/p/AsBuiltReport.VMware.Horizon.svg" /></a>
</p>
<p align="center">
    <a href="https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/graphs/commit-activity" alt="GitHub Last Commit">
        <img src="https://img.shields.io/github/last-commit/AsBuiltReport/AsBuiltReport.VMware.Horizon/master.svg" /></a>
    <a href="https://raw.githubusercontent.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/master/LICENSE" alt="GitHub License">
        <img src="https://img.shields.io/github/license/AsBuiltReport/AsBuiltReport.VMware.Horizon.svg" /></a>
    <a href="https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/graphs/contributors" alt="GitHub Contributors">
        <img src="https://img.shields.io/github/contributors/AsBuiltReport/AsBuiltReport.VMware.Horizon.svg"/></a>
</p>
<p align="center">
    <a href="https://twitter.com/AsBuiltReport" alt="Twitter">
            <img src="https://img.shields.io/twitter/follow/AsBuiltReport.svg?style=social"/></a>
</p>
<!-- ********** DO NOT EDIT THESE LINKS ********** -->

# VMware Horizon As Built Report

VMware Horizon As Built Report is a PowerShell module which works in conjunction with [AsBuiltReport.Core](https://github.com/AsBuiltReport/AsBuiltReport.Core).

[AsBuiltReport](https://github.com/AsBuiltReport/AsBuiltReport) is an open-sourced community project which utilises PowerShell to produce as-built documentation in multiple document formats for multiple vendors and technologies.

Please refer to the AsBuiltReport [website](https://www.asbuiltreport.com) for more detailed information about this project.

# :books: Sample Reports

## Sample Report - Custom Style

Sample VMware Horizon As Built report HTML file: [Sample VMware Horizon As-Built Report.html](https://htmlpreview.github.io/?https://raw.githubusercontent.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/dev/Samples/Sample%20VMware%20Horizon%20As%20Built%20Report.html)

Sample VMware Horizon As Built report PDF file: [Sample VMware Horizon As Built Report.pdf](https://raw.githubusercontent.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/dev/Samples/VMware%20Horizon%20As%20Built%20Report.pdf)


# :beginner: Getting Started

Below are the instructions on how to install, configure and generate a VMware Horizon As Built report.

## :floppy_disk: Supported Versions

The VMware Horizon As Built Report supports the following Horizon versions;

- Horizon 8+
- Horizon 7? (Need Testing)

### PowerShell

This report is compatible with the following PowerShell versions;

| Windows PowerShell 5.1 |     PowerShell 7    |
|:----------------------:|:--------------------:|
|   :white_check_mark:   | :white_check_mark: |

## :wrench: System Requirements

PowerShell 5.1 or PowerShell 7, and the following PowerShell modules are required for generating a VMware Horizon As Built Report.

- [VMware PowerCLI Module](https://www.powershellgallery.com/packages/VMware.PowerCLI/)
- [AsBuiltReport.VMware.Horizon Module](https://www.powershellgallery.com/packages/AsBuiltReport.VMware.Horizon/)

### :closed_lock_with_key: Required Privileges

- A VMware Horizon As Built Report can be generated with Administrators(Read only) privileges.

## :package: Module Installation

Open a PowerShell terminal window and install each of the required modules.

:warning: VMware PowerCLI 12.7 or higher is required. Please ensure older PowerCLI versions have been uninstalled.

```powershell
install-module VMware.PowerCLI -MinimumVersion 12.7 -AllowClobber
install-module AsBuiltReport.VMware.Horizon
```

### GitHub

If you are unable to use the PowerShell Gallery, you can still install the module manually. Ensure you repeat the following steps for the [system requirements](https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon#wrench-system-requirements) also.

1. Download the code package / [latest release](https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/releases/latest) zip from GitHub
2. Extract the zip file
3. Copy the folder `AsBuiltReport.VMware.Horizon` to a path that is set in `$env:PSModulePath`.
4. Open a PowerShell terminal window and unblock the downloaded files with
    ```powershell
    $path = (Get-Module -Name AsBuiltReport.VMware.Horizon -ListAvailable).ModuleBase; Unblock-File -Path $path\*.psd1; Unblock-File -Path $path\Src\Public\*.ps1; Unblock-File -Path $path\Src\Private\*.ps1
    ```
5. Close and reopen the PowerShell terminal window.

_Note: You are not limited to installing the module to those example paths, you can add a new entry to the environment variable PSModulePath if you want to use another path._

## :pencil2: Configuration

The VMware Horizon As Built Report utilises a JSON file to allow configuration of report information, options, detail and healthchecks.

A VMware Horizon report configuration file can be generated by executing the following command;

```powershell
New-AsBuiltReportConfig -Report VMware.Horizon -FolderPath <User specified folder> -Filename <Optional>
```

Executing this command will copy the default VMware Horizon report JSON configuration to a user specified folder.

All report settings can then be configured via the JSON file.

The following provides information of how to configure each schema within the report's JSON file.

<!-- ********** DO NOT CHANGE THE REPORT SCHEMA SETTINGS ********** -->
### Report

The **Report** schema provides configuration of the VMware Horizon report information.

| Sub-Schema          | Setting      | Default                        | Description                                                  |
|---------------------|--------------|--------------------------------|--------------------------------------------------------------|
| Name                | User defined | VMware Horizon As Built Report | The name of the As Built Report                              |
| Version             | User defined | 1.0                            | The report version                                           |
| Status              | User defined | Released                       | The report release status                                    |
| ShowCoverPageImage  | true / false | true                           | Toggle to enable/disable the display of the cover page image |
| ShowTableOfContents | true / false | true                           | Toggle to enable/disable table of contents                   |
| ShowHeaderFooter    | true / false | true                           | Toggle to enable/disable document headers & footers          |
| ShowTableCaptions   | true / false | true                           | Toggle to enable/disable table captions/numbering            |

### Options

The **Options** schema allows certain options within the report to be toggled on or off.

<!-- ********** Add/Remove the number of InfoLevels as required ********** -->
### InfoLevel

The **InfoLevel** schema allows configuration of each section of the report at a granular level. The following sections can be set.

There are 3 levels (0-3) of detail granularity for each section as follows;

| Setting | InfoLevel         | Description                                                                                                                                |
|:-------:|-------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
|    0    | Disabled          | Does not collect or display any information                                                                                                |
|    1    | Enabled / Summary | Provides summarised information for a collection of objects                                                                                |
|    2    | Adv Summary       | Provides condensed, detailed information for a collection of objects                                                                       |

The table below outlines the default and maximum InfoLevel settings for each UsersandGroups section.

| Sub-Schema   | Default Setting | Maximum Setting |
|--------------|:---------------:|:---------------:|
| Entitlements      |        1        |        2        |
| HomeSiteAssignments    |        1        |        1        |
| UnauthenticatedAccess     |        1        |        1        |

The table below outlines the default and maximum InfoLevel settings for each Inventory section.

| Sub-Schema   | Default Setting | Maximum Setting |
|--------------|:---------------:|:---------------:|
| Desktop      |        1        |        2        |
| Applications    |        1        |        2        |
| Farms     |        1        |        2        |
| Machines     |        1        |        1        |
| GlobalEntitlements     |        1        |        1        |

The table below outlines the default and maximum InfoLevel settings for each Settings section.

| Sub-Schema   | Default Setting | Maximum Setting |
|--------------|:---------------:|:---------------:|
| vCenter      |        1        |        2        |
| ESXiHosts    |        1        |        2        |
| DataStores     |        1        |        2        |
| ADDomains     |        1        |        1        |
| UAGServers      |        1        |        1     |
| ConnectionServers      |        1        |        2     |
| InstantCloneDomainAccounts      |        1        |        1     |
| ProductLicensingandUsage      |        1        |        2     |
| GlobalSettings      |        1        |        1     |
| RegisteredMachines      |        1        |        2     |
| AdministratorsandGroups      |        1        |        2     |
| RolePrivileges      |        1        |        1     |
| RolePermissions      |        1        |        1     |
| AccessGroup      |        1        |        2     |
| EventDatabase      |        1        |        1     |
| Syslog      |        1        |        1     |
| EventstoFileSystem      |        1        |        1     |

### Healthcheck

The **Healthcheck** schema is used to toggle health checks on or off.

## :computer: Examples

```powershell
# Generate a Horizon As Built Report for Horizon Connection Server 'horizon-cs-01.corp.local' using specified credentials. Export report to HTML & DOCX formats. Use default report style. Append timestamp to report filename. Save reports to 'C:\Users\Jon\Documents'
PS C:\> New-AsBuiltReport -Report VMware.Horizon -Target 'Horizon-cs-01.corp.local' -Username 'administrator@domain.local' -Password 'VMware1!' -Format Html,Word -OutputFolderPath 'C:\Users\Jon\Documents' -Timestamp

# Generate a Horizon As Built Report for Horizon Connection Server 'Horizon-cs-01.corp.local' using specified credentials and report configuration file. Export report to Text, HTML & DOCX formats. Use default report style. Save reports to 'C:\Users\Jon\Documents'. Display verbose messages to the console.
PS C:\> New-AsBuiltReport -Report VMware.Horizon -Target 'Horizon-cs-01.corp.local' -Username 'administrator@domain.local' -Password 'VMware1!' -Format Text,Html,Word -OutputFolderPath 'C:\Users\Jon\Documents' -ReportConfigFilePath 'C:\Users\Jon\AsBuiltReport\AsBuiltReport.VMware.Horizon.json' -Verbose

# Generate a Horizon As Built Report for Horizon Connection Server 'Horizon-cs-01.corp.local' using stored credentials. Export report to HTML & Text formats. Use default report style. Highlight environment issues within the report. Save reports to 'C:\Users\JOn\Documents'.
PS C:\> $Creds = Get-Credential
PS C:\> New-AsBuiltReport -Report VMware.Horizon -Target 'Horizon-cs-01.corp.local' -Credential $Creds -Format Html,Text -OutputFolderPath 'C:\Users\Jon\Documents' -EnableHealthCheck

# Generate a single Horizon As Built Report for Horizon Connection Servers 'Horizon-cs-01.corp.local' and 'Horizon-cs-02.corp.local' using specified credentials. Report exports to WORD format by default. Apply custom style to the report. Reports are saved to the user profile folder by default.
PS C:\> New-AsBuiltReport -Report VMware.Horizon -Target 'Horizon-cs-01.corp.local','Horizon-cs-02.corp.local' -Username 'administrator@domain.local' -Password 'VMware1!' -StyleFilePath 'C:\Scripts\Styles\MyCustomStyle.ps1'

# Generate a Horizon As Built Report for Horizon Connection Server 'Horizon-cs-01.corp.local' using specified credentials. Export report to HTML & DOCX formats. Use default report style. Reports are saved to the user profile folder by default. Attach and send reports via e-mail.
PS C:\> New-AsBuiltReport -Report VMware.Horizon -Target 'Horizon-cs-01.corp.local' -Username 'administrator@domain.local' -Password 'VMware1!' -Format Html,Word -OutputFolderPath 'C:\Users\Jon\Documents' -SendEmail
```

## :x: Known Issues

- There are problems with the report when the IP address is used instead of the "Fully Qualified Domain Name" of the server.
- The report requires the user to be specified as follows: "username@domain.local". Specifying otherwise will generate an error like this: "Valid Domain is required".
