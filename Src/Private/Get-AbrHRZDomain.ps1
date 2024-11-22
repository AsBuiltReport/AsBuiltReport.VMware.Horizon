function Get-AbrHRZDomain {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        1.1.4
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
            Section -Style Heading2 "Domains" {
                if ($InstantCloneDomainAdmins) {
                    if ($InfoLevel.Settings.InstantClone.InstantCloneDomainAccounts -ge 1) {
                        Section -Style Heading3 "Domain Accounts" {
                            Paragraph "The following section details the Domain Accounts configuration for $($HVEnvironment.toUpper()) server."
                            BlankLine
                            $OutObj = @()
                            foreach ($InstantCloneDomainAdmin in $InstantCloneDomainAdmins) {
                                try {
                                    Write-PScriboMessage "Discovered Domain Accounts Information."
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
                                Name = "Domain Accounts - $($HVEnvironment.toUpper())"
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
                if ($Domains) {
                    if ($InfoLevel.Settings.Servers.vCenterServers.ADDomains -ge 1) {
                        Section -Style Heading3 "Connection Server Domain Status" {
                            Paragraph "The following section shows connection servers domains for $($HVEnvironment.toUpper()) environment."
                            BlankLine
                            $OutObj = @()
                            foreach ($Domain in $Domains) {
                                try {
                                    Write-PScriboMessage "Discovered Domain Information $($Domain.DNSName)."
                                    $inObj = [ordered] @{
                                        'Domain DNS Name' = $Domain.DNSName
                                        'Status' = $Domain.ConnectionServerState[0].Status
                                        'Trust Relationship' = $Domain.ConnectionServerState[0].TrustRelationship
                                        'Connection Status' = $Domain.ConnectionServerState[0].Contactable

                                    }

                                    $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                } catch {
                                    Write-PScriboMessage -IsWarning $_.Exception.Message
                                }
                            }

                            if ($HealthCheck.DataStores.Status) {
                                $OutObj | Where-Object { $_.'Status' -eq 'ERROR' } | Set-Style -Style Warning
                            }

                            $TableParams = @{
                                Name = "Connection Server Domain Status- $($HVEnvironment.toUpper())"
                                List = $false
                                ColumnWidths = 25, 25, 25, 25
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }
                            $OutObj | Sort-Object -Property 'Name' | Table @TableParams
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