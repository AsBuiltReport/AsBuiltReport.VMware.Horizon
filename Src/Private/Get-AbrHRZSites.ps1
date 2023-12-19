function Get-AbrHRZSites {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        1.1.0
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
        Write-PScriboMessage "Site InfoLevel set at $($InfoLevel.Settings.Sites.Sites)."
        Write-PscriboMessage "Collecting Cloud Pod Site information."
    }

    process {
        try {
            if ($CloudPodSites) {
                if ($InfoLevel.Settings.Sites.Sites -ge 1) {
                    section -Style Heading2 "Site" {
                        Paragraph "The following section details on the Cloud Pod Site information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()
                        foreach($CloudPodSite in $CloudPodSites) {

                            # Find CloudPod Info
                            foreach($CloudPodList in $CloudPodLists) {
                                if($CloudPodList.Id.id -eq $CloudPodSite.pods.id){
                                    $CloudPodDisplayName = $CloudPodList.DisplayName
                                    break
                                } # if($AccessGroup.Id.id -eq $RDSServers.base.accessgroup.id)
                            } # Close out foreach($AccessGroup in $AccessGroups)


                            Write-PscriboMessage "Discovered Site Information."
                            $inObj = [ordered] @{
                                'Cloud Pod Sites Name' = $CloudPodSite.base.DisplayName
                                'Cloud Pod Sites Description' = $CloudPodSite.base.Description
                                'Cloud Pod Site Pod Name' = $CloudPodDisplayName
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                        }

                        $TableParams = @{
                            Name = "Site - $($HVEnvironment.toUpper())"
                            List = $true
                            ColumnWidths = 50, 50
                        }

                        if ($Report.ShowTableCaptions) {
                            #$TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Table @TableParams
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