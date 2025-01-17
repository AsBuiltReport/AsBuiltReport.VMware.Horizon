function Get-AbrHRZHCEventDataBase {
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
        Write-PScriboMessage "Event Database Health Check InfoLevel set at $($HealthCheck.Components.EventDataBase)."
        Write-PScriboMessage "Event Database Health information."
    }

    process {
        try {
            if ($EventDataBaseHealth) {
                if ($HealthCheck.Components.EventDataBase) {
                     Section -Style Heading3 "Event Database Health Information" {
                        Paragraph "The following section details on the event database health information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()

                            if ($EventDataBaseHealth.configured -eq $true) {
                                Write-PScriboMessage "Event Database Status Information."
                                $inObj = [ordered] @{
                                    "Server name" = $EventDataBaseHealth.data.Servername;
                                    "Port" = $EventDataBaseHealth.data.Port;
                                    "Status" = $EventDataBaseHealth.data.State;
                                    "Username" = $EventDataBaseHealth.data.Username;
                                    "Database Name" = $EventDataBaseHealth.data.DatabaseName
                                    "Table Prefix" = $EventDataBaseHealth.data.TablePrefix;
                                    "State" = $EventDataBaseHealth.data.State;
                                    "Error" = $EventDataBaseHealth.data.Error;
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }


                        $TableParams = @{
                            Name = "Event Database Health Information - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 20, 8, 12, 16, 18, 8, 10, 10
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Table @TableParams
                    }
                }
            }
        } catch {
            Write-PScriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}
}