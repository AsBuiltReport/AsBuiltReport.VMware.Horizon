function Invoke-AsBuiltReport.VMware.Horizon {
<#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon View in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon View in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        0.1.1
        Author:         Karl Newick, Chris Hildebrandt
        Twitter:        @karlnewick, @childebrandt42
        Github:         
        Credits:        Iain Brighton (@iainbrighton) - PScribo module

    .LINK
        https://github.com/AsBuiltReport/
    #>
    #region Script Parameters
    [CmdletBinding()]
    param (
        [String[]] $Target,
        [PSCredential] $Credential,
        [String]$StylePath
    )

    # Import JSON Configuration for Options and InfoLevel
    $InfoLevel = $ReportConfig.InfoLevel
    $Options = $ReportConfig.Options

    # If custom style not set, use default style
    if (!$StylePath) {
        & "$PSScriptRoot\..\..\AsBuiltReport.VMware.Horizon.Style.ps1"
    }

    # You will need to close this loop. Basically all your code should go within this loop so that you can specify multiple Horizon servers
    foreach ($HVServer in $Target) {} #move this brack to the end when you're done cleaning up your code
    
        Try { 
            $script:HvServer = Connect-HVServer $HVServer -Credential $Credential -ErrorAction Stop 
        } Catch { 
            Write-Error $_
        }

    $script:HvServer = $null
    #$hvServer = Connect-HVServer -Server test -User user -Password pass -Domain domain
    $Global:hvServices = $hvServer.ExtensionData
    $csService = New-Object VMware.Hv.ConnectionServerService
    $CSList = $CSService.ConnectionServer_List($hvServices)


    $ViewAPI = $global:DefaultHVServers.ExtensionData
    $ViewAPICS = @($ViewAPI.ConnectionServer.ConnectionServer_List().general)

    

        #Gather information about the HHorizon environment which are used in later sections within the script
            $script:vCenter = Get-HVvCenterServer
            $ViewComposerAccount = $ViewAPI.ViewComposerDomainAdministrator.ViewComposerDomainAdministrator_List($vCenter.Id)

        #----------------------------------------------------------------------------------------------------#
        #                Horizon POD Settings                                                                #
        #----------------------------------------------------------------------------------------------------#

        $ViewPod = $ViewAPI.pod.Pod_Get((($ViewAPI.Site.Site_List()).pods | select -First 1))


        #----------------------------------------------------------------------------------------------------#
        #                Horizon vCenter Settngs                                                             #
        #----------------------------------------------------------------------------------------------------#
        #Create major section in the output file for View Configuration
            Section -Style Heading2 'Horizon Servers' {
                Paragraph 'The following section provides a summary of the VMware vCenter Servers.'
                BlankLine
                #Provide a summary of the vCenter Environment
                    Section -Style Heading2 'vCenter Server Settings' {
                            $vCenterSummary = [PSCustomObject] @{
                                'vCenter Hostname' = $vCenter.ServerSpec.Servername
                                'vCenter Version' = $global:DefaultHVServers.ExtensionData.VirtualCenterHealth.VirtualCenterHealth_List().Data.Version
                                'VCenter Build' = $global:DefaultHVServers.ExtensionData.VirtualCenterHealth.VirtualCenterHealth_List().Data.Build
                                'vCenter API Version' = $global:DefaultHVServers.ExtensionData.VirtualCenterHealth.VirtualCenterHealth_List().Data.ApiVersion
                                'Username' = $vCenter.ServerSpec.Username
                                'Description' = $vCenter.Description
                                'Port' = $vCenter.ServerSpec.Port
                                'SSL' = $vCenter.ServerSpec.UseSSL
                                'Server Type' = $vCenter.ServerSpec.ServerType
                            }
                        }
                        $vCenterSummary | Table -Name 'vCenter Server Settings'
                    
                
                        Section -Style Heading3 'vCenter Advanced Settings' {
                                    $vCenterAdvanced = [PSCustomObject] @{
                                        'Max concurrent vCenter provisioning operations'= $vCenter.Limits.VcProvisioningLimit
                                        'Max concurrent power operations' = $vCenter.Limits.VcPowerOperationsLimit
                                        'Max concurrent View Composer maintenance operations' = $vCenter.Limits.ViewComposerMaintenanceLimit
                                        'Max concurrent View Composer provisioning operations' = $vCenter.Limits.ViewComposerProvisioningLimit
                                        'Max concurrent Instant Clone Engine provisioning operations'= $vCenter.Limits.InstantCloneEngineProvisioningLimit
                                    }
                                }
                                $vCenterAdvanced | Table -Name 'vCenter Advanced Settings'
                
                #Provide a summary of the Composer Settings
                Section -Style Heading2 'Composer Info' {
                            $ComposerSummary = [PSCustomObject] @{
                                'Version' =  $global:DefaultHVServers.ExtensionData.ViewComposerHealth.ViewComposerHealth_List().Data.Version
                                'Build' =  $global:DefaultHVServers.ExtensionData.ViewComposerHealth.ViewComposerHealth_List().Data.Build
                                'Api Version' = $global:DefaultHVServers.ExtensionData.ViewComposerHealth.ViewComposerHealth_List().Data.ApiVersion
                                'Min VC Version' = $global:DefaultHVServers.ExtensionData.ViewComposerHealth.ViewComposerHealth_List().Data.MinVCVersion
                                'Min Esx Version' =  $global:DefaultHVServers.ExtensionData.ViewComposerHealth.ViewComposerHealth_List().Data.MinEsxVersion
                                            }
                        }
                        $ComposerSummary | Table -Name 'Composer Info'
                    
                
                        Section -Style Heading3 'vCenter Composer Settings' {
                                    $ComposerSettings = [PSCustomObject] @{
                                        'Enabled' = $vCenter.ViewComposerData.ViewComposerType
                                        'Server Address' = $vCenter.ViewComposerData.ServerSpec.ServerName
                                        'Username' = $vCenter.ViewComposerData.ServerSpec.UserName
                                        'Port' = $vCenter.ViewComposerData.ServerSpec.Port
                                        'SSl Enabled' = $vCenter.ViewComposerData.ServerSpec.UseSSL

                                    }
                                }
                                $ComposerSettings | Table -Name 'vCenter Composer Settings'
                

                        Section -Style Heading3 'vCenter Composer Settings' {
                                            $ComposerDomainSettings = [PSCustomObject] @{
                                                'Domain(s)' = $ViewComposerAccount.base.Domain
                                                'Service Account' = $ViewComposerAccount.base.UserName

                                            }
                                        }
                                        $ComposerDomainSettings | Table -Name 'vCenter Composer Settings'
                                        }
                

                #Provide a summary of the vCenter Environment
                    Section -Style Heading3 'vCenter Configuration' {
                            $vCenterSummary = [PSCustomObject] @{
                                'ESXi Hosts' =  $global:DefaultHVServers.ExtensionData.VirtualCenterHealth.VirtualCenterHealth_List().HostData.Name
                                'ESXi Version' =  $global:DefaultHVServers.ExtensionData.VirtualCenterHealth.VirtualCenterHealth_List().HostData.Version
                                'ESXi Status' =  $global:DefaultHVServers.ExtensionData.VirtualCenterHealth.VirtualCenterHealth_List().HostData.Status
                                'Cluster' = $global:DefaultHVServers.ExtensionData.VirtualCenterHealth.VirtualCenterHealth_List().HostData.ClusterName
                                'vGPU Type' =  $global:DefaultHVServers.ExtensionData.VirtualCenterHealth.VirtualCenterHealth_List().HostData.VGPUTypes
                            }
                        $vCenterSummary | Table -Name 'vCenter Information'
                    }
                


                
                #----------------------------------------------------------------------------------------------------#
                #                Horizon vCenter Storage Settings                                                    #
                #----------------------------------------------------------------------------------------------------#



                #Provide summary of the vCenter Storage Settings
                Section -Style Heading3 'vCenter Storage Settings' {
                    $vCenterStorageSettings = [PSCustomObject] @{
                        'Reclaim VM disk Space' = $vCenter.SeSparseReclamationEnabled
                        'Host Cache Enabled' = $vCenter.StorageAcceleratorData.Enabled
                        'Default Host Cache' = $vCenter.StorageAcceleratorData.DefaultCacheSizeMB
                        'Host Cache Overrides' = $vCenter.StorageAcceleratorData.HostOverrides
                            }
                        $vCenterStorageSettings | Table -Name 'vCenter Storage Settings'
                    }


                #----------------------------------------------------------------------------------------------------#
                #                Horizon Security Server Settings                                                    #
                #----------------------------------------------------------------------------------------------------#







                #----------------------------------------------------------------------------------------------------#
                #                Horizon UAG Settings                                                                #
                #----------------------------------------------------------------------------------------------------#
<#

                $RAWUAG1 = Get-Content -Raw -path .\UAG1.json | ConvertFrom-Json
                $RAWUAG2 = Get-Content -Raw -path .\UAG2.json | ConvertFrom-Json


                # 3 NIC Deployment

                UAG General Settings

                'Internet IP' = $RAWUAG1.generalSettings.ip0
                'Internet Subnet' = $RAWUAG1.generalSettings.netmask0
                'Gateway' = $RAWUAG1.generalSettings.defaultGateway
                'Management IP' = $RAWUAG1.generalSettings.ip1
                'Management Subnet' = $RAWUAG1.generalSettings.netmask1

                'Backend IP' = $RAWUAG1.generalSettings.ip2
                'Backend Subnet' = $RAWUAG1.generalSettings.netmask2

                'DNS' = $RAWUAG1.generalSettings.DNS

                Edge Service Settings

                Horizon Settings
                'Enabled' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.enabled
                'Identifier' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.Identifier
                'Connection Server URL' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.proxyDestinationUrl
                'Connection Server URL Thumbprint' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.proxyDestinationUrlThumbprints
                'Health Check URL' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.healthCheckUrl
                'Enable PCoIP' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.pcoipEnabled
                'PCoIP External URL' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.pcoipExternalUrl
                'Enabled Blast' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.blastEnabled
                'Blast External URL' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.blastExternalUrl
                'Enabled UDP Blast Tunnel' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.tunnelEnabled
                'Blast Tunnel External URL' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.tunnelExternalUrl
                'Proxy Pattern' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.proxyPattern
                'SmartCard Hint Prompt ' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.smartCardHintPrompt 
                'Windows UserName Match' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.matchWindowsUserName
                'Location' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.gatewayLocation
                'Windows SSO' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.windowsSSOEnabled
                'Blast UDP Tunnel' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.udpTunnelServerEnabled
                'Disable Html Access' = $RAWUAG1.edgeServiceSettingsList.edgeServiceSettingsList.disableHtmlAccess

                Reverse Proxt Settings

                VMware Tunnel Settings

                Content Gateway Settings

                System Configuration

                'UAG Name' =$RAWUAG1.systemSettings.uagName
                'Location' = $RAWUAG1.systemSettings.locale
                'Admin Password Expires' = $RAWUAG1.systemSettings.adminPasswordExpirationDays
                'License version' = $RAWUAG1.systemSettings.licenseEdition
                'TLS 1.0 Enabled' = $RAWUAG1.systemSettings.tls10Enabled
                'TLS 1.1 Enabled' = $RAWUAG1.systemSettings.tls11Enabled
                'TLS 1.2 Enabled' = $RAWUAG1.systemSettings.tls12Enabled
                'Syslog URL' = $RAWUAG1.systemSettings.syslogUrl
                'Health Check URL' = $RAWUAG1.systemSettings.healthCheckUrl
                'Cookies To Be Cached' = $RAWUAG1.systemSettings.cookiesToBeCached
                'Quiesce Mode' = $RAWUAG1.systemSettings.quiesceMode
                'Monitor Interval' = $RAWUAG1.systemSettings.monitorInterval
                'Authentication Timeout' = $RAWUAG1.systemSettings.authenticationTimeout
                'Body Receive Timeout' = $RAWUAG1.systemSettings.bodyReceiveTimeoutMsec
                'Client Connection idel Timeout' = $RAWUAG1.systemSettings.clientConnectionIdleTimeout
                'Request Timeout ms' = $RAWUAG1.systemSettings.requestTimeoutMsec
                'Session Time Out' = $RAWUAG1.systemSettings.sessionTimeout


                High Availability Settings
                'Mode' = $RAWUAG1.loadBalancerSettings.loadBalancerMode
                'Virtual IP Address' = $RAWUAG1.loadBalancerSettings.virtualIPAddress
                'Group ID' = $RAWUAG1.loadBalancerSettings.groupID


#>





     





                #----------------------------------------------------------------------------------------------------#
                #                Horizon Connection Settings                                                         #
                #----------------------------------------------------------------------------------------------------#
   
                        Section -Style Heading2 'Horizon As Built Configuration' {
                            Paragraph 'VMware Horizon Connection Server(s) configuration.'
                            BlankLine
                            #Provide a summary of the Horizon Environment
                                $HorizonConnectionSettings = foreach ($CS in $CSList) {
                                    [PSCustomObject] @{
                                        'Host Name' = $CS.General.Name
                                        'Server Address' = $CS.General.ServerAddress                    
                                        'Enabled' = $CS.General.Enabled
                                        'Tags' = $cs.General.Tags             
                                        'External URL' = $cs.General.ExternalURL
                                        'External PCoIP URL' = $cs.General.ExternalPCoIPURL
                                        'AuxillaryExternalPCoIPIPv4Address' = $cs.General.AuxillaryExternalPCoIPIPv4Address
                                        'External App Blast URL' = $cs.General.ExternalAppblastURL
                                        'Local Connection Server' = $cs.General.LocalConnectionServer
                                        'Bypass Tunnel' = $cs.General.BypassTunnel
                                        'Bypass PCoIP Gateway' = $cs.General.BypassPCoIPGateway
                                        'Bypass AppBlast Gateway' = $cs.General.BypassAppBlastGateway
                                        'Version' = $cs.General.Version
                                        'IpMode' = $cs.General.IpMode
                                        'FipsModeEnabled' = $cs.General.FipsModeEnabled
                                        'FQDN' = $cs.General.Fqhn
                                    }}
                            $HorizonConnectionSettings | Table -Name 'Horizon Connection Server(s)'
                        }
                    

                    Section -Style Heading3 'Syslog' {

                                    $Syslog = $ViewAPI.Syslog.Syslog_Get()
                                    $SyslogHash =@()
                                    $SyslogHash =[PSCustomObject]@{
                                                'Syslog Enabled' = $Syslog.UdpData.Enabled
                                                'Syslog Server' = $Syslog.UdpData.NetworkAddresses
                                                'Syslog File Enabled' = $Syslog.FileData.Enabled
                                                'Path' =$Syslog.FileData.UncPath
                                                'UserName' = $Syslog.FileData.UncUserName
                                                'Domain' = $Syslog.FileData.UncDomain
                                    }
                                $SyslogHash |Table -Name 'Syslog Information'

                }

                $document | Export-Document -Path .\ -Format Word,Html,Text -Verbose;







    foreach ($HZCS in $ViewAPICS) {
        $ViewAPICS.fqhn
        Write-Host "This is $_."
        } 
    }