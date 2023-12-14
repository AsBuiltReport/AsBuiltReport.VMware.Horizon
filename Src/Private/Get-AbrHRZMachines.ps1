function Get-AbrHRZMachines {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        1.1.0
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
        Write-PScriboMessage "Machine InfoLevel set at $($InfoLevel.Inventory.Machines)."
        Write-PscriboMessage "Collecting Machine information."
    }

    process {
        try {
            if ($Machines) {
                if ($InfoLevel.Inventory.Machines -ge 1) {
                    section -Style Heading3 "Machines" {
                        Paragraph "The following section details on all of the machine information for $($HVEnvironment)."
                        BlankLine
                                                                       
                        Write-PscriboMessage "Working on Machines Information for $($HVEnvironment)."
                        
                        section -Style Heading4 "vCenter Machine Summary" {
                            $OutObj = @()
                        
                            foreach ($Machine in $Machines) {
                                $inObj = [ordered] @{
                                    'Machine Name' = $Machine.Base.Name
                                    'Agent Version' = $Machine.Base.AgentVersion
                                    'User' = $Machine.Base.User
                                    'Host' = $Machine.ManagedMachineData.VirtualCenterData.Hostname
                                    'Data Store' = $Machine.ManagedMachineData.VirtualCenterData.VirtualDisks.DatastorePath
                                    'Basic State' = $Machine.Base.BasicState
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                        
                            $TableParams = @{ 
                                Name         = "vCenter Machine Summary - $($HVEnvironment)" 
                                List         = $false 
                                ColumnWidths = 15, 10, 20, 25, 15, 15 
                            } 
                            if ($Report.ShowTableCaptions) { 
                                $TableParams['Caption'] = "- $($TableParams.Name)" 
                            } 
                            $OutObj | Table @TableParams
                        }
                        <#
                        if ($InfoLevel.Inventory.Machines -ge 1) {

                            $OutObj = @()
                            #section -Style Heading4 "vCenter Machine Details" {
                                foreach ($Machine in $Machines) {
                                    $inObj = [ordered] @{
                                        'Machine Name' = $machine.base.Name
                                        'DNS Name' = $machine.base.DnsName
                                        'User' = $machine.base.User
                                        'Users' = $machine.base.Users
                                        'Aliases' = $machine.base.Aliases
                                        'Access Group' = $machine.base.AccessGroup
                                        'Desktop' = $machine.base.Desktop
                                        'Desktop Name' = $machine.base.DesktopName
                                        'Session' = $machine.base.Session
                                        'State' = $machine.base.BasicState
                                        'Type' = $machine.base.Type
                                        'Operating System' = $machine.base.OperatingSystem
                                        'System Architecture' = $machine.base.OperatingSystemArchitecture
                                        'Agent Build Version' = $machine.base.AgentVersion
                                        'Agent Build Number' = $machine.base.AgentBuildNumber
                                        'Remote Experence Agent Version' = $machine.base.RemoteExperienceAgentVersion
                                        'Remote Experence Agent Build' = $machine.base.RemoteExperienceAgentBuildNumber
                                        'Agent Upgrade' = $machine.base.AgentUpgradeInfo
                                    }
                                    $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                }
                            
                                $TableParams = @{ 
                                    Name         = "vCenter Machine Details - $($HVEnvironment)" 
                                    List         = $true 
                                    ColumnWidths =  60, 40
                                } 
                                if ($Report.ShowTableCaptions) { 
                                    $TableParams['Caption'] = "- $($TableParams.Name)" 
                                } 
                                $OutObj | Table @TableParams
                            #}
    
                        }
                        #>
    
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