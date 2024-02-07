function Get-AbrHRZGlobalSetting {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        1.1.2
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
        Write-PScriboMessage "Collecting Global Settings information."
    }

    process {
        try {
            if ($GlobalSettings) {
                if ($InfoLevel.Settings.GlobalSettings.GlobalSettings -ge 1) {
                    Section -Style Heading2 "Global Settings" {
                        Paragraph "The following section details the Global Settings configuration for $($HVEnvironment.toUpper()) server."
                        BlankLine
                        Section -Style Heading3 "General Settings" {
                            $OutObj = @()
                            Write-PScriboMessage "Discovered Global Settings Information."
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
                                'Enable UI User Name Caching' = $GlobalSettings.GeneralData.EnableUIUserNameCaching
                                'Console Session Timeout in Minutes' = $GlobalSettings.GeneralData.ConsoleSessionTimeoutMinutes
                                'Enable Automatic Status Updates' = $GlobalSettings.GeneralData.EnableAutomaticStatusUpdates
                                'Send Domain List' = $GlobalSettings.GeneralData.SendDomainList
                                'Enable Credential Cleanup for HTML Access' = $GlobalSettings.GeneralData.EnableCredentialCleanupForHTMLAccess
                                'Hide Server Information In Client' = $GlobalSettings.GeneralData.HideServerInformationInClient
                                'Hide Domain List In Client' = $GlobalSettings.GeneralData.HideDomainListInClient
                                'Enable Multi Factor Reauthentication' = $GlobalSettings.GeneralData.EnableMultiFactorReAuth
                                'Disconnect Warning Time' = $GlobalSettings.GeneralData.DisconnectWarningTime
                                'Disconnect Warning Message' = $GlobalSettings.GeneralData.DisconnectWarningMessage
                                'Disconnect Message' = $GlobalSettings.GeneralData.DisconnectMessage
                                'Display Pre-login Admin Banner' = $GlobalSettings.GeneralData.DisplayPreLoginAdminBanner
                                'Pre-Login Admin Banner Header' = $GlobalSettings.GeneralData.PreLoginAdminBannerHeader
                                'Pre-Login Admin Banner Message' = $GlobalSettings.GeneralData.PreLoginAdminBannerMessage
                                'Enforce CSRF Protection' = $GlobalSettings.GeneralData.EnorceCSRFProtection
                                'Enforce E2E Encryption' = $GlobalSettings.GeneralData.EnforceE2EEncryption


                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                            $TableParams = @{
                                Name = "Global Settings - $($HVEnvironment.toUpper())"
                                List = $true
                                ColumnWidths = 50, 50
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }
                            $OutObj | Table @TableParams
                        }

                        try {
                            if ($InfoLevel.Settings.GlobalSettings.GlobalSettings -ge 2) {
                                Section -Style Heading3 "Security Settings" {
                                    $OutObj = @()
                                    Write-PScriboMessage "Discovered Security Settings Information."
                                    $inObj = [ordered] @{
                                        'Reauthenticate Secure Tunnel After Interruption' = $GlobalSettings.SecurityData.ReauthSecureTunnelAfterInterruption
                                        'Disallow Enhanced Security Mode' = $GlobalSettings.SecurityData.DisallowEnhancedSecurityMode
                                        'No Managed Certs' = $GlobalSettings.SecurityData.NoManagedCerts
                                        'Message Security Mode' = $GlobalSettings.SecurityData.MessageSecurityMode
                                        'Message Security Status' = $GlobalSettings.SecurityData.MessageSecurityStatus
                                        'Enable IP Sec for Security Server Pairing' = $GlobalSettings.SecurityData.EnableIPSecForSecurityServerPairing
                                    }
                                    $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                    $TableParams = @{
                                        Name = "Security Settings - $($HVEnvironment.toUpper())"
                                        List = $true
                                        ColumnWidths = 50, 50
                                    }

                                    if ($Report.ShowTableCaptions) {
                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                    }
                                    $OutObj | Table @TableParams
                                }
                            }
                        } catch {
                            Write-PScriboMessage -IsWarning $_.Exception.Message
                        }

                        try {
                            if ($InfoLevel.Settings.GlobalSettings.GlobalSettings -ge 2) {
                                Section -Style Heading3 "Client Restriction Settings" {
                                    $OutObj = @()
                                    Write-PScriboMessage "Discovered Client Restriction Settings Information."
                                    foreach ($CLientData in $GlobalSettings.ClientRestrictionConfiguration.ClientData) {
                                        $inObj = [ordered] @{
                                            'Type' = $CLientData.Type
                                            'Version' = $CLientData.Version
                                            'Warn Specific Versions' = $CLientData.WarnSpecificVersions
                                            'Block Specific Versions' = $CLientData.BlockSpecificVersions
                                        }
                                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                    }

                                    $TableParams = @{
                                        Name = "Client Restriction Settings - $($HVEnvironment.toUpper())"
                                        List = $false
                                        ColumnWidths = 25, 25, 25, 25
                                    }

                                    if ($Report.ShowTableCaptions) {
                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                    }
                                    $OutObj | Table @TableParams
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