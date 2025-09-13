function Get-AbrHRZInfrastructure {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        1.1.5
        Author:         Chris Hildebrandt, Karl Newick
        Twitter:        @childebrandt42, @karlnewick
        Editor:         Jonathan Colon, @jcolonfzenpr, Chris Hildebrandt
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
        Write-PScriboMessage "Collecting Infrastructure Summary information."
    }

    process {
        try {
            Section -Style NOTOCHeading4 "Executive Summary for $($HVEnvironment.toUpper())" {
                $OutObj = @()
                Write-PScriboMessage "Discovered Infrastructure Summary Information."
                $inObj = [ordered] @{
                    'Number of Local Entitlements' = $EntitledUserOrGroupLocalMachines.Count
                    'Number of Global Entitlements' = $GlobalEntitlements.Count
                    'Number of Desktop Pools' = $Pools.Count
                    'Number of Application Pool' = $Apps.Count
                    'Number of Farms Pools' = $Farms.Count
                    'Number of vCenter Servers' = $vCenterServers.Count
                    'Number of ESXi Hosts' = $Esxhosts.HostData.Count
                    'Number of Datastores' = $Datastores.DatastoreData.Count
                    'Number of Active Directory Domains' = $ADDomains.Count
                    'Number of UAG Servers' = $GatewayServers.Count
                    'Number of Connection Servers' = $connectionservers.Count
                    'Number of Instant Clone Accounts' = $InstantCloneDomainAdmins.Count
                    'Number of RDS Hosts' = $RDSServers.Count
                    'Number of Administrators and Groups' = $Administrators.Count
                }

                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                $TableParams = @{
                    Name = "Executive Summary  - $($HVEnvironment.toUpper())"
                    List = $true
                    ColumnWidths = 50, 50
                }

                if ($Report.ShowTableCaptions) {
                    $TableParams['Caption'] = "- $($TableParams.Name)"
                }
                $OutObj | Table @TableParams
            }
        } catch {
            Write-PScriboMessage -IsWarning $_.Exception.Message
        }
    }
    end {}
}