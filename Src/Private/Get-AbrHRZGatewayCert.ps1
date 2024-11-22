function Get-AbrHRZGatewayCert {
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
        Write-PScriboMessage "Gatway Certificate InfoLevel set at $($InfoLevel.Settings.Servers.ConnectionServers.ConnectionServers)."
        Write-PScriboMessage "Collecting Gatway Certificate information."
    }

    process {
        try {
            if ($GatewayCerts) {
                if ($InfoLevel.Settings.CloudPodArch.CloudPodArch -ge 1) {
                    Section -Style Heading3 "Gateway Certificate" {
                        Paragraph "The following section details on the gateway certificate information for $($HVEnvironment.toUpper())."
                        BlankLine
                        Write-PScriboMessage "Working on Gateway Certificate Information for $($HVEnvironment.toUpper())."
                        $OutObj = @()
                        foreach ($GatewayCert in $GatewayCerts) {
                            $inObj = [ordered] @{
                                'Certificate Name' = $GatewayCert.CertificateName
                                'Common Name' = $GatewayCert.CommonName
                                'Issuer' = $GatewayCert.Issuer
                                'Expiry Date' = $GatewayCert.ExpiryDate
                                'Serial Number' = $GatewayCert.SerialNum
                            }
                            $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)
                        }
                        $TableParams = @{
                            Name = "Gateway Certificate - $($HVEnvironment.toUpper())"
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