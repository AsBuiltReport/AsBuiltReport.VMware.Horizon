function Get-AbrHRZGlobalSetting {
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
        Write-PScriboMessage "GlobalSettings InfoLevel set at $($InfoLevel.Settings.GlobalSettings.GlobalSettings)."
        Write-PscriboMessage "Collecting Global Settings information."
    }

    process {
        try {
            if ($GlobalSettings) {
                if ($InfoLevel.Settings.GlobalSettings.GlobalSettings -ge 1) {
                    section -Style Heading3 "Global Settings" {
                        $OutObj = @()
                        Write-PscriboMessage "Discovered Global Settings Information."
                        $inObj = [ordered] @{
                            'Client Session Time Out Policy' = $GlobalSettings.GeneralData.ClientIdleSessionTimeoutPolicy
                            'Client Max Session Time Minutes ' = $GlobalSettings.GeneralData.ClientMaxSessionTimeMinutes
                            'Client Idle Session Timeout Policy' = $GlobalSettings.GeneralData.ClientIdleSessionTimeoutPolicy
                            'Client Idle Session Timeout Minutes' = $GlobalSettings.GeneralData.ClientIdleSessionTimeoutMinutes
                            'Client Session Timeout Minutes ' = $GlobalSettings.GeneralData.ClientSessionTimeoutMinutes
                            'Desktop SSO Timeout Policy' = $GlobalSettings.GeneralData.DesktopSSOTimeoutPolicy
                            'Desktop SSO Timeout Minutes' = $GlobalSettings.GeneralData.DesktopSSOTimeoutMinutes
                            'Application SSO Timeout Policy' = $GlobalSettings.GeneralData.ApplicationSSOTimeoutPolicy
                            'Application SSO Timeout Minutes' = $GlobalSettings.GeneralData.ApplicationSSOTimeoutMinutes
                            'View API Session Timeout Minutes' = $GlobalSettings.GeneralData.ViewAPISessionTimeoutMinutes
                            'Pre-Login Message' = $GlobalSettings.GeneralData.PreLoginMessage
                            'Display Warning Before Forced Logoff' = $GlobalSettings.GeneralData.DisplayWarningBeforeForcedLogoff
                            'Forced Logoff Timeout Minutes' = $GlobalSettings.GeneralData.ForcedLogoffTimeoutMinutes
                            'Forced Logoff Message' = $GlobalSettings.GeneralData.ForcedLogoffMessage
                            'Enable Server in Single User Mode' = $GlobalSettings.GeneralData.EnableServerInSingleUserMode
                            'Store CAL on Broker' = $GlobalSettings.GeneralData.StoreCALOnBroker
                            'Store CAL on Client' = $GlobalSettings.GeneralData.StoreCALOnClient
                            'Reauthenticate Secure Tunnel After Interruption' = $GlobalSettings.SecurityData.ReauthSecureTunnelAfterInterruption
                            'Message Security Mode' = $GlobalSettings.SecurityData.MessageSecurityMode
                            'Message Security Status' = $GlobalSettings.SecurityData.MessageSecurityStatus
                            'Enable IP Sec for Security Server Pairing' = $GlobalSettings.SecurityData.EnableIPSecForSecurityServerPairing
                            'Mirage Configuration Enabled' = $GlobalSettings.MirageConfiguration.Enabled
                            'Mirage Configuration URL' = $GlobalSettings.MirageConfiguration.Url
                        }

                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                        $TableParams = @{
                            Name = "Global Settings - $($HVEnvironment)"
                            List = $true
                            ColumnWidths = 50, 50
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Table @TableParams
                        try {
                            if ($InfoLevel.Settings.GlobalSettings.GlobalSettings -ge 2) {
                                section -Style Heading4 "Client Restriction Settings" {
                                    $OutObj = @()
                                    Write-PscriboMessage "Discovered Client Restriction Settings Information."
                                    foreach ($CLientData in $GlobalSettings.ClientRestrictionConfiguration.ClientData) {
                                        $inObj = [ordered] @{
                                            'Type' = $CLientData.Type
                                            'Version' = $CLientData.Version
                                            'WarnSpecificVersions' = $CLientData.WarnSpecificVersions
                                            'BlockSpecificVersions' = $CLientData.BlockSpecificVersions
                                        }
                                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                    }

                                    $TableParams = @{
                                        Name = "Client Restriction Settings - $($HVEnvironment)"
                                        List = $false
                                        ColumnWidths = 25, 25, 25, 25
                                    }

                                    if ($Report.ShowTableCaptions) {
                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                    }
                                    $OutObj | Table @TableParams
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