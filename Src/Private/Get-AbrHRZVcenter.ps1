function Get-AbrHRZVcenter {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        1.1.0
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
        Write-PScriboMessage "vCenterServers InfoLevel set at $($InfoLevel.Settings.Servers.vCenterServers.vCenter)."
        Write-PscriboMessage "Collecting vCenterServers information."
    }

    process {
        try {
            if ($vCenterServers) {
                if ($InfoLevel.Settings.Servers.vCenterServers.vCenter -ge 1) {
                    section -Style Heading3 "vCenter Servers" {
                        Paragraph "The following section details the vCenter Servers configuration for $($HVEnvironment) server."
                        BlankLine
                        $vCenterHealthData = $vCenterHealth.data
                        $OutObj = @()
                        foreach ($vCenterServer in $vCenterServers) {
                            try {
                                Write-PscriboMessage "Discovered Virtual Centers Information $($vCenterServer.serverspec.ServerName)."
                                $inObj = [ordered] @{
                                    'Name' = $vCenterServer.serverspec.ServerName
                                    'Version' = ($vCenterHealthData | Where-Object {$_.InstanceUuid -eq $vCenterServer.InstanceUuid}).Version
                                    'Build Number' = ($vCenterHealthData | Where-Object {$_.InstanceUuid -eq $vCenterServer.InstanceUuid}).Build
                                    'API Version' = ($vCenterHealthData | Where-Object {$_.InstanceUuid -eq $vCenterServer.InstanceUuid}).ApiVersion
                                    'Provisioning Enabled' = ConvertTo-TextYN $vCenterServer.Enabled
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "vCenter - $($HVEnvironment.split(".").toUpper()[0])"
                            List = $false
                            ColumnWidths = 40, 15, 15, 15, 15
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                        try {
                            if ($InfoLevel.Settings.Servers.vCenterServers.vCenter -ge 2) {
                                foreach ($vCenterServer in $vCenterServers) {
                                    try {
                                        section -Style Heading4 "$($vCenterServer.serverspec.ServerName)" {
                                            $OutObj = @()
                                            Write-PscriboMessage "Discovered Virtual Centers Information $($vCenterServer.serverspec.ServerName)."
                                            $inObj = [ordered] @{
                                                'Name' = $vCenterServer.serverspec.ServerName
                                                'Description' = $vCenterServer.Description
                                                'Certificate Override' = $vCenterServer.CertificateOverride
                                                'Provisioning Enabled' = $vCenterServer.Enabled
                                                'Reclaim Disk Space' = $vCenterServer.SeSparseReclamationEnabled
                                                'Port' = $vCenterServer.serverspec.Port
                                                'User SSL' = $vCenterServer.serverspec.UseSSL
                                                'User Name' = $vCenterServer.serverspec.UserName
                                                'Type' = $vCenterServer.serverspec.ServerType
                                                'TCP Port Number' = $vCenterServer.serverspec.Port
                                                'Max Concurrent Provisioning Operations' = $vCenterServer.Limits.VcProvisioningLimit
                                                'Max Concurrent Power Operations' = $vCenterServer.Limits.VcPowerOperationsLimit
                                                'Max Concurrent View Composer Maintenance Operations' = $vCenterServer.Limits.ViewComposerProvisioningLimit
                                                'Max Concurrent View Composer Provisioning Operations' = $vCenterServer.Limits.ViewComposerMaintenanceLimit
                                                'Max Concurrent Instant Clone Engine Provisioning Operations' = $vCenterServer.Limits.InstantCloneEngineProvisioningLimit
                                                'Storage Acceleration Enabled' = $vCenterServer.StorageAcceleratorData.Enabled
                                                'Storage Accelerator Default Cache Size' = "$($vCenterServer.StorageAcceleratorData.DefaultCacheSizeMB)MB"
                                            }

                                            $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                            $TableParams = @{
                                                Name = "vCenter Server Details - $($vCenterServer.serverspec.ServerName)"
                                                List = $true
                                                ColumnWidths = 50, 50
                                            }

                                            if ($Report.ShowTableCaptions) {
                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                            }
                                            $OutObj | Table @TableParams
                                            try {
                                                $HorizonVirtualCenterStorageAcceleratorHostOverrides = $vCenterServer.StorageAcceleratorData.HostOverrides
                                                if ($HorizonVirtualCenterStorageAcceleratorHostOverrides) {
                                                    section -ExcludeFromTOC -Style NOTOCHeading6 "Storage Accelerator Overrides" {
                                                        $OutObj = @()
                                                        foreach ($HorizonVirtualCenterStorageAcceleratorHostOverride in $HorizonVirtualCenterStorageAcceleratorHostOverrides) {
                                                            try {
                                                                Write-PscriboMessage "Discovered Storage Accelerator Overrides Information $($vCenterServer.serverspec.ServerName)."
                                                                $DATACENTER = $HorizonVirtualCenterStorageAcceleratorHostOverride.Path.Split('/')[1]
                                                                $Cluster = $HorizonVirtualCenterStorageAcceleratorHostOverride.Path.Split('/')[3]
                                                                $VMHost = $HorizonVirtualCenterStorageAcceleratorHostOverride.Path.Split('/')[4]
                                                                $inObj = [ordered] @{
                                                                    'Datacenter' = $DATACENTER
                                                                    'Cluster' = $Cluster
                                                                    'Host' = $VMHost
                                                                    'Cache Size' = "$($HorizonVirtualCenterStorageAcceleratorHostOverride.CacheSizeMB)MB"
                                                                }

                                                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                                            }
                                                            catch {
                                                                Write-PscriboMessage -IsWarning $_.Exception.Message
                                                            }
                                                        }

                                                        $TableParams = @{
                                                            Name = "Storage Accelerator Overrides - $($vCenterServer.serverspec.ServerName)"
                                                            List = $false
                                                            ColumnWidths = 25, 25, 25, 25
                                                        }

                                                        if ($Report.ShowTableCaptions) {
                                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                                        }
                                                        $OutObj | Sort-Object -Property 'Cluster' | Table @TableParams
                                                    }
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