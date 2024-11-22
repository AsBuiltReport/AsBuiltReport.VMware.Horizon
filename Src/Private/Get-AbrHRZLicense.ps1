function Get-AbrHRZLicense {
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
        Write-PScriboMessage "ProductLicensingandUsage InfoLevel set at $($InfoLevel.Settings.ProductLicensing.ProductLicensingandUsage)."
        Write-PScriboMessage "Collecting Product Licensing information."
    }

    process {
        try {
            if ($ProductLicenseingInfo) {
                if ($InfoLevel.Settings.ProductLicensing.ProductLicensingandUsage -ge 1) {
                    Section -Style Heading2 "Product Licensing and Usage" {
                        Paragraph "The following section details the product license and usage information for $($HVEnvironment.toUpper()) server."
                        BlankLine

                        Section -Style Heading3 "Licensing" {
                            $OutObj = @()
                            foreach ($ProductLic in $ProductLicenseingInfo) {
                                try {
                                    Write-PScriboMessage "Discovered Product Licensing Information."

                                    # If $ProductLic.ExpirationTime is null, then the license is perpetual
                                    $ProductLicExpirationTime = ""
                                    if ($null -eq $ProductLic.ExpirationTime) {
                                        $ProductLicExpirationTime = "Perpetual"
                                    } else {
                                        $ProductLicExpirationTime = $ProductLic.ExpirationTime.ToShortDateString()
                                    }

                                    $inObj = [ordered] @{
                                        'Is Licensed' = $ProductLic.Licensed
                                        'License Key' = $ProductLic.LicenseKey
                                        'License Expiration' = $ProductLicExpirationTime
                                        'Composer enabled' = $ProductLic.ViewComposerEnabled
                                        'Desktop Launching enabled' = $ProductLic.DesktopLaunchingEnabled
                                        'Application Launching enabled' = $ProductLic.ApplicationLaunchingEnabled
                                        'Instant Clone enabled' = $ProductLic.InstantCloneEnabled
                                        'Helpdesk enabled' = $ProductLic.HelpDeskEnabled
                                        'Collaboration enabled' = $ProductLic.CollaborationEnabled
                                        'License Edition' = $ProductLic.LicenseEdition
                                        'License Usage Model' = $ProductLic.UsageModel
                                        'License Mode' = $ProductLic.LicenseMode
                                        'Grace Period Days' = $ProductLic.GracePeriodDays
                                        'Subscription Slice Expiry' = $ProductLic.SubscriptionSliceExpiry
                                        'License Health' = $ProductLic.LicenseHealth
                                    }

                                    $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)
                                } Catch {
                                    Write-PScriboMessage -IsWarning $_.Exception.Message
                                }
                            }
                            $TableParams = @{
                                Name = "Licensing - $($HVEnvironment.toUpper())"
                                List = $true
                                ColumnWidths = 50, 50
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }
                            $OutObj | Table @TableParams
                        }
                        try {
                            $UsageStatisticsInfo = try { $hzServices.UsageStatistics.UsageStatistics_GetLicensingCounters() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }
                            if ($UsageStatisticsInfo) {
                                if ($InfoLevel.Settings.ProductLicensing.ProductLicensingandUsage -ge 2) {
                                    Section -Style Heading3 "Usage" {
                                        $OutObj = @()
                                        foreach ($ProductUsage in $UsageStatisticsInfo.HighestUsage.PSObject.Properties.Name) {
                                            try {
                                                Write-PScriboMessage "Discovered Product Licensing Usage Information."
                                                $inObj = [ordered] @{
                                                    'Name' = ($ProductUsage -creplace '([A-Z\W_]|\d+)(?<![a-z])', ' $&').trim()
                                                    'Current Usage' = ($UsageStatisticsInfo.CurrentUsage.PSObject.Properties | Where-Object { $_.Name -eq $ProductUsage }).Value
                                                    'Highest Usage' = ($UsageStatisticsInfo.HighestUsage.PSObject.Properties | Where-Object { $_.Name -eq $ProductUsage }).Value
                                                }

                                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                            } catch {
                                                Write-PScriboMessage -IsWarning $_.Exception.Message
                                            }
                                        }

                                        $TableParams = @{
                                            Name = "Usage - $($HVEnvironment.toUpper())"
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
                        } catch {
                            Write-PScriboMessage -IsWarning $_.Exception.Message
                        }

                        try {
                            if ($CEIP) {
                                if ($InfoLevel.Settings.ProductLicensing.ProductLicensingandUsage -ge 2) {
                                    Section -Style Heading3 "Customer Experience Program" {
                                        $OutObj = @()
                                        try {
                                            Write-PScriboMessage "Discovered Customer Experience Program Information."
                                            $inObj = [ordered] @{
                                                'CEIP Enabled' = $CEIP.Enabled
                                                'Company Size' = $CEIP.CompanySize
                                                'Geolocation' = $CEIP.Geolocation
                                                'Vertical' = $CEIP.Vertical
                                            }

                                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                        } catch {
                                            Write-PScriboMessage -IsWarning $_.Exception.Message
                                        }

                                        $TableParams = @{
                                            Name = "Customer Experience Program - $($HVEnvironment.toUpper())"
                                            List = $true
                                            ColumnWidths = 40, 60
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
                }
            }
        } catch {
            Write-PScriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}
}