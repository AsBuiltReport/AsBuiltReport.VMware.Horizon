function Get-AbrHRZInstantClone {
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
        Write-PScriboMessage "InstantCloneDomainAccounts InfoLevel set at $($InfoLevel.Settings.InstantClone.InstantCloneDomainAccounts)."
        Write-PscriboMessage "Collecting Instant Clone Domain Accounts information."
    }

    process {
        try {
            $InstantCloneDomainAdmins = try {$hzServices.InstantCloneEngineDomainAdministrator.InstantCloneEngineDomainAdministrator_List()} catch {Write-PscriboMessage -IsWarning $_.Exception.Message}
            if ($InstantCloneDomainAdmins) {
                if ($InfoLevel.Settings.InstantClone.InstantCloneDomainAccounts -ge 1) {
                    section -Style Heading3 "Instant Clone Accounts" {
                        $OutObj = @()
                        foreach ($InstantCloneDomainAdmin in $InstantCloneDomainAdmins) {
                            try {
                                Write-PscriboMessage "Discovered Instant Clone Accounts Information."
                                $inObj = [ordered] @{
                                    'User Name' = $InstantCloneDomainAdmin.Base.UserName
                                    'Domain Name' = $InstantCloneDomainAdmin.NamesData.DnsName
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Instant Clone Domain Accounts - $($HVEnvironment)"
                            List = $false
                            ColumnWidths = 50, 50
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'User Name' | Table @TableParams
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