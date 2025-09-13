function Get-AbrHRZHCLicenseService {
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
        Write-PScriboMessage "License Health Check InfoLevel set at $($HealthCheck.OtherComponents.LicenseService)."
        Write-PScriboMessage "License Health information."
    }

    process {
        try {
            if ($ProductLicenseingInfo) {
                if ($HealthCheck.OtherComponents.LicenseService) {
                    Section -Style Heading3 "License Health Information" {
                        Paragraph "The following section details on the License health information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()

                        $LicensedEditionEdited = $ProductLicenseingInfo.LicenseEdition -replace "_", " "
                        $culture = [System.Globalization.CultureInfo]::CurrentCulture
                        $textInfo = $culture.TextInfo
                        $properCaseLicensedEditionEdited = $textInfo.ToTitleCase($LicensedEditionEdited.ToLower())

                        # $ProductLicenseingInfo.Licensed
                        if ($ProductLicenseingInfo.Licensed -eq $true) {
                            $LicStatus = "Okay"
                        } else {
                            $LicStatus = "Unlicensed"
                        }

                        Write-PScriboMessage "License Health Status Information."
                        $inObj = [ordered] @{
                            "Status" = $LicStatus;
                            "License Key" = $ProductLicenseingInfo.LicenseKey;
                            "License Edition" = $properCaseLicensedEditionEdited;
                        }

                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)


                        $TableParams = @{
                            Name = "License Health Information - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 30, 40, 30
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