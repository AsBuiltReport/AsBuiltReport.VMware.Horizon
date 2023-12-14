function Get-AbrHRZRolePrivilege {
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
        Write-PScriboMessage "Role Provilege InfoLevel set at $($InfoLevel.Settings.Administrators.RolePrivileges)."
        Write-PscriboMessage "Collecting Role Provilege information."
    }

    process {
        try {
            if ($Roles) {
                if ($InfoLevel.Settings.Administrators.RolePrivileges -ge 1) {
                    section -Style Heading3 "Role Privileges" {
                        Paragraph "The following section details the Role Privileges information for $($HVEnvironment) server."
                        BlankLine
                        $OutObj = @()
                        foreach ($Role in $Roles) {
                            Write-PscriboMessage "Discovered Role Provilege Information."
                            $inObj = [ordered] @{
                                'Name' = $Role.base.Name
                                'Description' = $Role.base.Description
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                        }

                        $TableParams = @{
                            Name = "Role Privileges - $($HVEnvironment)"
                            List = $false
                            ColumnWidths = 50, 50
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                    }
                    
                    if ($InfoLevel.Settings.Administrators.RolePrivileges -ge 2) {   
                        section -Style Heading4 "Role Privileges Details" {
                            
                            Paragraph "The following section details the Role Privilege details for information for $($HVEnvironment) server."
                            BlankLine
                            $OutObj = @()
                            foreach ($Role in $Roles) {
                                Write-PscriboMessage "Discovered Role Provilege Detailed Information for $($HVEnvironment) server."
                                $inObj = [ordered] @{
                                    'Name' = $Role.base.Name
                                    'Description' = [string]::join("`n", $($Role.base.Privileges))
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }

                            $TableParams = @{
                                Name = "Role Privileges Details - $($Role.base.Name)"
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
    end {}
}