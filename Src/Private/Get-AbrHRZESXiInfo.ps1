function Get-AbrHRZESXiInfo {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        0.2.0
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
        Write-PScriboMessage "Esxi Servers InfoLevel set at $($InfoLevel.Settings.Servers.vCenterServers.ESXiHosts)."
        Write-PscriboMessage "Collecting Esxi Servers information."
    }

    process {
        try {
            $vCenterHealth = try {$hzServices.VirtualCenterHealth.VirtualCenterHealth_List()} catch {Write-PscriboMessage -IsWarning $_.Exception.Message}
            if ($vCenterHealth) {
                if ($InfoLevel.Settings.Servers.vCenterServers.ESXiHosts -ge 1) {
                    section -Style Heading4 "ESXi Hosts Information" {
                        $ESXHosts = $vCenterHealth.hostdata
                        foreach ($ESXCLUSTER in ($ESXHosts.ClusterName | Select-Object -Unique)) {
                            section -ExcludeFromTOC -Style Heading5 "$($ESXCLUSTER) Hosts Summary" {
                                $OutObj = @()
                                try {
                                    foreach ($ESXHost in ($ESXHosts | Where-Object {$_.ClusterName -eq $ESXCLUSTER})) {
                                        Write-PscriboMessage "Discovered ESXI Server Information from $($ESXCLUSTER)."
                                        $inObj = [ordered] @{
                                            'Name' = $ESXHost.Name
                                            'Version' = $ESXHost.Version
                                            'API Version' = $ESXHost.APIVersion
                                            'Status' = $ESXHost.Status
                                        }

                                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                                    }
                                    if ($HealthCheck.ESXiHosts.Status) {
                                        $OutObj | Where-Object { $_.'Status' -ne 'CONNECTED'} | Set-Style -Style Warning
                                    }
                                }
                                catch {
                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                }

                                $TableParams = @{
                                    Name = "ESXI Hosts - $($ESXCLUSTER)"
                                    List = $false
                                    ColumnWidths = 25, 25, 25, 25
                                }

                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }
                                $OutObj | Sort-Object -Property 'Name' | Table @TableParams
                                try {
                                    if ($InfoLevel.Settings.Servers.vCenterServers.ESXiHosts -ge 2) {
                                        foreach ($ESXHost in ($ESXHosts | Where-Object {$_.ClusterName -eq $ESXCLUSTER})) {
                                            if ($ESXHost.Name) {
                                                try {
                                                    section -Style Heading5 "$($ESXHost.Name) Details" {
                                                        Write-PscriboMessage "Discovered ESXI Server Information from $($ESXHost.Name)."
                                                        $inObj = [ordered] @{
                                                            'Cpu Cores' = $ESXHost.NumCpuCores
                                                            'Cpu in Mhz' = $ESXHost.CpuMhz
                                                            'Memory Size' = "$([math]::round($ESXHost.MemorySizeBytes / 1GB))GB"
                                                            'VGPU Types' = $ESXHost.VGPUTypes
                                                            'VDI Machines' = $ESXHost.NumMachines
                                                        }

                                                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                                                        $TableParams = @{
                                                            Name = "ESXI Hosts - $($ESXHost.Name)"
                                                            List = $true
                                                            ColumnWidths = 50, 50
                                                        }

                                                        if ($Report.ShowTableCaptions) {
                                                            $TableParams['Caption'] = "- $($TableParams.Name)"
                                                        }
                                                        $OutObj | Table @TableParams
                                                    }
                                                }
                                                catch {
                                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                                }
                                            }
                                        }
                                    }
                                }
                                catch {
                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                }
                            }
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