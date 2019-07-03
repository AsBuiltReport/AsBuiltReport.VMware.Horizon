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
                        section -Style Heading5 'View Composer Storage Settings'
                        'Use Separate Datastores Replica And OS Disks' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewComposerStorageSettings.UseSeparateDatastoresReplicaAndOSDisks
                        'Replica Disk Datastore' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewComposerStorageSettings.ReplicaDiskDatastore
                        'Use Native Snapshots' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewComposerStorageSettings.UseNativeSnapshots
                        'Reclaim Vm Disk Space' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewComposerStorageSettings.SpaceReclamationSettings.ReclaimVmDiskSpace
                        'ReclamationThresholdGB' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewComposerStorageSettings.SpaceReclamationSettings.ReclamationThresholdGB
                        'Redirect Windows Profile' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewComposerStorageSettings.PersistentDiskSettings.RedirectWindowsProfile
                        'Use Separate Datastores Persistent And OS Disks' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewComposerStorageSettings.PersistentDiskSettings.UseSeparateDatastoresPersistentAndOSDisks
                        'Persistent Disk Datastores' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewComposerStorageSettings.PersistentDiskSettings.PersistentDiskDatastores
                        'Disk Size MB' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewComposerStorageSettings.PersistentDiskSettings.DiskSizeMB
                        'Disk Drive Letter' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewComposerStorageSettings.PersistentDiskSettings.DiskDriveLetter
                        'Redirect Disposable Files' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewComposerStorageSettings.NonPersistentDiskSettings.RedirectDisposableFiles
                        'Disk Size MB' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewComposerStorageSettings.NonPersistentDiskSettings.DiskSizeMB
                        section -Style Heading5 'View Storage Accelerator Settings'
                        'Use View Storage Accelerator' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewStorageAcceleratorSettings.UseViewStorageAccelerator
                        'View Composer Disk Types' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewStorageAcceleratorSettings.ViewComposerDiskTypes
                        'Regenerate View Storage Accelerator Days' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewStorageAcceleratorSettings.RegenerateViewStorageAcceleratorDays
                        'Blackout Times' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewStorageAcceleratorSettings.BlackoutTimes
                        section -Style Heading5 'User Assignment'
                        'User Assignment' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.userAssignment.userAssignment
                        'Automatic Assignment' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.userAssignment.AutomaticAssignment
                        section -Style Heading3 'Customization Settings'
                        'Customization Type' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.customizationSettings.CustomizationType
                        'Domain Administrator' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.customizationSettings.DomainAdministrator
                        'AdContainer' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.customizationSettings.AdContainer
                        'Reuse PreExisting Accounts' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.customizationSettings.ReusePreExistingAccounts
                        'No Customization Settings' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.customizationSettings.NoCustomizationSettings
                        'Sysprep Customization Settings' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.customizationSettings.SysprepCustomizationSettings
                        'Quick Prep Customization Settings' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.customizationSettings.QuickprepCustomizationSettings
                        section -Style Heading3 'Clone Prep Customization Settings'
                        'Instant Clone Engine Domain Administrator' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.customizationSettings.CloneprepCustomizationSettings.InstantCloneEngineDomainAdministrator
                        'Power Off Script Name' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.customizationSettings.CloneprepCustomizationSettings.PowerOffScriptName
                        'PowerOffScriptParameters' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.customizationSettings.CloneprepCustomizationSettings.PowerOffScriptParameters
                        'PostSynchronizationScriptName' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.customizationSettings.CloneprepCustomizationSettings.PostSynchronizationScriptName
                        'Post Synchronization Script Parameters' = $Pool.AutomatedDesktopSpec.virtualCenterProvisioningSettings.customizationSettings.CloneprepCustomizationSettings.PostSynchronizationScriptParameters
                        section -Style Heading3 'virtual Center'
                        'Virtual Center' = $Pool.AutomatedDesktopSpec.virtualCenter
                        section -Style Heading3 'VM Naming Spec'
                        'Naming Method' = $Pool.AutomatedDesktopSpec.virtualCenter.vmNamingSpec.namingMethod
                        'Max Number Of Machines' = $Pool.AutomatedDesktopSpec.virtualCenter.vmNamingSpec.patternNamingSettings.MaxNumberOfMachines
                        'Number Of Spare Machines' = $Pool.AutomatedDesktopSpec.virtualCenter.vmNamingSpec.patternNamingSettings.NumberOfSpareMachines
                        'Provisioning Time' = $Pool.AutomatedDesktopSpec.virtualCenter.vmNamingSpec.patternNamingSettings.ProvisioningTime
                        'Min Number Of Machines' = $Pool.AutomatedDesktopSpec.virtualCenter.vmNamingSpec.patternNamingSettings.MinNumberOfMachines
                        'Specific Naming Spec' = $Pool.AutomatedDesktopSpec.virtualCenter.vmNamingSpec.specificNamingSpec
                        'Provisioning Type' = $Pool.AutomatedDesktopSpec.virtualCenter.provisioningType
                        'Transparent Page Sharing Scope' = $Pool.AutomatedDesktopSpec.virtualCenter.virtualCenterManagedCommonSettings.TransparentPageSharingScope
                        'Min Number Of Machines' = $Pool.AutomatedDesktopSpec.virtualCenter.vmNamingSpec.patternNamingSettings.MinNumberOfMachines
                        section -Style Heading2 'Manual Desktop Spec'
                        'Machines' = $Pool.ManualDesktopSpec.machines
                        'User Assignment' = $Pool.ManualDesktopSpec.userAssignment.UserAssignment
                        'Automatic Assignment' = $Pool.ManualDesktopSpec.UserAssignment.AutomaticAssignment
                        'Source' = $Pool.ManualDesktopSpec.source
                        'Use View Storage Accelerator' = $Pool.ManualDesktopSpec.viewStorageAcceleratorSettings.UseViewStorageAccelerator
                        'View Composer Disk Types' = $Pool.ManualDesktopSpec.viewStorageAcceleratorSettings.ViewComposerDiskTypes
                        'Regenerate View Storage Accelerator Days' = $Pool.ManualDesktopSpec.viewStorageAcceleratorSettings.RegenerateViewStorageAcceleratorDays
                        'Blackout Times' = $Pool.ManualDesktopSpec.viewStorageAcceleratorSettings.BlackoutTimes
                        'Virtual Center' = $Pool.ManualDesktopSpec.virtualCenter
                        'Transparent Page Sharing Scope' = $Pool.ManualDesktopSpec.virtualCenterManagedCommonSettings.TransparentPageSharingScope
                        'Machines' = $Pool.ManualDesktopSpec.viewStorageAcceleratorSettings.
                        section -Style Heading2 'Rds Desktop Spec'
                        'Machines' = $Pool.RDSDesktopSpec.machines
                        'User Assignment' = $Pool.RDSDesktopSpec.userAssignment.UserAssignment
                        'Automatic Assignment' = $Pool.RDSDesktopSpec.UserAssignment.AutomaticAssignment
                        'Source' = $Pool.RDSDesktopSpec.source
                        'Use View Storage Accelerator' = $Pool.RDSDesktopSpec.viewStorageAcceleratorSettings.UseViewStorageAccelerator
                        'View Composer Disk Types' = $Pool.RDSDesktopSpec.viewStorageAcceleratorSettings.ViewComposerDiskTypes
                        'Regenerate View Storage Accelerator Days' = $Pool.RDSDesktopSpec.viewStorageAcceleratorSettings.RegenerateViewStorageAcceleratorDays
                        'Blackout Times' = $Pool.RDSDesktopSpec.viewStorageAcceleratorSettings.BlackoutTimes
                        'Virtual Center' = $Pool.RDSDesktopSpec.virtualCenter
                        'Transparent Page Sharing Scope' = $Pool.RDSDesktopSpec.virtualCenterManagedCommonSettings.TransparentPageSharingScope
                        'Machines' = $Pool.RDSDesktopSpec.viewStorageAcceleratorSettings.
                        
                        
                    }
                }
                $HorizonPools | Table -Name 'VMware Horizon Pool Information'
            }
        }

        
}
}
}