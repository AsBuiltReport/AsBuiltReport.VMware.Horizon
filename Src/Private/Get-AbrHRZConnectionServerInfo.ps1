function Get-AbrHRZConnectionServerInfo {
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
        Write-PScriboMessage "ConnectionServers InfoLevel set at $($InfoLevel.Settings.Servers.ConnectionServers.ConnectionServers)."
        Write-PscriboMessage "Collecting Connection Servers information."
    }

    process {
        try {
            $Connectionservers = try {$hzServices.ConnectionServer.ConnectionServer_List()} catch {Write-PscriboMessage -IsWarning $_.Exception.Message}
            if ($ConnectionServers) {
                if ($InfoLevel.Settings.Servers.ConnectionServers.ConnectionServers -ge 1) {
                    section -Style Heading4 "Connection Servers Summary" {
                        $OutObj = @()
                        foreach ($ConnectionServer in $ConnectionServers) {
                            try {
                                Write-PscriboMessage "Discovered Connection Servers Information $($ConnectionServer.General.Name)."
                                Switch ($GatewayServer.Type)
                                {
                                    'AP' {$GatewayType = 'UAG' }
                                }
                                $inObj = [ordered] @{
                                    'Name' = $ConnectionServer.General.Name
                                    'Version' = $ConnectionServer.General.Version
                                    'Enabled' = $ConnectionServer.General.Enabled
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        if ($HealthCheck.ConnectionServers.Status) {
                            $OutObj | Where-Object { $_.'Enabled' -eq 'No'} | Set-Style -Style Warning -Property 'Enabled'
                        }

                        $TableParams = @{
                            Name = "Connection Servers - $($HVEnvironment)"
                            List = $false
                            ColumnWidths = 42, 43, 15
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                        if ($InfoLevel.Settings.Servers.ConnectionServers.ConnectionServers -ge 2) {
                            try {
                                $OutObj = @()
                                foreach ($ConnectionServer in $ConnectionServers) {
                                    section -Style Heading5 "$($ConnectionServer.General.Name) Details" {
                                        try {
                                            $ConnectionServerTags = $ConnectionServer.General | ForEach-Object { $_.Tags}
                                            $ConnectionServerTagsresult = $ConnectionServerTags -join ', '
                                            Write-PscriboMessage "Discovered Connection Servers Information $($ConnectionServer.General.Name)."
                                            $inObj = [ordered] @{
                                                'Name' = $ConnectionServer.General.Name
                                                'FQDN' = $ConnectionServer.General.Fqhn
                                                'Server Address' = $ConnectionServer.General.ServerAddress
                                                'Version' = $ConnectionServer.General.Version
                                                'Enabled' = $ConnectionServer.General.Enabled
                                                'Tags' = $ConnectionServerTagsresult
                                                'External URL' = $ConnectionServer.General.ExternalURL
                                                'External PCoIP URL' = $ConnectionServer.General.ExternalPCoIPURL
                                                'Auxillary External PCoIP IPv4 Address' = $ConnectionServer.General.AuxillaryExternalPCoIPIPv4Address
                                                'External App Blast URL' = $ConnectionServer.General.ExternalAppblastURL
                                                'Local Connection Server' = $ConnectionServer.General.LocalConnectionServer
                                                'Bypass Tunnel' = $ConnectionServer.General.BypassTunnel
                                                'Bypass PCoIP Gateway' = $ConnectionServer.General.BypassPCoIPGateway
                                                'Bypass App Blast Gateway' = $ConnectionServer.General.BypassAppBlastGateway
                                                'IP Mode' = $ConnectionServer.General.IpMode
                                                'FIPs Mode Enabled' = $ConnectionServer.General.FipsModeEnabled
                                            }

                                            $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                            if ($HealthCheck.ConnectionServers.Status) {
                                                $OutObj | Where-Object { $_.'Enabled' -eq 'No'} | Set-Style -Style Warning -Property 'Enabled'
                                            }

                                            $TableParams = @{
                                                Name = "Connection Servers - $($ConnectionServer.General.Name)"
                                                List = $true
                                                ColumnWidths = 50, 50
                                            }

                                            if ($Report.ShowTableCaptions) {
                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                            }
                                            $OutObj | Table @TableParams
                                            try {
                                                $OutObj = @()
                                                section -Style Heading6 "Authentication" {
                                                    try {
                                                        if($connectionserver.authentication.samlconfig.SamlAuthenticator) {
                                                            $SAMLAuth = $hzServices.SAMLAuthenticator.SAMLAuthenticator_Get($connectionserver.authentication.samlconfig.SamlAuthenticator)
                                                            $SAMLAuthList = $hzServices.SAMLAuthenticator.SAMLAuthenticator_list($ConnectionServer.Authentication.SamlConfig.SamlAuthenticators)
                                                        }
                                                        Write-PscriboMessage "Discovered Connection Servers Authentication Information $($ConnectionServer.General.Name)."
                                                        $inObj = [ordered] @{
                                                            'Smart Card Support' = $ConnectionServer.Authentication.SmartCardSupport
                                                            'Log off When Smart Card Removed' = $ConnectionServer.Authentication.LogoffWhenRemoveSmartCard
                                                            'RSA Secure ID Enabled' = $ConnectionServer.Authentication.RsaSecureIdConfig.SecureIdEnabled
                                                            'RSA Secure ID Name Mapping' = $ConnectionServer.Authentication.RsaSecureIdConfig.NameMapping
                                                            'RSA Secure ID Clear Node Secret' = $ConnectionServer.Authentication.RsaSecureIdConfig.ClearNodeSecret
                                                            'RSA Secure ID Security File Data' = $ConnectionServer.Authentication.RsaSecureIdConfig.SecurityFileData
                                                            'RSA Secure ID Security File Uploaded' = $ConnectionServer.Authentication.RsaSecureIdConfig.SecurityFileUploaded
                                                            'Radius Enabled' = $ConnectionServer.Authentication.RadiusConfig.RadiusEnabled
                                                            'Radius Authenticator' = $ConnectionServer.Authentication.RadiusConfig.RadiusAuthenticator
                                                            'Radius Name Mapping' = $ConnectionServer.Authentication.RadiusConfig.RadiusNameMapping
                                                            'Radius SSO' = $ConnectionServer.Authentication.RadiusConfig.RadiusSSO
                                                            'SAML Support' = $ConnectionServer.Authentication.SamlConfig.SamlSupport
                                                            'SAML Authenticator' = $SAMLAuth.base.Label
                                                            'SAML Authenticators' = $SAMLAuthList.base.label
                                                            'Unauthenticated Access Config Enabled' = $ConnectionServer.Authentication.UnauthenticatedAccessConfig.Enabled
                                                            'Unauthenticated Access Default User' = $ConnectionServer.Authentication.UnauthenticatedAccessConfig.DefaultUser
                                                            'Unauthenticated Access User Idle Timeout' = $ConnectionServer.Authentication.UnauthenticatedAccessConfig.UserIdleTimeout
                                                        }

                                                        $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                        $TableParams = @{
                                                            Name = "Connection Servers - $($ConnectionServer.General.Name)"
                                                            List = $true
                                                            ColumnWidths = 50, 50
                                                        }

                                                        if ($Report.ShowTableCaptions) {
                                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                                        }
                                                        $OutObj | Table @TableParams
                                                    }
                                                    catch {
                                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                                    }
                                                }
                                            }
                                            catch {
                                                Write-PscriboMessage -IsWarning $_.Exception.Message
                                            }
                                            try {
                                                $OutObj = @()
                                                section -Style Heading6 "Backup" {
                                                    try {
                                                        Write-PscriboMessage "Discovered Connection Servers Authentication Information $($ConnectionServer.General.Name)."
                                                        $inObj = [ordered] @{
                                                            'Automatic Backup Frequency' = Switch ($ConnectionServer.Backup.LdapBackupFrequencyTime) {
                                                                'DAY_1' {'Every day'}
                                                                'DAY_2' {'Every 2 day'}
                                                                'HOUR_1' {'Every hour'}
                                                                'HOUR_12' {'Every 12 hours'}
                                                                'WEEK_1' {'Every week'}
                                                                'WEEK_2' {'Every 2 week'}
                                                                'HOUR_0' {'Disabled'}

                                                            }
                                                            'Max Number of Backups' = $ConnectionServer.Backup.LdapBackupMaxNumber
                                                            'Last Backup Time' = $ConnectionServer.Backup.LastLdapBackupTime
                                                            'Last Backup Status' = $ConnectionServer.Backup.LastLdapBackupStatus
                                                            'Folder Location' = $ConnectionServer.Backup.LdapBackupFolder
                                                        }

                                                        $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                        if ($HealthCheck.ConnectionServers.Status) {
                                                            $OutObj | Where-Object { $_.'Last Backup Status' -ne 'OK'} | Set-Style -Style Warning -Property 'Last Backup Status'
                                                            $OutObj | Where-Object { $_.'Automatic Backup Frequency' -eq 'Disabled'} | Set-Style -Style Critical -Property 'Automatic Backup Frequency'
                                                        }

                                                        $TableParams = @{
                                                            Name = "Connection Servers - $($ConnectionServer.General.Name)"
                                                            List = $true
                                                            ColumnWidths = 50, 50
                                                        }

                                                        if ($Report.ShowTableCaptions) {
                                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                                        }
                                                        $OutObj | Table @TableParams
                                                    }
                                                    catch {
                                                        Write-PscriboMessage -IsWarning $_.Exception.Message
                                                    }
                                                }
                                            }
                                            catch {
                                                Write-PscriboMessage -IsWarning $_.Exception.Message
                                            }
                                        }
                                        catch {
                                            Write-PscriboMessage -IsWarning $_.Exception.Message
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
        }
        catch {
            Write-PscriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}
}