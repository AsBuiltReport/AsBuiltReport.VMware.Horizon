function Get-AbrHRZDesktopPoolsInfo {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        0.2.0
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
        Write-PscriboMessage "Collecting Pool Desktop information."
    }

    process {
        try {
            if ($Pools) {
                if ($InfoLevel.Inventory.Desktop -ge 1) {
                    section -Style Heading3 "Desktop Pool Summary" {
                        Paragraph "The following section details the Desktop Pools configuration for $($HVEnvironment.split('.')[0]) server."
                        BlankLine
                        $OutObj = @()
                        foreach ($Pool in $Pools) {
                            Write-PscriboMessage "Discovered Desktop Pool Information."
                            Switch ($Pool.Automateddesktopdata.ProvisioningType)
                            {
                                'INSTANT_CLONE_ENGINE' {$ProvisioningType = 'Instant Clone' }
                                'VIRTUAL_CENTER' {$ProvisioningType = 'Full Virtual Machines' }
                            }

                            if ($Pool.Type -eq "MANUAL") {
                                $UserAssign = $Pool.ManualDesktopData.UserAssignment.UserAssignment
                            } else {$UserAssign = $Pool.AutomatedDesktopData.UserAssignment.UserAssignment}

                            $inObj = [ordered] @{
                                'Name' = $Pool.Base.Name
                                'Type' = $Pool.Type
                                'Provisioning Type' = $ProvisioningType
                                'User Assignment' = $UserAssign
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                        }

                        $TableParams = @{
                            Name = "Desktop Pools - $($HVEnvironment)"
                            List = $false
                            ColumnWidths = 25, 25, 25, 25
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                        try {
                            if ($InfoLevel.Inventory.Desktop -ge 2) {
                                section -Style Heading4 "Desktop Pool Details" {
                                    foreach ($Pool in $Pools) {
                                        # Find out Access Group for Desktop Pool
                                        $AccessgroupMatch = $false
                                        $Accessgroups = $hzServices.AccessGroup.AccessGroup_List()
                                        $AccessgroupsJoined = @()
                                        $AccessgroupsJoined += $Accessgroups
                                        $AccessgroupsJoined += $Accessgroups.Children
                                        foreach ($Accessgroup in $AccessgroupsJoined) {
                                            if ($Accessgroup.Id.id -eq $Pool.base.accessgroup.id) {
                                                $AccessGroupName = $Accessgroup.base.name
                                                $AccessgroupMatch = $true
                                            }
                                            if ($AccessgroupMatch) {
                                                break
                                            }
                                        }

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
                                            if ($farm.Id.id -eq $pool.rdsdesktopdata.farm.id) {
                                                $FarmIDName = $farm.data.name
                                                $farmMatch = $true
                                            }
                                            if ($farmMatch) {
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
                                            if ($PoolGroups.count -gt 1){
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
                                            if($PoolGroups.count -gt 1){
                                                $vCenterServerAutoIDNameResults += "$vCenterServerAutoIDName, "
                                                $vCenterServerAutoIDName = $vCenterServerAutoIDNameResults.TrimEnd(', ')
                                            }
                                        }

                                        # Find Base Image ID Name
                                        if ($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ParentVM.id){
                                            foreach ($CompatibleBaseImageVM in $CompatibleBaseImageVMs) {
                                                if ($CompatibleBaseImageVM.id.id -eq $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ParentVM.id){
                                                    $PoolBaseImage = $CompatibleBaseImageVM.name
                                                    $PoolBaseImagePath = $CompatibleBaseImageVM.Path
                                                    break
                                                }
                                            }
                                        }

                                        # Get Pool Base Image Snapshot
                                        if( $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Snapshot.id) {
                                            $BaseImageSnapshotList = $hzServices.BaseImageSnapshot.BaseImageSnapshot_List($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ParentVM)
                                            $BaseImageSnapshotListLast = $BaseImageSnapshotList | Select-Object -Last 1
                                        }

                                        # DataCenters
                                        if ($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Datacenter.id) {
                                            $DataCenterList = $hzServices.Datacenter.Datacenter_List($Pool.automateddesktopdata.virtualcenter)

                                            # Find DataCenter ID Name
                                            foreach ($DataCenter in $DataCenterList) {
                                                if ($DataCenter.id.id -eq $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Datacenter.id){
                                                    $PoolDataCenterName = $DataCenter.base.name
                                                    $PoolDatacenterPath = $DataCenter.base.Path
                                                    break
                                                }
                                            }
                                        }

                                        # VM Folder List
                                        if ($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.VmFolder.id){

                                            $VMFolderPath = $Pool.automateddesktopdata.VirtualCenterNamesData.VmFolderPath
                                            $VMFolder = $VMFolderPath -replace '^(.*[\\\/])'
                                        }

                                        # VM Host or Cluster
                                        if ($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.HostOrCluster.id){
                                            #$HostAndCluster = $hzServices.HostOrCluster.HostOrCluster_GetHostOrClusterTree($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Datacenter)
                                            $VMhostandCluterPath = $Pool.automateddesktopdata.VirtualCenterNamesData.HostOrClusterPath
                                            $VMhostandCluter = $VMhostandCluterPath -replace '^(.*[\\\/])'
                                        }

                                        # VM Resource Pool
                                        if ($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ResourcePool.id){
                                            #$ResourcePoolTree = $hzServices.ResourcePool.ResourcePool_GetResourcePoolTree($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Datacenter)
                                            $VMResourcePoolPath = $Pool.automateddesktopdata.VirtualCenterNamesData.ResourcePoolPath
                                            $VMResourcePool = $VMResourcePoolPath -replace '^(.*[\\\/])'
                                        }

                                        # VM Persistent Disk DataStores
                                        if ($Pool.automateddesktopdata.VirtualCenterNamesData.PersistentDiskDatastorePaths){
                                            $VMPersistentDiskDatastorePath = $Pool.automateddesktopdata.VirtualCenterNamesData.PersistentDiskDatastorePaths
                                            $VMPersistentDiskDatastore = $VMPersistentDiskDatastorePath -replace '^(.*[\\\/])'
                                        }

                                        # VM Network Card
                                        if ($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterNetworkingSettings.nics.nic.id) {
                                            $NetworkInterfaceCardList = $hzServices.NetworkInterfaceCard.NetworkInterfaceCard_ListBySnapshot($BaseImageSnapshotListLast.Id)
                                        }

                                        # VM AD Container
                                        if ($Pool.automateddesktopdata.CustomizationSettings.AdContainer.id) {
                                            foreach ($ADDomain in $ADDomains){
                                                $ADDomainID = ($ADDomain.id.id -creplace '^[^/]*/', '')
                                                if ($Pool.automateddesktopdata.CustomizationSettings.AdContainer.id -like "ADContainer/$ADDomainID/*") {
                                                    $ADContainers = $hzServices.ADContainer.ADContainer_ListByDomain($ADDomain.id)
                                                    foreach ($ADContainer in $ADContainers) {
                                                        if ($ADContainer.id.id -eq $Pool.automateddesktopdata.CustomizationSettings.AdContainer.id){
                                                            $PoolContainerName = $ADContainer.rdn
                                                            break
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        # VM Template
                                        if ($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Template.id){
                                            foreach ($Template in $CompatibleTemplateVMs) {
                                                if ($Template.id.id -eq $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Template.id){
                                                    $PoolTemplateName = $Template.name
                                                    break
                                                }
                                            }
                                        }
                                        try {
                                            section -Style Heading5 $($Pool.Base.name) {
                                                $SupportedDisplayProtocols = $Pool.DesktopSettings.DisplayProtocolSettings | ForEach-Object { $_.SupportedDisplayProtocols}
                                                $SupportedDisplayProtocolsresult = $SupportedDisplayProtocols -join ', '

                                                $StorageOvercommit = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterStorageSettings.datastores | ForEach-Object { $_.StorageOvercommit}
                                                $StorageOvercommitsresult = $StorageOvercommit -join ', '

                                                $DatastoreFinal = ''
                                                Switch ($Pool.Type) {
                                                    'MANUAL' {$POOLDST = $Pool.ManualDesktopData.VirtualCenterNamesData}
                                                    default {$POOLDST = $Pool.automateddesktopdata.VirtualCenterNamesData}
                                                }
                                                $DatastorePaths = $POOLDST | ForEach-Object { $_.DatastorePaths}
                                                foreach($Datastore in $DatastorePaths){
                                                $Datastorename = $Datastore -replace '^(.*[\\\/])'
                                                $DatastoreFinal += $DatastoreName -join "`r`n" | Out-String
                                                }
                                                $DatastorePathsresult = $DatastorePaths -join ', '
                                                try {
                                                    section -ExcludeFromTOC -Style NOTOCHeading5 "General" {
                                                        $OutObj = @()
                                                        Write-PscriboMessage "Discovered $($Pool.Base.name) General Information."
                                                        $inObj = [ordered] @{
                                                            'Name' = $Pool.Base.name
                                                            'Display Name' = $Pool.base.displayName
                                                            'Description' = $Pool.base.description
                                                            'Access Group' = $AccessGroupName
                                                            'Enabled' = $Pool.DesktopSettings.Enabled
                                                            'Type' = $Pool.Type
                                                            'Machine Source' = Switch ($pool.Source) {
                                                                'INSTANT_CLONE_ENGINE' {'vCenter(Instant Clone)' }
                                                                'VIRTUAL_CENTER' {'vCenter' }
                                                                default {$pool.Source}
                                                            }
                                                            'Provisioning Type' = Switch ($Pool.Automateddesktopdata.ProvisioningType) {
                                                                'INSTANT_CLONE_ENGINE' {'Instant Clone' }
                                                                'VIRTUAL_CENTER' {'Full Virtual Machines' }
                                                                default {$Pool.Automateddesktopdata.ProvisioningType}
                                                            }
                                                            'Enabled for Provisioning' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.EnableProvisioning
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
                                                }
                                                catch {
                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                }
                                                try {
                                                    section -ExcludeFromTOC -Style NOTOCHeading5 "Settings" {
                                                        $OutObj = @()
                                                        Write-PscriboMessage "Discovered $($Pool.Base.name) Pool Settings Information."
                                                        $inObj = [ordered] @{
                                                            'Max Number of Machines' = $pool.automateddesktopdata.vmnamingsettings.patternnamingsettings.MaxNumberOfMachines
                                                            'Min number of Machines' = $pool.automateddesktopdata.vmnamingsettings.patternnamingsettings.MinNumberOfMachines
                                                            'Number of Spare Machines' = $pool.automateddesktopdata.vmnamingsettings.patternnamingsettings.NumberOfSpareMachines
                                                            'Connection Server Restrictions' = [string]($Pool.DesktopSettings.ConnectionServerRestrictions -join ",")
                                                            'Stop Provisioning on Error' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.StopProvisioningOnError
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
                                                            'Supported Display Protocols' = $SupportedDisplayProtocolsresult
                                                            'Default Display Protocol' = $Pool.DesktopSettings.DisplayProtocolSettings.DefaultDisplayProtocol
                                                            'Allow Users to Choose Protocol' = $Pool.DesktopSettings.DisplayProtocolSettings.AllowUsersToChooseProtocol
                                                            'Enable HTML Access' = $Pool.DesktopSettings.DisplayProtocolSettings.EnableHTMLAccess
                                                            'Renderer 3D' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.Renderer3D
                                                            'Enable GRID vGPUs' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.EnableGRIDvGPUs
                                                            'vGPU Grid Profile' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.VGPUGridProfile
                                                            'vRam Size MB' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.VRamSizeMB
                                                            'Max Number of Monitors' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.MaxNumberOfMonitors
                                                            'Max Resolution of Any One Monitor' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.MaxResolutionOfAnyOneMonitor
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
                                                }
                                                catch {
                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                }
                                                try {
                                                    section -ExcludeFromTOC -Style NOTOCHeading5 "vCenter Server" {
                                                        $OutObj = @()
                                                        Write-PscriboMessage "Discovered $($Pool.Base.name) vCenter Server Information."
                                                        $inObj = [ordered] @{
                                                            'Virtual Center' = Switch ($Pool.Type) {
                                                                'MANUAL' {$vCenterServerIDName}
                                                                default {$vCenterServerAutoIDName}
                                                            }
                                                            'Template' = $PoolTemplateName
                                                            'Parent VM' = $PoolBaseImage
                                                            'Parent VM Path' = $PoolBaseImagePath
                                                            'Snapshot' = $BaseImageSnapshotListLast.name
                                                            'Snapshot Path' = $BaseImageSnapshotListLast.path
                                                            'Datacenter' = $PoolDataCenterName
                                                            'Datacenter Path' = $PoolDatacenterPath
                                                            'VM Folder' = $VMFolder
                                                            'VM Folder Path' = Switch ($Pool.Type) {
                                                                'MANUAL' {$Pool.ManualDesktopData.VirtualCenterNamesData.VmFolderPath}
                                                                default {$Pool.automateddesktopdata.VirtualCenterNamesData.VmFolderPath}
                                                            }
                                                            'Host or Cluster' = $VMhostandCluter
                                                            'Host or Cluster Path' = Switch ($Pool.Type) {
                                                                'MANUAL' {$Pool.ManualDesktopData.VirtualCenterNamesData.HostOrClusterPath}
                                                                default {$Pool.automateddesktopdata.VirtualCenterNamesData.HostOrClusterPath}
                                                            }
                                                            'Resource Pool' = $VMResourcePool
                                                            'Resource Pool Path' = Switch ($Pool.Type) {
                                                                'MANUAL' {$Pool.ManualDesktopData.VirtualCenterNamesData.ResourcePoolPath}
                                                                default {$Pool.automateddesktopdata.VirtualCenterNamesData.ResourcePoolPath}
                                                            }
                                                            'Datastores' = $DatastoreFinal
                                                            'Datastores Storage Over-Commit' = $StorageOvercommitsresult
                                                            'Replica Disk Datastore Path' = $Pool.automateddesktopdata.VirtualCenterNamesData.ReplicaDiskDatastorePath
                                                            'Networks' = Switch ($Pool.AutomatedDesktopData.VirtualCenterNamesData.NetworkLabelNames) {
                                                                $null {'Golden Image network selected'}
                                                                default {$Pool.AutomatedDesktopData.VirtualCenterNamesData.NetworkLabelNames}
                                                            }
                                                            'Customization Type' = $Pool.automateddesktopdata.CustomizationSettings.CustomizationType
                                                            'Guest Customization Account' = ($InstantCloneDomainAdmins | Where-Object {$_.id.id -eq $Pools.automateddesktopdata.CustomizationSettings.InstantCloneEngineDomainAdministrator.id}).Base.Username
                                                            'Ad Container' = $PoolContainerName
                                                            'Reuse Pre-Existing Accounts' = $Pool.automateddesktopdata.CustomizationSettings.ReusePreExistingAccounts
                                                        }

                                                        if ($Pool.Automateddesktopdata.ProvisioningType -eq 'VIRTUAL_CENTER' -or $Pool.Type -eq 'MANUAL') {
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

                                                        if ($Pool.Automateddesktopdata.ProvisioningType -eq 'INSTANT_CLONE_ENGINE') {
                                                            $inObj.Remove('Template')

                                                        }

                                                        $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                        $TableParams = @{
                                                            Name = "vCenter Server - $($Pool.Base.name)"
                                                            List = $true
                                                            ColumnWidths = 50, 50
                                                        }

                                                        if ($Report.ShowTableCaptions) {
                                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                                        }
                                                        $OutObj | Table @TableParams
                                                    }
                                                }
                                                catch {
                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                }
                                            }
                                        }
                                        catch {
                                            Write-PscriboMessage -IsWarning $_.Exception.Message
                                        }
                                    }
                                }
                            }
                        }
                        catch {
                            Write-PscriboMessage -IsWarning $_.Exception.Message
                        }
                        try {
                            section -Style Heading3 "Desktop Pool Entitlements" {
                                foreach ($Pool in $Pools) {
                                    section -ExcludeFromToC -Style NOTOCHeading5 $Pool.Base.Name {
                                        $OutObj = @()
                                        Write-PscriboMessage "Discovered Desktop Pool Entitlements Information."
                                        foreach ($Principal in ($EntitledUserOrGrouplocalMachines | Where-Object {$_.localData.Desktops.id -eq $Pool.Id.id})) {
                                            $inObj = [ordered] @{
                                                'Name' = $Principal.Base.LoginName
                                                'Domain' = $Principal.Base.Domain
                                                'Is Group?' = $Principal.Base.Group
                                            }
                                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                        }

                                        $TableParams = @{
                                            Name = "Desktop Pools Entitlements - $($Pool.Base.Name)"
                                            List = $false
                                            ColumnWidths = 34, 33, 33
                                        }

                                        if ($Report.ShowTableCaptions) {
                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                        }
                                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                                    }
                                }
                            }
                        }
                        catch {
                            Write-PscriboMessage -IsWarning $_.Exception.Message
                        }
                    }
                }
            }
        }
        catch {
            Write-PscriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}
}