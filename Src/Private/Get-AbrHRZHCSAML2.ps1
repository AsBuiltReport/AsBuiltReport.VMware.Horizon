function Get-AbrHRZHCSAML2 {
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
        Write-PScriboMessage "SAML Health Check InfoLevel set at $($HealthCheck.OtherComponents.SAML2)."
        Write-PScriboMessage "SAML Health information."
    }

    process {
        try {
            if ($SAMLAuthenticatorhealthlist) {
                if ($HealthCheck.OtherComponents.SAML2) {
                    Section -Style Heading3 "SAML Health Information" {
                        Paragraph "The following section details on the SAML health information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()
                        foreach ($SAMLAuthenticatorhealth in $SAMLAuthenticatorhealthlist){

                            Write-PScriboMessage "SAML Health Status Information."
                            $inObj = [ordered] @{
                                "Status" = $SAMLAuthenticatorHealthList.ConnectionServerData.Status[0];
                                "Authenticator Name" = $SAMLAuthenticatorhealth.data.label;
                                "Metadata URL" = $SAMLAuthenticatorhealth.data.MetadataURL;
                                "Details" = $SAMLAuthenticatorhealth.data.Description;
                                "Admin URL" = $SAMLAuthenticatorhealth.data.AdministratorURL;
                                "TrueSSO Trigger Mode" = $SAMLAuthenticatorhealth.data.CertificateSsoTriggerMode;
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                        }

                        $TableParams = @{
                            Name = "SAML Health Information - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 10, 10, 25, 10, 25, 10
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