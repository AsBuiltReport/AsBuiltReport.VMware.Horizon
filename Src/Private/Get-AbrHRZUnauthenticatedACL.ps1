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
        Write-PScriboMessage "Home Site Assignments InfoLevel set at $($InfoLevel.UsersAndGroups.HomeSiteAssignments)."
        Write-PscriboMessage "Collecting Home Site General Information."
    }

    process {
        if ($InfoLevel.UsersAndGroups.HomeSiteAssignments -ge 1) {
            try {
                try {
                    # Unauthenticated Access
                    $unauthenticatedAccessList = $hzServices.UnauthenticatedAccessUser.UnauthenticatedAccessUser_List()
                }
                catch {
                    Write-PscriboMessage -IsWarning $_.Exception.Message
                }
                $OutObj = @()
                if ($unauthenticatedAccessList) {
                    if ($InfoLevel.UsersAndGroups.UsersAndGroups.UnauthenticatedAccess -ge 1) {
                        section -Style Heading2 "Unauthenticated Access General Information" {
                            foreach ($unauthenticatedAccess in $unauthenticatedAccessList) {
                                # User Info
                                $unauthenticatedAccessUserIDName = ''
                                if($unauthenticatedAccess.userdata.UserId){
                                    $unauthenticatedAccessUserID = $hzServices.ADUserOrGroup.ADUserOrGroup_Get($unauthenticatedAccess.userdata.UserId)
                                    $unauthenticatedAccessUserIDName = $unauthenticatedAccessUserID.Base.DisplayName
                                }
                                # Pod Info
                                $unauthenticatedAccessPodListName = ''
                                if($unauthenticatedAccess.sourcepods){
                                    $unauthenticatedAccessPodList = $hzServices.Pod.Pod_Get($unauthenticatedAccessList.sourcepods)
                                    $unauthenticatedAccessPodListName = $unauthenticatedAccessPodList.DisplayName
                                }
                                $inObj = [ordered] @{
                                    'Login Name' = $unauthenticatedAccess.userdata.LoginName
                                    'User ID' = $unauthenticatedAccessUserIDName
                                    'Description' = $unauthenticatedAccess.userdata.Description
                                    'Hybrid Logon Config' = $unauthenticatedAccess.userdata.HybridLogonConfig
                                    'Pod' = $unauthenticatedAccessPodListName
                                }
                                $OutObj += [pscustomobject]$inobj
                            }
                        }
                    }

                    $TableParams = @{
                        Name = "Home Site General - $($HVEnvironment)"
                        List = $false
                        ColumnWidths = 20, 20, 20, 20, 20
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
    end {}
}