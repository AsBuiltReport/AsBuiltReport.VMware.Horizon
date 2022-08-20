function Get-AbrHRZLicense {
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
        Write-PScriboMessage "ProductLicensingandUsage InfoLevel set at $($InfoLevel.Settings.ProductLicensing.ProductLicensingandUsage)."
        Write-PscriboMessage "Collecting Product Licensing information."
    }

    process {
        try {
            if ($ProductLicenseingInfo) {
                if ($InfoLevel.Settings.ProductLicensing.ProductLicensingandUsage -ge 1) {
                    section -Style Heading3 "Product Licenses" {
                        Paragraph "The following section details the Product License information for $($HVEnvironment.split('.')[0]) server."
                        BlankLine
                        $OutObj = @()
                        foreach ($ProductLic in $ProductLicenseingInfo) {
                            try {
                                Write-PscriboMessage "Discovered Product Licensing Information."
                                $inObj = [ordered] @{
                                    'License Edition' = $ProductLic.LicenseEdition
                                    'Is Licensed' = $ProductLic.Licensed
                                    'License Key' = $ProductLic.LicenseKey
                                    'License Expiration' = $ProductLic.ExpirationTime.ToShortDateString()
                                    'Composer enabled' = $ProductLic.ViewComposerEnabled
                                    'Desktop Launching enabled' = $ProductLic.DesktopLaunchingEnabled
                                    'Application Launching enabled' = $ProductLic.ApplicationLaunchingEnabled
                                    'Instant Clone enabled' = $ProductLic.InstantCloneEnabled
                                    'HelpDesk enabled' = $ProductLic.HelpDeskEnabled
                                    'Collaboration enabled' = $ProductLic.CollaborationEnabled
                                    'License Usage Model' = $ProductLic.UsageModel
                                }

                                $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Product Licenses - $($HVEnvironment.split(".").toUpper()[0])"
                            List = $true
                            ColumnWidths = 50, 50
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Table @TableParams
                        try {
                            $UsageStatisticsInfo = try {$hzServices.UsageStatistics.UsageStatistics_GetLicensingCounters()} catch {Write-PscriboMessage -IsWarning $_.Exception.Message}
                            if ($UsageStatisticsInfo) {
                                if ($InfoLevel.Settings.ProductLicensing.ProductLicensingandUsage -ge 2) {
                                    section -Style Heading4 "Product License Usage" {
                                        $OutObj = @()
                                        foreach ($ProductUsage in $UsageStatisticsInfo.HighestUsage.PSObject.Properties.Name) {
                                            try {
                                                Write-PscriboMessage "Discovered Product Licensing Usage Information."
                                                $inObj = [ordered] @{
                                                    'Name' = ($ProductUsage -creplace '([A-Z\W_]|\d+)(?<![a-z])',' $&').trim()
                                                    'Current Usage' = ($UsageStatisticsInfo.CurrentUsage.PSObject.Properties | Where-Object {$_.Name -eq $ProductUsage}).Value
                                                    'Highest Usage' = ($UsageStatisticsInfo.HighestUsage.PSObject.Properties | Where-Object {$_.Name -eq $ProductUsage}).Value
                                                }

                                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                            }
                                            catch {
                                                Write-PscriboMessage -IsWarning $_.Exception.Message
                                            }
                                        }

                                        $TableParams = @{
                                            Name = "Product Licenses Usage - $($HVEnvironment.split(".").toUpper()[0])"
                                            List = $false
                                            ColumnWidths = 60, 20, 20
                                        }

                                        if ($Report.ShowTableCaptions) {
                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                        }
                                        $OutObj | Table @TableParams
                                    }
                                }
                            }
                        }
                        catch {
                            Write-PscriboMessage -IsWarning $_.Exception.Message
                        }
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