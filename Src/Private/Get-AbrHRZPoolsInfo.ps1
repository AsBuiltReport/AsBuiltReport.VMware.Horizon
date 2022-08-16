function Get-AbrHRZPoolsInfo {
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
        Write-PScriboMessage "Pool Desktop InfoLevel set at $($InfoLevel.Inventory.Desktop)."
        Write-PscriboMessage "Collecting Pool Desktop information."
    }

    process {
        try {
            $vCenterServers = try {$hzServices.VirtualCenter.VirtualCenter_List()} catch {Write-PscriboMessage -IsWarning $_.Exception.Message}
            try {
                # Pool Info
                $PoolQueryDefn = New-Object VMware.Hv.QueryDefinition
                $PoolQueryDefn.queryentitytype='DesktopSummaryView'
                $poolqueryResults = $Queryservice.QueryService_Create($hzServices, $PoolQueryDefn)
                $Pools = foreach ($poolresult in $poolqueryResults.results) {
                    $hzServices.desktop.desktop_get($poolresult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            }
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }
            try {
                # Base Images
                $BaseImageVMList = $vCenterServers | ForEach-Object  {$hzServices.BaseImageVM.BaseImageVM_List($_.id, $null)}
                $CompatibleBaseImageVMs = $BaseImageVMList | Where-Object {
                    ($_.IncompatibleReasons.InUseByDesktop -eq $false) -and
                    ($_.IncompatibleReasons.InUseByLinkedCloneDesktop -eq $false) -and
                    ($_.IncompatibleReasons.ViewComposerReplica -eq $false) -and
                    ($_.IncompatibleReasons.UnsupportedOS -eq $false) -and
                    ($_.IncompatibleReasons.NoSnapshots -eq $false) -and
                    (($null -eq $_.IncompatibleReasons.InstantInternal) -or ($_.IncompatibleReasons.InstantInternal -eq $false))
                }
            }
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }
            if ($Pools) {
                if ($InfoLevel.Inventory.Desktop -ge 1) {
                    section -Style Heading4 "Desktops" {
                        $OutObj = @()
                        foreach ($Pool in $Pools) {
                            Write-PscriboMessage "Discovered Role Provilege Information."
                            Switch ($Pool.Automateddesktopdata.ProvisioningType)
                            {
                                'INSTANT_CLONE_ENGINE' {$ProvisioningType = 'Instant Clone' }
                            }
                            $inObj = [ordered] @{
                                'Name' = $Pool.Base.Name
                                'User Assignment' = $Pool.Type
                                'Provisioning Type' = $ProvisioningType
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                        }

                        $TableParams = @{
                            Name = "Desktops - $($HVEnvironment)"
                            List = $false
                            ColumnWidths = 34, 33, 33
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'Name' | Table @TableParams
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