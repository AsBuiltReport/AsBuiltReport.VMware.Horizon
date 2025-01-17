function Get-AbrHRZHCRemotePod {
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
        Write-PScriboMessage "Remote Pod Health Check InfoLevel set at $($HealthCheck.RemotePod.RemotePod)."
        Write-PScriboMessage "Remote Pod Health information."
    }

    process {
        try {
            if ($CloudPodListsLocal) {
                if ($HealthCheck.RemotePod.RemotePod) {
                    Section -Style Heading3 "Remote Pod Health Information" {
                        Paragraph "The following section details on the Remote Pod health information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()
                        foreach ($pod in $CloudPodListsLocal){
                            if($pod){
                                $endpoints = $hzServices.podhealth.podhealth_get($pod.id).data.endpointhealth
                                $PodDetail = $hzServices.pod.pod_get($pod.id)
                                $PodName = $PodDetail.DisplayName
                                #$PodName = "Pod Name"
                                if($endpoints){
                                    foreach ($endpoint in $endpoints){

                                        Write-PScriboMessage "Remote Pod Health Status Information."
                                        $inObj = [ordered] @{
                                            "Status" = $endpoint.EndpointInfo | Select-Object -expandproperty Enabled;
                                            "Name" = $PodName;
                                            "Connection Servers" = $endpoint.EndpointInfo | Select-Object -expandproperty Name;
                                            "Description" = $endpoint | Select-Object -expandproperty State;
                                        }

                                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                    }
                                }
                            }
                            $pod = $null
                        }

                        $TableParams = @{
                            Name = "Remote Pod Health Information - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 10, 25, 25, 30
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