function Get-AbrHRZFarmInfo {
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
        Write-PScriboMessage "Farm InfoLevel set at $($InfoLevel.Inventory.Farms)."
        Write-PscriboMessage "Collecting Farm information."
    }

    process {
        try {
            if ($Farms) {
                if ($InfoLevel.Inventory.Farms -ge 1) {
                    section -Style Heading3 "Farms Summary" {
                        $OutObj = @()
                        foreach ($Farm in $Farms) {
                            Write-PscriboMessage "Discovered Farms Information."
                            $inObj = [ordered] @{
                                'Name' = $Farm.Data.displayName
                                'Type' = $Farm.Type
                                'Enabled' = $Farm.Data.Enabled
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                        }

                        $TableParams = @{
                            Name = "Farms - $($HVEnvironment)"
                            List = $false
                            ColumnWidths = 34, 33, 33
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                        try {
                            if ($InfoLevel.Inventory.Farms -ge 2) {
                                section -Style Heading4 "Farms Details" {
                                    foreach ($Farm in $Farms) {
                                        section -Style Heading5 $($Farm.Data.name) {
                                            # Find out Access Group for Applications
                                            $AccessgroupMatch = $false
                                            $Accessgroups = $hzServices.AccessGroup.AccessGroup_List()
                                            $AccessgroupJoined = @()
                                            $AccessgroupJoined += $Accessgroups
                                            $AccessgroupJoined += $Accessgroups.Children
                                            foreach ($Accessgroup in $AccessgroupJoined) {
                                                if ($Accessgroup.Id.id -eq $Farm.data.accessgroup.id) {
                                                    $AccessGroupName = $Accessgroup.base.name
                                                    $AccessgroupMatch = $true
                                                }
                                                if ($AccessgroupMatch) {
                                                    break
                                                }
                                            }
                                            try {
                                                section -ExcludeFromTOC -Style Heading6 "General" {
                                                    $OutObj = @()
                                                    Write-PscriboMessage "Discovered $($Farm.Data.name) General Information."
                                                    $inObj = [ordered] @{
                                                        'Pool Name' = $Farm.Data.name
                                                        'Display Name' = $Farm.Data.displayName
                                                        'Description' = $Farm.Data.description
                                                        'Type' = $Farm.Type
                                                        'Source' = $Farm.Source
                                                        'Enabled' = $Farm.Data.Enabled
                                                        'Deleting' = $Farm.Data.Deleting
                                                        'Desktop' = $Farm.Data.Desktop
                                                        'Access Group' = $AccessGroupName
                                                        'Default Display Protocol' = $Farm.Data.DisplayProtocolSettings.DefaultDisplayProtocol
                                                        'Allow Users to Choose Protocol' = $Farm.Data.DisplayProtocolSettings.AllowDisplayProtocolOverride
                                                        'HTML Access' = $Farm.Data.DisplayProtocolSettings.EnableHTMLAccess
                                                    }

                                                    $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                    $TableParams = @{
                                                        Name = "Farm General Information - $($Farm.Data.name)"
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
                                                section -ExcludeFromTOC -Style Heading6 "Settings" {
                                                    $OutObj = @()
                                                    Write-PscriboMessage "Discovered $($Farm.Data.name) Settings."
                                                    $inObj = [ordered] @{
                                                        'Provisioning Enabled' = $Farm.AutomatedFarmData.VirtualCenterProvisioningSettings.EnableProvisioning
                                                        'Stop Provisioning on Error' = $Farm.AutomatedFarmData.VirtualCenterProvisioningSettings.StopProvisioningOnError
                                                        'Disconnected Session Timeout Minutes' = $Farm.Data.settings.DisconnectedSessionTimeoutMinutes
                                                        'Disconnected Session Timeout Policy' = $Farm.Data.settings.DisconnectedSessionTimeoutPolicy
                                                        'Empty Session Timeout Minutes' = $Farm.Data.settings.EmptySessionTimeoutMinutes
                                                        'Empty Session Timeout Policy' = $Farm.data.Settings.EmptySessionTimeoutPolicy
                                                        'Log off After Timeout' = $Farm.data.Settings.LogoffAfterTimeout
                                                    }

                                                    $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                    $TableParams = @{
                                                        Name = "Farm Settings - $($Farm.Data.name)"
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
                                                section -ExcludeFromTOC -Style Heading6 "Load Balancing Settings" {
                                                    $OutObj = @()
                                                    Write-PscriboMessage "Discovered $($Farm.Data.name) Load Balancing Settings."
                                                    $inObj = [ordered] @{
                                                        'Use Custom Script' = $Farm.Data.LbSettings.UseCustomScript
                                                        'Include Session Count' = $Farm.Data.LbSettings.LbMetricsSettings.IncludeSessionCount
                                                        'Cpu Usage Threshold' = $Farm.Data.LbSettings.LbMetricsSettings.CpuThreshold
                                                        'Memory UsageThreshold' = $Farm.Data.LbSettings.LbMetricsSettings.MemThreshold
                                                        'Disk Queue Length Threshold' = $Farm.Data.LbSettings.LbMetricsSettings.DiskQueueLengthThreshold
                                                        'Disk Read Latency Threshold' = $Farm.Data.LbSettings.LbMetricsSettings.DiskReadLatencyThreshold
                                                        'Disk Write Latency Threshold' = $Farm.Data.LbSettings.LbMetricsSettings.DiskWriteLatencyThreshold

                                                    }

                                                    $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                    $TableParams = @{
                                                        Name = "Farm Load Balancing Settings - $($Farm.Data.name)"
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
                                                section -ExcludeFromTOC -Style Heading6 "vCenter Server Settings" {
                                                    $OutObj = @()
                                                    Write-PscriboMessage "Discovered $($Farm.Data.name) vCenter Server Settings Information."
                                                    $inObj = [ordered] @{
                                                        'VM folder' = ($Farm.AutomatedFarmData.VirtualCenterNamesData.VmFolderPath.Split('/') | Select-Object -SkipIndex 0,2) -join "/"
                                                        'Host Or Cluster Path' = ($Farm.AutomatedFarmData.VirtualCenterNamesData.HostOrClusterPath.Split('/') | Select-Object -SkipIndex 0,2) -join "/"
                                                        'Resource Pool' = ($Farm.AutomatedFarmData.VirtualCenterNamesData.ResourcePoolPath.Split('/') | Select-Object -SkipIndex 0,2,4) -join "/"
                                                        'Golden Image' = ($Farm.AutomatedFarmData.VirtualCenterNamesData.ParentVmPath.Split('/') | Select-Object -SkipIndex 0,2) -join "/"
                                                        'Snapshot' = $Farm.AutomatedFarmData.VirtualCenterNamesData.SnapshotPath
                                                        'DatastorePaths' = ($Farm.AutomatedFarmData.VirtualCenterNamesData.DatastorePaths | ForEach-Object {$_.Split('/')[4]}) -join ', '
                                                        'NetworkLabelNames' = Switch ($Farm.AutomatedFarmData.VirtualCenterNamesData.NetworkLabelNames) {
                                                            $null {'Golden Image network selected'}
                                                            default {$Farm.AutomatedFarmData.VirtualCenterNamesData.NetworkLabelNames}
                                                        }
                                                        'Guest Customization' = $Farm.AutomatedFarmData.CustomizationSettings.CustomizationType
                                                        'Guest Customization Domain and Account' = ($InstantCloneDomainAdmins | Where-Object {$_.Id.id -eq $Farm.AutomatedFarmData.CustomizationSettings.InstantCloneEngineDomainAdministrator.id}).Base.UserName
                                                        'Allow Reuse of Existing Computer Accounts' = $Farm.AutomatedFarmData.CustomizationSettings.ReusePreExistingAccounts
                                                    }

                                                    $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                    $TableParams = @{
                                                        Name = "Farm vCenter Settings - $($Farm.Data.name)"
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