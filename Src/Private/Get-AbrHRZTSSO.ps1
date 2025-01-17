function Get-AbrHRZTSSO {
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
        Write-PScriboMessage "TrueSSO InfoLevel set at $($InfoLevel.Settings.Servers.ConnectionServers.TrueSSO)."
        Write-PScriboMessage "TrueSSO information."
    }

    process {
        try {
            if ($CertificateSSOconnectorHealthlist) {
                if ($InfoLevel.settings.servers.ConnectionServers.TrueSSO -ge 1) {
                    Section -Style Heading3 "TrueSSO Information" {
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
                                    'Primary Enrollment Server' = $CertificateSSOconnectorHealth.Data.PrimaryEnrollmentServerHealth.DnsName
                                    'Primary Enrollment Server State' = $CertificateSSOconnectorHealth.Data.PrimaryEnrollmentServerHealth.State
                                    'Primary Enrollment Server State Reason' = $CertificateSSOconnectorHealth.Data.PrimaryEnrollmentServerHealth.StateReasons
                                    'Secondary Enrollment Server' = $CertificateSSOconnectorHealth.Data.SecondaryEnrollmentServerHealth.DnsName
                                    'Secondary Enrollment Server State' = $CertificateSSOconnectorHealth.Data.SecondaryEnrollmentServerHealth.State
                                    'Secondary Enrollment Server State Reason' = $CertificateSSOconnectorHealth.Data.SecondaryEnrollmentServerHealth.StateReasons
                                    'Template Name' = $CertificateSSOconnectorHealth.Data.TemplateHealth.name
                                    'Template State' = $CertificateSSOconnectorHealth.Data.TemplateHealth.State
                                    'Template Primary Enrollment Server State Reason' = $CertificateSSOconnectorHealth.Data.TemplateHealth.PrimaryEnrollmentServerStateReasons
                                    'Template Secondary Enrollment Server State Reason' = $CertificateSSOconnectorHealth.Data.TemplateHealth.SecondaryEnrollmentServerStateReasons
                                    'Certificate Server Name' = $CertificateSSOconnectorHealth.Data.CertificateServerHealths.Name
                                    'Certificate Server State' = $CertificateSSOconnectorHealth.Data.CertificateServerHealths.State
                                    'Certificate Server Primary Enrollment Server State Reason' = $CertificateSSOconnectorHealth.Data.CertificateServerHealths.PrimaryEnrollmentServerStateReasons
                                    'Certificate Server Secondary Enrollment Server State Reason' = $CertificateSSOconnectorHealth.Data.CertificateServerHealths.SecondaryEnrollmentServerStateReasons
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            if (-not $CertificateSSOconnectorHealth.Data.SecondaryEnrollmentServerHealth.DnsName) {
                                $inObj.Remove('Secondary Enrollment Server')
                                $inObj.Remove('Secondary Enrollment Server State')
                                $inObj.Remove('Secondary Enrollment Server State Reason')
                                $inObj.Remove('Template Secondary Enrollment Server State Reason')
                                $inObj.Remove('Certificate Server Secondary Enrollment Server State Reason')
                            }
                        }

                        $TableParams = @{
                            Name = "TrueSSO Information - $($HVEnvironment.toUpper())"
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
        } catch {
            Write-PScriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}
}