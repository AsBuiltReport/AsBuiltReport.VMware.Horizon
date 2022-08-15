function Get-AbrHRZAccessGroup {
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
        Write-PScriboMessage "AccessGroup InfoLevel set at $($InfoLevel.Settings.Administrators.AccessGroup)."
        Write-PscriboMessage "Collecting Access Group information."
    }

    process {
        try {
            if ($AccessGroups) {
                if ($InfoLevel.Settings.Administrators.AccessGroup -ge 1) {
                    section -Style Heading4 "Access Groups Summary" {
                        $OutObj = @()
                        $AccessGroupJoined = @()
                        $AccessGroupJoined += $AccessGroups
                        $AccessGroupJoined += $AccessGroups.Children
                        foreach ($AccessGroup in $AccessGroupJoined) {
                            Write-PscriboMessage "Discovered $($AccessGroup.base.Name) Access Groups Information."
                            $inObj = [ordered] @{
                                'Name' = $AccessGroup.base.Name
                                'Description' = $AccessGroup.base.Description
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                        }

                        $TableParams = @{
                            Name = "Access Groups - $($HVEnvironment)"
                            List = $false
                            ColumnWidths = 50, 50
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                        try {
                            if ($InfoLevel.Settings.Administrators.AccessGroup -ge 2) {
                                $AccessGroupJoined = @()
                                $AccessGroupJoined += $AccessGroups
                                $AccessGroupJoined += $AccessGroups.Children
                                foreach ($AccessGroup in $AccessGroupJoined) {
                                    Write-PscriboMessage "Discovered $($AccessGroup.base.Name) Access Groups Detailed Information."
                                    $AdministratorIDNameResults = ''
                                    # Find Administrator ID Name
                                    $AdministratorIDName = ''
                                    foreach ($AccessGroupID in $AccessGroup.data.Permissions.id) {
                                        foreach ($Permission in $Permissions) {
                                            if ($AccessGroupID -eq $Permission.id.id){
                                                foreach ($PermissionGroup in $Permission.base.UserOrGroup.id) {
                                                    foreach ($Administrator in $Administrators) {
                                                        if ($Administrator.Id.id -eq $PermissionGroup) {
                                                            $AdministratorIDName = $Administrator.base.name
                                                            break
                                                        }
                                                    }
                                                    $AdministratorIDNameResults += "$AdministratorIDName, "
                                                    $AdministratorIDName = $AdministratorIDNameResults.TrimEnd(', ')
                                                }
                                            }
                                        }
                                    }
                                    if ($AdministratorIDName) {
                                        section -ExcludeFromTOC -Style Heading5 $AccessGroup.base.Name {
                                            $OutObj = @()
                                            foreach ($Principal in ($AdministratorIDName.split(', ') | Select-Object -Unique)){
                                                $PrincipalPermissionsName = ''
                                                $PrincipalID = ($Administrators | Where-Object {$_.Base.Name -eq $Principal}).Id.Id
                                                $PrincipalPermissions = ($Permissions.Base | Where-Object {$_.UserOrGroup.Id -eq $PrincipalID}).Role.Id
                                                foreach ($PrincipalPermission in $PrincipalPermissions) {
                                                    $PrincipalPermissionsName += "$(($Roles | Where-Object {$_.Id.id -eq $PrincipalPermission}).Base.Name), "
                                                }

                                                $inObj = [ordered] @{
                                                    'Name' = $Principal
                                                    'Permissions' = [string](($PrincipalPermissionsName.split(', ') | Select-Object -Unique) -join ', ')
                                                }

                                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                            }

                                            $TableParams = @{
                                                Name = "Access Groups - $($AccessGroup.base.Name)"
                                                List = $false
                                                ColumnWidths = 50, 50
                                            }

                                            if ($Report.ShowTableCaptions) {
                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                            }
                                            $OutObj | Sort-Object -Property 'Name' | Table @TableParams
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