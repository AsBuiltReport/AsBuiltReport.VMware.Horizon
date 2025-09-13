function Get-AbrHRZHCDataStore {
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
        Write-PScriboMessage "Data Store Health Check InfoLevel set at $($HealthCheck.vSphere.DataStores)."
        Write-PScriboMessage "Data Store Health information."
    }

    process {
        try {
            if ($vCenterHealth) {
                if ($HealthCheck.vSphere.DataStores) {
                    Section -Style Heading3 "Data Store Health Information" {
                        Paragraph "The following section details on the data store health information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()
                        foreach ($VCHealth in $vCenterHealth){
                            foreach ($DSHealth in $VCHealth.DatastoreData){
                                Write-PScriboMessage "DataStore Health Status Information."
                                $inObj = [ordered] @{
                                    "Datastore" = $DSHealth.name;
                                    "Accessible" = $DSHealth.accessible;
                                    "Path" = $DSHealth.path;
                                    "Datastore Type" = $DSHealth.datastoreType;
                                    "Capacity MB" = $DSHealth.capacityMB;
                                    "Free Space MB" = $DSHealth.freeSpaceMB;
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                        }

                        $TableParams = @{
                            Name = "DataStore Health Information - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 20, 12, 28, 10, 15, 15
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