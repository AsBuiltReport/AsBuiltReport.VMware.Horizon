function Get-AbrHRZAdminGroupInfo {
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
        Write-PScriboMessage "Administrators InfoLevel set at $($InfoLevel.Settings.Administrators.AdministratorsandGroups)."
        Write-PscriboMessage "Collecting Registered Machines information."
    }

    process {
        try {
            if ($Administrators) {
                if ($InfoLevel.Settings.Administrators.AdministratorsandGroups -ge 1) {
                    section -Style Heading4 "Administrators and Groups" {
                        Paragraph "The following section details the configuration of Administrators and Groups for $($HVEnvironment.split('.')[0]) server."
                        BlankLine
                        $OutObj = @()
                        foreach ($Administrator in $Administrators) {
                            $RoleIDNameResults = ''
                            foreach ($Permission in $Permissions) {
                                if ($Administrator.PermissionData.Permissions.id -eq $Permission.id.id){
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
                                        if ($Administrator.PermissionData.Permissions.id.count -gt 1){
                                            $RoleIDNameResults += "$RoleIDName, "
                                            $RoleIDName = $RoleIDNameResults.TrimEnd(', ')
                                        }
                                    }
                                }
                            }

                            Write-PscriboMessage "Discovered Administrators and Groups Information."
                            $inObj = [ordered] @{
                                'Display Name' = $Administrator.base.DisplayName
                                'Type' = Switch ($Administrator.base.Group) {
                                    $False {'User'}
                                    $True {'Group'}
                                }
                                'Permission Role' = [string](($RoleIDName.split(', ') | Select-Object -Unique) -join ', ')
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                        }

                        $TableParams = @{
                            Name = "Administrators and Groups - $($HVEnvironment)"
                            List = $false
                            ColumnWidths = 42, 15, 43
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'Display Name' | Table @TableParams
                        try {
                            if ($InfoLevel.Settings.Administrators.AdministratorsandGroups -ge 2) {
                                section -Style Heading5 'Administrators Details' {
                                    foreach ($Administrator in $Administrators) {
                                        Write-PscriboMessage "Discovered $($Administrator.base.Name) Information."
                                        $RoleIDNameResults = ''
                                        foreach($Permission in $Permissions) {
                                            if($Administrator.PermissionData.Permissions.id -eq $Permission.id.id){
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
                                                    if ($Administrator.PermissionData.Permissions.id.count -gt 1){
                                                        $RoleIDNameResults += "$RoleIDName, "
                                                        $RoleIDName = $RoleIDNameResults.TrimEnd(', ')
                                                    }
                                                }
                                            }
                                        }
                                        Switch ($Administrator.base.Group)
                                        {
                                            'True' {$Administratorbasegroup = 'Group' }
                                            'False' {$Administratorbasegroup = 'User' }
                                        }
                                        section -ExcludeFromTOC -Style NOTOCHeading6 $Administrator.Base.Name {
                                            $OutObj = @()
                                            $inObj = [ordered] @{
                                                'Name' = $Administrator.base.Name
                                                'First Name' = $Administrator.base.FirstName
                                                'Last Name' = $Administrator.base.LastName
                                                'Login Name' = $Administrator.base.LoginName
                                                'Display Name' = $Administrator.base.DisplayName
                                                'Long Display Name' = $Administrator.base.LongDisplayName
                                                'Is Assignment a Group of User' = $Administratorbasegroup
                                                'Domain' = $Administrator.base.Domain
                                                'AD Distinguished Name' = $Administrator.base.AdDistinguishedName
                                                'Email' = $Administrator.base.Email
                                                'Kiosk User' = $Administrator.base.KioskUser
                                                'Phone Number' = $Administrator.base.Phone
                                                'Description' = $Administrator.base.Description
                                                'in Folder' = $Administrator.base.InFolder
                                                'UPN' = $Administrator.base.UserPrincipalName
                                                'Permission Role' = [string](($RoleIDName.split(', ') | Select-Object -Unique) -join ', ')
                                            }
                                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                                            $TableParams = @{
                                                Name = "Administrator - $($Administrator.base.Name)"
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