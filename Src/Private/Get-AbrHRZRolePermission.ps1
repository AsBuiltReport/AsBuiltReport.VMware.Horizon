function Get-AbrHRZRolePermission {
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
        Write-PScriboMessage "Role Permissions InfoLevel set at $($InfoLevel.Settings.Administrators.RolePermissions)."
        Write-PscriboMessage "Collecting Role Permissions information."
    }

    process {
        try {
            if ($Permissions) {
                if ($InfoLevel.Settings.Administrators.RolePermissions -ge 1) {
                    section -Style Heading4 "Role Permissions" {
                        $OutObj = @()
                        foreach ($Permission in $Permissions) {
                            Write-PscriboMessage "Discovered Role Permissions Information."
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
                                    if ($PermissionGroups.count -gt 1){
                                        $AdministratorIDNameResults += "$AdministratorIDName, "
                                        $AdministratorIDName = $AdministratorIDNameResults.TrimEnd(', ')
                                    }
                            }
                            Switch ($AdministratorIDName)
                            {
                                '' {$AdministratorIDName = 'N/A'}
                                ' ' {$AdministratorIDName = 'N/A'}
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
                            $AccessGroupIDNameResults = ''
                            $AccessGroupIDName = ''
                            $PermissionGroups = $Permission.base.AccessGroup.id
                            foreach ($PermissionGroup in $PermissionGroups) {
                                foreach ($AccessGroup in $AccessGroups) {
                                    if ($AccessGroup.Id.id -eq $PermissionGroup) {
                                        $AccessGroupIDName = "/$($AccessGroup.base.name)"
                                    }
                                    elseif ($AccessGroup.Children.id.id -eq $PermissionGroup) {
                                        $AccessGroupIDName = "/Root/$(($AccessGroup.Children | Where-Object {$_.id.id -eq $PermissionGroup}).Base.Name)"
                                    } else {
                                        $AccessGroupIDName = "Federation Access Group"
                                    }
                                }
                                if ($PermissionGroups.count -gt 1){
                                    $AccessGroupIDNameResults += "$AccessGroupIDName, "
                                    $AccessGroupIDName = $AccessGroupIDNameResults.TrimEnd(', ')
                                }
                            }

                            $inObj = [ordered] @{
                                'User or Group Name' = $AdministratorIDName
                                'Role' = $RoleIDName
                                'Access Group' = $AccessGroupIDName
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                        }

                        $TableParams = @{
                            Name = "Role Permissions - $($HVEnvironment)"
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
        }
        catch {
            Write-PscriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}
}