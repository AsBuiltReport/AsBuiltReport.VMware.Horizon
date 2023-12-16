function Get-AbrHRZApplicationPool {
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
        Write-PScriboMessage "Applications InfoLevel set at $($InfoLevel.Inventory.Applications)."
        Write-PscriboMessage "Collecting Applications information."
    }

    process {
        try {
            if ($Apps) {
                if ($InfoLevel.Inventory.Applications -ge 1) {
                    section -Style Heading3 "Application Pool" {
                        Paragraph "The following section details the configuration of Application Pool for $($HVEnvironment.toUpper()) server."
                        BlankLine
                        $OutObj = @()
                        foreach ($App in $Apps) {
                            Write-PscriboMessage "Discovered Applications Information for $($App.Data.DisplayName)."
                            $inObj = [ordered] @{
                                'Name' = $App.Data.DisplayName
                                'Version' = $App.ExecutionData.Version
                                'Enabled' = $App.Data.Enabled
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                        }

                        $TableParams = @{
                            Name = "Applications - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 34, 33, 33
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                        try {
                            if ($InfoLevel.Inventory.Applications -ge 2) {
                                section -Style Heading4 "Application Pool Details" {
                                    foreach ($App in $Apps) {
                                        # Find out Farm Name for Applications
                                        $farmMatch = $false
                                        foreach ($farm in $farms) {
                                            if ($farm.Id.id -eq $app.executiondata.farm.id) {
                                                $ApplicationFarmName = $farm.data.name
                                                $farmMatch = $true
                                            }
                                            if ($farmMatch) {
                                                break
                                            }
                                        }

                                        # Find out Access Group for Applications
                                        $AccessgroupMatch = $false
                                        foreach ($Accessgroup in $Accessgroups) {
                                            if ($Accessgroup.Id.id -eq $app.accessgroup.id) {
                                                $AccessGroupName = $Accessgroup.base.name
                                                $AccessgroupMatch = $true
                                            }
                                            if ($AccessgroupMatch) {
                                                break
                                            }
                                        }

                                        # Find out Global Application Entitlement Group for Applications
                                        $GlobalApplicationEntitlementGroupDisplayName = ('')
                                        $GlobalApplicationEntitlementGroupMatch = $false
                                        foreach ($GlobalApplicationEntitlementGroup in $GlobalApplicationEntitlementGroups) {
                                            if ($GlobalApplicationEntitlementGroup.Id.id -eq $app.data.GlobalApplicationEntitlement.id) {
                                                $GlobalApplicationEntitlementGroupDisplayName = $GlobalApplicationEntitlementGroup.base.DisplayName
                                                $GlobalApplicationEntitlementGroupMatch = $true
                                            } else {
                                                $GlobalApplicationEntitlementGroupDisplayName = "No Global Application Entitlement"
                                            }
                                        if ($GlobalApplicationEntitlementGroupMatch) {
                                            break
                                            }
                                        }

                                        If([string]::IsNullOrEmpty($App.Data.AvApplicationPackageGuid)){

                                            $AppVolumesApp = "False"
                                        }
                                        else {
                                            $AppVolumesApp = "True"
                                        }

                                        $ApplicationFileTypes = $App.ExecutionData.FileTypes | ForEach-Object { $_.FileType}
                                        $ApplicationFileTypesresult = $ApplicationFileTypes -join ', '

                                        $OtherApplicationFileTypes = $App.ExecutionData.OtherFileTypes | ForEach-Object { $_.FileType}
                                        $OtherApplicationFileTypesresult = $OtherApplicationFileTypes -join ', '

                                        section -Style Heading5 "Application Summary - $($App.Data.DisplayName)" {
                                            $OutObj = @()
                                            Write-PscriboMessage "Discovered $($App.Data.DisplayName) Applications Information."
                                            $inObj = [ordered] @{
                                                'Display Name' = $App.Data.DisplayName
                                                'Description' = $App.Data.Description
                                                'Enabled' = $App.Data.Enabled
                                                'Global Application Entitlement' = $GlobalApplicationEntitlementGroupDisplayName
                                                'Enable Anti Affinity Rules' = $App.Data.EnableAntiAffinityRules
                                                'Anti-Affinity Patterns' = $App.Data.AntiAffinityPatterns
                                                'Anti-Affinity Count' = $App.Data.AntiAffinityCount
                                                'Enable Pre-Launch' = $App.Data.EnablePreLaunch
                                                'Connection Server Restrictions' = $App.Data.ConnectionServerRestrictions
                                                'Category Folder' = $App.Data.CategoryFolder
                                                'Client Restrictions' = $App.Data.ClientRestrictions
                                                'Shortcut Location' = $App.Data.ShortcutLocation
                                                'Multi Session Mode' = $App.Data.MultiSessionMode
                                                'Max Multi Sessions' = $App.Data.MaxMultiSessions
                                                'Cloud Brokered' = $App.Data.CloudBrokered
                                                'App Volumes App' = $AppVolumesApp
                                                'App Volumes Package' = $App.Data.AvApplicationPackageGuid
                                                'Executable Path' = $App.ExecutionData.ExecutablePath
                                                'Version' = $App.ExecutionData.Version
                                                'Publisher' = $App.ExecutionData.Publisher
                                                'Start Folder' = $App.ExecutionData.StartFolder
                                                'Argument' = $App.ExecutionData.Args
                                                'Farm' = $ApplicationFarmName
                                                'File Types' = $ApplicationFileTypesresult
                                                'Auto Update File Types' = $App.ExecutionData.AutoUpdateFileTypes
                                                'Other File Types' = $OtherApplicationFileTypesresult
                                                'Auto Update Other File Types' = $App.ExecutionData.AutoUpdateFileTypes
                                                'Access Group' = $AccessGroupName
                                            }

                                            $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                            $TableParams = @{
                                                Name = "Application Summary - $($App.Data.DisplayName)"
                                                List = $true
                                                ColumnWidths = 50, 50
                                            }

                                            if ($Report.ShowTableCaptions) {
                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                            }
                                            $OutObj | Table @TableParams
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