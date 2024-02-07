function Get-AbrHRZFederationAccessGroups {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        1.1.2
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
        Write-PScriboMessage "Role Permissions InfoLevel set at $($InfoLevel.Settings.Administrators.RolePermissions)."
        Write-PScriboMessage "Collecting Role Federation Access Groups information."
    }

    process {
        try {
            if ($Permissions) {
                if ($InfoLevel.Settings.Administrators.FederationAccessGroup -ge 1) {
                    Section -Style Heading3 "Federation Access Groups" {
                        Paragraph "The following section details the Federation Access Group information for $($HVEnvironment.toUpper()) server."
                        BlankLine
                        $OutObj = @()

                        $FilteredPermissions = ''
                        $FilteredPermissions = $Permissions | Where-Object { $null -ne $_.base.GlobalAccessGroup }

                        foreach ($Permission in $FilteredPermissions) {

                            $AdministratorIDNameResults = ''
                            # Find Administrator ID Name
                            $AdministratorIDName = ''
                            $PermissionGroups = $Permission.base.UserOrGroup.id
                            foreach ($PermissionGroup in $PermissionGroups) {
                                foreach ($Administrator in $Administrators) {
                                    if ($Administrator.Id.id -eq $PermissionGroup) {
                                        $AdministratorIDName = $Administrator.base.name
                                        break
                                    }
                                }
                                if ($PermissionGroups.count -gt 1) {
                                    $AdministratorIDNameResults += "$AdministratorIDName, "
                                    $AdministratorIDName = $AdministratorIDNameResults.TrimEnd(', ')
                                }
                            }
                            Switch ($AdministratorIDName) {
                                '' { $AdministratorIDName = 'N/A' }
                                ' ' { $AdministratorIDName = 'N/A' }
                            }

                            # Mach Permission Role ID with Role ID
                            # Find Role ID Name
                            $RoleIDName = ''
                            $PermissionGroups = $Permission.base.Role.id
                            foreach ($PermissionGroup in $PermissionGroups) {

                                foreach ($Role in $Roles) {
                                    if ($Role.Id.id -eq $PermissionGroup) {
                                        $RoleIDName = $Role.base.name
                                        break
                                    }

                                }
                                if ($PermissionGroups.count -gt 1) {
                                    $RoleIDNameResults += "$RoleIDName, "
                                    $RoleIDName = $RoleIDNameResults.TrimEnd(', ')
                                    $RoleIDName = [string](($RoleIDName.split(', ') | Select-Object -Unique) -join ', ')
                                }
                            }

                            # Find AccessGroup ID Name
                            $GlobalAccessGroupIDName = ''
                            $PermissionGroups = $Permission.base.GlobalAccessGroup.id
                            foreach ($PermissionGroup in $PermissionGroups) {
                                foreach ($GlobalAccessGroup in $GlobalAccessGroups) {
                                    if ($GlobalAccessGroup.Id.id -eq $PermissionGroup) {
                                        $GlobalAccessGroupIDName = "/$($GlobalAccessGroup.base.name)"
                                    } elseif ($GlobalAccessGroup.Children.id.id -eq $PermissionGroup) {
                                        $GlobalAccessGroupIDName = "/Root/$(($AccessGroup.Children | Where-Object {$_.id.id -eq $PermissionGroup}).Base.Name)"
                                    }
                                    $GlobalAccessGroupIDName = $GlobalAccessGroupIDName.TrimStart('/')

                                }
                            }
                            $inObj = [ordered] @{
                                'User or Group Name' = $AdministratorIDName
                                'Role' = $RoleIDName
                                'Global Access Group' = $GlobalAccessGroupIDName
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                        }
                        $TableParams = @{
                            Name = "Role Permissions - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 33, 33, 34
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'User or Group Name' | Table @TableParams



                    }
                }
            }
        } catch {
            Write-PScriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}
}