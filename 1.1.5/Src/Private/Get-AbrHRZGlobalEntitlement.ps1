function Get-AbrHRZGlobalEntitlement {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        1.1.5
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
        Write-PScriboMessage "Global Entitlements InfoLevel set at $($InfoLevel.Inventory.GlobalEntitlements)."
        Write-PScriboMessage "Collecting Global Entitlements information."
    }

    process {
        try {
            if ($GlobalEntitlements) {

                if ($InfoLevel.Inventory.GlobalEntitlements -ge 1) {
                    Section -Style Heading3 "Global Entitlements" {
                        Paragraph "The following section details the Global Entitlements configuration for $($HVEnvironment.toUpper()) server."
                        BlankLine

                        $GlobalEntitlements | ForEach-Object { $_ | Add-Member -MemberType NoteProperty -Name "GE_Type" -Value "Desktop" }
                        $GlobalApplicationEntitlementGroups | ForEach-Object { $_ | Add-Member -MemberType NoteProperty -Name "GE_Type" -Value "Application" }
                        $GlobalEntitlementJoined = @()
                        $GlobalEntitlementJoined += $GlobalEntitlements
                        $GlobalEntitlementJoined += $GlobalApplicationEntitlementGroups

                        $OutObj = @()
                        foreach ($GlobalEntitlement in $GlobalEntitlementJoined) {
                            Write-PScriboMessage "Discovered Global Entitlements Information."
                            $GlobalEntitlementPodCount = ($GlobalEntitlement.data.memberpods.id).count
                            if ($GlobalEntitlement.Data.LocalApplicationCount) {
                                $Type = 'Application'
                            } elseif ($GlobalEntitlement.Data.LocalDesktopCount) {
                                $Type = 'Desktop'
                            }
                            $inObj = [ordered] @{
                                'Name' = $GlobalEntitlement.base.DisplayName
                                'Type' = $Type
                                'Number of Pods' = $GlobalEntitlementPodCount
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                        }

                        $TableParams = @{
                            Name = "Global Entitlements - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 34, 33, 33
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams


                        Section -Style Heading4 "Global Entitlement Summary Details" {
                            foreach ($GlobalEntitlement in $GlobalEntitlementJoined) {

                                Write-PScriboMessage "Discovered Global Entitlements Detailed Information for $($GlobalEntitlement.base.DisplayName)."
                                try {
                                    if ($InfoLevel.Inventory.GlobalEntitlements -ge 2) {
                                        Section -Style NOTOCHeading5 "Summary - $($GlobalEntitlement.base.DisplayName)" {

                                            $SupportedDisplayProtocolsresult = ''
                                            $SupportedDisplayProtocols = $GlobalEntitlement.base | ForEach-Object { $_.SupportedDisplayProtocols }
                                            $SupportedDisplayProtocolsresult = $SupportedDisplayProtocols -join ', '

                                            if ($GlobalEntitlement.Data.LocalApplicationCount) {
                                                $Type = 'Application'
                                            } elseif ($GlobalEntitlement.Data.LocalDesktopCount) {
                                                $Type = 'Desktop'
                                            }

                                            $GlobalAccessGroupID = $($hzServices.GlobalAccessGroup.GlobalAccessGroup_Get($GlobalEntitlement.base.GlobalAccessGroupId).base.Name)

                                            $OutObj = @()
                                            Write-PScriboMessage "Discovered Global Entitlement Data for $HVEnvironment"
                                            $inObj = [ordered] @{
                                                'Display Name' = $GlobalEntitlement.base.DisplayName
                                                'Alias Name' = $GlobalEntitlement.base.AliasName
                                                'Description' = $GlobalEntitlement.base.DisplayName.description
                                                'Scope' = $GlobalEntitlement.base.Scope
                                                'From Home Site' = $GlobalEntitlement.base.FromHome
                                                'Require Home Site' = $GlobalEntitlement.base.RequireHomeSite
                                                'Multiple Session Auto Clean' = $GlobalEntitlement.base.MultipleSessionAutoClean
                                                'Enabled' = $GlobalEntitlement.base.Enabled
                                                'Supported Display Protocols' = $SupportedDisplayProtocolsresult
                                                'Default Display Protocol' = $GlobalEntitlement.base.DefaultDisplayProtocol
                                                'Allow Users to Choose Display Protocol' = $GlobalEntitlement.base.AllowUsersToChooseProtocol
                                                'Allow User to Reset Machines' = $GlobalEntitlement.base.AllowUsersToResetMachines
                                                'Enable HTML Access' = $GlobalEntitlement.base.EnableHTMLAccess
                                                'Allow Multiple Sessions Per User' = $GlobalEntitlement.base.AllowMultipleSessionsPerUser
                                                'Enable Pre-Launch' = $GlobalEntitlement.base.EnablePreLaunch
                                                'Connection Server Restrictions' = $GlobalEntitlement.base.ConnectionServerRestrictions
                                                'Enable Prelaunch' = $GlobalEntitlement.base.EnablePreLaunch
                                                'Category Folder Name' = $GlobalEntitlement.base.CategoryFolderName
                                                'Client Restrictions' = $GlobalEntitlement.base.ClientRestrictions
                                                'Enable Collaboration' = $GlobalEntitlement.base.EnableCollaboration
                                                'Shortcut Locations' = $($GlobalEntitlement.base.ShortcutLocations -join ', ')
                                                'Multisession Mode' = $GlobalEntitlement.base.MultiSessionMode
                                                'Backup GAE' = $GlobalEntitlement.base.BackupGAE
                                                'Display Assigned Machine Name' = $GlobalEntitlement.base.DisplayAssignedMachineName
                                                'Display Machine Alias' = $GlobalEntitlement.base.DisplayMachineAlias
                                                'Global Access Group ID' = $GlobalAccessGroupID
                                            }

                                            $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                            if ($Type -eq 'Desktop') {
                                                $inObj.Remove('Enable Pre-Launch')
                                                $inObj.Remove('Multi Session Mode')
                                            }


                                            if ($Type -eq 'Application') {
                                                $inObj.Remove('Allow User to Reset Machines')
                                                $inObj.Remove('Allow Multiple Sessions Per User')
                                                $inObj.Remove('Enable Collaboration')
                                                $inObj.Remove('Display Assigned Machine Name')
                                                $inObj.Remove('Display Machine Alias')
                                            }


                                            $TableParams = @{
                                                Name = "Detailed Information - $($GlobalEntitlement.base.DisplayName)"
                                                List = $true
                                                ColumnWidths = 50, 50
                                            }

                                            if ($Report.ShowTableCaptions) {
                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                            }
                                            $OutObj | Table @TableParams
                                        }

                                        try {
                                            $OutObj = @()
                                            Section -Style NOTOCHeading6 "Local Pools - $($GlobalEntitlement.base.DisplayName)" {
                                                try {
                                                    Write-PScriboMessage "Discovered Local Pools Information for $($HVEnvironment.toUpper())."

                                                    $GEPodMembers = $GlobalEntitlement.data.MemberPods.id
                                                    $PodSiteID = ('')

                                                    Foreach ($GEPodMember in $GEPodMembers) {
                                                        Foreach ($CPSite in $CloudPodLists) {
                                                            If ($CPSite.id.id -eq $GEPodMember) {
                                                                $PodSiteID += $CPSite.DisplayName
                                                            }
                                                        }
                                                    }

                                                    $PodMembers = ''
                                                    $PodMembers = ForEach-Object { $PodSiteID }
                                                    $PodMemberList = $PodMembers -join ', '

                                                    $inObj = [ordered] @{
                                                        'Local Desktop Count' = $GlobalEntitlement.data.LocalDesktopCount
                                                        'Local Application Count' = $GlobalEntitlement.data.LocalApplicationCount
                                                        'Remote Desktop Count' = $GlobalEntitlement.data.RemoteDesktopCount
                                                        'Remote Application Count' = $GlobalEntitlement.data.RemoteApplicationCount
                                                        'User Count' = $GlobalEntitlement.data.UserCount
                                                        'User or Group Count' = $GlobalEntitlement.data.UserGroupCount
                                                        'User or Group Site Override Count' = $GlobalEntitlement.data.UserGroupSiteOverrideCount
                                                        'Member Pods' = $PodMemberList
                                                    }
                                                    $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                    if ($Type -eq 'Application') {
                                                        $inObj.Remove('Local Desktop Count')
                                                        $inObj.Remove('Remote Desktop Count')
                                                    }

                                                    if ($Type -eq 'Desktop') {
                                                        $inObj.Remove('Local Application Count')
                                                        $inObj.Remove('Remote Application Count')
                                                    }

                                                    $TableParams = @{
                                                        Name = "Local Pools - $($HVEnvironment.toUpper())"
                                                        List = $true
                                                        ColumnWidths = 30, 70
                                                    }
                                                    if ($Report.ShowTableCaptions) {
                                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                                    }
                                                    $OutObj | Table @TableParams
                                                } catch {
                                                    Write-PScriboMessage -IsWarning $_.Exception.Message
                                                }
                                            }
                                        } catch {
                                            Write-PScriboMessage -IsWarning $_.Exception.Message
                                        }

                                        # Users and Groups
                                        try {

                                            Section -Style NOTOCHeading6 "Users and Groups - $($GlobalEntitlement.base.DisplayName)" {
                                                $OutObj = @()
                                                try {
                                                    Write-PScriboMessage "Discovered Users and Groups - $($GlobalEntitlement.base.DisplayName)."

                                                    foreach ($EntitledUserOrGroupGlobal in $EntitledUserOrGroupGlobals) {
                                                        Switch ($EntitledUserOrGroupGlobal.base.Group) {
                                                            'True' { $GlobalEntitledGroup = 'Group' }
                                                            'False' { $GlobalEntitledGroup = 'User' }
                                                        }
                                                        $EntitledDefined = @()


                                                        foreach ($GE in $($EntitledUserOrGroupGlobal.GlobalData.GlobalEntitlements.id -split [Environment]::NewLine)) {
                                                            if ($GlobalEntitlement.Id.id -eq $GE) {
                                                                $EntitledDefined += $EntitledUserOrGroupGlobal
                                                            }
                                                        }
                                                        foreach ($GEA in $($EntitledUserOrGroupGlobal.GlobalData.GlobalApplicationEntitlements.id -split [Environment]::NewLine)) {
                                                            if ($GlobalEntitlement.Id.id -eq $GEA) {
                                                                $EntitledDefined += $EntitledUserOrGroupGlobal
                                                            }
                                                        }

                                                        foreach ($ED in $EntitledDefined) {
                                                            $inObj = [ordered] @{
                                                                'Name' = $ED.Base.Name
                                                                'User or Group' = $GlobalEntitledGroup
                                                                'Domain' = $ED.Base.Domain
                                                            }
                                                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                                        }

                                                    } # End If Group or User
                                                } catch {
                                                    Write-PScriboMessage -IsWarning $_.Exception.Message
                                                }

                                                $TableParams = @{
                                                    Name = "Users and Groups - $($GlobalEntitlement.base.DisplayName)"
                                                    List = $false
                                                    ColumnWidths = 40, 30, 30
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
                                } catch {
                                    Write-PScriboMessage -IsWarning $_.Exception.Message
                                }
                            }
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