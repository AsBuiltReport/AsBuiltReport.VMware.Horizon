function Get-AbrHRZLocalEntitlement {
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
        Write-PScriboMessage "Users And Groups InfoLevel set at $($InfoLevel.UsersAndGroups.Entitlements)."
        Write-PScriboMessage "Collecting Users And Groups information."
    }

    process {
        if ($InfoLevel.UsersAndGroups.Entitlements -ge 1 -and $EntitledUserOrGroupLocalMachines) {
            try {
                Section -Style Heading3 'Local Entitlements' {
                    Paragraph "The following section provide a summary of local user & groups entitlements."
                    BlankLine
                    $OutObj = @()
                    if ($EntitledUserOrGroupLocalMachines) {
                        foreach ($EntitledUserOrGroupLocalMachine in $EntitledUserOrGroupLocalMachines) {
                            try {
                                Switch ($EntitledUserOrGroupLocalMachine.base.Group) {
                                    'True' { $EntitledUserOrGroupLocalMachinegroup = 'Group' }
                                    'False' { $EntitledUserOrGroupLocalMachinegroup = 'User' }
                                }
                                Switch ($EntitledUserOrGroupLocalMachinegroup) {
                                    'Group' { $UserPrincipalName = $EntitledUserOrGroupLocalMachine.base.Name }
                                    'User' { $UserPrincipalName = $EntitledUserOrGroupLocalMachine.base.UserPrincipalName }
                                }
                                Write-PScriboMessage "Discovered Local Entitlements $($EntitledUserOrGroupLocalMachine.base.UserPrincipalName)."
                                $inObj = [ordered] @{
                                    'User Principal Name' = $UserPrincipalName
                                    'Group or User' = $EntitledUserOrGroupLocalMachinegroup
                                    'Desktop Entitlements' = ($EntitledUserOrGrouplocalMachine.localData.Desktops.id).count
                                    'Application Entitlements' = ($EntitledUserOrGroupLocalMachine.LocalData.Applications.id).count
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            } catch {
                                Write-PScriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Local Entitlements - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 55, 15, 15, 15
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'User Principal Name' | Table @TableParams

                        if ($InfoLevel.UsersAndGroups.Entitlements -ge 2) {
                            Section -Style Heading4 "Local Entitlements Details" {
                                Paragraph "The following section detail per user or group local entitlements."
                                BlankLine
                                try {
                                    $PoolIDNameResults = ''
                                    $AppIDNameResults = ''
                                    foreach ($EntitledUserOrGroupLocalMachine in $EntitledUserOrGroupLocalMachines) {
                                        try {
                                            # Find Machine ID Name
                                            $MachineIDName = ''
                                            $Entitledlocalmachines = $EntitledUserOrGroupLocalMachine.LocalData.Machines.id
                                            foreach ($Entitledlocalmachine in $Entitledlocalmachines) {
                                                foreach ($Machine in $Machines) {
                                                    if ($Machine.Id.id -eq $Entitledlocalmachine) {
                                                        $MachineIDName = $Machine.base.Name
                                                        break
                                                    }
                                                }
                                                if ($Entitledlocalmachines.count -gt 1) {
                                                    $MachineIDNameResults += "$MachineIDName, "
                                                    $MachineIDName = $MachineIDNameResults.TrimEnd(', ')
                                                }
                                            }
                                            Switch ($MachineIDName) {
                                                '' { $MachineIDName = 'N/A' }
                                                ' ' { $MachineIDName = 'N/A' }
                                            }

                                            # Find Desktop ID Name
                                            $PoolIDName = ''
                                            $Entitledlocalmachines = $EntitledUserOrGrouplocalMachine.localData.Desktops.id
                                            foreach ($Entitledlocalmachine in $Entitledlocalmachines) {
                                                foreach ($Pool in $Pools) {
                                                    if ($Pool.Id.id -eq $Entitledlocalmachine) {
                                                        $PoolIDName = $pool.base.Name
                                                        break
                                                    }
                                                }
                                                if ($Entitledlocalmachines.count -gt 1) {
                                                    $PoolIDNameResults += "$PoolIDName, "
                                                    $PoolIDName = $PoolIDNameResults.TrimEnd(', ')
                                                }
                                            }

                                            # Find App ID Name
                                            $AppIDName = ''
                                            $Entitledlocalmachines = $EntitledUserOrGroupLocalMachine.LocalData.Applications.id
                                            foreach ( $Entitledlocalmachine in $Entitledlocalmachines) {
                                                foreach ($App in $Apps) {
                                                    if ($App.Id.id -eq $Entitledlocalmachine) {
                                                        $AppIDName = $app.data.DisplayName
                                                        break
                                                    }

                                                }
                                                if ($Entitledlocalmachines.count -gt 1) {
                                                    $AppIDNameResults += "$AppIDName, "
                                                    $AppIDName = $AppIDNameResults.TrimEnd(', ')
                                                }
                                            }
                                            Switch ($AppIDName) {
                                                '' { $AppIDName = 'N/A' }
                                                ' ' { $AppIDName = 'N/A' }
                                            }

                                            Switch ($EntitledUserOrGroupLocalMachine.base.Group) {
                                                'True' { $EntitledUserOrGroupLocalMachinegroup = 'Group' }
                                                'False' { $EntitledUserOrGroupLocalMachinegroup = 'User' }
                                            }
                                            Section -ExcludeFromTOC -Style NOTOCHeading5 "Local Entitlement Details - $($EntitledUserOrGroupLocalMachine.base.Name)" {
                                                $OutObj = @()
                                                try {
                                                    Write-PScriboMessage "Local Entitlements Details for $($EntitledUserOrGroupLocalMachine.base.Name)."
                                                    $inObj = [ordered] @{
                                                        'Name' = $EntitledUserOrGroupLocalMachine.base.Name
                                                        'Group or User' = $EntitledUserOrGroupLocalMachinegroup
                                                        'Domain' = $EntitledUserOrGroupLocalMachine.base.Domain
                                                        'Ad Distinguished Name' = $EntitledUserOrGroupLocalMachine.base.AdDistinguishedName
                                                        'First Name' = $EntitledUserOrGroupLocalMachine.base.FirstName
                                                        'Last Name' = $EntitledUserOrGroupLocalMachine.base.LastName
                                                        'Login Name' = $EntitledUserOrGroupLocalMachine.base.LoginName
                                                        'Display Name' = $EntitledUserOrGroupLocalMachine.base.DisplayName
                                                        'Long Display Name' = $EntitledUserOrGroupLocalMachine.base.LongDisplayName
                                                        'Email' = $EntitledUserOrGroupLocalMachine.base.Email
                                                        'Kiosk User' = $EntitledUserOrGroupLocalMachine.base.KioskUser
                                                        'Phone' = $EntitledUserOrGroupLocalMachine.base.Phone
                                                        'Description' = $EntitledUserOrGroupLocalMachine.base.Description
                                                        'In Folder' = $EntitledUserOrGroupLocalMachine.base.InFolder
                                                        'User Principal Name' = $EntitledUserOrGroupLocalMachine.base.UserPrincipalName
                                                        'Local Machines' = $MachineIDName
                                                        'Local User Persistent Disks' = $EntitledUserOrGroupLocalMachine.LocalData.PersistentDisks
                                                        'Local Desktops' = $PoolIDName
                                                        'User Applications' = $AppIDName
                                                    }
                                                    $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                                                    $TableParams = @{
                                                        Name = "Local Entitlements Details - $($EntitledUserOrGroupLocalMachine.base.Name)"
                                                        List = $True
                                                        ColumnWidths = 50, 50
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
                                    }
                                } catch {
                                    Write-PScriboMessage -IsWarning $_.Exception.Message
                                }
                            }
                        }
                    }
                }
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }
        }
    }
    end {}
}