function Get-AbrHRZConnectionServer {
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
        Write-PScriboMessage "ConnectionServers InfoLevel set at $($InfoLevel.Settings.Servers.ConnectionServers.ConnectionServers)."
        Write-PScriboMessage "Collecting Connection Servers information."
    }

    process {
        try {
            if ($ConnectionServers) {
                if ($InfoLevel.Settings.Servers.ConnectionServers.ConnectionServers -ge 1) {
                    Section -Style Heading3 "Connection Servers" {
                        Paragraph "The following section details the configuration of Connection Servers for $($HVEnvironment.toUpper()) server."
                        BlankLine
                        $OutObj = @()
                        foreach ($ConnectionServer in $ConnectionServers) {
                            try {
                                Write-PScriboMessage "Discovered Connection Servers Information $($ConnectionServer.General.Name)."
                                #Switch ($GatewayServer.Type)
                                #{
                                #    'AP' {$GatewayType = 'UAG' }
                                #}
                                $inObj = [ordered] @{
                                    'Name' = $ConnectionServer.General.Name
                                    'Version' = $ConnectionServer.General.Version
                                    'Enabled' = $ConnectionServer.General.Enabled
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            } catch {
                                Write-PScriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        if ($HealthCheck.ConnectionServers.Status) {
                            $OutObj | Where-Object { $_.'Enabled' -eq 'No' } | Set-Style -Style Warning -Property 'Enabled'
                        }

                        $TableParams = @{
                            Name = "Connection Servers - $($HVEnvironment.toUpper())"
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
                                    Section -Style NOTOCHeading5 "General $($ConnectionServer.General.Name) Details" {
                                        try {
                                            $ConnectionServerTags = $ConnectionServer.General | ForEach-Object { $_.Tags }
                                            $ConnectionServerTagsresult = $ConnectionServerTags -join ', '

                                            # Connection Server Health Data
                                            $ConnectionServerHealthMatch = $false
                                            foreach ($ConnectionServerHealth in $ConnectionServersHealth) {
                                                if ($ConnectionServerHealth.id.id -eq $ConnectionServer.id.id) {
                                                    $ConnectionServerHealthData = $ConnectionServerHealth
                                                    $ConnectionServerHealthMatch = $true
                                                }
                                                if ($ConnectionServerHealthMatch) {
                                                    break
                                                }
                                            }

                                            Write-PScriboMessage "Discovered Connection Servers Information $($ConnectionServer.General.Name)."
                                            $inObj = [ordered] @{
                                                'Name' = $ConnectionServer.General.Name
                                                'FQDN' = $ConnectionServer.General.Fqhn
                                                'Server Address' = $ConnectionServer.General.ServerAddress
                                                'Version' = $ConnectionServer.General.Version
                                                'Enabled' = $ConnectionServer.General.Enabled
                                                'Tags' = $ConnectionServerTagsresult
                                                'External URL' = $ConnectionServer.General.ExternalURL
                                                'External PCoIP URL' = $ConnectionServer.General.ExternalPCoIPURL
                                                'Auxiliary External PCoIP IPv4 Address' = $ConnectionServer.General.AuxillaryExternalPCoIPIPv4Address
                                                'External App Blast URL' = $ConnectionServer.General.ExternalAppblastURL
                                                'Local Connection Server' = $ConnectionServer.General.LocalConnectionServer
                                                'Bypass Tunnel' = $ConnectionServer.General.BypassTunnel
                                                'Bypass PCoIP Gateway' = $ConnectionServer.General.BypassPCoIPGateway
                                                'Bypass App Blast Gateway' = $ConnectionServer.General.BypassAppBlastGateway
                                                'IP Mode' = $ConnectionServer.General.IpMode
                                                'FIPs Mode Enabled' = $ConnectionServer.General.FipsModeEnabled
                                                'Replication Status' = $ConnectionServerHealthData.ReplicationStatus.Status
                                                'Current CPU Usage Percentage' = $($ConnectionServerHealthData.ResourcesData.CpuUsagePercentage).ToString() + '%'
                                                'Current Memory Usage Percentage' = $($ConnectionServerHealthData.ResourcesData.MemoryUsagePercentage).ToString() + '%'
                                            }

                                            $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                            if ($HealthCheck.ConnectionServers.Status) {
                                                $OutObj | Where-Object { $_.'Enabled' -eq 'No' } | Set-Style -Style Warning -Property 'Enabled'
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


                                        } catch {
                                            Write-PScriboMessage -IsWarning $_.Exception.Message
                                        }
                                    }

                                    try {
                                        $OutObj = @()
                                        Section -Style NOTOCHeading5 "Authentication $($ConnectionServer.General.Name) Details" {
                                            try {
                                                Write-PScriboMessage "Discovered Connection Servers Authentication Information $($ConnectionServer.General.Name)."

                                                if ($connectionserver.authentication.samlconfig.SamlAuthenticators) {
                                                    $SAMLAuth = $hzServices.SAMLAuthenticator.SAMLAuthenticator_Get($connectionserver.authentication.samlconfig.SamlAuthenticator)
                                                    #$SAMLAuthList = $hzServices.SAMLAuthenticator.SAMLAuthenticator_list()
                                                }

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
                                                    'SAML Authenticator' = $SAMLAuth.General.Label
                                                    'SAML Authenticator Description' = $SAMLAuth.General.Description
                                                    'SAML Trigger Mode' = $SAMLAuth.General.CertificateSSOData.TriggerMode
                                                    'SAML Password Mode' = $SAMLAuth.General.CertificateSSOData.PasswordMode
                                                    'SAML Authenticator Type' = $SAMLAuth.server.AuthenticatorType
                                                    'SAML Metadata URL' = $SAMLAuth.server.MetadataURL
                                                    'SAML Administrator URL' = $SAMLAuth.server.AdministratorURL
                                                    'SAML Static Meta Data' = $SAMLAuth.server.StaticMetaData
                                                    'Unauthenticated Access Config Enabled' = $ConnectionServer.Authentication.UnauthenticatedAccessConfig.Enabled
                                                    'Unauthenticated Access Default User' = $ConnectionServer.Authentication.UnauthenticatedAccessConfig.DefaultUser
                                                    'Unauthenticated Access User Idle Timeout' = $ConnectionServer.Authentication.UnauthenticatedAccessConfig.UserIdleTimeout
                                                    'Unauthenticated Access Client Puzzle Difficulty' = $ConnectionServer.Authentication.UnauthenticatedAccessConfig.ClientPuzzleDifficulty
                                                    'Block Unsupported Clients' = $ConnectionServer.Authentication.UnauthenticatedAccessConfig.BlockUnsupportedClients
                                                }
                                                $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)
                                                $TableParams = @{
                                                    Name = "Authentication - $($ConnectionServer.General.Name)"
                                                    List = $true
                                                    ColumnWidths = 40, 60
                                                }
                                                if ($Report.ShowTableCaptions) {
                                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                                }
                                                $OutObj | Table @TableParams
                                            } catch {
                                                Write-PScriboMessage -IsWarning $_.Exception.Message
                                            }
                                        }
                                    } catch {
                                        Write-PScriboMessage -IsWarning $_.Exception.Message
                                    }
                                    try {
                                        $OutObj = @()
                                        Section -Style NOTOCHeading5 "Backup $($ConnectionServer.General.Name) Details" {
                                            try {
                                                Write-PScriboMessage "Discovered Connection Servers Authentication Information $($ConnectionServer.General.Name)."
                                                $inObj = [ordered] @{
                                                    'Automatic Backup Frequency' = Switch ($ConnectionServer.Backup.LdapBackupFrequencyTime) {
                                                        'DAY_1' { 'Every day' }
                                                        'DAY_2' { 'Every 2 day' }
                                                        'HOUR_1' { 'Every hour' }
                                                        'HOUR_12' { 'Every 12 hours' }
                                                        'WEEK_1' { 'Every week' }
                                                        'WEEK_2' { 'Every 2 week' }
                                                        'HOUR_0' { 'Disabled' }

                                                    }
                                                    'Max Number of Backups' = $ConnectionServer.Backup.LdapBackupMaxNumber
                                                    'Last Backup Time' = $ConnectionServer.Backup.LastLdapBackupTime
                                                    'Last Backup Status' = $ConnectionServer.Backup.LastLdapBackupStatus
                                                    'Folder Location' = $ConnectionServer.Backup.LdapBackupFolder
                                                }

                                                $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)

                                                if ($HealthCheck.ConnectionServers.Status) {
                                                    $OutObj | Where-Object { $_.'Last Backup Status' -ne 'OK' } | Set-Style -Style Warning -Property 'Last Backup Status'
                                                    $OutObj | Where-Object { $_.'Automatic Backup Frequency' -eq 'Disabled' } | Set-Style -Style Critical -Property 'Automatic Backup Frequency'
                                                }

                                                $TableParams = @{
                                                    Name = "Backup - $($ConnectionServer.General.Name)"
                                                    List = $true
                                                    ColumnWidths = 50, 50
                                                }

                                                if ($Report.ShowTableCaptions) {
                                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                                }
                                                $OutObj | Table @TableParams
                                            } catch {
                                                Write-PScriboMessage -IsWarning $_.Exception.Message
                                            }
                                        }
                                    } catch {
                                        Write-PScriboMessage -IsWarning $_.Exception.Message
                                    }
                                    try {
                                        $OutObj = @()
                                        Section -Style NOTOCHeading5 "Certificate Details for $($ConnectionServer.General.Name) Details" {
                                            try {

                                                # Connection Server Health Data
                                                $ConnectionServerHealthMatch = $false
                                                foreach ($ConnectionServerHealth in $ConnectionServersHealth) {
                                                    if ($ConnectionServerHealth.id.id -eq $ConnectionServer.id.id) {
                                                        $ConnectionServerHealthData = $ConnectionServerHealth
                                                        $ConnectionServerHealthMatch = $true
                                                    }
                                                    if ($ConnectionServerHealthMatch) {
                                                        break
                                                    }
                                                }

                                                Write-PScriboMessage "Working on Certificate Information for $($ConnectionServerHealthData.Name)."

                                                if (![string]::IsNullOrEmpty($ConnectionServerHealthData.CertificateHealth.ConnectionServerCertificate)) {
                                                    $Cert = $ConnectionServerHealthData.CertificateHealth.ConnectionServerCertificate
                                                    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Cert)
                                                    $PodCert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($Bytes)
                                                }

                                                $inObj = [ordered] @{
                                                    'Connection Server' = $ConnectionServerHealthData.Name
                                                    'Self-Signed Certificate' = $ConnectionServerHealthData.DefaultCertificate
                                                    'Certificate Subject' = $PodCert.Subject
                                                    'Certificate Issuer' = $PodCert.Issuer
                                                    'Certificate Not Before' = $PodCert.NotBefore
                                                    'Certificate Not After' = $PodCert.NotAfter
                                                    'Certificate SANs' = $(($PodCert.DnsNameList | ForEach-Object { $_.Punycode }) -join ', ')
                                                    'Certificate Thumbprint' = $PodCert.Thumbprint
                                                }
                                                $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)
                                                if ($HealthCheck.ConnectionServers.Status) {
                                                    $OutObj | Where-Object { $_.'Enabled' -eq 'No' } | Set-Style -Style Warning -Property 'Enabled'
                                                }
                                                $TableParams = @{
                                                    Name = "Certificate Details for - $($ConnectionServerHealthData.Name)"
                                                    List = $true
                                                    ColumnWidths = 30, 70
                                                }
                                                if ($Report.ShowTableCaptions) {
                                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                                }
                                                $OutObj | Table @TableParams
                                            } catch {
                                                Write-PScriboMessage -IsWarning $_.Exception.Message
                                            }
                                        }
                                    } catch {
                                        Write-PScriboMessage -IsWarning $_.Exception.Message
                                    }
                                    if ($ConnectionServersHealth.replicationstatus) {
                                        if ($InfoLevel.settings.servers.ConnectionServers.ConnectionServers -ge 2) {
                                            try {
                                                $OutObj = @()
                                                Section -Style NOTOCHeading5 "Replication Status for Connection Server $($connectionserver.General.Name)" {
                                                    try {
                                                        Write-PScriboMessage "Working on Replication Information for $($connectionserver.General.Name)."

                                                        If ($CSHealth.Message) {
                                                            $CSHealthMessage = $CSHealth.Message
                                                        } else {
                                                            $CSHealthMessage = "No Replication Issues"
                                                        }

                                                        foreach ($CSHealth in ($ConnectionServersHealth | Where-Object { $_.Name -EQ $connectionserver.General.Name })) {
                                                            $inObj = [ordered] @{
                                                                'Connection Server' = $CSHealth.Name
                                                                'Replication Partner' = $($CSHealth.ReplicationStatus | ForEach-Object { $_.ServerName }) -join ','
                                                                'Status' = $($CSHealth.ReplicationStatus | ForEach-Object { $_.Status }) -join ','
                                                                'Message' = $CSHealthMessage
                                                            }
                                                            $OutObj = [pscustomobject](ConvertTo-HashToYN $inObj)
                                                        }

                                                        $TableParams = @{
                                                            Name = "Connection Servers Replication- $($connectionserver.General.Name)"
                                                            List = $true
                                                            ColumnWidths = 30, 70
                                                        }
                                                        if ($Report.ShowTableCaptions) {
                                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                                        }
                                                        $OutObj | Table @TableParams
                                                    } catch {
                                                        Write-PScriboMessage -IsWarning $_.Exception.Message
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

                    }
                }
            }
        } catch {
            Write-PScriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}
}