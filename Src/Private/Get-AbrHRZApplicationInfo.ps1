function Get-AbrHRZApplicationInfo {
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
        Write-PScriboMessage "Applications InfoLevel set at $($InfoLevel.Inventory.Applications)."
        Write-PscriboMessage "Collecting Applications information."
    }

    process {
        try {
            $AccessGroups = $hzServices.AccessGroup.AccessGroup_List()
            try {
                # Entitled User Or Group Global
                $GlobalApplicationEntitlementGroupsQueryDefn = New-Object VMware.Hv.QueryDefinition
                $GlobalApplicationEntitlementGroupsQueryDefn.queryentitytype='GlobalApplicationEntitlementInfo'
                $GlobalApplicationEntitlementGroupsqueryResults = $Queryservice.QueryService_Create($hzServices, $GlobalApplicationEntitlementGroupsQueryDefn)
                $GlobalApplicationEntitlementGroups = foreach ($GlobalApplicationEntitlementGroupsResult in $GlobalApplicationEntitlementGroupsqueryResults.results) {
                    $hzServices.GlobalApplicationEntitlement.GlobalApplicationEntitlement_Get($GlobalApplicationEntitlementGroupsResult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            }
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }
            try {
                # Farm Info
                $FarmdQueryDefn = New-Object VMware.Hv.QueryDefinition
                $FarmdQueryDefn.queryentitytype='FarmSummaryView'
                $FarmqueryResults = $Queryservice.QueryService_Create($hzServices, $FarmdQueryDefn)
                $Farms = foreach ($farmresult in $farmqueryResults.results) {
                    $hzServices.farm.farm_get($farmresult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            }
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }
            try {
                # Application Pools
                $AppQueryDefn = New-Object VMware.Hv.QueryDefinition
                $AppQueryDefn.queryentitytype='ApplicationInfo'
                $AppqueryResults = $Queryservice.QueryService_Create($hzServices, $AppQueryDefn)
                $Apps = foreach ($Appresult in $AppqueryResults.results) {
                    $hzServices.Application.Application_Get($Appresult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            }
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }
            if ($Apps) {
                if ($InfoLevel.Inventory.Applications -ge 1) {
                    section -Style Heading3 "Applications Summary" {
                        $OutObj = @()
                        foreach ($App in $Apps) {
                            Write-PscriboMessage "Discovered Applications Information."
                            $inObj = [ordered] @{
                                'Name' = $App.Data.DisplayName
                                'Version' = $App.ExecutionData.Version
                                'Enabled' = $App.Data.Enabled
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                        }

                        $TableParams = @{
                            Name = "Applications - $($HVEnvironment)"
                            List = $false
                            ColumnWidths = 34, 33, 33
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                        try {
                            if ($InfoLevel.Inventory.Applications -ge 2) {
                                section -Style Heading4 "Applications Details" {
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
                                        $GlobalApplicationEntitlementGroupMatch = $false
                                        foreach ($GlobalApplicationEntitlementGroup in $GlobalApplicationEntitlementGroups) {
                                            if ($GlobalApplicationEntitlementGroup.Id.id -eq $app.data.GlobalApplicationEntitlement.id) {
                                                $GlobalApplicationEntitlementGroupDisplayName = $GlobalApplicationEntitlementGroup.base.DisplayName
                                                $GlobalApplicationEntitlementGroupMatch = $true
                                            }
                                        if ($GlobalApplicationEntitlementGroupMatch) {
                                            break
                                            }
                                        }

                                        $ApplicationFileTypes = $App.ExecutionData.FileTypes | ForEach-Object { $_.FileType}
                                        $ApplicationFileTypesresult = $ApplicationFileTypes -join ', '

                                        $OtherApplicationFileTypes = $App.ExecutionData.OtherFileTypes | ForEach-Object { $_.FileType}
                                        $OtherApplicationFileTypesresult = $OtherApplicationFileTypes -join ', '

                                        section -ExcludeFromTOC -Style Heading5 $App.Data.DisplayName {
                                            $OutObj = @()
                                            Write-PscriboMessage "Discovered $($App.Data.DisplayName) Applications Information."
                                            $inObj = [ordered] @{
                                                'Display Name' = $App.Data.DisplayName
                                                'Description' = $App.Data.Description
                                                'Enabled' = $App.Data.Enabled
                                                'Global Application Entitlement' = $GlobalApplicationEntitlementGroupDisplayName
                                                'Enable Anti Affinity Rules' = $App.Data.EnableAntiAffinityRules
                                                'Anti Affinity Patterns' = $App.Data.AntiAffinityPatterns
                                                'Anti Affinity Count' = $App.Data.AntiAffinityCount
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
                                                Name = "Application - $($App.Data.Name)"
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