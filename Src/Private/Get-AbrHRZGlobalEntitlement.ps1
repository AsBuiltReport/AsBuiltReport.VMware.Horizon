function Get-AbrHRZGlobalEntitlement {
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
        Write-PScriboMessage "Global Entitlements InfoLevel set at $($InfoLevel.Inventory.GlobalEntitlements)."
        Write-PscriboMessage "Collecting Global Entitlements information."
    }

    process {
        try {
            if ($GlobalEntitlements) {
                if ($InfoLevel.Inventory.GlobalEntitlements -ge 1) {
                    section -Style Heading4 "Global Entitlements" {
                        $OutObj = @()
                        foreach ($GlobalEntitlement in $GlobalEntitlements) {
                            Write-PscriboMessage "Discovered Global Entitlements Information."
                            $GlobalEntitlementPodCount = ($GlobalEntitlement.data.memberpods.id).count
                            $inObj = [ordered] @{
                                'Entitlement Name' = $GlobalEntitlement.base.DisplayName
                                'Entitlement Type' = 'Desktop'
                                'Entitlement Number of Pods' = $GlobalEntitlementPodCount
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                        }

                        $TableParams = @{
                            Name = "Global Entitlements - $($HVEnvironment)"
                            List = $false
                            ColumnWidths = 50, 50
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