function Get-AbrHRZUAG {
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
        Write-PScriboMessage "SecurityServers InfoLevel set at $($InfoLevel.Settings.Servers.vCenterServers.ADDomains)."
        Write-PscriboMessage "Collecting Security Servers information."
    }

    process {
        try {
            if ($GatewayServers) {
                if ($InfoLevel.Settings.Servers.UAG.UAGServers -ge 1) {
                    section -Style Heading4 "UAG Servers" {
                        Paragraph "The following section details the UAG Servers information for $($HVEnvironment.split('.')[0]) server."
                        BlankLine
                        $OutObj = @()
                        foreach ($GatewayServer in $GatewayServers.GeneralData) {
                            try {
                                Write-PscriboMessage "Discovered UAG Information $($GatewayServer.Name)."
                                Switch ($GatewayServer.Type)
                                {
                                    'AP' {$GatewayType = 'UAG' }
                                }
                                $inObj = [ordered] @{
                                    'Name' = $GatewayServer.Name
                                    'IP' = $GatewayServer.Address
                                    'Version' = $GatewayServer.Version
                                    'Type' = $GatewayType
                                    'Zone Internal' = $GatewayServer.GatewayZoneInternal
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "UAG Servers - $($HVEnvironment.split(".").toUpper()[0])"
                            List = $false
                            ColumnWidths = 35, 20, 15, 15, 15
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