function Get-AbrHRZHCGatewayServer {
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
        Write-PScriboMessage "Gateway Server Health Check InfoLevel set at $($HealthCheck.Components.GatewayServer)."
        Write-PScriboMessage "Gateway Server Health information."
    }

    process {
        try {
            if ($GatewayServers) {
                if ($HealthCheck.Components.GatewayServer) {
                     Section -Style Heading3 "Gateway Server Health Information" {
                        Paragraph "The following section details on the gateway server health information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()
                        foreach ($GWServer in $GatewayServers) {
                            if ($GWServer) {
                                $Gatewayhealth = $hzServices.GatewayHealth.GatewayHealth_Get($GWServer.id)
                                $lastcontact = (([System.DateTimeOffset]::FromUnixTimeMilliSeconds(($Gatewayhealth.LastUpdatedTimestamp)).DateTime).ToString("s"))
                                Switch ($Gatewayhealth.GatewayZoneInternal) {
                                    "False" {$GateayZoneType = "External"}
                                    "True" {$GateayZoneType = "Internal"}
                                    Default{$GateayZoneType = "Lost"}
                                }
                                Switch ($Gatewayhealth.type) {
                                    "AP" {$GWType = "UAG"}
                                    "F5" {$GWType = "F5 Load Balanced"}
                                    Default {$GWType = "Unknown"}
                                }

                                Write-PScriboMessage "Gateway Server Status Information."
                                $inObj = [ordered] @{
                                    "UAG Name" = $Gatewayhealth.name;
                                    "UAG Address" = $Gatewayhealth.Address;
                                    "UAG Zone" = $GateayZoneType;
                                    "UAG Version" = $Gatewayhealth.Version;
                                    "UAG Type" = $GWType;
                                    "UAG Active" = $Gatewayhealth.GatewayStatusActive;
                                    "UAG Stale" = $Gatewayhealth.GatewayStatusStale;
                                    "UAG Contacted" = $Gatewayhealth.GatewayContacted;
                                    "UAG Last Contact" = $lastcontact;
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                        }

                        $TableParams = @{
                            Name = "Gateway Server Health Information - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 16, 10, 10, 10, 12, 8, 8, 12, 14
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Table @TableParams

                        #<#
                        $OutObj = @()
                        foreach ($GWServer in $GatewayServers) {
                            if ($GWServer) {
                                $Gatewayhealth = $hzServices.GatewayHealth.GatewayHealth_Get($GWServer.id)
                                Write-PScriboMessage "Gateway Server Connection Stats Information."
                                $inObj = [ordered] @{
                                    "UAG Name" = $Gatewayhealth.name;
                                    "UAG Active Connections" = $Gatewayhealth.ConnectionData.NumActiveConnections;
                                    "UAG Blast Connections" = $Gatewayhealth.ConnectionData.NumBlastConnections;
                                    "UAG PCOIP Connections" = $Gatewayhealth.ConnectionData.NumPcoipConnections;
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                        }

                        $TableParams = @{
                            Name = "Gateway Server Health Connection Stats Information - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 25, 25, 25, 25
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Table @TableParams
                    #>
                    }
                }
            }
        } catch {
            Write-PScriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}
}