# function Get-AbrHRZTemplate {
#     <#
#     .SYNOPSIS
#         PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
#     .DESCRIPTION
#         Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
#     .NOTES
#         Version:        0.2.0
#         Author:         Chris Hildebrandt, Karl Newick
#         Twitter:        @childebrandt42, @karlnewick
#         Editor:         Jonathan Colon, @jcolonfzenpr
#         Twitter:        @asbuiltreport
#         Github:         AsBuiltReport
#         Credits:        Iain Brighton (@iainbrighton) - PScribo module


#     .LINK
#         https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon
#     #>

#     [CmdletBinding()]
#     param (
#     )

#     begin {
#         Write-PScriboMessage "Home Site Assignments InfoLevel set at $($InfoLevel.UsersAndGroups.HomeSiteAssignments)."
#         Write-PscriboMessage "Collecting Home Site General Information."
#     }

#     process {
#         if ($InfoLevel.UsersAndGroups.HomeSiteAssignments -ge 1) {
#             try {
#                 try {
#                     # Home Site Info
#                     $HomesiteQueryDefn = New-Object VMware.Hv.QueryDefinition
#                     $HomesiteQueryDefn.queryentitytype='UserHomeSiteInfo'
#                     $HomesitequeryResults = $Queryservice.QueryService_Create($hzServices, $HomesiteQueryDefn)
#                     $Homesites = foreach ($Homesiteresult in $HomesitequeryResults.results) {
#                         $hzServices.UserHomeSite.UserHomeSite_GetInfos($Homesiteresult.id)
#                     }
#                     $queryservice.QueryService_DeleteAll($hzServices)
#                 }
#                 catch {
#                     Write-PscriboMessage -IsWarning $_.Exception.Message
#                 }
#                 if ($Homesites) {
#                     Section -Style Heading3 'Home Site General Information' {
#                         $OutObj = @()
#                         foreach ($HomeSite in $HomeSites) {
#                             try {
#                                 $inObj = [ordered] @{
#                                     'User or Group Name' = $HomeSiteUserIDName
#                                     'Domain' = $HomeSiteUserIDDomain
#                                     'Group' = $HomeSiteUserIDGroup
#                                     'Email' = $HomeSiteUserIDEmail
#                                     'Home Site' = $HomeSiteSiteIDName
#                                     'Global Entitlement' = $HomeSiteGlobalEntitlementIDName
#                                     'Global Application Entitlement' = $HomeSiteGlobalApplicationEntitlementIDName
#                                 }
#                                 $OutObj += [pscustomobject]$inobj
#                             }
#                             catch {
#                                 Write-PscriboMessage -IsWarning $_.Exception.Message
#                             }
#                         }

#                         $TableParams = @{
#                             Name = "Home Site General - $($HVEnvironment)"
#                             List = $false
#                             ColumnWidths = 17, 10, 10, 18, 15, 15, 15
#                         }

#                         if ($Report.ShowTableCaptions) {
#                             $TableParams['Caption'] = "- $($TableParams.Name)"
#                         }
#                         $OutObj | Sort-Object -Property 'User or Group Name' | Table @TableParams
#                     }
#                 }
#             }
#             catch {
#                 Write-PscriboMessage -IsWarning $_.Exception.Message
#             }
#         }
#     }
#     end {}
# }