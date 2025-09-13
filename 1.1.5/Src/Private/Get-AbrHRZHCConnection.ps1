function Get-AbrHRZHCConnection {
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
        Write-PScriboMessage "Connection Server Health Check InfoLevel set at $($HealthCheck.Components.ConnectionServers)."
        Write-PScriboMessage "Connection Server Health information."
    }

    process {
        try {
            if ($ConnectionServersHealth) {
                if ($HealthCheck.Components.ConnectionServers) {
                     Section -Style Heading3 "Connection Server Health Information" {
                        Paragraph "The following section details on the connection server health information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()
                        foreach ($CSHealth in $ConnectionServersHealth) {
                            if($CSHealth.CertificateHealth.ExpirationTime -lt ((Get-Date).AddDays(30))) {
                                $ConServCertExpiry = "Certificate Expiring Soon"
                            } elseif ($CSHealth.CertificateHealth.ExpirationTime -lt (Get-Date)) {
                                $ConServCertExpiry = "Certificate Expired"
                            } else {
                                $ConServCertExpiry = "False"
                            }
                            if ($CSHealth) {
                                Write-PScriboMessage "Connection Server Status Information."
                                $inObj = [ordered] @{
                                    'Name' = $CSHealth.Name
                                    'Status' = $CSHealth.Status
                                    'Version' = $CSHealth.Version
                                    'Build' = $CSHealth.Build
                                    'Cert Valid' = $CSHealth.CertificateHealth.valid
                                    'Cert Expiring' = $ConServCertExpiry
                                    'Cert Expiry Date' = $CSHealth.CertificateHealth.ExpirationTime
                                    'Cert Invalidation Reason' = $CSHealth.CertificateHealth.InvalidationReason
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                        }

                        $TableParams = @{
                            Name = "Connection Server Health Information - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 16, 8, 10, 16, 6, 10, 20, 14
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