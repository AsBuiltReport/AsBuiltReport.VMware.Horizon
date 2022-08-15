function Get-AbrHRZLicenseInfo {
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
                    section -Style Heading3 "Product Licensing" {
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
                            Name = "Product Licensing - $($HVEnvironment)"
                            List = $true
                            ColumnWidths = 50, 50
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Table @TableParams
                        try {
                            if ($UsageStatisticsInfo) {
                                if ($InfoLevel.Settings.ProductLicensing.ProductLicensingandUsage -ge 2) {
                                    section -Style Heading4 "Product Licensing Usage" {
                                        $OutObj = @()
                                        foreach ($ProductUsage in $UsageStatisticsInfo.HighestUsage) {
                                            try {
                                                Write-PscriboMessage "Discovered Product Licensing Usage Information."
                                                $inObj = [ordered] @{
                                                    'Total Concurrent Connections' = $ProductUsage.TotalConcurrentConnections
                                                    'Total Named Users' = $ProductUsage.TotalNamedUsers
                                                    'Total Concurrent Sessions' = $ProductUsage.TotalConcurrentSessions
                                                    'Concurrent Full Vm Sessions' = $ProductUsage.ConcurrentFullVmSessions
                                                    'Concurrent Linked Clone Sessions' = $ProductUsage.ConcurrentLinkedCloneSessions
                                                    'Concurrent Unmanaged Vm Sessions' = $ProductUsage.ConcurrentUnmanagedVmSessions
                                                    'Concurrent Application Sessions' = $ProductUsage.ConcurrentApplicationSessions
                                                    'Concurrent Collaborative Sessions' = $ProductUsage.ConcurrentCollaborativeSessions
                                                    'Total Collaborators' = $ProductUsage.TotalCollaborators
                                                }

                                                $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)
                                            }
                                            catch {
                                                Write-PscriboMessage -IsWarning $_.Exception.Message
                                            }
                                        }

                                        $TableParams = @{
                                            Name = "Product Licensing Usage - $($HVEnvironment)"
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