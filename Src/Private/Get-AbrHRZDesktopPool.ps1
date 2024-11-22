function Get-AbrHRZDesktopPool {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        1.1.4
        Author:         Chris Hildebrandt, Karl Newick
        Twitter:        @childebrandt42, @karlnewick
        Editor:         Jonathan Colon, @jcolonfzenpr
        Twitter:        @asbuiltreport
        Github:         AsBuiltReport
        Credits:        Iain Brighton (@iainbrighton) - PScribo module


    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon
    #>

    [CmdletBinding()]
    param (
    )

    begin {
        Write-PScriboMessage "Pool Desktop InfoLevel set at $($InfoLevel.Inventory.Desktop)."
        Write-PScriboMessage "Collecting Pool Desktop information."
    }

    process {
        try {
            if ($Pools) {
                if ($InfoLevel.Inventory.Desktop -ge 1) {
                    Section -Style Heading3 "Desktop Pools" {
                        Paragraph "The following section details the Desktop Pools configuration for $($HVEnvironment.toUpper()) server."
                        BlankLine
                        $OutObj = @()
                        foreach ($Pool in $Pools) {
                            Write-PScriboMessage "Discovered Desktop Pool Information for Pool $($Pool.Base.Name)."
                            Switch ($Pool.Automateddesktopdata.ProvisioningType) {
                                'INSTANT_CLONE_ENGINE' { $ProvisioningType = 'Instant Clone' }
                                'VIRTUAL_CENTER' { $ProvisioningType = 'Full Virtual Machines' }
                            }

                            if ($Pool.Type -eq "MANUAL") {
                                $UserAssign = $Pool.ManualDesktopData.UserAssignment.UserAssignment
                            } else { $UserAssign = $Pool.AutomatedDesktopData.UserAssignment.UserAssignment }

                            $inObj = [ordered] @{
                                'Name' = $Pool.Base.Name
                                'Type' = $Pool.Type
                                'Provisioning Type' = $ProvisioningType
                                'User Assignment' = $UserAssign
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                        }

                        $TableParams = @{
                            Name = "Desktop Pools - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 25, 25, 25, 25
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                        try {
                            if ($InfoLevel.Inventory.Desktop -ge 2) {
                                Section -Style Heading4 "Desktop Pools Details" {
                                    foreach ($Pool in $Pools) {
                                        # Find Access Group for Desktop Pool
                                        $AccessgroupsJoined = $hzServices.AccessGroup.AccessGroup_List() + $hzServices.AccessGroup.AccessGroup_List().Children
                                        $AccessGroupMatch = $AccessgroupsJoined | Where-Object { $_.Id.id -eq $Pool.base.accessgroup.id }

                                        if ($AccessGroupMatch) {
                                            $AccessGroupName = $AccessGroupMatch.base.name
                                        } else {
                                            $AccessGroupName = ''  # Set to a default value if no match is found
                                        }
                                        <#
                                        # Find out Global Entitlement Group for Applications
                                        $InstantCloneDomainAdminGroupMatch = $false
                                        foreach ($InstantCloneDomainAdminGroup in $InstantCloneDomainAdminGroups) {
                                            if ($InstantCloneDomainAdminGroup.Id.id -eq $Pool.automateddesktopdata.CustomizationSettings.CloneprepCustomizationSettings.InstantCloneEngineDomainAdministrator.id) {
                                                $InstantCloneDomainAdminGroupDisplayName = $InstantCloneDomainAdmins.base.username
                                                $InstantCloneDomainAdminGroupMatch = $true
                                            }
                                        if ($InstantCloneDomainAdminGroupMatch) {
                                            break
                                            }
                                        }

                                        # Find out Global Entitlement Group for Applications
                                        $GlobalEntitlementMatch = $false
                                        foreach ($GlobalEntitlement in $GlobalEntitlements) {
                                            if ($GlobalEntitlement.Id.id -eq $Pool.globalentitlementdata.globalentitlement.id) {
                                                $GlobalEntitlementDisplayName = $GlobalEntitlement.base.DisplayName
                                                $GlobalEntitlementMatch = $true
                                            }
                                        if ($GlobalEntitlementMatch) {
                                            break
                                            }
                                        }

                                        $farmMatch = $false
                                        foreach ($farm in $farms) {
                                            if ($farm.Id.id -eq $Pool.rdsdesktopdata.farm.id) {
                                                $FarmIDName = $farm.data.name
                                                $farmMatch = $true
                                            }
                                            if ($farmMatch) {
                                                break
                                            }
                                        }
                                        #>
                                        # Desktop OS Data
                                        $DesktopAssignmentViewResultsDataMatch = $false
                                        foreach ($DesktopAssignmentViewResult in $DesktopAssignmentViewResultsData.DesktopAssignmentData) {
                                            if ($DesktopAssignmentViewResult.name -eq $Pool.Base.Name) {
                                                $NumberofPoolMachines = $DesktopAssignmentViewResult.Name
                                                $PooLOpperatingSystem = $DesktopAssignmentViewResult.OperatingSystem
                                                $PoolOpperatingSystemArch = $DesktopAssignmentViewResult.OperatingSystemArchitecture
                                                $DesktopAssignmentViewResultsDataMatch = $true
                                            }
                                            if ($DesktopAssignmentViewResultsDataMatch) {
                                                break
                                            }
                                        }

                                        # Find vCenter ID Name
                                        $vCenterServerIDName = ''
                                        $PoolGroups = $pool.manualdesktopdata.virtualcenter.id
                                        foreach ($PoolGroup in $PoolGroups) {
                                            foreach ($vCenterServer in $vCenterServers) {
                                                if ($vCenterServer.Id.id -eq $PoolGroup) {
                                                    $vCenterServerIDName = $vCenterServer.serverspec.ServerName
                                                    break
                                                }
                                            }
                                            if ($PoolGroups.count -gt 1) {
                                                $vCenterServerIDNameResults += "$vCenterServerIDName, "
                                                $vCenterServerIDName = $vCenterServerIDNameResults.TrimEnd(', ')
                                            }
                                        }

                                        # Find vCenter Auto ID Name
                                        $vCenterServerAutoIDName = ''
                                        $PoolGroups = $Pool.automateddesktopdata.virtualcenter.id
                                        foreach ($PoolGroup in $PoolGroups) {
                                            foreach ($vCenterServer in $vCenterServers) {
                                                if ($vCenterServer.Id.id -eq $PoolGroup) {
                                                    $vCenterServerAutoIDName = $vCenterServer.serverspec.ServerName
                                                    break
                                                }

                                            }
                                            if ($PoolGroups.count -gt 1) {
                                                $vCenterServerAutoIDNameResults += "$vCenterServerAutoIDName, "
                                                $vCenterServerAutoIDName = $vCenterServerAutoIDNameResults.TrimEnd(', ')
                                            }
                                        }

                                        # Find Base Image ID Name
                                        $PoolBaseImage = ''
                                        $PoolBaseImagePath = ''
                                        if ($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ParentVM.id) {
                                            foreach ($CompatibleBaseImageVM in $CompatibleBaseImageVMs) {
                                                if ($CompatibleBaseImageVM.id.id -eq $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ParentVM.id) {
                                                    $PoolBaseImage = $CompatibleBaseImageVM.name
                                                    $PoolBaseImagePath = $CompatibleBaseImageVM.Path
                                                    break
                                                }
                                            }
                                        }

                                        # Get Pool Base Image Snapshot
                                        $BaseImageSnapshotListLast = ''
                                        if ( $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Snapshot.id) {
                                            $BaseImageSnapshotList = $hzServices.BaseImageSnapshot.BaseImageSnapshot_List($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ParentVM)
                                            $BaseImageSnapshotListLast = $BaseImageSnapshotList | Select-Object -Last 1
                                        }

                                        # DataCenters
                                        $PoolDataCenterName = ''
                                        $PoolDatacenterPath = ''
                                        if ($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Datacenter.id) {
                                            $DataCenterList = $hzServices.Datacenter.Datacenter_List($Pool.automateddesktopdata.virtualcenter)

                                            # Find DataCenter ID Name
                                            foreach ($DataCenter in $DataCenterList) {
                                                if ($DataCenter.id.id -eq $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Datacenter.id) {
                                                    $PoolDataCenterName = $DataCenter.base.name
                                                    $PoolDatacenterPath = $DataCenter.base.Path
                                                    break
                                                }
                                            }
                                        }

                                        # VM Folder List
                                        $VMFolder = ''
                                        $VMFolderPath = ''
                                        if ($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.VmFolder.id) {

                                            $VMFolderPath = $Pool.automateddesktopdata.VirtualCenterNamesData.VmFolderPath
                                            $VMFolder = $VMFolderPath -replace '^(.*[\\\/])'
                                        }

                                        # VM Host or Cluster
                                        $VMhostandCluter = ''
                                        if ($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.HostOrCluster.id) {
                                            #$HostAndCluster = $hzServices.HostOrCluster.HostOrCluster_GetHostOrClusterTree($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Datacenter)
                                            $VMhostandCluterPath = $Pool.automateddesktopdata.VirtualCenterNamesData.HostOrClusterPath
                                            $VMhostandCluter = $VMhostandCluterPath -replace '^(.*[\\\/])'
                                        }

                                        # VM Resource Pool
                                        $VMResourcePool = ''
                                        if ($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ResourcePool.id) {
                                            #$ResourcePoolTree = $hzServices.ResourcePool.ResourcePool_GetResourcePoolTree($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Datacenter)
                                            $VMResourcePoolPath = $Pool.automateddesktopdata.VirtualCenterNamesData.ResourcePoolPath
                                            $VMResourcePool = $VMResourcePoolPath -replace '^(.*[\\\/])'
                                        }

                                        <#
                                        # VM Persistent Disk DataStores
                                        if ($Pool.automateddesktopdata.VirtualCenterNamesData.PersistentDiskDatastorePaths){
                                            $VMPersistentDiskDatastorePath = $Pool.automateddesktopdata.VirtualCenterNamesData.PersistentDiskDatastorePaths
                                            $VMPersistentDiskDatastore = $VMPersistentDiskDatastorePath -replace '^(.*[\\\/])'
                                        }
                                        #>

                                        # VM Network Card
                                        if ($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterNetworkingSettings.nics.nic.id) {
                                            $NetworkInterfaceCardList = $hzServices.NetworkInterfaceCard.NetworkInterfaceCard_ListBySnapshot($BaseImageSnapshotListLast.Id)
                                        }

                                        # VM AD Container
                                        $PoolContainerName = ''
                                        if ($Pool.automateddesktopdata.CustomizationSettings.AdContainer.id) {
                                            foreach ($ADDomain in $ADDomains) {
                                                $ADDomainID = ($ADDomain.id.id -creplace '^[^/]*/', '')
                                                if ($Pool.automateddesktopdata.CustomizationSettings.AdContainer.id -like "ADContainer/$ADDomainID/*") {
                                                    $ADContainers = $hzServices.ADContainer.ADContainer_ListByDomain($ADDomain.id)
                                                    foreach ($ADContainer in $ADContainers) {
                                                        if ($ADContainer.id.id -eq $Pool.automateddesktopdata.CustomizationSettings.AdContainer.id) {
                                                            $PoolContainerName = $ADContainer.rdn
                                                            break
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        # Black out Times
                                        $BlackOutDates = $pool.ManualDesktopData.ViewStorageAcceleratorSettings.BlackoutTimes
                                        $BlackOutDateString = $BlackOutDates | Format-Table | Out-String

                                        # Pool Customization Type
                                        $Customizations = ('')
                                        If ($pool.AutomatedDesktopData.CustomizationSettings.CustomizationType -eq "SYS_PREP") {
                                            Foreach ($vCenterServer in $vCenterServers) {
                                                $Customizations = $hzServices.CustomizationSpec.CustomizationSpec_List($vCenterServer.id)
                                                Foreach ($Customization in $Customizations) {
                                                    if ($pool.AutomatedDesktopData.CustomizationSettings.SysprepCustomizationSettings.CustomizationSpec.id -eq $Customization.id.id) {
                                                        $PoolCustomization = $($Customization.CustomizationSpecData.Name)
                                                    }
                                                }
                                            }
                                        }
                                        # VM Template
                                        $PoolTemplateName = ''
                                        if ($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Template.id) {
                                            foreach ($Template in $CompatibleTemplateVMs) {
                                                if ($Template.id.id -eq $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Template.id) {
                                                    $PoolTemplateName = $Template.name
                                                    break
                                                }
                                            }
                                        }
                                        try {
                                            Section -Style Heading5 "Pool - $($Pool.Base.name)" {
                                                $SupportedDisplayProtocolsresult = ''
                                                $SupportedDisplayProtocols = $Pool.DesktopSettings.DisplayProtocolSettings | ForEach-Object { $_.SupportedDisplayProtocols }
                                                $SupportedDisplayProtocolsresult = $SupportedDisplayProtocols -join ', '

                                                $StorageOvercommitsresult = ''
                                                $StorageOvercommit = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterStorageSettings.datastores | ForEach-Object { $_.StorageOvercommit }
                                                $StorageOvercommitsresult = $StorageOvercommit -join ', '

                                                $DatastoreFinal = ''
                                                Switch ($Pool.Type) {
                                                    'MANUAL' { $POOLDST = $Pool.ManualDesktopData.VirtualCenterNamesData }
                                                    default { $POOLDST = $Pool.automateddesktopdata.VirtualCenterNamesData }
                                                }
                                                $DatastorePaths = $POOLDST | ForEach-Object { $_.DatastorePaths }
                                                foreach ($Datastore in $DatastorePaths) {
                                                    $Datastorename = $Datastore -replace '^(.*[\\\/])'
                                                    $DatastoreFinal += $DatastoreName -join "`r`n" | Out-String
                                                }
                                                #$DatastorePathsresult = $DatastorePaths -join ', '
                                                try {
                                                    Section -ExcludeFromTOC -Style Heading5 "General Summary - $($Pool.Base.name)" {
                                                        $OutObj = @()
                                                        Write-PScriboMessage "Discovered $($Pool.Base.name) General Information."
                                                        $inObj = [ordered] @{
                                                            'Name' = $Pool.Base.name
                                                            'Display Name' = $Pool.base.displayName
                                                            'Description' = $Pool.base.description
                                                            'Access Group' = $AccessGroupName
                                                            'Enabled' = $Pool.DesktopSettings.Enabled
                                                            'Type' = $Pool.Type
                                                            'Machine Source' = Switch ($pool.Source) {
                                                                'INSTANT_CLONE_ENGINE' { 'vCenter(Instant Clone)' }
                                                                'VIRTUAL_CENTER' { 'vCenter' }
                                                                default { $pool.Source }
                                                            }
                                                            'Provisioning Type' = Switch ($Pool.Automateddesktopdata.ProvisioningType) {
                                                                'INSTANT_CLONE_ENGINE' { 'Instant Clone' }
                                                                'VIRTUAL_CENTER' { 'Full Virtual Machines' }
                                                                default { $Pool.Automateddesktopdata.ProvisioningType }
                                                            }
                                                            'Enabled for Provisioning' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.EnableProvisioning
                                                            'Client Restrictions Enabled' = $Pool.DesktopSettings.ClientRestrictions
                                                        }

                                                        if ($Pool.Type -eq 'MANUAL') {
                                                            $inObj.Remove('Provisioning Type')
                                                            $inObj.Remove('Enabled for Provisioning')
                                                        }

                                                        $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                        $TableParams = @{
                                                            Name = "General - $($Pool.Base.name)"
                                                            List = $true
                                                            ColumnWidths = 50, 50
                                                        }

                                                        if ($Report.ShowTableCaptions) {
                                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                                        }
                                                        $OutObj | Table @TableParams
                                                    }
                                                } catch {
                                                    Write-PScriboMessage -IsWarning $_.Exception.Message
                                                }
                                                try {
                                                    Section -ExcludeFromTOC -Style Heading5 "Detailed Settings - $($Pool.Base.name)" {
                                                        $OutObj = @()
                                                        Write-PScriboMessage "Discovered $($Pool.Base.name) Pool Setting Information."
                                                        $inObj = [ordered] @{
                                                            'Name' = $Pool.Base.name
                                                            'Display Name' = $Pool.base.displayName
                                                            'Description' = $Pool.base.description
                                                            'Access Group' = $AccessGroupName
                                                            'Enabled' = $Pool.DesktopSettings.Enabled
                                                            'Type' = $Pool.Type
                                                            'Machine Source' = Switch ($pool.Source) {
                                                                'INSTANT_CLONE_ENGINE' { 'vCenter(Instant Clone)' }
                                                                'VIRTUAL_CENTER' { 'vCenter' }
                                                                default { $pool.Source }
                                                            }
                                                            'Provisioning Type' = Switch ($Pool.Automateddesktopdata.ProvisioningType) {
                                                                'INSTANT_CLONE_ENGINE' { 'Instant Clone' }
                                                                'VIRTUAL_CENTER' { 'Full Virtual Machines' }
                                                                default { $Pool.Automateddesktopdata.ProvisioningType }
                                                            }
                                                            'Enabled for Provisioning' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.EnableProvisioning
                                                            'Client Restrictions Enabled' = $Pool.DesktopSettings.ClientRestrictions

                                                            'Max Number of Machines' = $pool.automateddesktopdata.vmnamingsettings.patternnamingsettings.MaxNumberOfMachines
                                                            'Min number of Machines' = $pool.automateddesktopdata.vmnamingsettings.patternnamingsettings.MinNumberOfMachines
                                                            'Number of Spare Machines' = $pool.automateddesktopdata.vmnamingsettings.patternnamingsettings.NumberOfSpareMachines
                                                            'Connection Server Restrictions' = [string]($Pool.DesktopSettings.ConnectionServerRestrictions -join ",")
                                                            'Stop Provisioning on Error' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.StopProvisioningOnError
                                                            'Add Virtual TPM' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.AddVirtualTPM
                                                            'Minimum Number of Machines Ready' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.MinReadyVMsOnVComposerMaintenance
                                                            'Naming Method' = $Pool.automateddesktopdata.VmNamingSettings.NamingMethod
                                                            'Naming Pattern' = $pool.automateddesktopdata.vmnamingsettings.patternnamingsettings.namingpattern
                                                            'Power Policy' = $Pool.DesktopSettings.LogoffSettings.PowerPolicy
                                                            'Provisioning Time' = $pool.automateddesktopdata.vmnamingsettings.patternnamingsettings.ProvisioningTime
                                                            'Automatic Logoff Policy' = $Pool.DesktopSettings.LogoffSettings.AutomaticLogoffPolicy
                                                            'Automatic Logoff Minutes' = $Pool.DesktopSettings.LogoffSettings.AutomaticLogoffMinutes
                                                            'Allow Users to Reset Machines' = $Pool.DesktopSettings.LogoffSettings.AllowUsersToResetMachines
                                                            'Allow Multiple Sessions Per User' = $Pool.DesktopSettings.LogoffSettings.AllowMultipleSessionsPerUser
                                                            'Delete or Refresh Machine After Logoff' = $Pool.DesktopSettings.LogoffSettings.DeleteOrRefreshMachineAfterLogoff
                                                            'Refresh OS Disk After Logoff' = $Pool.DesktopSettings.LogoffSettings.RefreshOsDiskAfterLogoff
                                                            'Refresh Period Days for Replica OS Disk' = $Pool.DesktopSettings.LogoffSettings.RefreshPeriodDaysForReplicaOsDisk
                                                            'Refresh Threshold Percentage For Replica OS Disk' = $Pool.DesktopSettings.LogoffSettings.RefreshThresholdPercentageForReplicaOsDisk
                                                            'Empty Session Timeout Policy' = $Pool.DesktopSettings.LogoffSettings.EmptySessionTimeoutPolicy
                                                            'Empty Session Timeout Minutes' = $Pool.DesktopSettings.LogoffSettings.EmptySessionTimeoutMinutes
                                                            'Log off After Timeout' = $Pool.DesktopSettings.LogoffSettings.LogoffAfterTimeout
                                                            'Prelaunch Session Timeout Policy' = $Pool.DesktopSettings.LogoffSettings.PreLaunchSessionTimeoutPolicy
                                                            'Prelaunch Session Timeout Minutes' = $Pool.DesktopSettings.LogoffSettings.PreLaunchSessionTimeoutMinutes
                                                            'Session Timeout Policy' = $Pool.DesktopSettings.LogoffSettings.SessionTimeoutPolicy
                                                            'Category Folder Name' = $pool.DesktopSettings.CategoryFolderName
                                                            'Client Restrictions' = $Pool.DesktopSettings.ClientRestrictions
                                                            'Shortcut Locations' = $Pool.DesktopSettings.ShortcutLocations
                                                            'Allow Users to use Multiple Sessions Per User' = $Pool.DesktopSettings.LogoffSettings.AllowMultipleSessionsPerUser
                                                            'Supported Session Types' = $Pool.DesktopSettings.SupportedSessionTypes
                                                            'Cloud Managed' = $Pool.DesktopSettings.CloudManaged
                                                            'Cloud Assigned' = $Pool.DesktopSettings.CloudAssigned
                                                            'Display Assigned Machine Name' = $Pool.DesktopSettings.DisplayAssignedMachineName
                                                            'Display Machine Alias' = $Pool.DesktopSettings.DisplayMachineAlias
                                                            'Supported Display Protocols' = $SupportedDisplayProtocolsresult
                                                            'Default Display Protocol' = $Pool.DesktopSettings.DisplayProtocolSettings.DefaultDisplayProtocol
                                                            'Allow Users to Choose Protocol' = $Pool.DesktopSettings.DisplayProtocolSettings.AllowUsersToChooseProtocol
                                                            'Enable HTML Access' = $Pool.DesktopSettings.DisplayProtocolSettings.EnableHTMLAccess
                                                            'Enable Collaboration' = $Pool.DesktopSettings.DisplayProtocolSettings.EnableCollaboration
                                                            'Renderer 3D' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.Renderer3D
                                                            'Enable GRID vGPUs' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.EnableGRIDvGPUs
                                                            'vGPU Grid Profile' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.VGPUGridProfile
                                                            'vRam Size MB' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.VRamSizeMB
                                                            'Max Number of Monitors' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.MaxNumberOfMonitors
                                                            'Max Resolution of Any One Monitor' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.MaxResolutionOfAnyOneMonitor
                                                            'Use View Storage Accelerator' = $pool.ManualDesktopData.ViewStorageAcceleratorSettings.UseViewStorageAccelerator
                                                            'Regenerate View Storage Accelerator Days' = $pool.ManualDesktopData.ViewStorageAcceleratorSettings.RegenerateViewStorageAcceleratorDays
                                                            'Black Out Times' = $BlackOutDateString
                                                            'Transparent Page Sharing Scope' = $Pool.ManualDesktopData.VirtualCenterManagedCommonSettings.TransparentPageSharingScope
                                                        }
                                                        if ($Pool.Type -eq 'AUTOMATED') {
                                                            $inObj.Remove('Use View Storage Accelerator')
                                                            $inObj.Remove('Regenerate View Storage Accelerator Days')
                                                            $inObj.Remove('Black Out Times')
                                                            $inObj.Remove('Transparent Page Sharing Scope')
                                                        }

                                                        if ($Pool.Type -eq 'MANUAL') {
                                                            $inObj.Remove('Max Number of Machines')
                                                            $inObj.Remove('Min number of Machines')
                                                            $inObj.Remove('Number of Spare Machines')
                                                            $inObj.Remove('Connection Server Restrictions')
                                                            $inObj.Remove('Stop Provisioning on Error')
                                                            $inObj.Remove('Naming Method')
                                                            $inObj.Remove('Naming Pattern')
                                                            $inObj.Remove('Provisioning Time')
                                                            $inObj.Remove('Refresh Period Days for Replica OS Disk')
                                                            $inObj.Remove('Refresh Threshold Percentage For Replica OS Disk')
                                                        }

                                                        if ($Pool.Type -eq 'RDS') {
                                                            $inObj.Remove('Max Number of Machines')
                                                            $inObj.Remove('Min number of Machines')
                                                            $inObj.Remove('Number of Spare Machines')
                                                            $inObj.Remove('Stop Provisioning on Error')
                                                            $inObj.Remove('Naming Method')
                                                            $inObj.Remove('Naming Pattern')
                                                            $inObj.Remove('Provisioning Time')
                                                            $inObj.Remove('Refresh Period Days for Replica OS Disk')
                                                            $inObj.Remove('Refresh Threshold Percentage For Replica OS Disk')
                                                        }

                                                        $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                        $TableParams = @{
                                                            Name = "Pool Settings - $($Pool.Base.name)"
                                                            List = $true
                                                            ColumnWidths = 50, 50
                                                        }

                                                        if ($Report.ShowTableCaptions) {
                                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                                        }
                                                        $OutObj | Table @TableParams
                                                    }
                                                } catch {
                                                    Write-PScriboMessage -IsWarning $_.Exception.Message
                                                }
                                                try {
                                                    Section -ExcludeFromTOC -Style Heading5 "vCenter Server Settings - $($Pool.Base.name)" {
                                                        $OutObj = @()
                                                        Write-PScriboMessage "Discovered $($Pool.Base.name) vCenter Server Information."
                                                        $inObj = [ordered] @{
                                                            'Virtual Center' = Switch ($Pool.Type) {
                                                                'MANUAL' { $vCenterServerIDName }
                                                                default { $vCenterServerAutoIDName }
                                                            }
                                                            'Template' = $PoolTemplateName
                                                            'Parent VM' = $PoolBaseImage
                                                            'Parent VM Path' = $PoolBaseImagePath
                                                            'Current Number of Machines' = $NumberofPoolMachines
                                                            'Parent Operating System' = $PooLOpperatingSystem
                                                            'Parent Operating System Architecture' = $PoolOpperatingSystemArch
                                                            'Snapshot' = $BaseImageSnapshotListLast.name
                                                            'Snapshot Path' = $BaseImageSnapshotListLast.path
                                                            'Datacenter' = $PoolDataCenterName
                                                            'Datacenter Path' = $PoolDatacenterPath
                                                            'VM Folder' = $VMFolder
                                                            'VM Folder Path' = Switch ($Pool.Type) {
                                                                'MANUAL' { $Pool.ManualDesktopData.VirtualCenterNamesData.VmFolderPath }
                                                                default { $Pool.automateddesktopdata.VirtualCenterNamesData.VmFolderPath }
                                                            }
                                                            'Host or Cluster' = $VMhostandCluter
                                                            'Host or Cluster Path' = Switch ($Pool.Type) {
                                                                'MANUAL' { $Pool.ManualDesktopData.VirtualCenterNamesData.HostOrClusterPath }
                                                                default { $Pool.automateddesktopdata.VirtualCenterNamesData.HostOrClusterPath }
                                                            }
                                                            'Resource Pool' = $VMResourcePool
                                                            'Resource Pool Path' = Switch ($Pool.Type) {
                                                                'MANUAL' { $Pool.ManualDesktopData.VirtualCenterNamesData.ResourcePoolPath }
                                                                default { $Pool.automateddesktopdata.VirtualCenterNamesData.ResourcePoolPath }
                                                            }
                                                            'Datastores' = $DatastoreFinal
                                                            'Datastores Storage Over-Commit' = $StorageOvercommitsresult
                                                            'Use VSAN' = $pool.AutomatedDesktopData.VirtualCenterProvisioningSettings.VirtualCenterStorageSettings.usevsan
                                                            'Storage Cluster Path' = $pool.AutomatedDesktopData.VirtualCenterNamesData.SdrsClusterPath
                                                            'View Storage Accelerator' = Switch ($Pool.Type) {
                                                                'MANUAL' { $Pool.ManualDesktopData.ViewStorageAcceleratorSettings.UseViewStorageAccelerator }
                                                                'AUTOMATED' { $Pool.AutomatedDesktopData.VirtualCenterProvisioningSettings.VirtualCenterStorageSettings.ViewStorageAcceleratorSettings.UseViewStorageAccelerator }
                                                                default { 'Not Supported' }
                                                            }
                                                            'Transparent Page Sharing Scope' = Switch ($Pool.Type) {
                                                                'MANUAL' { $Pool.ManualDesktopData.VirtualCenterManagedCommonSettings.TransparentPageSharingScope }
                                                                'AUTOMATED' { $Pool.AutomatedDesktopData.VirtualCenterManagedCommonSettings.TransparentPageSharingScope }
                                                                default { 'Not Supported' }
                                                            }
                                                            'Replica Disk Datastore Path' = $Pool.automateddesktopdata.VirtualCenterNamesData.ReplicaDiskDatastorePath
                                                            'Networks' = Switch ($Pool.AutomatedDesktopData.VirtualCenterNamesData.NetworkLabelNames) {
                                                                $null { 'Golden Image network selected' }
                                                                default { $Pool.AutomatedDesktopData.VirtualCenterNamesData.NetworkLabelNames }
                                                            }
                                                            'Network Card' = $NetworkInterfaceCardList.data.name
                                                            'Network Label Enabled' = $pool.AutomatedDesktopData.VirtualCenterProvisioningSettings.VirtualCenterNetworkingSettings.nics.NetworkLabelAssignmentSpecs.Enabled
                                                            'Network Nic Name' = $pool.AutomatedDesktopData.VirtualCenterProvisioningSettings.VirtualCenterNetworkingSettings.nics.NicName
                                                            'Network Label Names' = [string]($Pool.DesktopSettings.ConnectionServerRestrictions -join ",")
                                                            'Network Max Label Type' = $pool.AutomatedDesktopData.VirtualCenterProvisioningSettings.VirtualCenterNetworkingSettings.nics.NetworkLabelAssignmentSpecs.MaxLabelType
                                                            'Network Max Label' = $pool.AutomatedDesktopData.VirtualCenterProvisioningSettings.VirtualCenterNetworkingSettings.nics.NetworkLabelAssignmentSpecs.MaxLabel
                                                            'Customization Type' = $Pool.automateddesktopdata.CustomizationSettings.CustomizationType
                                                            'Customization Spec Name' = $Pool.automateddesktopdata.CustomizationSettings.CustomizationSpecName
                                                            'Power off Script Name' = $pool.AutomatedDesktopData.CustomizationSettings.CloneprepCustomizationSettings.PowerOffScriptName
                                                            'Power off Script Parameters' = $pool.AutomatedDesktopData.CustomizationSettings.CloneprepCustomizationSettings.PowerOffScriptParameters
                                                            'Post Synchronization Script Name' = $pool.AutomatedDesktopData.CustomizationSettings.CloneprepCustomizationSettings.PostSynchronizationScriptName
                                                            'Post Synchronization Script Parameters' = $pool.AutomatedDesktopData.CustomizationSettings.CloneprepCustomizationSettings.PostSynchronizationScriptParameters
                                                            'Priming Computer Account' = $pool.AutomatedDesktopData.CustomizationSettings.CloneprepCustomizationSettings.PrimingComputerAccount
                                                            'Guest Customization Account' = ($InstantCloneDomainAdmins | Where-Object { $_.id.id -eq $Pool.automateddesktopdata.CustomizationSettings.InstantCloneEngineDomainAdministrator.id }).Base.Username
                                                            'No Customization Settings' = $pool.AutomatedDesktopData.CustomizationSettings.NoCustomizationSettings
                                                            'Sysprep Customization Settings' = $PoolCustomization
                                                            'Quick Prep Customization Settings' = $pool.AutomatedDesktopData.CustomizationSettings.QuickprepCustomizationSettings
                                                            'Ad Container' = $PoolContainerName
                                                            'Reuse Pre-Existing Accounts' = $Pool.automateddesktopdata.CustomizationSettings.ReusePreExistingAccounts
                                                            'Image Management Stream' = $pool.AutomatedDesktopData.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ImageManagementStream
                                                            'Image Management Tag' = $pool.AutomatedDesktopData.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ImageManagementTag
                                                            'Compute Profile' = $pool.AutomatedDesktopData.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ComputeProfile
                                                        }

                                                        if ($Pool.Automateddesktopdata.ProvisioningType -eq 'VIRTUAL_CENTER') {
                                                            $inObj.Remove('Parent VM')
                                                            $inObj.Remove('Parent VM Path')
                                                            $inObj.Remove('Snapshot')
                                                            $inObj.Remove('Snapshot Path')
                                                            $inObj.Remove('VM Folder')
                                                            $inObj.Remove('VM Folder Path')
                                                            $inObj.Remove('Datastores')
                                                            $inObj.Remove('Datastores Storage Over-Commit')
                                                            $inObj.Remove('Replica Disk Datastore Path')
                                                            $inObj.Remove('Pool Customization Type')
                                                            $inObj.Remove('Pool Domain Administrator')
                                                            $inObj.Remove('Pool Reuse Pre-Existing Accounts')
                                                            $inObj.Remove('Ad Container')
                                                            $inObj.Remove('Reuse Pre-Existing Accounts')
                                                            $inObj.Remove('Customization Type')
                                                        }

                                                        if ($Pool.Type -eq 'MANUAL') {
                                                            $inObj.Remove('Template')
                                                            $inObj.Remove('Parent VM')
                                                            $inObj.Remove('Parent VM Path')
                                                            $inObj.Remove('Snapshot')
                                                            $inObj.Remove('Snapshot Path')
                                                            $inObj.Remove('VM Folder')
                                                            $inObj.Remove('VM Folder Path')
                                                            $inObj.Remove('Datastores')
                                                            $inObj.Remove('Datastores Storage Over-Commit')
                                                            $inObj.Remove('Replica Disk Datastore Path')
                                                            $inObj.Remove('Pool Customization Type')
                                                            $inObj.Remove('Pool Domain Administrator')
                                                            $inObj.Remove('Pool Reuse Pre-Existing Accounts')
                                                            $inObj.Remove('Ad Container')
                                                            $inObj.Remove('Reuse Pre-Existing Accounts')
                                                            $inObj.Remove('Customization Type')
                                                            $inObj.Remove('Datacenter')
                                                            $inObj.Remove('Datacenter Path')
                                                            $inObj.Remove('Host or Cluster')
                                                            $inObj.Remove('Host or Cluster Path')
                                                            $inObj.Remove('Resource Pool')
                                                            $inObj.Remove('Resource Pool Path')
                                                            $inObj.Remove('Networks')
                                                            $inObj.Remove('Guest Customization Account')
                                                        }

                                                        if ($Pool.Automateddesktopdata.ProvisioningType -eq 'INSTANT_CLONE_ENGINE') {
                                                            $inObj.Remove('Template')

                                                        }

                                                        if ([string]::IsNullOrEmpty($pool.AutomatedDesktopData.CustomizationSettings.CloneprepCustomizationSettings)) {
                                                            $inObj.Remove('Power off Script Name')
                                                            $inObj.Remove('Power Off Script Parameters')
                                                            $inObj.Remove('Post Synchronization Script Name')
                                                            $inObj.Remove('Post Synchronization Script Parameters')
                                                            $inObj.Remove('Priming Computer Account')
                                                        }

                                                        $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                        $TableParams = @{
                                                            Name = "vCenter Server Settings - $($Pool.Base.name)"
                                                            List = $true
                                                            ColumnWidths = 40, 60
                                                        }

                                                        if ($Report.ShowTableCaptions) {
                                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                                        }
                                                        $OutObj | Table @TableParams
                                                    }
                                                } catch {
                                                    Write-PScriboMessage -IsWarning $_.Exception.Message
                                                }
                                            }

                                            if ($InfoLevel.Inventory.Desktop -ge 3) {
                                                try {
                                                    Section -ExcludeFromTOC -Style Heading6 "Pool Machine Summary - $($Pool.Base.name)" {
                                                        $OutObj = @()
                                                        foreach ($Machine in $Machines) {
                                                            if($Machine.Base.Name) {
                                                                If ($Machine.Base.DesktopName -like $Pool.base.Name) {
                                                                    $inObj = [ordered] @{
                                                                        'Machine Name' = $Machine.Base.Name
                                                                        'Agent Version' = $Machine.Base.AgentVersion
                                                                        'User' = $Machine.Base.User
                                                                        'Host' = $Machine.ManagedMachineData.VirtualCenterData.Hostname
                                                                        'Data Store' = $Machine.ManagedMachineData.VirtualCenterData.VirtualDisks.DatastorePath
                                                                        'Basic State' = $Machine.Base.BasicState
                                                                    }
                                                                    $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                                                }
                                                            }
                                                        }
                                                        $TableParams = @{
                                                            Name = "Pool Machine Summary - $($Pool.Base.Name)"
                                                            List = $false
                                                            ColumnWidths = 15, 10, 20, 25, 15, 15
                                                        }
                                                        if ($Report.ShowTableCaptions) {
                                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                                        }
                                                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                                                    }
                                                } catch {
                                                    Write-PScriboMessage -IsWarning $_.Exception.Message
                                                }

                                            }

                                        } catch {
                                            Write-PScriboMessage -IsWarning $_.Exception.Message
                                        }
                                        try {
                                            if($EntitledUserOrGrouplocalMachines | Where-Object { $_.localData.Desktops.id -eq $Pool.Id.id }){
                                                Section -ExcludeFromTOC -Style Heading6 "Desktop Pools Entitlements - $($Pool.Base.Name)" {
                                                    try {
                                                        $OutObj = @()
                                                        Write-PScriboMessage "Discovered Desktop Pool Entitlements Information for - $($Pool.Base.Name)."
                                                        foreach ($Principal in ($EntitledUserOrGrouplocalMachines | Where-Object { $_.localData.Desktops.id -eq $Pool.Id.id })) {
                                                            if($Principal.Base.LoginName){
                                                                Write-PScriboMessage "Discovered Desktop Pool Entitlements Name for - $($Principal.Base.LoginName)."
                                                                $inObj = [ordered] @{
                                                                    'Name' = $Principal.Base.LoginName
                                                                    'Domain' = $Principal.Base.Domain
                                                                    'Is Group?' = $Principal.Base.Group
                                                                }
                                                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                                            }
                                                        }
                                                        $TableParams += @{
                                                            Name = "Desktop Pools Entitlements - $($Pool.Base.Name)"
                                                            List = $false
                                                            ColumnWidths = 34, 33, 33
                                                        }
                                                        if ($Report.ShowTableCaptions) {
                                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                                        }
                                                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                                                    } catch {
                                                        Write-PScriboMessage -IsWarning $_.Exception.Message
                                                    }
                                                }
                                            }
                                        } catch {
                                            Write-PScriboMessage -IsWarning $_.Exception.Message
                                        }
                                    }
                                }
                            }
                        } catch {
                            Write-PScriboMessage -IsWarning $_.Exception.Message
                        }
                    }
                }
            }
        } catch {
            Write-PScriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}
}