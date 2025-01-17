function Get-AbrHRZHCTrueSSO {
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
        Credits:        Iain Brighton (@iainbrighton) - PScribo module, Wouter Kursten - Health Check


    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon
    #>

    [CmdletBinding()]
    param (
    )

    begin {
        Write-PScriboMessage "TrueSSO Health Check InfoLevel set at $($HealthCheck.Components.TrueSSO)."
        Write-PScriboMessage "TrueSSO Health information."
    }

    process {
        try {
            if ($CertificateSSOconnectorHealthlist) {
                if ($InfoLevel.settings.servers.ConnectionServers.TrueSSO -ge 1) {
                    Section -Style Heading3 "TrueSSO Health Information" {
                        Paragraph "The following section details on the TrueSSO information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()
                        foreach ($CertificateSSOconnectorHealth in $CertificateSSOconnectorHealthlist) {
                            if ($CertificateSSOconnectorHealth) {

                                Write-PScriboMessage "Discovered TrueSSO Information."
                                $inObj = [ordered] @{
                                    'TrueSSO Name' = $CertificateSSOconnectorHealth.DisplayName
                                    'TrueSSO Enabled' = $CertificateSSOconnectorHealth.Enabled
                                    'TrueSSO State' = $CertificateSSOconnectorHealth.Data.OverallState
                                    'Primary ES' = $CertificateSSOconnectorHealth.Data.PrimaryEnrollmentServerHealth.DnsName
                                    'Primary ES State' = $CertificateSSOconnectorHealth.Data.PrimaryEnrollmentServerHealth.State
                                    'Primary ES State Reason' = $CertificateSSOconnectorHealth.Data.PrimaryEnrollmentServerHealth.StateReasons
                                    'Secondary Enrollment Server' = $CertificateSSOconnectorHealth.Data.SecondaryEnrollmentServerHealth.DnsName
                                    'Secondary Enrollment Server State' = $CertificateSSOconnectorHealth.Data.SecondaryEnrollmentServerHealth.State
                                    'Secondary Enrollment Server State Reason' = $CertificateSSOconnectorHealth.Data.SecondaryEnrollmentServerHealth.StateReasons
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                        }

                        $TableParams = @{
                            Name = "TrueSSO Health Information - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 15, 10, 10, 15, 10, 20, 10, 10, 10
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Table @TableParams
                    }
                }
            }
        } catch {
            Write-PScriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}
}