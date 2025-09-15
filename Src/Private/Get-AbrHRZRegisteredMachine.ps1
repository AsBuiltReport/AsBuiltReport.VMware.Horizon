function Get-AbrHRZRegisteredMachine {
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
        Credits:        Iain Brighton (@iainbrighton) - PScribo module


    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon
    #>

    [CmdletBinding()]
    param (
    )

    begin {
        Write-PScriboMessage "RegisteredMachines InfoLevel set at $($InfoLevel.Settings.RegisteredMachines.RDSHosts)."
        Write-PScriboMessage "Collecting Registered Machines information."
    }

    process {
        try {
            if ($RDSServers) {
                if ($InfoLevel.Settings.RegisteredMachines.RDSHosts -ge 1) {
                    Section -Style Heading2 "Registered Machines" {
                        Paragraph "The following section provides information of Registered Machines for $($HVEnvironment.toUpper()) server."
                        BlankLine
                        Section -Style Heading3 'RDS Hosts' {
                            Paragraph "The following section details the RDS Hosts configuration for $($HVEnvironment.toUpper()) server."
                            BlankLine
                            $OutObj = @()
                            foreach ($RDSServer in $RDSServers) {
                                Write-PScriboMessage "Discovered RDS Hosts Information."
                                $inObj = [ordered] @{
                                    'Name' = $RDSServer.base.name
                                    'Farm Name' = $RDSServer.SummaryData.FarmName
                                    'Status' = $RDSServer.runtimedata.Status
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }

                            if ($HealthCheck.RDSFarms.RDSFarms) {
                                $OutObj | Where-Object { $_.'Status' -ne 'AVAILABLE' } | Set-Style -Style Warning
                            }

                            $TableParams = @{
                                Name = "RDS Hosts - $($HVEnvironment.toUpper())"
                                List = $false
                                ColumnWidths = 34, 33, 33
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }
                            $OutObj | Table @TableParams
                            try {
                                if ($InfoLevel.Settings.RegisteredMachines.RDSHosts -ge 2) {
                                    Section -Style Heading4 'RDS Hosts Details' {
                                        foreach ($RDSServer in $RDSServers) {
                                            Write-PScriboMessage "Discovered RDS Host $($RDSServer.base.name) Information."
                                            $OutObj = @()
                                            Section -ExcludeFromTOC -Style NOTOCHeading6 $RDSServer.Base.Name {
                                                $inObj = [ordered] @{
                                                    'Name' = $RDSServer.base.name
                                                    'Description' = $RDSServer.base.Description
                                                    'Farm Name' = $RDSServer.SummaryData.FarmName
                                                    'Desktop Pool Name' = $RDSServer.SummaryData.DesktopName
                                                    'Farm Type' = $RDSServer.SummaryData.FarmType
                                                    'Access Group' = $RDSServerAccessgroup
                                                    'Message Security Mode' = $RDSServer.MessageSecurityData.MessageSecurityMode
                                                    'Message Security Enhanced Mode Supported' = $RDSServer.MessageSecurityData.MessageSecurityEnhancedModeSupported
                                                    'Operating System' = $RDSServer.agentdata.OperatingSystem
                                                    'Agent Version' = $RDSServer.agentdata.AgentVersion
                                                    'Agent Build Number' = $RDSServer.agentdata.AgentBuildNumber
                                                    'Remote Experience Agent Version' = $RDSServer.agentdata.RemoteExperienceAgentVersion
                                                    'Remote Experience Agent Build Number' = $RDSServer.agentdata.RemoteExperienceAgentBuildNumber
                                                    'Max Sessions Type' = $RDSServer.settings.SessionSettings.MaxSessionsType
                                                    'Max Sessions Set By Admin' = $RDSServer.settings.SessionSettings.MaxSessionsSetByAdmin
                                                    'Agent Max Sessions Type' = $RDSServer.settings.AgentMaxSessionsData.MaxSessionsType
                                                    'Agent Max Sessions Set By Admin' = $RDSServer.settings.AgentMaxSessionsData.MaxSessionsSeenByAgent
                                                    'Enabled' = $RDSServer.settings.enabled
                                                    'Status' = $RDSServer.runtimedata.Status
                                                }
                                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                                                $TableParams = @{
                                                    Name = "RDS Host - $($RDSServer.base.name)"
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
                            } catch {
                                Write-PScriboMessage -IsWarning $_.Exception.Message
                            }

                            if ($RegisteredPhysicalMachines) {
                                Section -Style Heading3 'Others' {
                                    Paragraph "The following section details the RDS Hosts configuration for $($HVEnvironment.toUpper()) server."
                                    BlankLine
                                    $OutObj = @()
                                    foreach ($RegisteredPhysicalMachine in $RegisteredPhysicalMachines) {
                                        Write-PScriboMessage "Other Registerd Machines"
                                        $inObj = [ordered] @{
                                            'Name' = $RegisteredPhysicalMachines.MachineBase.name
                                            'DNS Name' = $RegisteredPhysicalMachines.MachineBase.DnsName
                                            'Description' = $RegisteredPhysicalMachines.MachineBase.Description
                                            'OperatingSystem' = $RegisteredPhysicalMachines.MachineBase.Description
                                        }
                                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                    }
                                    if ($HealthCheck.RDSFarms.RDSFarms) {
                                        $OutObj | Where-Object { $_.'Status' -ne 'AVAILABLE' } | Set-Style -Style Warning
                                    }
                                    $TableParams = @{
                                        Name = "Other Registered Machines - $($HVEnvironment.toUpper())"
                                        List = $false
                                        ColumnWidths = 20, 20, 30, 30
                                    }
                                    if ($Report.ShowTableCaptions) {
                                        $TableParams['Caption'] = "- $($TableParams.Name)"
                                    }
                                }
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