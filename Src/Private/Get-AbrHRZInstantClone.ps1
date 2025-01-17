function Get-AbrHRZInstantClone {
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
        Write-PScriboMessage "InstantCloneDomainAccounts InfoLevel set at $($InfoLevel.Settings.InstantClone.InstantCloneDomainAccounts)."
        Write-PScriboMessage "Collecting Instant Clone Domain Accounts information."
    }

    process {
        try {
            if ($InstantCloneDomainAdmins) {
                if ($InfoLevel.Settings.InstantClone.InstantCloneDomainAccounts -ge 1) {
                    Section -Style Heading3 "Instant Clone Accounts" {
                        Paragraph "The following section details the Instant Clone Accounts configuration for $($HVEnvironment.split('.')[0]) server."
                        BlankLine
                        $OutObj = @()
                        foreach ($InstantCloneDomainAdmin in $InstantCloneDomainAdmins) {
                            try {
                                Write-PScriboMessage "Discovered Instant Clone Accounts Information."
                                $inObj = [ordered] @{
                                    'User Name' = $InstantCloneDomainAdmin.Base.UserName
                                    'Domain Name' = $InstantCloneDomainAdmin.NamesData.DnsName
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            } catch {
                                Write-PScriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Instant Clone Domain Accounts - $($HVEnvironment.split(".").toUpper()[0])"
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
        } catch {
            Write-PScriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}
}