function Get-AbrHRZHCRDSFarm {
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
        Write-PScriboMessage "RDS Farms Health Check InfoLevel set at $($HealthCheck.RDSFarms.RDSFarms)."
        Write-PScriboMessage "RDS Farms Health information."
    }

    process {
        try {
            if ($farms) {
                if ($HealthCheck.RDSFarms.RDSFarms) {
                     Section -Style Heading3 "RDS Farms Health Information" {
                        Paragraph "The following section details on the RDS farms health information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()
                        foreach ($Farm in $Farms) {
                            if ($Farm) {
                                $health=$hzServices.Farmhealth.farmhealth_get($farm.id)
                                $farmhealthstatus = $health.health
                                $farmname = $farm.data.name
                                Write-PScriboMessage "RDS Farms Status Information."
                                $inObj = [ordered] @{
                                    "Farm Name" = $farmname;
                                    "Farm Health" = $farmhealthstatus;
                                    "RDS Hostname" = $rdsserver.name;
                                    "RDS Status" = $rdsserver.status;
                                    "RDS health" = $rdsserver.health;
                                    "RDS Available" = $rdsserver.available;
                                    "RDS Missing Apps" = $missingapps;
                                    "RDS Load Preference" = $rdsserver.LoadPreference;
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                        }

                        $TableParams = @{
                            Name = "RDS Farms Health Information - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 14, 8, 16, 8, 12, 10, 10, 12, 12
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