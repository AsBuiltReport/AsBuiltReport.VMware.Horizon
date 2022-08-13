function Get-AbrHRZADDomainiInfo {
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
        Write-PScriboMessage "ADDomains InfoLevel set at $($InfoLevel.Settings.Servers.vCenterServers.ADDomains)."
        Write-PscriboMessage "Collecting Active Directory Domain information."
    }

    process {
        try {
            if ($Domains) {
                if ($InfoLevel.Settings.Servers.vCenterServers.ADDomains -ge 1) {
                    section -Style Heading4 "Active Directory Domains Summary" {
                        $OutObj = @()
                        foreach ($Domain in $Domains) {
                            try {
                                Write-PscriboMessage "Discovered Domain Information $($Domain.DNSName)."
                                $inObj = [ordered] @{
                                    'Domain DNS Name' = $Domain.DNSName
                                    'Status' = $Domain.ConnectionServerState[0].Status
                                    'Trust Relationship' = $Domain.ConnectionServerState[0].TrustRelationship
                                    'Connection Status' = $Domain.ConnectionServerState[0].Contactable

                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        if ($HealthCheck.DataStores.Status) {
                            $OutObj | Where-Object { $_.'Status' -eq 'ERROR'} | Set-Style -Style Warning
                        }

                        $TableParams = @{
                            Name = "Active Directory Domains - $($HVEnvironment)"
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
        catch {
            Write-PscriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}
}