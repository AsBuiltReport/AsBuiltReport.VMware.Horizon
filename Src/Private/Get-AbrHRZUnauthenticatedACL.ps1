function Get-AbrHRZUnauthenticatedACL {
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
        Write-PScriboMessage "UnauthenticatedAccess InfoLevel set at $($InfoLevel.UsersAndGroups.UnauthenticatedAccess)."
        Write-PscriboMessage "Collecting Unauthenticated Access Information."
    }

    process {
        if ($InfoLevel.UsersAndGroups.UnauthenticatedAccess -ge 1) {
            try {
                if ($unauthenticatedAccessList) {
                    section -Style Heading3 "Unauthenticated Access" {
                        Paragraph "The following section provide a summary of user and group unauthenticated access configuration."
                        BlankLine
                        $OutObj = @()
                        foreach ($unauthenticatedAccess in $unauthenticatedAccessList) {
                            try {
                                # User Info
                                try {
                                    $unauthenticatedAccessUserIDName = ''
                                    if ($unauthenticatedAccess.userdata.UserId) {
                                        $unauthenticatedAccessUserID = $hzServices.ADUserOrGroup.ADUserOrGroup_Get($unauthenticatedAccess.userdata.UserId)
                                        $unauthenticatedAccessUserIDName = $unauthenticatedAccessUserID.Base.DisplayName
                                    }
                                }
                                catch {
                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                }
                                # Pod Info
                                try {
                                    $unauthenticatedAccessPodListName = ''
                                    if ($unauthenticatedAccess.SourcePods) {
                                        $unauthenticatedAccessPodList = $CloudPodLists | Where-Object {$_.id.id -eq $unauthenticatedAccess.SourcePods.Id}
                                        $unauthenticatedAccessPodListName = $unauthenticatedAccessPodList.DisplayName
                                    }
                                }
                                catch {
                                    Write-PscriboMessage -IsWarning $_.Exception.Message
                                }

                                $inObj = [ordered] @{
                                    'Login Name' = $unauthenticatedAccess.userdata.LoginName
                                    'User ID' = $unauthenticatedAccessUserIDName
                                    'Description' = $unauthenticatedAccess.userdata.Description
                                    'Hybrid Logon' = $unauthenticatedAccess.userdata.HybridLogonConfig
                                    'Pod Name' = $unauthenticatedAccessPodListName
                                }
                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                            catch {
                                Write-PscriboMessage -IsWarning $_.Exception.Message
                            }
                        }

                        $TableParams = @{
                            Name = "Unauthenticated Access - $($HVEnvironment.split(".").toUpper()[0])"
                            List = $false
                            ColumnWidths = 20, 20, 20, 20, 20
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }
                        $OutObj | Sort-Object -Property 'Login Name' | Table @TableParams
                    }
                }
            }
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }
        }
    }
    end {}
}