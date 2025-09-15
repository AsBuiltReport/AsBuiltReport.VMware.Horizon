function Get-AbrHRZCertMgmt {
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
        Write-PScriboMessage "Certificate Management InfoLevel set at $($InfoLevel.Settings.Servers.ConnectionServers.ConnectionServers)."
        Write-PScriboMessage "Collecting Certificate Management information."
    }

    process {
        try {
            if ($ConnectionServersHealth) {
                if ($InfoLevel.Settings.CloudPodArch.CloudPodArch -ge 1) {
                    # Connection Server Health Data
                    $ConnectionServerHealthData = $ConnectionServersHealth | Select-Object -First 1

                    Section -Style Heading2 "Certificate Management" {
                        Paragraph "The following section details on the certificate management information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()
                        Write-PScriboMessage "Working on Certificate Information for $($ConnectionServerHealthData.Name)."

                        $Cert = $ConnectionServerHealthData.CertificateHealth.ConnectionServerCertificate
                        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Cert)
                        $PodCert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($Bytes)

                        $inObj = [ordered] @{
                            'Self-Signed Certificate' = $ConnectionServerHealthData.DefaultCertificate
                            'Certificate Subject' = $PodCert.Subject
                            'Certificate Issuer' = $PodCert.Issuer
                            'Certificate Not Before' = $PodCert.NotBefore
                            'Certificate Not After' = $PodCert.NotAfter
                            'Certificate SANs' = $PodCert.DnsNameList
                            'Certificate Thumbprint' = $PodCert.Thumbprint
                        }
                        $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)
                        if ($HealthCheck.Components.ConnectionServers) {
                            $OutObj | Where-Object { $_.'Enabled' -eq 'No' } | Set-Style -Style Warning -Property 'Enabled'
                        }
                        $TableParams = @{
                            Name = "Certificate Management - $($HVEnvironment.toUpper())"
                            List = $true
                            ColumnWidths = 30, 70
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