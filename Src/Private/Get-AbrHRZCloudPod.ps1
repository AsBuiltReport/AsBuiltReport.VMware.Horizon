function Get-AbrHRZCloudPod {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        1.1.4
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
        Write-PScriboMessage "Cloud Pod Architecture InfoLevel set at $($InfoLevel.Settings.CloudPodArch.CloudPodArch)."
        Write-PScriboMessage "Collecting Cloud Pod Architecture information."
    }

    process {
        try {
            if ($CloudPodFederation) {
                if ($InfoLevel.Settings.CloudPodArch.CloudPodArch -ge 1) {
                    Section -Style Heading2 "Cloud Pod Architecture" {
                        Paragraph "The following section details on the cloud pod architecture information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()
                        foreach ($CloudPodList in $CloudPodLists) {
                            if ($CloudPodList) {

                                # CP Site Info
                                $CloudPodSiteInfo = $hzServices.Site.Site_Get($CloudPodList.site)

                                # Connection Server Info
                                $CloudPodListEndpoints = $CloudPodList.Endpoints
                                $CloudPodListEndpointConnectionServerList = ''
                                foreach ($CloudPodListEndpoint in $CloudPodListEndpoints) {
                                    $CloudPodListEndpointConnectionServer = $hzServices.PodEndpoint.PodEndpoint_Get($CloudPodListEndpoint)
                                    $CloudPodListEndpointConnectionServerList += $CloudPodListEndpointConnectionServer.name -join "`r`n" | Out-String
                                }

                                # Active Global Entitlements
                                $CloudPodListActiveGlobalEntitlements = $CloudPodList.ActiveGlobalEntitlements
                                $CloudPodListActiveGlobalEntitlementList = ''
                                foreach ($CloudPodListActiveGlobalEntitlement in $CloudPodListActiveGlobalEntitlements) {
                                    $CloudPodListActiveGlobalEntitlementInfo = $hzServices.GlobalEntitlement.GlobalEntitlement_Get($CloudPodListActiveGlobalEntitlement)
                                    $CloudPodListActiveGlobalEntitlementList += $CloudPodListActiveGlobalEntitlementInfo.Base.DisplayName -join "`r`n" | Out-String
                                }

                                # Active Global Application Entitlements
                                $CloudPodListActiveGlobalApplicationEntitlements = $CloudPodList.ActiveGlobalApplicationEntitlements
                                $CloudPodListActiveGlobalApplicationEntitlementList = ''
                                foreach ($CloudPodListActiveGlobalApplicationEntitlement in $CloudPodListActiveGlobalApplicationEntitlements) {
                                    $CloudPodListActiveGlobalApplicationEntitlementInfo = $hzServices.GlobalApplicationEntitlement.GlobalApplicationEntitlement_Get($CloudPodListActiveGlobalApplicationEntitlement)
                                    $CloudPodListActiveGlobalApplicationEntitlementList += $CloudPodListActiveGlobalApplicationEntitlementInfo.Base.DisplayName -join "`r`n" | Out-String
                                }


                                Write-PScriboMessage "Discovered Cloud Pod Federation Information."
                                $inObj = [ordered] @{
                                    'Pod Name' = $CloudPodList.DisplayName
                                    'Pod Local' = $CloudPodList.Localpod
                                    'Pod Site' = $CloudPodSiteInfo.Base.DisplayName
                                    'Pod Description' = $CloudPodList.Description
                                    'Pod Cloud Managed' = $CloudPodList.CloudManaged
                                    'Pod Connection Servers' = $CloudPodListEndpointConnectionServerList
                                    'Pod Active Global Entitlements' = $CloudPodListActiveGlobalEntitlementList
                                    'Pod Active Global Application Entitlements' = $CloudPodListActiveGlobalApplicationEntitlementList
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                        }

                        $TableParams = @{
                            Name = "Cloud Pod Architecture - $($HVEnvironment.toUpper())"
                            List = $true
                            ColumnWidths = 50, 50
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