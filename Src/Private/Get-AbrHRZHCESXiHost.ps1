function Get-AbrHRZHCESXiHost {
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
        Write-PScriboMessage "ESXi Health Check InfoLevel set at $($HealthCheck.vSphere.ESXiHosts)."
        Write-PScriboMessage "ESXi Health information."
    }

    process {
        try {
            if ($vCenterHealth) {
                if ($HealthCheck.vSphere.ESXiHosts) {
                    Section -Style Heading3 "ESXi Health Information" {
                        Paragraph "The following section details on the ESXi health information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()
                        foreach ($VCHealth in $vCenterHealth){
                            foreach ($ESXiHost in $VCHealth.hostData){
                                if ($esxihost.vGPUTypes){
                                    $vGPUTypes= [system.String]::Join(",", $ESXiHost.vGPUTypes)
                                }
                                else{
                                    $vGPUTypes="n/a"
                                }
                                Write-PScriboMessage "ESXi Health Status Information."
                                $inObj = [ordered] @{
                                    "ESXi Host" = $ESXiHost.name;
                                    "Version" = $ESXiHost.version;
                                    "API Version" = $ESXiHost.apiVersion;
                                    "Status" = $ESXiHost.status;
                                    "cluster Name" = $ESXiHost.clusterName;
                                    "vGPU Types" = $vGPUTypes;
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                        }

                        $TableParams = @{
                            Name = "ESXi Health Information - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 30, 10, 10, 20, 15, 15
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