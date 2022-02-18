function Get-AbrHRZLocalEntitlement {
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
        Write-PScriboMessage "Users And Groups InfoLevel set at $($InfoLevel.UsersAndGroups.Entitlements)."
        Write-PscriboMessage "Collecting Users And Groups information."
    }

    process {
        try {
            try {
                $EntitledUserOrGroupLocalMachineQueryDefn = New-Object VMware.Hv.QueryDefinition
                $EntitledUserOrGroupLocalMachineQueryDefn.queryentitytype='EntitledUserOrGroupLocalSummaryView'
                $EntitledUserOrGroupLocalMachinequeryResults = $Queryservice.QueryService_Create($hzServices, $EntitledUserOrGroupLocalMachineQueryDefn)
                $EntitledUserOrGroupLocalMachines = foreach ($EntitledUserOrGroupLocalMachineresult in $EntitledUserOrGroupLocalMachinequeryResults.results){$hzServices.EntitledUserOrGroup.EntitledUserOrGroup_GetLocalSummaryView($EntitledUserOrGroupLocalMachineresult.id)}
                $queryservice.QueryService_DeleteAll($hzServices)
            }
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }
            Section -Style Heading3 'Local Entitlements' {
                $OutObj = @()
                if ($EntitledUserOrGroupLocalMachines) {
                    foreach ($EntitledUserOrGroupLocalMachine in $EntitledUserOrGroupLocalMachines) {
                        try {
                            Switch ($EntitledUserOrGroupLocalMachine.base.Group) {
                                'True' {$EntitledUserOrGroupLocalMachinegroup = 'Group' }
                                'False' {$EntitledUserOrGroupLocalMachinegroup = 'User' }
                            }
                            Switch ($EntitledUserOrGroupLocalMachinegroup) {
                                'Group' {$UserPrincipalName = $EntitledUserOrGroupLocalMachine.base.Name}
                                'User' {$UserPrincipalName = $EntitledUserOrGroupLocalMachine.base.UserPrincipalName}
                            }
                            Write-PscriboMessage "Discovered Local Entitlements $($EntitledUserOrGroupLocalMachine.base.UserPrincipalName)."
                            $inObj = [ordered] @{
                                'User Principal Name' = $UserPrincipalName
                                'Group or User' = $EntitledUserOrGroupLocalMachinegroup
                            }
                            $OutObj += [pscustomobject]$inobj
                        }
                        catch {
                            Write-PscriboMessage -IsWarning $_.Exception.Message
                        }
                    }
                }

                $TableParams = @{
                    Name = "Local Entitlements - $($HVEnvironment)"
                    List = $false
                    ColumnWidths = 60, 40
                }

                if ($Report.ShowTableCaptions) {
                    $TableParams['Caption'] = "- $($TableParams.Name)"
                }
                $OutObj | Sort-Object -Property 'User Principal Name' | Table @TableParams

                if ($InfoLevel.UsersAndGroups.Entitlements -ge 2) {
                    Section -Style Heading4 "Per Object Local Entitlements Details" {
                        try {
                            $PoolIDNameResults = ''
                            $AppIDNameResults = ''
                            foreach($EntitledUserOrGroupLocalMachine in $EntitledUserOrGroupLocalMachines) {
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
                                        if($Entitledlocalmachines.count -gt 1){
                                            $MachineIDNameResults += "$MachineIDName, "
                                            $MachineIDName = $MachineIDNameResults.TrimEnd(', ')
                                        }
                                    }
                                    Switch ($MachineIDName) {
                                        '' {$MachineIDName = 'N/A'}
                                        ' ' {$MachineIDName = 'N/A'}
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
                                        if($Entitledlocalmachines.count -gt 1){
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
                                        if ($Entitledlocalmachines.count -gt 1){
                                            $AppIDNameResults += "$AppIDName, "
                                            $AppIDName = $AppIDNameResults.TrimEnd(', ')
                                        }
                                    }
                                    Switch ($AppIDName) {
                                        '' {$AppIDName = 'N/A'}
                                        ' ' {$AppIDName = 'N/A'}
                                    }

                                    Switch ($EntitledUserOrGroupLocalMachine.base.Group) {
                                        'True' {$EntitledUserOrGroupLocalMachinegroup = 'Group' }
                                        'False' {$EntitledUserOrGroupLocalMachinegroup = 'User' }
                                    }
                                    Section -Style Heading5 "$($EntitledUserOrGroupLocalMachine.base.Name)" {
                                        $OutObj = @()
                                        try {
                                            Write-PscriboMessage "Local Entitlements Details for $($EntitledUserOrGroupLocalMachine.base.Name)."
                                            $inObj = [ordered] @{
                                                'Name' = $EntitledUserOrGroupLocalMachine.base.Name
                                                'Group or User' = $EntitledUserOrGroupLocalMachinegroup
                                                'SID' = $EntitledUserOrGroupLocalMachine.base.Sid
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
                                                'in Folder' = $EntitledUserOrGroupLocalMachine.base.InFolder
                                                'User Principal Name' = $EntitledUserOrGroupLocalMachine.base.UserPrincipalName
                                                'Local Machines' = $MachineIDName
                                                'Local User Persistent Disks' = $EntitledUserOrGroupLocalMachine.LocalData.PersistentDisks
                                                'Local Desktops' = $PoolIDName
                                                'User Applications' = $AppIDName
                                            }
                                            $OutObj += [pscustomobject]$inobj

                                            $TableParams = @{
                                                Name = "Local Entitlements Details - $($EntitledUserOrGroupLocalMachine.base.Name)"
                                                List = $True
                                                ColumnWidths = 50, 50
                                            }

                                            if ($Report.ShowTableCaptions) {
                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                            }

                                            $OutObj | Table @TableParams
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