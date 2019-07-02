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
            section -Style Heading2 'Farms' {
                $HorizonFarms = foreach($Farm in $Farms) {
                    [PSCustomObject] @{
                        'Name' = $Farm.data.name
                        'Display Name' = $Farm.data.Displayname
                        'Description' = $Farm.data.Description
                        'Farm Enabled' = $Farm.data.Enabled
                        'Farm Deleting' = $Farm.data.Deleting
                        'Diconnected Session Timeout Policy' = $Farm.data.Settings.disconnectedsessiontimeoutpolicy
                        'Disconnected Session Timeout Minutes' = $Farm.data.Settings.DisconnectedSessionTimeoutMinutes
                        'Empty Session Timeout Policy' = $Farm.data.Settings.EmptySessionTimeoutPolicy
                        'Empty Session Timeout Minutes' = $Farm.data.Settings.EmptySessionTimeoutMinutes
                        'Log off After Timeout' = $Farm.data.Settings.LogoffAfterTimeout
                        'DefaultDisplayProtocol' = $Farm.data.DisplayProtocolSettings.DefaultDisplayProtocol
                        'Allow Display Protocol Override' = $Farm.data.DisplayProtocolSettings.AllowDisplayProtocolOverride
                        'Enable HTML Access' = $Farm.data.DisplayProtocolSettings.EnableHTMLAccess
                    }
                }
                $HorizonFarms | Table -Name 'VMware Horizon Farm Information'
            }
        }

        if ($Pools) {
            section -Style Heading2 'Pools' {
                $HorizonPools = foreach($Pool in $Pools) {
                    $poolname = $pool.base.Name
                    $pool | get-hvpoolspec
                    [PSCustomObject] @{
                        'Pool Name' = $Pool.Base.name
                        'Display Name' = $Pool.base.displayName
                        'Discription' = $Pool.base.description
                        section -Style Heading3 'Deskop Settings'
                        'Enabled' = $Pool.DesktopSettings.Enabled
                        'Deleting' = $Pool.DesktopSettings.Deleting
                        'Connection Server Restrictions' = $Pool.DesktopSettings.ConnectionServerRestrictions
                        'Pool Type' = $Pool.Type
                        section -Style Heading3 'Log Off Settings'
                        'Power Policy' = $Pool.DesktopSettings.LogoffSettings.PowerPolicy
                        'Automatic Logoff Policy' = $Pool.DesktopSettings.LogoffSettings.AutomaticLogoffPolicy
                        'Automatic Logoff Minutes' = $Pool.DesktopSettings.LogoffSettings.AutomaticLogoffMinutes
                        'Allow Users To Reset Machines' = $Pool.DesktopSettings.LogoffSettings.AllowUsersToResetMachines
                        'Allow Multiple Sessions Per User' = $Pool.DesktopSettings.LogoffSettings.AllowMultipleSessionsPerUser
                        'Delete Or Refresh Machine After Logoff' = $Pool.DesktopSettings.LogoffSettings.DeleteOrRefreshMachineAfterLogoff
                        'Refresh Os Disk After Logoff' = $Pool.DesktopSettings.LogoffSettings.RefreshOsDiskAfterLogoff
                        'Refresh Period Days For Replica Os Disk' = $Pool.DesktopSettings.LogoffSettings.RefreshPeriodDaysForReplicaOsDisk
                        'Refresh Threshold Percentage For Replica Os Disk' = $Pool.DesktopSettings.LogoffSettings.RefreshThresholdPercentageForReplicaOsDisk
                        section -Style Heading3 'Display Protocol Settings'
                        'SupportedDisplayProtocols' = $Pool.DesktopSettings.DisplayProtocolSettings.SupportedDisplayProtocols
                        'Default Display Protocol' = $Pool.DesktopSettings.DisplayProtocolSettings.DefaultDisplayProtocol
                        'Allow Users To Choose Protocol' = $Pool.DesktopSettings.DisplayProtocolSettings.AllowUsersToChooseProtocol
                        'EnableHTMLAccess' = $Pool.DesktopSettings.DisplayProtocolSettings.EnableHTMLAccess
                        section -Style Heading4 'Pcoip Display Settings'
                        'Renderer 3D' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.Renderer3D
                        'Enable GRID vGPUs' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.EnableGRIDvGPUs
                        'VGPU Grid Profile' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.VGPUGridProfile
                        'VRam Size MB' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.VRamSizeMB
                        'Max Number Of Monitors' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.MaxNumberOfMonitors
                        'MaxResolutionOfAnyOneMonitor' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.MaxResolutionOfAnyOneMonitor
                        section -Style Heading3 'Flash Settings'
                        'Flash Quality' = $Pool.DesktopSettings.FlashSettings.Quality
                        'Flash Throttling' = $Pool.DesktopSettings.FlashSettings.Throttling
                        section -Style Heading3 'Mirage Configuration Overrides'
                        'Over ride Global Setting' = $Pool.DesktopSettings.MirageConfigurationOverrides.OverrideGlobalSetting
                        'Enabled' = $Pool.DesktopSettings.MirageConfigurationOverrides.Enabled
                        'Url' = $Pool.DesktopSettings.MirageConfigurationOverrides.Url
                        section -Style Heading3 'Automated Desktop Specs'
                        section -Style Heading4 'Virtual Center Provisioning Settings'
                        'Enable Provisioning' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.EnableProvisioning
                        'Stop Provisioning On Error' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.StopProvisioningOnError
                        'Minimum Ready VMs On vComposer Maintenance' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.MinReadyVMsOnVComposerMaintenance
                        section -Style Heading5 'Virtual Center Provisioning Data'
                        'Datacenter' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterProvisioningData.datacenter
                        'Parent VM' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterProvisioningData.parentVm
                        'Host Or Cluster' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterProvisioningData.hostOrCluster
                        'Resource Pool' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterProvisioningData.resourcePool
                        'Snapshot' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterProvisioningData.snapshot
                        'vmFolder' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterProvisioningData.vmFolder
                        'Template' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterProvisioningData.template
                        section -Style Heading5 'Virtual Center Storage Settings'
                        'Data Store Storage Over Commit' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.Datastores.storageOvercommit
                        'Data Store' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.Datastores.datastore
                        'Use VSan' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.UseVSan


                        
                    }
                }
                $HorizonPools | Table -Name 'VMware Horizon Pool Information'
            }
        }

        
}
}
}