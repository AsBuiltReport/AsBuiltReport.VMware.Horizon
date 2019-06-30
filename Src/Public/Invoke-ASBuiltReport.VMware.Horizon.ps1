Invoke-AsBuiltReport.VMware.Horizon {

#requires -Modules HV-Helper

<#
.SYNOPSIS
    PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    This is an extension of New-AsBuiltReport.ps1 and cannot be run independently
.DESCRIPTION
    Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
.NOTES
    Version:        0.1
    Author:         Chris Hildebrandt and Karl Newick
    Twitter:        @childebrandt42 and @karlnewick
    Github:         childebrandt42
    Credits:        Iain Brighton (@iainbrighton) - PScribo module

.LINK
    https://github.com/tpcarman/As-Built-Report
#>


#region Configuration Settings
###############################################################################################
#                                    CONFIG SETTINGS                                          #
###############################################################################################

# If custom style not set, use VMware Storage style
if (!$StyleName) {
    .\Styles\VMware.ps1
}



[CmdletBinding(SupportsShouldProcess = $False)]
Param(

    [Parameter(Position = 0, Mandatory = $true, HelpMessage = 'Please provide the IP/FQDN of a Horizon Connection Server')]
    [ValidateNotNullOrEmpty()]
    [String]$HVServer,

    [parameter(ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
    [PSCredential]$Credentials
)

$script:HorizonServer = $null
Try { 
    $script:HorizonServer = Connect-HVServer $HVServer -Credential $Credentials 
} Catch { 
    Write-Verbose "Unable to connect to Horizon Connection Server $HVserver."
}

    #endregion Configuration Settings

    #region Script Body
    ###############################################################################################
    #                                       SCRIPT BODY                                           #
    ###############################################################################################


if ($HorizonServer) {
    #Gather information about the NSX environment which are used in later sections within the script
    $script:NSXControllers = Get-NsxController
    $script:Pools = GetHVpool
    $Script:Farms = GetHVFarm

#If this NSX Manager has Controllers, provide a summary of the NSX Controllers
        if ($Farms) {
            section -Style Heading3 'Farms' {
                $HorizonFarms = foreach ($Farm in $Farms) {
                    [PSCustomObject] @{
                        'Name' = $Farm.name
                        'Display Name' = $Farm.Displayname
                        'Access Group' = $Farm.AccessGroup
                        'Description' = $Farm.Description
                        'Enabled' = $Farm.Enabled
                        'Deleting' = $Farm.Deleting
                        
                    }
                }
                $HorizonFarms | Table -Name 'VMware Horizon Farm Information'
            }
        }

        
}
)