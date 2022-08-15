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
                        $GlobalEntitlementJoined = @()
                        $GlobalEntitlementJoined += $GlobalEntitlements
                        $GlobalEntitlementJoined += $GlobalApplicationEntitlementGroups
                        $OutObj = @()
                        foreach ($GlobalEntitlement in $GlobalEntitlementJoined) {
                            Write-PscriboMessage "Discovered Global Entitlements Information."
                            $GlobalEntitlementPodCount = ($GlobalEntitlement.data.memberpods.id).count
                            if ($GlobalEntitlement.Data.LocalApplicationCount) {
                                $Type = 'Application'
                            }
                            elseif ($GlobalEntitlement.Data.LocalDesktopCount) {
                                $Type = 'Desktop'
                            }
                            $inObj = [ordered] @{
                                'Name' = $GlobalEntitlement.base.DisplayName
                                'Type' = $Type
                                'Number of Pods' = $GlobalEntitlementPodCount
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                        }

                        $TableParams = @{
                            Name = "Global Entitlements - $($HVEnvironment)"
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