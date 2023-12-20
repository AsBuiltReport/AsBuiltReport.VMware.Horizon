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
                        Paragraph "The following section details on all of the machine information for $($HVEnvironment.toUpper())."
                        BlankLine
                        Write-PscriboMessage "Working on Machines Information for $($HVEnvironment.toUpper())."
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
                                Name         = "vCenter Machine Summary - $($HVEnvironment.toUpper())"
                                List         = $false
                                ColumnWidths = 15, 10, 20, 25, 15, 15
                            }
                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }
                            $OutObj | Table @TableParams
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