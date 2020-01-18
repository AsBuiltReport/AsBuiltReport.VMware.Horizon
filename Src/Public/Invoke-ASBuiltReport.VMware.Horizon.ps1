function Invoke-AsBuiltReport.VMware.Horizon {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        0.1.1
        Author:         Chris Hildebrandt, Karl Newick
        Twitter:        @childebrandt42, @karlnewick
        Github:         https://github.com/AsBuiltReport
        Credits:        Iain Brighton (@iainbrighton) - PScribo module


    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon
    #>

    [CmdletBinding()]
    param (
        [String[]] $Target,
        [PSCredential] $Credential,
        [String] $StylePath
    ) #Close out Param

    # Import JSON Configuration for Options and InfoLevel
    $InfoLevel = $ReportConfig.InfoLevel
    #$Options = $ReportConfig.Options

    # If custom style not set, use default style
    if (!$StylePath) {
        & "$PSScriptRoot\..\..\AsBuiltReport.VMware.Horizon.Style.ps1"
    } #Close out If (!$StylePath)


    foreach ($HVEnvironment in $Target) {
    
        Try {
            $HvServer = Connect-HVServer -Server $HVEnvironment -Credential $Credential -ErrorAction Stop
        } Catch { 
            Write-Error $_
        } #Close Out Try Catch


        #region Script Body
        #---------------------------------------------------------------------------------------------#
        #                                       SCRIPT BODY                                           #
        #---------------------------------------------------------------------------------------------#
        

        # Generate report if connection to Horizon Environment Server Connection is successful
        if ($HvServer) {

            #Environment Varibles

            # Assign a variable to obtain the API Extension Data
            $hzServices = $Global:DefaultHVServers.ExtensionData

            # Define HV Query Services
            $Queryservice = new-object vmware.hv.queryserviceservice
            #$QueryDef = New-Object VMware.Hv.QueryDefinition
            
            # Virtual Centers
            $vCenterServers = $hzServices.VirtualCenter.VirtualCenter_List()

            # Composer Servers
            $Composers = $vCenterServers.viewcomposerdata

            # vCenter Health, ESX Hosts, and DataStores
            $vCenterHealth = $hzServices.VirtualCenterHealth.VirtualCenterHealth_List()

            # ESXHosts
            $esxhosts = $vCenterHealth

            # DataStores
            $datastores = $vCenterHealth
            
            # Domains
            $domains = $hzServices.ADDomainHealth.ADDomainHealth_List()

            # Connection Server Info
            $connectionservers = $hzServices.ConnectionServer.ConnectionServer_List()

            # Security Server Info
            $SecurityServers = $hzServices.SecurityServer.SecurityServer_List()

            # GateWay Server Info
            $GatewayServers = $hzServices.Gateway.Gateway_List()

            # Instant Clone Domain Admins
            $InstantCloneDomainAdmins = $hzServices.InstantCloneEngineDomainAdministrator.InstantCloneEngineDomainAdministrator_List()

            # Product Licensing and Usage Info
            $ProductLicenseingInfo = $hzServices.License.License_Get()

            # Global Settings
            $GlobalSettings = $hzServices.GlobalSettings.GlobalSettings_Get()

            # Administrators
            $Administrators = $hzServices.AdminUserOrGroup.AdminUserOrGroup_List()

            # ThinApp Configuration

            # Cloud Pod Architecture
            $CloudPodFederation = $hzServices.PodFederation.PodFederation_Get()

            # Sites
            $CloudPodSites = $hzServices.Site.Site_List()
            $CloudPodLists = $hzServices.Pod.Pod_List()

            # Event Database Info
            $EventDataBases = $hzServices.EventDatabase.EventDatabase_Get()

            # Virtual Centers
            $vCenterServers = $hzServices.VirtualCenter.VirtualCenter_List()

            # Pool Info
            $PoolQueryDefn = New-Object VMware.Hv.QueryDefinition
            $PoolQueryDefn.queryentitytype='DesktopSummaryView'
            $poolqueryResults = $Queryservice.QueryService_Create($hzServices, $PoolQueryDefn)
            $pools = foreach ($poolresult in $poolqueryResults.results){$hzServices.desktop.desktop_get($poolresult.id)}
            $queryservice.QueryService_DeleteAll($hzServices)

            # Application Pools
            $AppQueryDefn = New-Object VMware.Hv.QueryDefinition
            $AppQueryDefn.queryentitytype='ApplicationInfo'
            $AppqueryResults = $Queryservice.QueryService_Create($hzServices, $AppQueryDefn)
            $Apps = foreach ($Appresult in $AppqueryResults.results){$hzServices.Application.Application_Get($Appresult.id)}
            $queryservice.QueryService_DeleteAll($hzServices)
            
            # Thin Apps

            # Global Entitlements
            $GlobalEntitlementGroupsQueryDefn = New-Object VMware.Hv.QueryDefinition
            $GlobalEntitlementGroupsQueryDefn.queryentitytype='GlobalEntitlementSummaryView'
            $GlobalEntitlementGroupsqueryResults = $Queryservice.QueryService_Create($hzServices, $GlobalEntitlementGroupsQueryDefn)
            $GlobalEntitlements = foreach ($GlobalEntitlementGroupsResult in $GlobalEntitlementGroupsqueryResults.results){$hzServices.GlobalEntitlement.GlobalEntitlement_Get($GlobalEntitlementGroupsResult.id)}
            $queryservice.QueryService_DeleteAll($hzServices)

            # Entitled User Or Group Global
            $GlobalApplicationEntitlementGroupsQueryDefn = New-Object VMware.Hv.QueryDefinition
            $GlobalApplicationEntitlementGroupsQueryDefn.queryentitytype='GlobalApplicationEntitlementInfo'
            $GlobalApplicationEntitlementGroupsqueryResults = $Queryservice.QueryService_Create($hzServices, $GlobalApplicationEntitlementGroupsQueryDefn)
            $GlobalApplicationEntitlementGroups = foreach ($GlobalApplicationEntitlementGroupsResult in $GlobalApplicationEntitlementGroupsqueryResults.results){$hzServices.GlobalApplicationEntitlement.GlobalApplicationEntitlement_Get($GlobalApplicationEntitlementGroupsResult.id)}
            $queryservice.QueryService_DeleteAll($hzServices)

            # EntitledUserOrGroupGlobalMachine Info
            $EntitledUserOrGroupGlobalMachineQueryDefn = New-Object VMware.Hv.QueryDefinition
            $EntitledUserOrGroupGlobalMachineQueryDefn.queryentitytype='EntitledUserOrGroupGlobalSummaryView'
            $EntitledUserOrGroupGlobalMachinequeryResults = $Queryservice.QueryService_Create($hzServices, $EntitledUserOrGroupGlobalMachineQueryDefn)
            $EntitledUserOrGroupGlobalMachines = foreach ($EntitledUserOrGroupGlobalMachineresult in $EntitledUserOrGroupGlobalMachinequeryResults.results){$hzServices.EntitledUserOrGroup.EntitledUserOrGroup_GetGlobalSummaryView($EntitledUserOrGroupGlobalMachineresult.id)}
            $queryservice.QueryService_DeleteAll($hzServices)

            # EntitledUserOrGroupLocalMachine Info
            $EntitledUserOrGroupLocalMachineQueryDefn = New-Object VMware.Hv.QueryDefinition
            $EntitledUserOrGroupLocalMachineQueryDefn.queryentitytype='EntitledUserOrGroupLocalSummaryView'
            $EntitledUserOrGroupLocalMachinequeryResults = $Queryservice.QueryService_Create($hzServices, $EntitledUserOrGroupLocalMachineQueryDefn)
            $EntitledUserOrGroupLocalMachines = foreach ($EntitledUserOrGroupLocalMachineresult in $EntitledUserOrGroupLocalMachinequeryResults.results){$hzServices.EntitledUserOrGroup.EntitledUserOrGroup_GetLocalSummaryView($EntitledUserOrGroupLocalMachineresult.id)}
            $queryservice.QueryService_DeleteAll($hzServices)

            # Permissions
            $Permissions = $hzServices.Permission.Permission_List()

            # Roles
            $Roles = $hzServices.Role.Role_List()

            # Access Groups
            $AccessGroups = $hzServices.AccessGroup.AccessGroup_List()

            # Farm Info
            $FarmdQueryDefn = New-Object VMware.Hv.QueryDefinition
            $FarmdQueryDefn.queryentitytype='FarmSummaryView'
            $FarmqueryResults = $Queryservice.QueryService_Create($hzServices, $FarmdQueryDefn)
            $farms = foreach ($farmresult in $farmqueryResults.results){$hzServices.farm.farm_get($farmresult.id)}
            $queryservice.QueryService_DeleteAll($hzServices)

            # Machines
            $MachinesQueryDefn = New-Object VMware.Hv.QueryDefinition
            $MachinesQueryDefn.queryentitytype='MachineSummaryView'
            $MachinesqueryResults = $Queryservice.QueryService_Create($hzServices, $MachinesQueryDefn)
            $Machines = foreach ($Machinesresult in $MachinesqueryResults.results){$hzServices.machine.machine_get($Machinesresult.id)}
            $queryservice.QueryService_DeleteAll($hzServices)

            # RDS Servers
            $RDSServerQueryDefn = New-Object VMware.Hv.QueryDefinition
            $RDSServerQueryDefn.queryentitytype='RDSServerSummaryView'
            $RDSServerqueryResults = $Queryservice.QueryService_Create($hzServices, $RDSServerQueryDefn)
            $RDSServers = foreach ($RDSServerresult in $RDSServerqueryResults.results){$hzServices.RDSServer.RDSServer_GetSummaryView($RDSServerresult.id)}
            $queryservice.QueryService_DeleteAll($hzServices)
            
            # Persistent Disks
            $PersistentDisksQueryDefn = New-Object VMware.Hv.QueryDefinition
            $PersistentDisksQueryDefn.queryentitytype='PersistentDiskInfo'
            $PersistentDisksqueryResults = $Queryservice.QueryService_Create($hzServices, $PersistentDisksQueryDefn)
            $PersistentDisks = foreach ($PersistentDisksresult in $PersistentDisksqueryResults.results){$hzServices.PersistentDisk.PersistentDisk_Get($PersistentDisksresult.id)}
            $queryservice.QueryService_DeleteAll($hzServices)

            # Global Policies

            # Sessions
            $SessionsQueryDefn = New-Object VMware.Hv.QueryDefinition
            $SessionsQueryDefn.queryentitytype='SessionLocalSummaryView'
            $SessionsqueryResults = $Queryservice.QueryService_Create($hzServices, $SessionsQueryDefn)
            $Sessions = foreach ($Sessionsresult in $SessionsqueryResults.results){$hzServices.Session.Session_GetLocalSummaryView($Sessionsresult.id)}
            $queryservice.QueryService_DeleteAll($hzServices)

            # Base Images
            $BaseImageVMList = $hzServices.BaseImageVM.BaseImageVM_List($vCenterServers.id)
            $CompatibleBaseImageVMs = $BaseImageVMList | Where-Object {
                ($_.IncompatibleReasons.InUseByDesktop -eq $false) -and
                ($_.IncompatibleReasons.InUseByLinkedCloneDesktop -eq $false) -and
                ($_.IncompatibleReasons.ViewComposerReplica -eq $false) -and
                ($_.IncompatibleReasons.UnsupportedOS -eq $false) -and
                ($_.IncompatibleReasons.NoSnapshots -eq $false) -and
                (($null -eq $_.IncompatibleReasons.InstantInternal) -or ($_.IncompatibleReasons.InstantInternal -eq $false))
            }

            # Home Site Info
            $HomesiteQueryDefn = New-Object VMware.Hv.QueryDefinition
            $HomesiteQueryDefn.queryentitytype='UserHomeSiteInfo'
            $HomesitequeryResults = $Queryservice.QueryService_Create($hzServices, $HomesiteQueryDefn)
            $Homesites = foreach ($Homesiteresult in $HomesitequeryResults.results){$hzServices.UserHomeSite.UserHomeSite_GetInfos($Homesiteresult.id)}
            $queryservice.QueryService_DeleteAll($hzServices)

            # Unauthenticated Access
            $unauthenticatedAccessList = $hzServices.UnauthenticatedAccessUser.UnauthenticatedAccessUser_List()

        } # Close out if ($HvServer) 

        section -Style Heading1 "Horizon Server $($HVEnvironment)" {}

        #---------------------------------------------------------------------------------------------#
        #                                 Users And Groups                                            #
        #---------------------------------------------------------------------------------------------#
        
        if ($EntitledUserOrGroupLocalMachines -or $HomeSites -or $unauthenticatedAccessList) {
            section -Style Heading1 'Users and Groups' {
                LineBreak

                #---------------------------------------------------------------------------------------------#
                #                                     Entitlements                                            #
                #---------------------------------------------------------------------------------------------#
                if ($EntitledUserOrGroupLocalMachines) {
                    if ($InfoLevel.UsersAndGroups.UsersAndGroups.Entitlements -ge 1) {
                        section -Style Heading2 'Local Entitlements Information' {
                            $LocalEntitlementsDetails = foreach($EntitledUserOrGroupLocalMachine in $EntitledUserOrGroupLocalMachines) {
                                Switch ($EntitledUserOrGroupLocalMachine.base.Group)
                                {
                                    'True' {$EntitledUserOrGroupLocalMachinegroup = 'Group' }
                                    'False' {$EntitledUserOrGroupLocalMachinegroup = 'User' }
                                } #Close out Switch ($EntitledUserOrGroupLocalMachine.base.Group)

                                [PSCustomObject]@{
                                    'User Principal Name' = $EntitledUserOrGroupLocalMachine.base.UserPrincipalName
                                    'Group or User' = $EntitledUserOrGroupLocalMachinegroup
                                } # Close Out [PSCustomObject]
                            }
                            $LocalEntitlementsDetails | Table -Name 'Local Entitlements Information' -ColumnWidths 60,40

                            if ($InfoLevel.UsersAndGroups.UsersAndGroups.Entitlements -ge 2) {
                                $PoolIDNameResults = ''
                                $AppIDNameResults = ''
                                foreach($EntitledUserOrGroupLocalMachine in $EntitledUserOrGroupLocalMachines) {
                                    # Find Machine ID Name
                                    $MachineIDName = ''
                                    $Entitledlocalmachines = $EntitledUserOrGroupLocalMachine.LocalData.Machines.id
                                    foreach($Entitledlocalmachine in $Entitledlocalmachines) {
                                        foreach($Machine in $Machines) {
                                            if($Machine.Id.id -eq $Entitledlocalmachine) {
                                                $MachineIDName = $Machine.base.Name
                                                break
                                            } # Close out if($Machine.Id.id -eq $Entitledlocalmachine)
                                        } # Close out foreach($Machine in $Machines)
                                            if($Entitledlocalmachines.count -gt 1){
                                                $MachineIDNameResults += "$MachineIDName, " 
                                                $MachineIDName = $MachineIDNameResults.TrimEnd(', ')
                                            } #Close Out if($Entitledlocalmachines.count -gt 1)
                                    } # Close out foreach($Entitledlocalmachine in $Entitledlocalmachines)
                                    Switch ($MachineIDName)
                                    {
                                        '' {$MachineIDName = 'N/A'}
                                        ' ' {$MachineIDName = 'N/A'}
                                    }                        

                                    # Find Desktop ID Name
                                    $PoolIDName = ''
                                    $Entitledlocalmachines = $EntitledUserOrGrouplocalMachine.localData.Desktops.id
                                    foreach($Entitledlocalmachine in $Entitledlocalmachines) {
                                        foreach($Pool in $Pools) {
                                            if($Pool.Id.id -eq $Entitledlocalmachine) {
                                                $PoolIDName = $pool.base.Name
                                                break
                                            } # Close out if($Pool.Id.id -eq $Entitledlocalmachine)
                                        } # Close out foreach($Pool in $Pools)
                                            if($Entitledlocalmachines.count -gt 1){
                                                $PoolIDNameResults += "$PoolIDName, " 
                                                $PoolIDName = $PoolIDNameResults.TrimEnd(', ')
                                            } #Close Out if($Entitledlocalmachines.count -gt 1)
                                    } # Close out foreach($Entitledlocalmachine in $Entitledlocalmachines)
                                    # Find App ID Name
                                    $AppIDName = ''
                                    $Entitledlocalmachines = $EntitledUserOrGroupLocalMachine.LocalData.Applications.id
                                    foreach($Entitledlocalmachine in $Entitledlocalmachines) {


                                        foreach($App in $Apps) {
                                            if($App.Id.id -eq $Entitledlocalmachine) {
                                                $AppIDName = $app.data.DisplayName
                                                break
                                            } # Close out if($App.Id.id -eq $Entitledlocalmachine)
                        
                                        } # Close out foreach($App in $Apps)
                                            if($Entitledlocalmachines.count -gt 1){
                                                $AppIDNameResults += "$AppIDName, " 
                                                $AppIDName = $AppIDNameResults.TrimEnd(', ')
                                            } #Close Out if($Entitledlocalmachines.count -gt 1)
                                    } # Close out foreach($Entitledlocalmachine in $Entitledlocalmachines)
                                    Switch ($AppIDName)
                                    {
                                        '' {$AppIDName = 'N/A'}
                                        ' ' {$AppIDName = 'N/A'}
                                    }

                                    Switch ($EntitledUserOrGroupLocalMachine.base.Group)
                                    {
                                        'True' {$EntitledUserOrGroupLocalMachinegroup = 'Group' }
                                        'False' {$EntitledUserOrGroupLocalMachinegroup = 'User' }
                                    } #Close out Switch ($EntitledUserOrGroupLocalMachine.base.Group)

                                    PageBreak
                                    section -Style Heading3 "Local Entitlements Details of $($EntitledUserOrGroupLocalMachine.base.Name)" {
                                        $HorizonEntitledUserOrGroupLocalMachine = [PSCustomObject]@{
                                            'Name' = $EntitledUserOrGroupLocalMachine.base.Name
                                            'Group or User' = $EntitledUserOrGroupLocalMachinegroup
                                            'SID' = $EntitledUserOrGroupLocalMachine.base.Sid
                                            'Domain' = $EntitledUserOrGroupLocalMachine.base.Domain
                                            'Ad Distinguished Name' = $EntitledUserOrGroupLocalMachine.base.AdDistinguishedName
                                            'First Name' = $EntitledUserOrGroupLocalMachine.base.FirstName
                                            'Last Name' = $EntitledUserOrGroupLocalMachine.base.LastName
                                            'Login Name' = $EntitledUserOrGroupLocalMachine.base.LoginName
                                            'Display Name' = $EntitledUserOrGroupLocalMachine.base.DisplayName
                                            'Long Display Name' = $EntitledUserOrGroupLocalMachine.base.LongDisplayName
                                            'Email' = $EntitledUserOrGroupLocalMachine.base.Email
                                            'Kiosk User' = $EntitledUserOrGroupLocalMachine.base.KioskUser
                                            'Phone' = $EntitledUserOrGroupLocalMachine.base.Phone
                                            'Description' = $EntitledUserOrGroupLocalMachine.base.Description
                                            'in Folder' = $EntitledUserOrGroupLocalMachine.base.InFolder
                                            'User Principal Name' = $EntitledUserOrGroupLocalMachine.base.UserPrincipalName
                                            'Local Machines' = $MachineIDName
                                            'Local User Persistent Disks' = $EntitledUserOrGroupLocalMachine.LocalData.PersistentDisks
                                            'Local Desktops' = $PoolIDName
                                            'User Applications' = $AppIDName
                                        } # Close Out $HorizonEntitledUserOrGroupLocalMachine = [PSCustomObject]
                                        $HorizonEntitledUserOrGroupLocalMachine | Table -Name "Local Entitlements Details of $($EntitledUserOrGroupLocalMachine.base.Name)" -List -ColumnWidths 50,50
                                    } # Close out section -Style Heading3 'Local Entitlements Details of'
                                } # Close out foreach($EntitledUserOrGroupLocalMachine in $EntitledUserOrGroupLocalMachines)
                            } # Close out if ($InfoLevel.UsersAndGroups.UsersAndGroups.Entitlements -ge 2)
                        } # Close out section -Style Heading2 'Entitled User Or Group Local Machines'
                    } # Close out if ($InfoLevel.UsersAndGroups.UsersAndGroups.Entitlements -ge 1)
                } # Close out if ($EntitledUserOrGroupLocalMachines)


                #---------------------------------------------------------------------------------------------#
                #                                   Remote Access                                           #
                #---------------------------------------------------------------------------------------------#


                #---------------------------------------------------------------------------------------------#
                #                               Home Site Assignment                                          #
                #---------------------------------------------------------------------------------------------#

                if ($HomeSites) {
                    if ($InfoLevel.UsersAndGroups.UsersAndGroups.HomeSiteAssignments -ge 1) {
                        PageBreak
                        section -Style Heading2 "Home Site General Information" {

                            $HomeSiteGeneralInfo = foreach($HomeSite in $HomeSites) {
                                
                                # Clear Var
                                $HomeSiteUserIDName = ''
                                $HomeSiteUserIDDomain = ''
                                $HomeSiteUserIDEmail = ''
                                $HomeSiteUserIDGroup = ''
                                $HomeSiteSiteIDName = ''
                                $HomeSiteGlobalEntitlementIDName = ''
                                $HomeSiteGlobalApplicationEntitlementIDName = ''

                                # HomeSite User or Group ID
                                if($homesite.Base.UserOrGroup){
                                    $HomeSiteUserID = $hzServices.ADUserOrGroup.ADUserOrGroup_Get($homesite.Base.UserOrGroup)
                                    $HomeSiteUserIDName = $HomeSiteUserID.Base.Name
                                    $HomeSiteUserIDDomain = $HomeSiteUserID.Base.Domain
                                    $HomeSiteUserIDEmail = $HomeSiteUserID.Base.Email
                                    $HomeSiteUserIDGroup = $HomeSiteUserID.Base.Group
                                }

                                # Home Site Site ID
                                if($homesite.Base.Site){
                                    $HomeSiteSiteID = $hzServices.Site.Site_Get($homesite.Base.Site)
                                    $HomeSiteSiteIDName = $HomeSiteSiteID.base.DisplayName
                                }

                                # Home Site Global Entilement ID
                                if($homesite.Base.GlobalEntitlement){
                                    $HomeSiteGlobalEntitlementID = $hzServices.GlobalEntitlement.GlobalEntitlement_Get($homesite.Base.GlobalEntitlement)
                                    $HomeSiteGlobalEntitlementIDName = $HomeSiteGlobalEntitlementID.base.DisplayName
                                }

                                # Home Site Global Application Entilement ID
                                if($homesite.Base.GlobalApplicationEntitlement){
                                    $HomeSiteGlobalApplicationEntitlementID = $hzServices.GlobalApplicationEntitlement.GlobalApplicationEntitlement_Get($homesite.Base.GlobalApplicationEntitlement)
                                    $HomeSiteGlobalApplicationEntitlementIDName = $HomeSiteGlobalApplicationEntitlementID.base.DisplayName
                                }

                                [PSCustomObject]@{
                                    'User or Group Name' = $HomeSiteUserIDName
                                    'Domain' = $HomeSiteUserIDDomain
                                    'Group' = $HomeSiteUserIDGroup
                                    'Email' = $HomeSiteUserIDEmail
                                    'Home Site' = $HomeSiteSiteIDName
                                    'Global Entitlement' = $HomeSiteGlobalEntitlementIDName
                                    'Global Application Entitlement' = $HomeSiteGlobalApplicationEntitlementIDName
                                } # Close Out $HorizonRole = [PSCustomObject]
                            }
                            $HomeSiteGeneralInfo | Table -Name 'Home Site General Information' -ColumnWidths 17,10,10,18,15,15,15
                            
                        } # Close out section -Style Heading4 'Cloud Pod Sites General Information'         
                    } # Close out if (($InfoLevel.Settings.Sites.Sites -ge 1) {            
                } # Close out if ($HomeSites)

                #---------------------------------------------------------------------------------------------#
                #                              Unauthenticated Access                                         #
                #---------------------------------------------------------------------------------------------#
                
                if ($unauthenticatedAccessList) {
                    if ($InfoLevel.UsersAndGroups.UsersAndGroups.UnauthenticatedAccess -ge 1) {
                        PageBreak
                        section -Style Heading2 "Unauthenticated Access General Information" {

                            $unauthenticatedAccessGeneralInfo = foreach($unauthenticatedAccess in $unauthenticatedAccessList) {
                                
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

                                [PSCustomObject]@{
                                    'Login Name' = $unauthenticatedAccess.userdata.LoginName
                                    'User ID' = $unauthenticatedAccessUserIDName
                                    'Description' = $unauthenticatedAccess.userdata.Description
                                    'Hybrid Logon Config' = $unauthenticatedAccess.userdata.HybridLogonConfig
                                    'Pod' = $unauthenticatedAccessPodListName
                                } # Close Out $HorizonRole = [PSCustomObject]
                            }
                            $unauthenticatedAccessGeneralInfo | Table -Name 'Unauthenticated Access General Information' -ColumnWidths 20,20,20,20,20
                            
                        } # Close out section -Style Heading4 'Unauthenticated Access General Information'         
                    } # Close out if (($InfoLevel.UsersAndGroups.UsersAndGroups.UnauthenticatedAccess -ge 1) {            
                } # Close out if ($unauthenticatedAccessList)

            } # Close out section -Style Heading1 'Users And Groups'
        } # Close out if ($EntitledUserOrGroupLocalMachines -or $HomeSites -or $unauthenticatedAccessList)


        #---------------------------------------------------------------------------------------------#
        #                                 Inventory                                                   #
        #---------------------------------------------------------------------------------------------#
        
        if ($Pools -or $Apps -or $Farms -or $Machines -or $RDSServers -or $PersistentDisks -or $ThinApps -or $GlobalEntitlements -or $GlobalApplicationEntitlementGroups) {
            PageBreak
            section -Style Heading1 'Inventory' {
                LineBreak

                #---------------------------------------------------------------------------------------------#
                #                                 Desktops                                                    #
                #---------------------------------------------------------------------------------------------#

                if ($Pools) {
                    if ($InfoLevel.Inventory.Desktop -ge 1) {
                        section -Style Heading2 'Desktops' {
                            section -Style Heading3 'Desktop Pools General Information' {
                                $HorizonPoolGeneralInfo = foreach($Pool in $Pools) {
                                    Switch ($Pool.automateddesktopdata.ProvisioningType)
                                            {
                                                'INSTANT_CLONE_ENGINE' {$ProvisioningType = 'Instant Clone' }
                                            }
                                    [PSCustomObject]@{
                                    'Pool Name' = $Pool.Base.name
                                    'Pool User Assignment' = $Pool.Type
                                    'Provisioning Type' = $ProvisioningType
                                    } # Close out [PSCustomObject]
                                } # Close out $HorizonPoolGeneralInfo = foreach($Pool in $Pools)
                                $HorizonPoolGeneralInfo | Table -Name 'Desktop Pools General Information' -ColumnWidths 40,30,30

                                if ($InfoLevel.Inventory.Desktop -ge 2) {
                                    section -Style Heading3 'Desktop Pool Details' { 
                                        foreach($Pool in $Pools) {
                                            # Find out Access Group for Applications
                                            $AccessgroupMatch = $false
                                            $Accessgroups = $hzServices.AccessGroup.AccessGroup_List()
                                            foreach($Accessgroup in $Accessgroups) {
                                                if($Accessgroup.Id.id = $Pool.base.accessgroup.id) {
                                                    $AccessGroupName = $Accessgroup.base.name
                                                    $AccessgroupMatch = $true
                                                } # Close out if($Accessgroup.Id.id = $app.accessgroup.id) 
                                                if($AccessgroupMatch) {
                                                    break
                                                } # Close out if($AccessgroupMatch) 
                                            } # Close out foreach($Accessgroup in $Accessgroups)

                                            # Find out Global Entitlement Group for Applications
                                            $InstantCloneDomainAdminGroupMatch = $false
                                            foreach($InstantCloneDomainAdminGroup in $InstantCloneDomainAdminGroups) {
                                                if($InstantCloneDomainAdminGroup.Id.id = $Pool.automateddesktopdata.CustomizationSettings.CloneprepCustomizationSettings.InstantCloneEngineDomainAdministrator.id) {
                                                    $InstantCloneDomainAdminGroupDisplayName = $InstantCloneDomainAdmins.base.username
                                                    $InstantCloneDomainAdminGroupMatch = $true
                                                } # Close out if($InstantCloneDomainAdminGroup.Id.id = $app.executiondata.farm.id)
                                            if($InstantCloneDomainAdminGroupMatch) {
                                                break
                                                } #Close out if($InstantCloneDomainAdminGroupMatch) 
                                            } # Close out foreach($InstantCloneDomainAdminGroup in $InstantCloneDomainAdminGroups)

                                            # Find out Global Entitlement Group for Applications
                                            $GlobalEntitlementMatch = $false
                                            foreach($GlobalEntitlement in $GlobalEntitlements) {
                                                if($GlobalEntitlement.Id.id = $Pool.globalentitlementdata.globalentitlement.id) {
                                                    $GlobalEntitlementDisplayName = $GlobalEntitlement.base.DisplayName
                                                    $GlobalEntitlementMatch = $true
                                                } # Close out if($GlobalEntitlement.Id.id = $app.executiondata.farm.id)
                                            if($GlobalEntitlementMatch) {
                                                break
                                                } #Close out if($GlobalEntitlementMatch) 
                                            } # Close out foreach($GlobalEntitlement in $GlobalEntitlements)

                                            $farmMatch = $false
                                            foreach($farm in $farms) {
                                                if($farm.Id.id = $pool.rdsdesktopdata.farm.id) {
                                                    $FarmIDName = $farm.data.name
                                                    $farmMatch = $true
                                                } # Close out if($farm.Id.id = $pool.rdsdesktopdata.farm.id)
                                                if($farmMatch) {
                                                    break
                                                } # Close out if($farmMatch) 
                                            } # Close out foreach($farm in $farms)
                                            
                                            # Find vCenter ID Name
                                            $vCenterServerIDName = ''
                                            $PoolGroups = $pool.manualdesktopdata.virtualcenter.id
                                            foreach($PoolGroup in $PoolGroups) {
                                                foreach($vCenterServer in $vCenterServers) {
                                                    if($vCenterServer.Id.id -eq $PoolGroup) {
                                                        $vCenterServerIDName = $vCenterServer.serverspec.ServerName
                                                        break
                                                    } # Close out if($vCenterServer.Id.id -eq $Entitledlocalmachine)
                                
                                                } # Close out foreach($vCenterServer in $vCenterServers)
                                                    if($PoolGroups.count -gt 1){
                                                        $vCenterServerIDNameResults += "$vCenterServerIDName, " 
                                                        $vCenterServerIDName = $vCenterServerIDNameResults.TrimEnd(', ')
                                                    } #Close Out if($PoolGroups.count -gt 1)
                                            } # Close out foreach($PoolGroup in $PoolGroups)

                                            # Find vCenter Auto ID Name
                                            $vCenterServerAutoIDName = ''
                                            $PoolGroups = $Pool.automateddesktopdata.virtualcenter.id
                                            foreach($PoolGroup in $PoolGroups) {
                                                foreach($vCenterServer in $vCenterServers) {
                                                    if($vCenterServer.Id.id -eq $PoolGroup) {
                                                        $vCenterServerAutoIDName = $vCenterServer.serverspec.ServerName
                                                        break
                                                    } # Close out if($vCenterServer.Id.id -eq $PoolGroup)
                                
                                                } # Close out foreach($vCenterServer in $vCenterServers)
                                                    if($PoolGroups.count -gt 1){
                                                        $vCenterServerAutoIDNameResults += "$vCenterServerAutoIDName, " 
                                                        $vCenterServerAutoIDName = $vCenterServerAutoIDNameResults.TrimEnd(', ')
                                                    } #Close Out if($PoolGroups.count -gt 1)
                                            } # Close out foreach($PoolGroup in $PoolGroups)

                                            # Find Base Image ID Name
                                            if($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ParentVM.id){
                                                foreach($CompatibleBaseImageVM in $CompatibleBaseImageVMs) {
                                                    if($CompatibleBaseImageVM.id.id -eq $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ParentVM.id){
                                                        $PoolBaseImage = $CompatibleBaseImageVM.name
                                                        $PoolBaseImagePath = $CompatibleBaseImageVM.Path
                                                        break
                                                    } # Close out if($CompatibleBaseImageVM.id.id -eq $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ParentVM.id)
                                                } # Close out foreach($CompatibleBaseImageVM in $CompatibleBaseImageVMs)
                                            }

                                            # Get Pool Base Image Snapshot
                                            if($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Snapshot.id) {
                                                $BaseImageSnapshotList = $hzServices.BaseImageSnapshot.BaseImageSnapshot_List($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ParentVM)
                                                $BaseImageSnapshotListLast = $BaseImageSnapshotList | Select-Object -Last 1
                                            }

                                            # DataCenters
                                            if($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Datacenter.id) {
                                                $DataCenterList = $hzServices.Datacenter.Datacenter_List($Pool.automateddesktopdata.virtualcenter)
                                            
                                                # Find DataCenter ID Name
                                                foreach($DataCenter in $DataCenterList) {
                                                    if($DataCenter.id.id -eq $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Datacenter.id){
                                                        $PoolDataCenterName = $DataCenter.base.name
                                                        $PoolDatacenterPath = $DataCenter.base.Path
                                                        break
                                                    } # Close out if($DataCenter.id.id -eq $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Datacenter.id)
                                                } # Close out foreach($DataCenter in $DataCenterList)
                                            }

                                            # VM Folder List
                                            if($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.VmFolder.id){
                                                #$VMFolderList = $hzServices.VmFolder.VmFolder_GetVmFolderTree($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Datacenter)
                                                $VMFolderPath = $Pool.automateddesktopdata.VirtualCenterNamesData.VmFolderPath
                                                $VMFolder = $VMFolderPath -replace '^(.*[\\\/])'
                                            }

                                            # VM Host or Cluster
                                            if($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.HostOrCluster.id){
                                                #$HostAndCluster = $hzServices.HostOrCluster.HostOrCluster_GetHostOrClusterTree($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Datacenter)
                                                $VMhostandCluterPath = $Pool.automateddesktopdata.VirtualCenterNamesData.HostOrClusterPath
                                                $VMhostandCluter = $VMhostandCluterPath -replace '^(.*[\\\/])'
                                            }

                                            # VM Resource Pool
                                            if($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ResourcePool.id){
                                                #$ResourcePoolTree = $hzServices.ResourcePool.ResourcePool_GetResourcePoolTree($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Datacenter)
                                                $VMResourcePoolPath = $Pool.automateddesktopdata.VirtualCenterNamesData.HostOrClusterPath
                                                $VMResourcePool = $VMResourcePoolPath -replace '^(.*[\\\/])'
                                            }

                                            # VM Persistent Disk DataStores
                                            if($Pool.automateddesktopdata.VirtualCenterNamesData.PersistentDiskDatastorePaths){
                                                $VMPersistentDiskDatastorePath = $Pool.automateddesktopdata.VirtualCenterNamesData.PersistentDiskDatastorePaths
                                                $VMPersistentDiskDatastore = $VMPersistentDiskDatastorePath -replace '^(.*[\\\/])'
                                            }

                                            # VM Network Card
                                            if($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterNetworkingSettings.nics.nic.id) {
                                                $NetworkInterfaceCardList = $hzServices.NetworkInterfaceCard.NetworkInterfaceCard_ListBySnapshot($BaseImageSnapshotListLast.Id)
                                            }

                                            # VM AD Container
                                            if($Pool.automateddesktopdata.CustomizationSettings.AdContainer.id) {
                                                foreach($ADDomain in $ADDomains){
                                                    $ADDomainID = ($ADDomain.id.id -creplace '^[^/]*/', '')
                                                    if($Pool.automateddesktopdata.CustomizationSettings.AdContainer.id -like "ADContainer/$ADDomainID/*") {
                                                        $ADContainers = $hzServices.ADContainer.ADContainer_ListByDomain($ADDomain.id)
                                                        foreach($ADContainer in $ADContainers) {
                                                            if($ADContainer.id.id -eq $TestContain){
                                                                $PoolContainerName = $ADContainer.rdn
                                                                break
                                                            } # Close out if($ADContainer.id.id -eq $TestContain)
                                                        } # Close out foreach($ADContainer in $ADContainers)
                                                    } # Close out if($Pool.automateddesktopdata.CustomizationSettings.AdContainer.id -like "ADContainer/$ADDomainID/*")
                                                } # Close out foreach($ADDomain in $ADDomains)
                                            }
                                            
                                            # VM Template
                                            if($Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Template.id){
                                                foreach($Template in $Template) {
                                                    if($Template.id.id -eq $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Template.id){
                                                        $PoolTemplateName = $Template.name
                                                        break
                                                    } # Close out if($Template.id.id -eq $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.Template.id)
                                                } # Close out foreach($Template in $Template)
                                            }

                                            PageBreak
                                            section -Style Heading4 "Pool $($Pool.Base.name) Information" {

                                                $SupportedDisplayProtocols = $Pool.DesktopSettings.DisplayProtocolSettings | ForEach-Object { $_.SupportedDisplayProtocols} 
                                                $SupportedDisplayProtocolsresult = $SupportedDisplayProtocols -join ', '

                                                $StorageOvercommit = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterStorageSettings.datastores | ForEach-Object { $_.StorageOvercommit} 
                                                $StorageOvercommitsresult = $StorageOvercommit -join ', '

                                                $DatastoreFinal = ''
                                                $DatastorePaths = $Pool.automateddesktopdata.VirtualCenterNamesData | ForEach-Object { $_.DatastorePaths} 
                                                foreach($Datastore in $DatastorePaths){
                                                $Datastorename = $Datastore -replace '^(.*[\\\/])'
                                                $DatastoreFinal += $DatastoreName -join "`r`n" | Out-String
                                                }
                                                $DatastorePathsresult = $DatastorePaths -join ', '


                                                $HorizonPoolInfoP1 = [PSCustomObject]@{
                                                    'Pool Name' = $Pool.Base.name
                                                    'Pool Display Name' = $Pool.base.displayName
                                                    'Pool Description' = $Pool.base.description
                                                    'Pool Access Group' = $AccessGroupName
                                                    'Pool Enabled' = $Pool.DesktopSettings.Enabled
                                                    'Pool Deleting' = $Pool.DesktopSettings.Deleting
                                                    'Connection Server Restrictions' = $Pool.DesktopSettings.ConnectionServerRestrictions
                                                    'Pool Type' = $Pool.Type
                                                    'Pool Source' = $pool.Source
                                                    'Virtual Center' = $vCenterServerAutoIDName
                                                    'Provisioning Type' = $Pool.automateddesktopdata.ProvisioningType
                                                    'Pool Naming Method' = $Pool.automateddesktopdata.VmNamingSettings.NamingMethod
                                                    'Pool Naming Pattern' = $pool.automateddesktopdata.vmnamingsettings.patternnamingsettings.namingpattern
                                                    'Pool Max Number of Machines' = $pool.automateddesktopdata.vmnamingsettings.patternnamingsettings.MaxNumberOfMachines
                                                    'Pool Number of Spare Machines' = $pool.automateddesktopdata.vmnamingsettings.patternnamingsettings.NumberOfSpareMachines
                                                    'Pool Provisioning Time' = $pool.automateddesktopdata.vmnamingsettings.patternnamingsettings.ProvisioningTime
                                                    'Pool Min number of Machines' = $pool.automateddesktopdata.vmnamingsettings.patternnamingsettings.MinNumberOfMachines
                                                    'Pool Enabled for Provisioning' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.EnableProvisioning
                                                    'Stop Provisioning on Error' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.StopProvisioningOnError
                                                    'Min Ready VMs on vComposer Maintenance' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.MinReadyVMsOnVComposerMaintenance
                                                    'Pool Template' = $PoolTemplateName
                                                    'Pool Parent VM' = $PoolBaseImage
                                                    'Pool Parent VM Path' = $PoolBaseImagePath
                                                    'Pool Snapshot' = $BaseImageSnapshotListLast.name
                                                    'Pool Snapshot Path' = $BaseImageSnapshotListLast.path
                                                    'Pool Datacenter' = $PoolDataCenterName
                                                    'Pool Datacenter Path' = $PoolDatacenterPath
                                                    #'Pool VM Folder' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.VmFolder.id
                                                    'Pool VM Folder' = $VMFolder
                                                    'Pool VM Folder Path' = $Pool.automateddesktopdata.VirtualCenterNamesData.VmFolderPath
                                                    #'Pool Host or Cluster' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.HostOrCluster.id
                                                    'Pool Host or Cluster' = $VMhostandCluter
                                                    'Pool Host or Cluster Path' = $Pool.automateddesktopdata.VirtualCenterNamesData.HostOrClusterPath
                                                    #'Pool Resource Pool' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterProvisioningData.ResourcePool.id
                                                    
                                                } # Closing out $HorizonPoolInfo = [PSCustomObject]
                                                $HorizonPoolInfoP1 | Table -Name "Pool $($Pool.Base.name) Information Part 1" -List -ColumnWidths 60,40
                                                PageBreak
                                                    
                                                $HorizonPoolInfoP2 = [PSCustomObject]@{
                                                    'Pool Resource Pool' = $VMResourcePool
                                                    'Pool Resource Pool Path' = $Pool.automateddesktopdata.VirtualCenterNamesData.ResourcePoolPath
                                                    #'Pool Datastores' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterStorageSettings.datastores.datastore.id
                                                    'Pool Datastores' = $DatastoreFinal
                                                    'Pool Datastores Paths' = $DatastorePathsresult
                                                    'Pool Datastores Storage Over-Commit' = $StorageOvercommitsresult
                                                    'Pool Persistent Disk Datastore' = $VMPersistentDiskDatastore
                                                    'Pool Persistent Disk Datastore Paths' = $Pool.automateddesktopdata.VirtualCenterNamesData.PersistentDiskDatastorePaths
                                                    'Pool Replica Disk Datastore Path' = $Pool.automateddesktopdata.VirtualCenterNamesData.ReplicaDiskDatastorePath
                                                    'Pool Network Interface Card Name' = "$($Pool.automateddesktopdata.VirtualCenterNamesData.NicNames)"
                                                    'Pool Network Interface Card MAC Address' = $NetworkInterfaceCardList.data.MacAddress
                                                    'Pool Network Interface Card Enabled' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterNetworkingSettings.nics.NetworkLabelAssignmentSpecs.Enabled
                                                    'Pool Network Interface Card Network Label' = "$($Pool.automateddesktopdata.VirtualCenterNamesData.NetworkLabelNames)"
                                                    'Pool Network Label Name' = "$($Pool.automateddesktopdata.VirtualCenterNamesData.NetworkLabelNames)"
                                                    'Pool Network Interface Card Max Label Type' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterNetworkingSettings.nics.NetworkLabelAssignmentSpecs.MaxLabelType
                                                    'Pool Network Interface Card Max Label' = $Pool.automateddesktopdata.VirtualCenterProvisioningSettings.VirtualCenterNetworkingSettings.nics.NetworkLabelAssignmentSpecs.MaxLabel
                                                    'Pool Customization Spec Name' = $Pool.automateddesktopdata.VirtualCenterNamesData.CustomizationSpecName
                                                    'Pool Power Policy' = $Pool.DesktopSettings.LogoffSettings.PowerPolicy
                                                    'Pool Automatic Logoff Policy' = $Pool.DesktopSettings.LogoffSettings.AutomaticLogoffPolicy
                                                    'Pool Automatic Logoff Minutes' = $Pool.DesktopSettings.LogoffSettings.AutomaticLogoffMinutes
                                                    'Pool Allow Users to Reset Machines' = $Pool.DesktopSettings.LogoffSettings.AllowUsersToResetMachines
                                                    'Pool Allow Multiple Sessions Per User' = $Pool.DesktopSettings.LogoffSettings.AllowMultipleSessionsPerUser
                                                    'Pool Delete or Refresh Machine After Logoff' = $Pool.DesktopSettings.LogoffSettings.DeleteOrRefreshMachineAfterLogoff
                                                    'Pool Refresh OS Disk After Logoff' = $Pool.DesktopSettings.LogoffSettings.RefreshOsDiskAfterLogoff
                                                    'Pool Refresh Period Days for Replica OS Disk' = $Pool.DesktopSettings.LogoffSettings.RefreshPeriodDaysForReplicaOsDisk
                                                    'Pool Refresh Threshold Percentage For Replica OS Disk' = $Pool.DesktopSettings.LogoffSettings.RefreshThresholdPercentageForReplicaOsDisk
                                                    'Pool Supported Display Protocols' = $SupportedDisplayProtocolsresult
                                                    'Pool Default Display Protocol' = $Pool.DesktopSettings.DisplayProtocolSettings.DefaultDisplayProtocol
                                                    'Pool Allow Users to Choose Protocol' = $Pool.DesktopSettings.DisplayProtocolSettings.AllowUsersToChooseProtocol
                                                    'Pool Enable HTML Access' = $Pool.DesktopSettings.DisplayProtocolSettings.EnableHTMLAccess
                                                    'Pool Renderer 3D' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.Renderer3D
                                                    'Pool Enable GRID vGPUs' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.EnableGRIDvGPUs
                                                    'Pool vGPU Grid Profile' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.VGPUGridProfile
                                                    'Pool vRam Size MB' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.VRamSizeMB
                                                    'Pool Max Number of Monitors' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.MaxNumberOfMonitors
                                                    'Pool Max Resolution of Any One Monitor' = $Pool.DesktopSettings.DisplayProtocolSettings.PcoipDisplaySettings.MaxResolutionOfAnyOneMonitor
                                                } # Closing out $HorizonPoolInfo = [PSCustomObject]
                                                $HorizonPoolInfoP2 | Table -Name "Pool $($Pool.Base.name) Information Part 2" -List -ColumnWidths 60,40
                                                PageBreak
                                                    
                                                $HorizonPoolInfoP3 = [PSCustomObject]@{
                                                    'Pool Flash Quality' = $Pool.DesktopSettings.FlashSettings.Quality
                                                    'Pool Flash Throttling' = $Pool.DesktopSettings.FlashSettings.Throttling
                                                    'Pool Last Provisioning Error' = $Pool.automateddesktopdata.ProvisioningStatusData.LastProvisioningError
                                                    'Pool Last Provisioning Error Time' = $Pool.automateddesktopdata.ProvisioningStatusData.LastProvisioningErrorTime
                                                    'Pool Customization Type' = $Pool.automateddesktopdata.CustomizationSettings.CustomizationType
                                                    'Pool Domain Administrator' = $Pool.automateddesktopdata.CustomizationSettings.DomainAdministrator
                                                    'Pool Ad Container' = $PoolContainerName
                                                    'Pool Reuse Pre-Existing Accounts' = $Pool.automateddesktopdata.CustomizationSettings.ReusePreExistingAccounts
                                                    'Pool No Customization Settings' = $Pool.automateddesktopdata.CustomizationSettings.NoCustomizationSettings
                                                    'Pool Sys Prep Customization Settings' = $Pool.automateddesktopdata.CustomizationSettings.SysprepCustomizationSettings
                                                    'Pool Quick Prep Customization Settings' = $Pool.automateddesktopdata.CustomizationSettings.QuickprepCustomizationSettings
                                                    'Pool Customization Instant Clone Engine Domain Administrator' = $InstantCloneDomainAdminGroupDisplayName
                                                    'Pool Customization Power Off Script Name' = $Pool.automateddesktopdata.CustomizationSettings.CloneprepCustomizationSettings.PowerOffScriptName
                                                    'Pool Customization Power Off Script Parameters' = $Pool.automateddesktopdata.CustomizationSettings.CloneprepCustomizationSettings.CloneprepCustomizationSettings.PowerOffScriptParameters
                                                    'Pool Customization Post Synchronization Script Name' = $Pool.automateddesktopdata.CustomizationSettings.CloneprepCustomizationSettings.CloneprepCustomizationSettings.PostSynchronizationScriptName
                                                    'Pool Customization Post Synchronization Script Parameters' = $Pool.automateddesktopdata.CustomizationSettings.CloneprepCustomizationSettings.CloneprepCustomizationSettings.PostSynchronizationScriptParameters
                                                    'Pool Global Entitlement' = $GlobalEntitlementDisplayName
                                                    'Pool Manual Desktop User Assignment User ' = $pool.manualdesktopdata.userassignment.UserAssignment
                                                    'Pool Manual Desktop User Assignment User Automatic Assignment' = $pool.manualdesktopdata.userassignment.AutomaticAssignment
                                                    'Pool Manual Desktop Virtual Center' = $vCenterServerIDName
                                                    'Pool Manual Desktop Use Storage Accelerator' = $pool.manualdesktopdata.ViewStorageAcceleratorSettings.UseViewStorageAccelerator
                                                    'Pool Manual Desktop View Composer Disk Types' = $pool.manualdesktopdata.ViewStorageAcceleratorSettings.ViewComposerDiskTypes
                                                    'Pool Manual Desktop Regenerate View Storage Accelerator Days' = $pool.manualdesktopdata.ViewStorageAcceleratorSettings.RegenerateViewStorageAcceleratorDays
                                                    'Pool Manual Desktop Blackout Times' = $pool.manualdesktopdata.ViewStorageAcceleratorSettings.BlackoutTimes
                                                    'Pool Manual Desktop Transparent Page Sharing Scope' = $pool.manualdesktopdata.VirtualCenterManagedCommonSettings.TransparentPageSharingScope
                                                    'Pool RDS Desktop Farm' = $FarmIDName
                                                } # Closing out $HorizonPoolInfo = [PSCustomObject]
                                                $HorizonPoolInfoP3 | Table -Name "Pool $($Pool.Base.name) Information Part 3" -List -ColumnWidths 60,40
                                            } # Closing qut section -Style Heading4 'Pools'
                                        } # Close out $HorizonPools = foreach($Pool in $Pools)
                                    } # Close out section -Style Heading3 'Pools' 
                                } # Close out section -Style Heading3 'Desktop Pools General Information'
                            } # Close out if ($InfoLevel.Inventory.Desktop -ge 2) {
                        } # Close out section -Style Heading1 'Desktops'
                    } # Close out if ($InfoLevel.Inventory.Desktop -ge 1)
                } # Close out if ($Pools)

                #---------------------------------------------------------------------------------------------#
                #                                 Applications                                                #
                #---------------------------------------------------------------------------------------------#

                if ($Apps) {
                    if ($InfoLevel.Inventory.Applications -ge 1) {
                        PageBreak
                        section -Style Heading2 'Applications' {
                            section -Style Heading3 'Application General Information' {
                                $HorizonApplicationsGeneral = foreach($App in $Apps) {
                                    [PSCustomObject]@{
                                        'Horizon Application Display Name' = $App.Data.DisplayName
                                        'Horizon Application Version' = $App.ExecutionData.Version
                                        'Horizon Application Enabled' = $App.Data.Enabled
                                    }
                                } # Close out $HorizonApplications = foreach($App in $Apps)
                                $HorizonApplicationsGeneral | Table -Name 'Application General Information' -ColumnWidths 40,30,30
                            } # Close out section -Style Heading3 'Application General Info'

                            if ($InfoLevel.Inventory.Applications -ge 2) {
                                section -Style Heading3 'Applications Details' { 
                                    foreach($App in $Apps) {
                                    
                                        # Find out Farm Name for Applications
                                        $farmMatch = $false
                                        foreach($farm in $farms) {
                                            if($farm.Id.id -eq $app.executiondata.farm.id) {
                                                $ApplicationFarmName = $farm.data.name
                                                $farmMatch = $true
                                            } # Close out if($farm.Id.id = $app.executiondata.farm.id)
                                            if($farmMatch) {
                                                break
                                            } # Close out if($farmMatch) 
                                        } # Close out foreach($farm in $farms)

                                        # Find out Access Group for Applications
                                        $AccessgroupMatch = $false
                                        $Accessgroups = $hzServices.AccessGroup.AccessGroup_List()
                                        foreach($Accessgroup in $Accessgroups) {
                                            if($Accessgroup.Id.id -eq $app.accessgroup.id) {
                                                $AccessGroupName = $Accessgroup.base.name
                                                $AccessgroupMatch = $true
                                            } # Close out if($Accessgroup.Id.id = $app.accessgroup.id) 
                                            if($AccessgroupMatch) {
                                                break
                                            } # Close out if($AccessgroupMatch) 
                                        } # Close out foreach($Accessgroup in $Accessgroups)
                                        
                                        # Find out Global Application Entitlement Group for Applications
                                        $GlobalApplicationEntitlementGroupMatch = $false
                                        foreach($GlobalApplicationEntitlementGroup in $GlobalApplicationEntitlementGroups) {
                                            if($GlobalApplicationEntitlementGroup.Id.id = $app.data.GlobalApplicationEntitlement.id) {
                                                $GlobalApplicationEntitlementGroupDisplayName = $GlobalApplicationEntitlementGroup.base.DisplayName
                                                $GlobalApplicationEntitlementGroupMatch = $true
                                            } # Close out if($GlobalApplicationEntitlementGroup.Id.id = $app.executiondata.farm.id)
                                        if($GlobalApplicationEntitlementGroupMatch) {
                                            break
                                            } #Close out if($GlobalApplicationEntitlementGroupMatch) 
                                        } # Close out foreach($GlobalApplicationEntitlementGroup in $GlobalApplicationEntitlementGroups)
                                        
                                        $ApplicationFileTypes = $App.ExecutionData.FileTypes | ForEach-Object { $_.FileType} 
                                        $ApplicationFileTypesresult = $ApplicationFileTypes -join ', '
                                        
                                        $OtherApplicationFileTypes = $App.ExecutionData.OtherFileTypes | ForEach-Object { $_.FileType} 
                                        $OtherApplicationFileTypesresult = $OtherApplicationFileTypes -join ', '
                                        
                                        PageBreak
                                        section -Style Heading4 "Application Details for $($App.Data.DisplayName)" {
                                        $HorizonApplications = [PSCustomObject]@{

                                        'Application Name' = $App.Data.Name
                                        'Application Display Name' = $App.Data.DisplayName
                                        'Application Description' = $App.Data.Description
                                        'Application Enabled' = $App.Data.Enabled
                                        'Application Global Application Entitlement' = $GlobalApplicationEntitlementGroupDisplayName
                                        'Application Enable Anti Affinity Rules' = $App.Data.EnableAntiAffinityRules
                                        'Application Anti Affinity Patterns' = $App.Data.AntiAffinityPatterns
                                        'Application Anti Affinity Count' = $App.Data.AntiAffinityCount
                                        'Application Executable Path' = $App.ExecutionData.ExecutablePath
                                        'Application Version' = $App.ExecutionData.Version
                                        'Application Publisher' = $App.ExecutionData.Publisher
                                        'Application Start Folder' = $App.ExecutionData.StartFolder
                                        'Application Argument' = $App.ExecutionData.Args
                                        'Application Farm' = $ApplicationFarmName
                                        'Application File Types' = $ApplicationFileTypesresult
                                        'Application Auto Update File Types' = $App.ExecutionData.AutoUpdateFileTypes
                                        'Application Other File Types' = $OtherApplicationFileTypesresult
                                        'Application Auto Update Other File Types' = $App.ExecutionData.AutoUpdateFileTypes
                                        'Application Access Group' = $AccessGroupName
                                        } # Close out $HorizonApplications = [PSCustomObject]
                                        $HorizonApplications | Table -Name "Application Details for $($App.Data.DisplayName)" -List -ColumnWidths 60,40
                                        } # Close Out section -Style Heading4 'Applications'
                                    } # Close out foreach($App in $Apps)
                                } # Close out section -Style Heading3 'Applications'
                            } # Close out if ($InfoLevel.Inventory.Applications -ge 2)
                        } # Close out section -Style Heading2 'Applications'
                    } # Close out if ($InfoLevel.Inventory.Applications -ge 1)
                } # Close out if ($Apps)

                #---------------------------------------------------------------------------------------------#
                #                                 Farms                                                       #
                #---------------------------------------------------------------------------------------------#

                if ($Farms) {
                    if ($InfoLevel.Inventory.Farms -ge 1) {
                        PageBreak
                        section -Style Heading2 'Farms' {
                            section -Style Heading3 'Farms General Information' {
                                $FarmsGeneralInfo = foreach($Farm in $Farms) {
                                    [PSCustomObject]@{
                                        'Display Name' = $Farm.Data.displayName
                                        'Type' = $Farm.Type
                                        'Enabled' = $Farm.Data.Enabled
                                    }
                                }
                                $FarmsGeneralInfo | Table -Name 'Farms General Information' -ColumnWidths 40,30,30
                            
                                if ($InfoLevel.Inventory.Farms -ge 2) {
                                    section -Style Heading4 'Farms Details' {
                                        PageBreak
                                        foreach($Farm in $Farms) {
                                            
                                            # Find out Access Group for Applications
                                            $AccessgroupMatch = $false
                                            $Accessgroups = $hzServices.AccessGroup.AccessGroup_List()
                                            foreach($Accessgroup in $Accessgroups) {
                                                if($Accessgroup.Id.id -eq $Farm.data.accessgroup.id) {
                                                    $AccessGroupName = $Accessgroup.base.name
                                                    $AccessgroupMatch = $true
                                                } # Close out if($Accessgroup.Id.id = $app.accessgroup.id) 
                                                if($AccessgroupMatch) {
                                                    break
                                                } # Close out if($AccessgroupMatch) 
                                            } # Close out foreach($Accessgroup in $Accessgroups)

                                            section -Style Heading5 "Farm $($Farm.Data.name) Info" {
                                            $HorizonFarmInfo = [PSCustomObject]@{
                                                'Pool Name' = $Farm.Data.name
                                                'Display Name' = $Farm.Data.displayName
                                                'Description' = $Farm.Data.description
                                                'Type' = $Farm.Type
                                                'Automated Farm Data' = $Farm.AutomatedFarmData # Find out the Data not showing up
                                                'Source' = $Farm.Source
                                                'Enabled' = $Farm.Data.Enabled
                                                'Deleting' = $Farm.Data.Deleting
                                                'Desktop' = $Farm.Data.Desktop
                                                'Access Group' = $AccessGroupName
                                                } # Closing out $HorizonPoolInfo = [PSCustomObject]
                                                $HorizonFarmInfo | Table -Name "Farm $($Farm.Data.name) Info" -List

                                                #section -Style Heading5 'Farm Settings' {
                                                $HorizonFarmSettings = [PSCustomObject]@{
                                                    'Disconnected Session Timeout Minutes' = $Farm.Data.settings.DisconnectedSessionTimeoutMinutes
                                                    'Disconnected Session Timeout Policy' = $Farm.Data.settings.DisconnectedSessionTimeoutPolicy
                                                    'Empty Session Timeout Minutes' = $Farm.Data.settings.EmptySessionTimeoutMinutes
                                                    'Empty Session Timeout Policy' = $Farm.data.Settings.EmptySessionTimeoutPolicy
                                                    'Log off After Timeout' = $Farm.data.Settings.LogoffAfterTimeout
                                                    } # Closing out $HorizonFarmSettings = [PSCustomObject
                                                    $HorizonFarmSettings | Table -Name "Farm $($Farm.Data.name) Settings" -List
                                                #} # Closing qut section -Style Heading3 'Farm Settings'

                                                #section -Style Heading5 'Farm Display Protocol Settings' {
                                                $HorizonFarmDisplayProtocolSettings = [PSCustomObject]@{
                                                    'Disconnected Session Timeout Minutes' = $Farm.Data.DisplayProtocolSettings.DefaultDisplayProtocol
                                                    'Disconnected Session Timeout Policy' = $Farm.Data.DisplayProtocolSettings.AllowDisplayProtocolOverride
                                                    'Empty Session Timeout Minutes' = $Farm.Data.DisplayProtocolSettings.EnableHTMLAccess
                                                    } # Closing out $HorizonFarmDisplayProtocolSettings = [PSCustomObject]
                                                    $HorizonFarmDisplayProtocolSettings | Table -Name "Farm $($Farm.Data.name) Display Protocol Settings" -List
                                                #} # Closing qut section -Style Heading3 'Farm Settings'

                                                #section -Style Heading5 'Farm Mirage Configuration Overrides' {
                                                $HorizonFarmMirageConfigurationOverrides = [PSCustomObject]@{
                                                    'Disconnected Session Timeout Minutes' = $Farm.Data.MirageConfigurationOverrides.OverrideGlobalSetting
                                                    'Disconnected Session Timeout Policy' = $Farm.Data.MirageConfigurationOverrides.Enabled
                                                    'Farm URL' = $Farm.Data.MirageConfigurationOverrides.Url
                                                    } # Closing out $HorizonFarmMirageConfigurationOverrides = [PSCustomObject]
                                                    $HorizonFarmMirageConfigurationOverrides | Table -Name "Farm $($Farm.Data.name) Mirage Configuration Overrides" -List
                                                #} # Closing out section -Style Heading3 'Farm Mirage Configuration Overrides'
                                            } # Closing qut section -Style Heading2 'Farm Info'
                                        } # Closing out foreach($farm in $farms)
                                    } # Close out section -Style Heading4 'Farms'
                                } # Close out if ($InfoLevel.Inventory.Farms -ge 2)
                            } # Close out section -Style Heading3 'Farms General Information'
                        } # Close out section -Style Heading1 'Farms'
                    } # Close out if ($InfoLevel.Inventory.Farms -ge 1)
                } # Close out if ($Farms)

                #---------------------------------------------------------------------------------------------#
                #                                   Machines                                                  #
                #---------------------------------------------------------------------------------------------#
                
                if ($Machines -or $RDSServers) {
                    PageBreak
                    section -Style Heading2 'Machines' {

                        #---------------------------------------------------------------------------------------------#
                        #                                   Machines                                                  #
                        #---------------------------------------------------------------------------------------------#

                        if ($Machines) {
                            if ($InfoLevel.Inventory.Machines.vCenterVM -ge 1) {
                                section -Style Heading3 "vCenter VM's" {
                                    foreach($Machine in $Machines.base.name) {
                                        $i++
                                    }
                                    section -Style Heading4 "vCenter VM's General Information $($i) in Total" {

                                        $MachineGeneralInfo = foreach($Machine in $Machines) {
                                            [PSCustomObject]@{
                                                'Machine Name' = $Machine.base.name
                                                'Machine Type' = $Machine.base.Type
                                                'Machine State' = $Machine.base.basicstate
                                            } # Close Out $HorizonRole = [PSCustomObject]
                                        }
                                        $MachineGeneralInfo | Table -Name "vCenter VM's General Information $($i) in Total" -ColumnWidths 30,40,30

                                        if ($InfoLevel.Inventory.Machines.vCenterVM -ge 2) {
                                            PageBreak
                                            section -Style Heading5 "Machine Details for $($i) VM's" {
                                                $ii = 0
                                                foreach($Machine in $Machines) {
                                                    # Find Access Group ID Name
                                                    foreach($AccessGroup in $AccessGroups) {
                                                        if($AccessGroup.Id.id -eq $Machine.base.accessgroup.id){
                                                            $MachineAccessgroup = $AccessGroup.Base.Name
                                                            break
                                                        } # if($AccessGroup.Id.id -eq $Machine.base.accessgroup.id)
                                                    } # Close out foreach($AccessGroup in $AccessGroups)

                                                    # Find Session ID Name
                                                    foreach($Session in $Sessions) {
                                                        $MachineSession = "N/A"
                                                        if($Session.Id.id -eq $Machine.base.Session.id){
                                                            $MachineSession = $Session.namesdata.username
                                                            break
                                                        } # Close out if($Session.Id.id -eq $Machine.base.Session.id)
                                                    } # Close out foreach($Session in $Sessions)

                                                    # Find Permission ID Name
                                                    foreach($EntitledUserOrGroupLocalMachine in $EntitledUserOrGroupLocalMachines) {
                                                        if($EntitledUserOrGroupLocalMachine.id.id -eq $Machine.base.user.id){
                                                            $MachinePermission = $EntitledUserOrGroupLocalMachine.base.displayname
                                                            break
                                                        } # Close out if($EntitledUserOrGroupLocalMachine.id.id -eq $Machine.base.user.id)
                                                    } # Close out foreach($EntitledUserOrGroupLocalMachine in $EntitledUserOrGroupLocalMachines)
                                                    
                                                    if(($ii % 2) -eq 1){
                                                        PageBreak
                                                    }
                                                    $ii++
                                                    section -Style Heading6 "vCenter VM Details for $($Machine.base.Name)" {
                                                        $Machine = [PSCustomObject]@{
                                                            'Machine Name' = $Machine.base.name
                                                            'Machine DNS Name' = $Machine.base.DnsName
                                                            'Machine Assigned User' = $MachinePermission
                                                            'Machine Access Group' = $MachineAccessgroup
                                                            'Machine Pool Name' = $Machine.base.DesktopName
                                                            'Machine Connected User' = $MachineSession
                                                            'Machine State' = $Machine.base.basicstate
                                                            'Machine Type' = $Machine.base.Type
                                                            'Machine Operating System' = $Machine.base.OperatingSystem
                                                            'Machine Operating System Architecture' = $Machine.base.OperatingSystemArchitecture
                                                            'Machine Agent Version' = $Machine.base.AgentVersion
                                                            'Machine Agent Build Number' = $Machine.base.AgentBuildNumber
                                                            'Machine Remote Experience Agent Version' = $Machine.base.RemoteExperienceAgentVersion
                                                            'Machine Remote Experience Agent Build Number' = $Machine.base.RemoteExperienceAgentBuildNumber
                                                        } # Close Out $Machine = [PSCustomObject]
                                                    $Machine | Table -Name "vCenter VM Details for $($Machine.base.Name)" -List -ColumnWidths 50,50
                                                    } # Close out section -Style Heading6 "Machine Details for $($Machine.base.Name)"
                                                } # Close out foreach($Machine in $Machines)
                                            } # Close out section -Style Heading5 'Machine Details'
                                        } # Close out if ($InfoLevel.Inventory.Machines -ge 2)  
                                    } # Close out section -Style Heading4 'Machine General Information'
                                } # Close out section -Style Heading3 "vCenter VM's"
                            } # Close out if ($InfoLevel.Inventory.Machines -ge 1) {            
                        } # Close out if ($Machines)

                        #---------------------------------------------------------------------------------------------#
                        #                                   RDS Servers                                               #
                        #---------------------------------------------------------------------------------------------#

                        if ($RDSServers) {
                            if ($InfoLevel.Inventory.Machines.RDSHosts -ge 1) {
                                PageBreak
                                section -Style Heading3 'RDS Servers' {
                                    section -Style Heading4 "RDS Hosts General Information" {

                                        $RDSServerGeneralInfo = foreach($RDSServer in $RDSServers) {
                                            [PSCustomObject]@{
                                                'RDS Host Name' = $RDSServer.base.name
                                                'RDS Host Farm Name' = $RDSServer.SummaryData.FarmName
                                                'RDS Host State' = $RDSServer.runtimedata.Status
                                            } # Close Out $HorizonRole = [PSCustomObject]
                                        }
                                        $RDSServerGeneralInfo | Table -Name 'RDS Hosts General Information' -ColumnWidths 40,30,30

                                        if ($InfoLevel.Inventory.Machines.RDSHosts -ge 2) {
                                            section -Style Heading5 "RDS Hosts Details" {
                                                PageBreak
                                                $ii = 0
                                                foreach($RDSServer in $RDSServers) {

                                                    # Find Access Group ID Name
                                                    foreach($AccessGroup in $AccessGroups) {
                                                        if($AccessGroup.Id.id -eq $RDSServers.base.accessgroup.id){
                                                            $RDSServerAccessgroup = $AccessGroup.Base.Name
                                                            break
                                                        } # if($AccessGroup.Id.id -eq $RDSServers.base.accessgroup.id)
                                                    } # Close out foreach($AccessGroup in $AccessGroups)
                                                    
                                                    if(($ii % 2) -eq 1){
                                                        PageBreak
                                                    }
                                                    $ii++
                                                    section -Style Heading6 "RDS Host Details for $($RDSServer.base.Name)" {
                                                        $RDSServer = [PSCustomObject]@{
                                                            'RDS Host Name' = $RDSServer.base.name
                                                            'RDS Host Description' = $RDSServer.base.Description
                                                            'RDS Host Farm Name' = $RDSServer.SummaryData.FarmName
                                                            'RDS Host Desktop Pool Name' = $RDSServer.SummaryData.DesktopName
                                                            'RDS Host Farm Type' = $RDSServer.SummaryData.FarmType
                                                            'RDS Host Access Group' = $RDSServerAccessgroup
                                                            'RDS Host Message Security Mode' = $RDSServer.MessageSecurityData.MessageSecurityMode
                                                            'RDS Host Message Security Enhanced Mode Supported' = $RDSServer.MessageSecurityData.MessageSecurityEnhancedModeSupported
                                                            'RDS Host Operating System' = $RDSServer.agentdata.OperatingSystem
                                                            'RDS Host Agent Version' = $RDSServer.agentdata.AgentVersion
                                                            'RDS Host Agent Build Number' = $RDSServer.agentdata.AgentBuildNumber
                                                            'RDS Host Remote Experience Agent Version' = $RDSServer.agentdata.RemoteExperienceAgentVersion
                                                            'RDS Host Remote Experience Agent Build Number' = $RDSServer.agentdata.RemoteExperienceAgentBuildNumber
                                                            'RDS Host Max Sessions Type' = $RDSServer.settings.SessionSettings.MaxSessionsType
                                                            'RDS Host Max Sessions Set By Admin' = $RDSServer.settings.SessionSettings.MaxSessionsSetByAdmin
                                                            'RDS Host Agent Max Sessions Type' = $RDSServer.settings.AgentMaxSessionsData.MaxSessionsType
                                                            'RDS Host Agent Max Sessions Set By Admin' = $RDSServer.settings.AgentMaxSessionsData.MaxSessionsSeenByAgent
                                                            'RDS Host Enabled' = $RDSServer.settings.enabled
                                                            'RDS Host Status' = $RDSServer.runtimedata.Status

                                                        } # Close Out $RDSServer = [PSCustomObject]
                                                    $RDSServer | Table -Name "RDS Host Details for $($RDSServer.base.Name)" -List -ColumnWidths 50,50
                                                    } # Close out section -Style Heading6 "RDS Host Details for $($RDSServer.base.Name)"
                                                } # Close out foreach($RDSServer in $RDSServers)
                                            } # Close out section -Style Heading5 'RDS Host Details'
                                        } # Close out if ($InfoLevel.Inventory.Machines.RDSHosts -ge 2)  
                                    } # Close out section -Style Heading4 'RDS Host General Information'
                                } # Close out section -Style Heading3 'Machines'
                            } # Close out if ($InfoLevel.Inventory.Machines.RDSHosts -ge 1) {            
                        } # Close out if ($RDSServers)

                    } # Close out section -Style Heading1 'Machines'
                } # Close out if ($Machines -or $RDSServers)

                #---------------------------------------------------------------------------------------------#
                #                              Persistent Disks                                               #
                #---------------------------------------------------------------------------------------------#
                
                if ($PersistentDisks) {
                    if ($InfoLevel.Inventory.PersistentDisks -ge 1) {
                        PageBreak
                        section -Style Heading2 'Persistent Disks' {
                            section -Style Heading3 "Persistent Disks General Information" {

                                $PersistentDiskGeneralInfo = foreach($PersistentDisk in $PersistentDisks) {
                                    [PSCustomObject]@{
                                        'Persistent Disk Name' = $PersistentDisk.General.name
                                        'Persistent Disk Usage' = $PersistentDisk.General.Usage
                                        'Persistent Disk Status' = $PersistentDisk.General.Status
                                    } # Close Out $HorizonRole = [PSCustomObject]
                                }
                                $PersistentDiskGeneralInfo | Table -Name 'Persistent Disks General Information' -ColumnWidths 40,30,30

                                if ($InfoLevel.Inventory.PersistentDisks -ge 2) {
                                    section -Style Heading4 "Persistent Disks Details" {
                                        foreach($PersistentDisk in $PersistentDisks) {
                                            
                                            # Find Access Group ID Name
                                            foreach($AccessGroup in $AccessGroups) {
                                                if($AccessGroup.Id.id -eq $PersistentDisk.General.Access.id){
                                                    $PersistentDiskAccessgroup = $AccessGroup.Base.Name
                                                    break
                                                } # if($AccessGroup.Id.id -eq $RDSServers.base.accessgroup.id)
                                            } # Close out foreach($AccessGroup in $AccessGroups)

                                            # Desktop Info
                                            $DesktopInfo = $hzServices.Desktop.Desktop_GetSummaryView($PersistentDisk.General.desktop)

                                            # User Info
                                            $UserorGroupInfo = $hzServices.EntitledUserOrGroup.EntitledUserOrGroup_Get($PersistentDisk.General.user)

                                            # vCenter Info
                                            $vCenterInfo = $hzServices.VirtualCenter.VirtualCenter_Get($PersistentDisk.Storage.VirtualCenter)


                                            section -Style Heading5 "Persistent Disk for $($PersistentDisk.General.name)" {
                                                $PersistentDisk = [PSCustomObject]@{
                                                    'Persistent Disk Name' = $PersistentDisk.General.name
                                                    'Persistent Disk Desktop' = $DesktopInfo.DesktopSummaryData.Name
                                                    'Persistent Disk User' = $UserorGroupInfo.Base.DisplayName
                                                    'Persistent Disk Access Group' = $PersistentDiskAccessgroup
                                                    'Persistent Disk Usage' = $PersistentDisk.General.Usage
                                                    'Persistent Disk Status' = $PersistentDisk.General.Status
                                                    'Persistent Disk vCenter' = $vCenterInfo.DisplayName
                                                    'Persistent Disk DataStore Name' = $PersistentDisk.Storage.DatastoreName
                                                    'Persistent Disk Capacity in MB' = $PersistentDisk.Storage.CapacityMB
                                                } # Close Out $PersistentDisk = [PSCustomObject]
                                            $PersistentDisk | Table -Name "Persistent Disk for $($PersistentDisk.General.name)" -List -ColumnWidths 50,50
                                            } # Close out section -Style Heading5 "Persistent Disk Details"
                                        } # Close out foreach($PersistentDisk in $PersistentDisks)
                                    } # Close out section -Style Heading4 'Persistent Disks Details'
                                } # Close out if ($InfoLevel.Inventory.Machines -ge 2)  
                            } # Close out section -Style Heading3 'Persistent Disks General Information'         
                        } # Close out section -Style Heading2 'Persistent Disks'
                    } # Close out if ($InfoLevel.Inventory.Machines -ge 1)      
                } # Close out if ($PersistentDisks)
                
                #---------------------------------------------------------------------------------------------#
                #                                  ThinApps                                                   #
                #---------------------------------------------------------------------------------------------#
                
                <#
                section -Style Heading2 'ThinApps' {

                    # Generate report if connection to Horizon Environment Security Servers is successful
                    if ($ThinApps) {
                        if ($InfoLevel.Inventory.ThinApps -ge 1) {
                            section -Style Heading3 'ThinApps General Information' {
                                $ThinAppGeneralInfo = foreach($ThinApp in $ThinApps) {
                                    [PSCustomObject]@{
                                        'Display Name' = $ThinApp.Data.displayName
                                    }
                                }
                                $ThinAppGeneralInfo | Table -Name 'ThinApps General Information' -ColumnWidths 40,30,30
                            
                                if ($InfoLevel.Inventory.ThinApps -ge 2) {
                                    section -Style Heading1 'ThinApps Details' {
                                    
                                            foreach($ThinApp in $ThinApps) {
                                                section -Style Heading2 'ThinApp' {
                                                    $HorizonThinApp = [PSCustomObject]@{

                                                        'Row Info' = $ThinApp

                                                    } # Close Out $HorizonSecurityServers = [PSCustomObject]
                                                $HorizonThinApp | Table -Name 'VMware Horizon ThinApp Information' -List
                                                } # Close out section -Style Heading2 'ThinApp'
                                            } # Close out foreach($ThinApp in $ThinApps)
                                    } # Close out section -Style Heading2 'VMware ThinApps'
                                }
                            }
                        }
                    } # Close out if ($ThinApps)

                } # Close out section -Style Heading1 'ThinApps'
                #>

                #---------------------------------------------------------------------------------------------#
                #                             Global Entitlements                                             #
                #---------------------------------------------------------------------------------------------#

                if ($GlobalEntitlements -or $GlobalApplicationEntitlementGroups) {
                        if ($InfoLevel.Inventory.GlobalEntitlements -ge 1) {
                            PageBreak
                            section -Style Heading2 'Global Entitlements' {
                                section -Style Heading3 'Global Entitlements General Information' {
                                    if ($GlobalEntitlements) {
                                        $GlobalEntitlementsGeneralInfo = foreach($GlobalEntitlement in $GlobalEntitlements) {
                                            $GlobalEntitlementPodCount = ($GlobalEntitlement.data.memberpods.id).count
                                            [PSCustomObject]@{
                                                'Entitlement Name' = $GlobalEntitlement.base.DisplayName
                                                'Entitlement Type' = 'Desktop'
                                                'Entitlement Number of Pods' = $GlobalEntitlementPodCount
                                            }
                                        }
                                        $GlobalEntitlementsGeneralInfo | Table -Name 'Global Entitlements General Information' -ColumnWidths 40,30,30
                                    }

                                    if ($GlobalApplicationEntitlementGroups) {
                                        $GlobalApplicationEntitlementsGeneralInfo = foreach($GlobalApplicationEntitlementGroup in $GlobalApplicationEntitlementGroups) {
                                            $GlobalEntitlementPodCount = ($GlobalApplicationEntitlementGroup.data.memberpods.id).count
                                            [PSCustomObject]@{
                                                'Entitlement Name' = $GlobalApplicationEntitlementGroup.base.DisplayName
                                                'Entitlement Type' = 'Application'
                                                'Entitlement Number of Pods' = $GlobalEntitlementPodCount
                                            }
                                        }
                                        $GlobalApplicationEntitlementsGeneralInfo | Table -Name 'Global Entitlements General Information' -ColumnWidths 40,30,30
                                    }
                                
                                    if ($InfoLevel.Inventory.GlobalEntitlements -ge 2) {
                                        section -Style Heading4 'Global Entitlement Details' {
                                            if ($GlobalEntitlements) {
                                                foreach($GlobalEntitlement in $GlobalEntitlements) {

                                                    # Find Pod Name
                                                    $PodIDList = ''
                                                    $EntitlementGroupPodList = $GlobalEntitlement.Data.MemberPods
                                                    foreach($EntitlementGroupPod in $EntitlementGroupPodList) {
                                                        $PodID = $hzServices.Pod.Pod_Get($EntitlementGroupPod)
                                                        $PodIDList += $PodID.DisplayName -join "`r`n" | Out-String

                                                    } # Close out foreach($EntitlementGroupPod in $EntitlementGroupPodList)
                                                    
                                                    foreach($Pool in $Pools){
                                                        if($Pool.GlobalEntitlementData.GlobalEntitlement.id -eq $GlobalEntitlement.Id.id) {
                                                            $LocalSitePool = $pool.Base.Name
                                                        } # Close out if($Pool.GlobalEntitlementData.GlobalEntitlement.id -eq $GlobalEntitlement.Id.id)
                                                    } # Close out foreach($Pool in $Pools)
                                                
                            
                                                    $GESupportedDisplayProtocols = $GlobalEntitlement.Base | ForEach-Object { $_.SupportedDisplayProtocols} 
                                                    $GESupportedDisplayProtocolsresult = $GESupportedDisplayProtocols -join ', '
                                                    
                                                    PageBreak
                                                    section -Style Heading5 "Global Entitlement $($GlobalEntitlement.Base.DisplayName)" {
                                                        $HorizonGlobalEntitlements = [PSCustomObject]@{
                            
                                                            'Global Entitlement Display Name' = $GlobalEntitlement.Base.DisplayName
                                                            'Global Entitlement Description' = $GlobalEntitlement.Base.Description
                                                            'Global Entitlement Base Scope' = $GlobalEntitlement.Base.Scope
                                                            'Global Entitlement Dedicated' = $GlobalEntitlement.Base.Dedicated
                                                            'Global Entitlement From Home' = $GlobalEntitlement.Base.FromHome
                                                            'Global Entitlement Require Home Site' = $GlobalEntitlement.Base.RequireHomeSite
                                                            'Global Entitlement Multiple Session Auto Clean' = $GlobalEntitlement.Base.MultipleSessionAutoClean
                                                            'Global Entitlement Enabled' = $GlobalEntitlement.Base.Enabled
                                                            'Global Entitlement Supported Display Protocols' = $GESupportedDisplayProtocolsresult
                                                            'Global Entitlement Default Display Protocol' = $GlobalEntitlement.Base.DefaultDisplayProtocol
                                                            'Global Entitlement Allow Users to Choose Protocol' = $GlobalEntitlement.Base.AllowUsersToChooseProtocol
                                                            'Global Entitlement Allow Users to Reset Machines' = $GlobalEntitlement.Base.AllowUsersToResetMachines
                                                            'Global Entitlement Enable HTML Access' = $GlobalEntitlement.Base.EnableHTMLAccess
                                                            'Global Entitlement Allow Multiple Sessions Per User' = $GlobalEntitlement.Base.AllowMultipleSessionsPerUser
                                                            'Global Entitlement Connection Server Restrictions' = $GlobalEntitlement.Base.ConnectionServerRestrictions
                                                            'Global Entitlement Category Folder Name' = $GlobalEntitlement.Base.CategoryFolderName
                                                            'Global Entitlement Client Restrictions' = $GlobalEntitlement.Base.ClientRestrictions
                                                            'Global Entitlement Enable Collaboration' = $GlobalEntitlement.Base.EnableCollaboration
                                                            'Global Entitlement Shortcut Locations' = $($GlobalEntitlement.Base.ShortcutLocations)
                                                            'Global Entitlement Cloud Managed' = $GlobalEntitlement.Base.CloudManaged
                                                            'Global Entitlement Local Desktop Count' = $GlobalEntitlement.Data.LocalDesktopCount
                                                            'Global Entitlement Remote Desktop Count' = $GlobalEntitlement.Data.RemoteDesktopCount
                                                            'Global Entitlement User Count' = $GlobalEntitlement.Data.UserCount
                                                            'Global Entitlement User Group Count' = $GlobalEntitlement.Data.UserGroupCount
                                                            'Global Entitlement User Group Site Override Count' = $GlobalEntitlement.Data.UserGroupSiteOverrideCount
                                                            'Global Entitlement Member Pods' = $PodIDList
                                                            'Global Entitlement Local Site Pool' = $LocalSitePool
                                                        } # Close Out $HorizonGlobalEntitlements = [PSCustomObject]
                                                    $HorizonGlobalEntitlements | Table -Name "Global Entitlement $($GlobalEntitlement.Base.DisplayName)" -List -ColumnWidths 60,40
                                                    } # Close out section -Style Heading2 '$Global Entitlement'

                                                    section -Style Heading6 "Global Entitlement $($GlobalEntitlement.Base.DisplayName) Users and Groups List" {
                                                        $GlobalEntitlementsUsersList = foreach($EntitledUserOrGroupGlobalMachine in $EntitledUserOrGroupGlobalMachines) {
                                                            if($EntitledUserOrGroupGlobalMachine.globaldata.GlobalEntitlements.id -eq $GlobalEntitlement.id.id) {
                                                                [PSCustomObject]@{
                                                                    'User or Group Name' = $EntitledUserOrGroupGlobalMachine.base.name
                                                                    'Domain' = $EntitledUserOrGroupGlobalMachine.base.domain
                                                                    'Email' = $EntitledUserOrGroupGlobalMachine.base.email
                                                                }
                                                            } # Close out if($EntitledUserOrGroupGlobalMachine.globaldata.GlobalEntitlements.id -eq $GlobalEntitlement.id.id)
                                                        } # Close out foreach($EntitledUserOrGroupGlobalMachine in $EntitledUserOrGroupGlobalMachines)
                                                        $GlobalEntitlementsUsersList | Table -Name "Global Entitlement $($GlobalEntitlement.Base.DisplayName) Users and Groups List" -ColumnWidths 40,30,30
                                                    } # Close out section -Style Heading6 "Global Entitlement $($GlobalEntitlement.Base.DisplayName) Users and Groups List"
                                                    
                                                    
                                                    if ($InfoLevel.Inventory.GlobalEntitlements -ge 3) {
                                                        foreach($EntitledUserOrGroupGlobalMachine in $EntitledUserOrGroupGlobalMachines) {
                                                            if($EntitledUserOrGroupGlobalMachine.globaldata.GlobalEntitlements.id -eq $GlobalEntitlement.id.id) {
                                                                Switch ($EntitledUserOrGroupGlobalMachine.base.Group)
                                                                {
                                                                    'True' {$EntitledUserOrGroupGlobalMachinegroup = 'Group' }
                                                                    'False' {$EntitledUserOrGroupGlobalMachinegroup = 'User' }
                                                                }
                                                                
                                                                # Home Site Info
                                                                $EUGGMHomeSiteName = ''
                                                                if($EntitledUserOrGroupGlobalMachine.GlobalData.UserHomeSites){
                                                                    $EUGGMHomeSites = $hzServices.UserHomeSite.UserHomeSite_GetInfos($EntitledUserOrGroupGlobalMachine.GlobalData.UserHomeSites)
                                                                    $EUGGMHomeSiteNameList = ''
                                                                    foreach ($EUGGMHomeSite in $EUGGMHomeSites.base.Site) {
                                                                        $EUGGMHomeSiteName = $hzServices.Site.Site_Get($EUGGMHomeSite)
                                                                        $EUGGMHomeSiteDisplayName = $EUGGMHomeSiteName.Base.DisplayName
                                                                        $EUGGMHomeSiteNameList += "$EUGGMHomeSiteDisplayName, "
                                                                    }
                                                                    $EUGGMHomeSiteNameListTrim = $EUGGMHomeSiteNameList.TrimEnd(', ')
                                                                }

                                                                # Pod Details
                                                                $EUGGMPodDetails = ''
                                                                if($EntitledUserOrGroupGlobalMachine.GlobalData.PodAssignments){
                                                                    $EUGGMPodAssignment = $hzServices.PodAssignment.PodAssignment_GetInfos($EntitledUserOrGroupGlobalMachine.GlobalData.PodAssignments)
                                                                    $EUGGMPodDetails = $hzServices.Pod.Pod_Get($EUGGMPodAssignment.data.pod)
                                                                }

                                                                PageBreak
                                                                section -Style Heading7 "Global Entitlement $($EntitledUserOrGroupGlobalMachinegroup) Details for $($EntitledUserOrGroupGlobalMachine.base.Name)" {
                                                                    $HorizonEntitledUserOrGroupGlobalMachine = [PSCustomObject]@{
                                                                        'Global Entitlement Name' = $EntitledUserOrGroupGlobalMachine.base.Name
                                                                        'Group or User' = $EntitledUserOrGroupGlobalMachinegroup
                                                                        'Global Entitlement SID' = $EntitledUserOrGroupGlobalMachine.base.Sid
                                                                        'Global Entitlement Domain' = $EntitledUserOrGroupGlobalMachine.base.Domain
                                                                        'Global Entitlement Ad Distinguished Name' = $EntitledUserOrGroupGlobalMachine.base.AdDistinguishedName
                                                                        'Global Entitlement First Name' = $EntitledUserOrGroupGlobalMachine.base.FirstName
                                                                        'Global Entitlement Group Last Name' = $EntitledUserOrGroupGlobalMachine.base.LastName
                                                                        'Global Entitlement Login Name' = $EntitledUserOrGroupGlobalMachine.base.LoginName
                                                                        'Global Entitlement Display Name' = $EntitledUserOrGroupGlobalMachine.base.DisplayName
                                                                        'Global Entitlement Long Display Name' = $EntitledUserOrGroupGlobalMachine.base.LongDisplayName
                                                                        'Global Entitlement Email' = $EntitledUserOrGroupGlobalMachine.base.Email
                                                                        'Global Entitlement Kiosk User' = $EntitledUserOrGroupGlobalMachine.base.KioskUser
                                                                        'Global Entitlement Phone' = $EntitledUserOrGroupGlobalMachine.base.Phone
                                                                        'Global Entitlement Description' = $EntitledUserOrGroupGlobalMachine.base.Description
                                                                        'Global Entitlement In Folder' = $EntitledUserOrGroupGlobalMachine.base.InFolder
                                                                        'Global Entitlement User Principal Name' = $EntitledUserOrGroupGlobalMachine.base.UserPrincipalName
                                                                        'Global Entitlement User Home Site' = $EUGGMHomeSiteNameListTrim
                                                                        'Global Entitlement Pod Assignment' = $EUGGMPodDetails.DisplayName
                                                                    } # Close Out $HorizonEntitledUserOrGroupGlobalMachine = [PSCustomObject]
                                                                    $HorizonEntitledUserOrGroupGlobalMachine | Table -Name "Global Entitlement $($EntitledUserOrGroupGlobalMachinegroup) Details for $($EntitledUserOrGroupGlobalMachine.base.Name)" -List -ColumnWidths 60,40
                                                                } # Close out section -Style Heading6 "Global Entitlement Details for $($EntitledUserOrGroupGlobalMachine.base.Name)"
                                                            } # Close out if($EntitledUserOrGroupGlobalMachine.globaldata.GlobalEntitlements.id -eq $GlobalEntitlement.id.id)
                                                        } # Close out foreach($EntitledUserOrGroupGlobalMachine in $EntitledUserOrGroupGlobalMachines)
                                                    } # Close out if ($InfoLevel.Inventory.GlobalEntitlements -ge 3)
                                                } # Close out foreach($GlobalEntitlement in $GlobalEntitlements)
                                            } # Close out if ($GlobalEntitlements)

                                            if ($GlobalApplicationEntitlementGroups) {
                                                foreach($GlobalApplicationEntitlementGroup in $GlobalApplicationEntitlementGroups) {

                                                    # Find Pod Name
                                                    $ApplicationPodIDList = ''
                                                    $ApplicationEntitlementGroupPodList = $GlobalApplicationEntitlementGroup.Data.MemberPods
                                                    foreach($ApplicationEntitlementGroupPod in $ApplicationEntitlementGroupPodList) {
                                                        $ApplicationPodID = $hzServices.Pod.Pod_Get($ApplicationEntitlementGroupPod)
                                                        $ApplicationPodIDList += $ApplicationPodID.DisplayName -join "`r`n" | Out-String
                                                    } # Close out foreach($ApplicationEntitlementGroupPod in $ApplicationEntitlementGroupPodList)
                                                    
                                                    foreach($Pool in $Pools){
                                                        if($Pool.GlobalEntitlementData.GlobalEntitlement.id -eq $GlobalEntitlement.Id.id) {
                                                            $LocalSitePool = $pool.Base.Name
                                                        } # Close out if($Pool.GlobalEntitlementData.GlobalEntitlement.id -eq $GlobalEntitlement.Id.id)
                                                    } # Close out foreach($Pool in $Pools)

                                                    # Find Application Icon
                                                    $ApplicationEntitlementGroupApplicationIconSource = ''
                                                    $ApplicationEntitlementGroupApplicationIconApplication = ''
                                                    $ApplicationEntitlementGroupApplicationIconList = $GlobalApplicationEntitlementGroup.Icons
                                                    foreach($ApplicationEntitlementGroupApplicationIcon in $ApplicationEntitlementGroupApplicationIconList) {
                                                        $ApplicationEntitlementGroupApplicationIconID = $hzServices.ApplicationIcon.ApplicationIcon_Get($ApplicationEntitlementGroupApplicationIcon)
                                                        $ApplicationEntitlementGroupApplicationIconSource += $ApplicationEntitlementGroupApplicationIconID.base.IconSource -join "`r`n" | Out-String
                                                        $ApplicationEntitlementGroupApplicationIconApplication += $ApplicationEntitlementGroupApplicationIconID.base.Applications -join "`r`n" | Out-String
                                                    } # Close out foreach($ApplicationEntitlementGroupApplicationIcon in $ApplicationEntitlementGroupApplicationIconList)
                            
                                                    $GESupportedDisplayProtocols = $GlobalApplicationEntitlementGroup.Base | ForEach-Object { $_.SupportedDisplayProtocols} 
                                                    $GESupportedDisplayProtocolsresult = $GESupportedDisplayProtocols -join ', '

                                                    PageBreak
                                                    section -Style Heading5 "Global Application Entitlement $($GlobalApplicationEntitlementGroup.Base.DisplayName)" {
                                                        $HorizonGlobalEntitlements = [PSCustomObject]@{
                            
                                                            'Global Entitlement Display Name' = $GlobalApplicationEntitlementGroup.Base.DisplayName
                                                            'Global Entitlement Description' = $GlobalApplicationEntitlementGroup.Base.Description
                                                            'Global Entitlement Base Scope' = $GlobalApplicationEntitlementGroup.Base.Scope
                                                            'Global Entitlement From Home' = $GlobalApplicationEntitlementGroup.Base.FromHome
                                                            'Global Entitlement Require Home Site' = $GlobalApplicationEntitlementGroup.Base.RequireHomeSite
                                                            'Global Entitlement Multiple Session Auto Clean' = $GlobalApplicationEntitlementGroup.Base.MultipleSessionAutoClean
                                                            'Global Entitlement Enabled' = $GlobalApplicationEntitlementGroup.Base.Enabled
                                                            'Global Entitlement Supported Display Protocols' = $GESupportedDisplayProtocolsresult
                                                            'Global Entitlement Default Display Protocol' = $GlobalApplicationEntitlementGroup.Base.DefaultDisplayProtocol
                                                            'Global Entitlement Allow Users to Choose Protocol' = $GlobalApplicationEntitlementGroup.Base.AllowUsersToChooseProtocol
                                                            'Global Entitlement Allow Users to Reset Machines' = $GlobalApplicationEntitlementGroup.Base.AllowUsersToResetMachines
                                                            'Global Entitlement Enable HTML Access' = $GlobalApplicationEntitlementGroup.Base.EnableHTMLAccess
                                                            'Global Entitlement Allow Multiple Sessions Per User' = $GlobalApplicationEntitlementGroup.Base.AllowMultipleSessionsPerUser
                                                            'Global Entitlement Connection Server Restrictions' = $GlobalApplicationEntitlementGroup.Base.ConnectionServerRestrictions
                                                            'Global Entitlement Enable Pre-Launch' = $GlobalApplicationEntitlementGroup.Base.EnablePreLaunch
                                                            'Global Entitlement Category Folder Name' = $GlobalApplicationEntitlementGroup.Base.CategoryFolderName
                                                            'Global Entitlement Client Restrictions' = $GlobalApplicationEntitlementGroup.Base.ClientRestrictions
                                                            'Global Entitlement Shortcut Locations' = $($GlobalApplicationEntitlementGroup.Base.ShortcutLocations)
                                                            'Global Entitlement Multi Session Mode' = $GlobalApplicationEntitlementGroup.Base.MultiSessionMode
                                                            'Global Entitlement Local Application Count' = $GlobalApplicationEntitlementGroup.data.LocalApplicationCount
                                                            'Global Entitlement Remote Application Count' = $GlobalApplicationEntitlementGroup.data.RemoteApplicationCount
                                                            'Global Entitlement User Count' = $GlobalApplicationEntitlementGroup.data.UserCount
                                                            'Global Entitlement User Group Count' = $GlobalApplicationEntitlementGroup.data.UserGroupCount
                                                            'Global Entitlement User Group Site Override Count' = $GlobalApplicationEntitlementGroup.data.UserGroupSiteOverrideCount
                                                            'Global Entitlement Member Pods' = $ApplicationPodIDList
                                                            'Global Entitlement Local Site Pool' = $LocalSitePool
                                                            'Global Entitlement Executable Path' = $GlobalApplicationEntitlementGroup.ExecutionData.ExecutablePath
                                                            'Global Entitlement Publisher' = $GlobalApplicationEntitlementGroup.ExecutionData.Publisher
                                                            'Global Entitlement Version' = $GlobalApplicationEntitlementGroup.ExecutionData.Version
                                                            #'Global Entitlement Icon Source' = $ApplicationEntitlementGroupApplicationIconSource
                                                            #'Global Entitlement Icon Application' = $ApplicationEntitlementGroupApplicationIconApplication
                                                        } # Close Out $HorizonGlobalEntitlements = [PSCustomObject]
                                                    $HorizonGlobalEntitlements | Table -Name "Global Application Entitlement $($GlobalApplicationEntitlementGroup.Base.DisplayName)" -List -ColumnWidths 60,40
                                                    } # Close out section -Style Heading2 '$Global Entitlement'

                                                    section -Style Heading6 "Global Application Entitlement $($GlobalApplicationEntitlementGroup.Base.DisplayName) Users and Groups List" {
                                                        foreach($EntitledUserOrGroupGlobalMachine in $EntitledUserOrGroupGlobalMachines) {
                                                            if($EntitledUserOrGroupGlobalMachine.globaldata.GlobalApplicationEntitlements.id -eq $GlobalApplicationEntitlementGroup.id.id) {
                                                                    $EntitledUserorGroupEmail = $EntitledUserOrGroupGlobalMachine.base.email
                                                                    if(!($EntitledUserorGroupEmail)) {$EntitledUserorGroupEmail = 'N/A'}
                                                                    $GlobalAplicationEntitlementsUsersList = [PSCustomObject]@{
                                                                        'User or Group Name' = $EntitledUserOrGroupGlobalMachine.base.name
                                                                        'Domain' = $EntitledUserOrGroupGlobalMachine.base.domain
                                                                        'Email' = $EntitledUserorGroupEmail
                                                                    }
                                                                    $GlobalAplicationEntitlementsUsersList | Table -Name "Global Application Entitlement $($GlobalApplicationEntitlementGroup.Base.DisplayName) Users and Groups List" -ColumnWidths 40,30,30
                                                            } # Close out if($EntitledUserOrGroupGlobalMachine.globaldata.GlobalEntitlements.id -eq $GlobalEntitlement.id.id)
                                                        } # Close out foreach($EntitledUserOrGroupGlobalMachine in $EntitledUserOrGroupGlobalMachines)
                                                        
                                                    } # Close out section -Style Heading6 "Global Entitlement $($GlobalEntitlement.Base.DisplayName) Users and Groups List"
                                                    

                                                    if ($InfoLevel.Inventory.GlobalEntitlements -ge 3) {
                                                        foreach($EntitledUserOrGroupGlobalMachine in $EntitledUserOrGroupGlobalMachines) {
                                                            if($EntitledUserOrGroupGlobalMachine.globaldata.GlobalApplicationEntitlements.id -eq $GlobalApplicationEntitlementGroup.id.id) {
                                                                Switch ($EntitledUserOrGroupGlobalMachine.base.Group)
                                                                {
                                                                    'True' {$EntitledUserOrGroupGlobalMachinegroup = 'Group' }
                                                                    'False' {$EntitledUserOrGroupGlobalMachinegroup = 'User' }
                                                                }

                                                                # Home Site Info
                                                                $EUGGMHomeSiteName = ''
                                                                if($EntitledUserOrGroupGlobalMachine.GlobalData.UserHomeSites){
                                                                    $EUGGMHomeSites = $hzServices.UserHomeSite.UserHomeSite_GetInfos($EntitledUserOrGroupGlobalMachine.GlobalData.UserHomeSites)
                                                                    $EUGGMHomeSiteNameList = ''
                                                                    foreach ($EUGGMHomeSite in $EUGGMHomeSites.base.Site) {
                                                                        $EUGGMHomeSiteName = $hzServices.Site.Site_Get($EUGGMHomeSite)
                                                                        $EUGGMHomeSiteDisplayName = $EUGGMHomeSiteName.Base.DisplayName
                                                                        $EUGGMHomeSiteNameList += "$EUGGMHomeSiteDisplayName, "
                                                                    }
                                                                    $EUGGMHomeSiteNameListTrim = $EUGGMHomeSiteNameList.TrimEnd(', ')
                                                                }
                                                                
                                                                # Pod Details
                                                                $EUGGMPodDetails = ''
                                                                if($EntitledUserOrGroupGlobalMachine.GlobalData.PodAssignments){
                                                                    $EUGGMPodAssignment = $hzServices.PodAssignment.PodAssignment_GetInfos($EntitledUserOrGroupGlobalMachine.GlobalData.PodAssignments)
                                                                    $EUGGMPodDetails = $hzServices.Pod.Pod_Get($EUGGMPodAssignment.data.pod)
                                                                }

                                                                section -Style Heading7 "Global Entitlement $($EntitledUserOrGroupGlobalMachinegroup) Details for $($EntitledUserOrGroupGlobalMachine.base.Name)" {
                                                                    $HorizonEntitledUserOrGroupGlobalMachine = [PSCustomObject]@{
                                                                        'Global Entitlement Name' = $EntitledUserOrGroupGlobalMachine.base.Name
                                                                        'Group or User' = $EntitledUserOrGroupGlobalMachinegroup
                                                                        'Global Entitlement SID' = $EntitledUserOrGroupGlobalMachine.base.Sid
                                                                        'Global Entitlement Domain' = $EntitledUserOrGroupGlobalMachine.base.Domain
                                                                        'Global Entitlement Ad Distinguished Name' = $EntitledUserOrGroupGlobalMachine.base.AdDistinguishedName
                                                                        'Global Entitlement First Name' = $EntitledUserOrGroupGlobalMachine.base.FirstName
                                                                        'Global Entitlement Group Last Name' = $EntitledUserOrGroupGlobalMachine.base.LastName
                                                                        'Global Entitlement Login Name' = $EntitledUserOrGroupGlobalMachine.base.LoginName
                                                                        'Global Entitlement Display Name' = $EntitledUserOrGroupGlobalMachine.base.DisplayName
                                                                        'Global Entitlement Long Display Name' = $EntitledUserOrGroupGlobalMachine.base.LongDisplayName
                                                                        'Global Entitlement Email' = $EntitledUserOrGroupGlobalMachine.base.Email
                                                                        'Global Entitlement Kiosk User' = $EntitledUserOrGroupGlobalMachine.base.KioskUser
                                                                        'Global Entitlement Phone' = $EntitledUserOrGroupGlobalMachine.base.Phone
                                                                        'Global Entitlement Description' = $EntitledUserOrGroupGlobalMachine.base.Description
                                                                        'Global Entitlement In Folder' = $EntitledUserOrGroupGlobalMachine.base.InFolder
                                                                        'Global Entitlement User Principal Name' = $EntitledUserOrGroupGlobalMachine.base.UserPrincipalName
                                                                        'Global Entitlement User Home Site' = $EUGGMHomeSiteNameListTrim
                                                                        'Global Entitlement Pod Assignment' = $EUGGMPodDetails.DisplayName
                                                                    } # Close Out $HorizonEntitledUserOrGroupGlobalMachine = [PSCustomObject]
                                                                    $HorizonEntitledUserOrGroupGlobalMachine | Table -Name "Global Entitlement $($EntitledUserOrGroupGlobalMachinegroup) Details for $($EntitledUserOrGroupGlobalMachine.base.Name)" -List -ColumnWidths 60,40
                                                                } # Close out section -Style Heading6 "Global Entitlement Details for $($EntitledUserOrGroupGlobalMachine.base.Name)"
                                                            } # Close out if($EntitledUserOrGroupGlobalMachine.globaldata.GlobalEntitlements.id -eq $GlobalEntitlement.id.id)
                                                        } # Close out foreach($EntitledUserOrGroupGlobalMachine in $EntitledUserOrGroupGlobalMachines)
                                                    } # Close out if ($InfoLevel.Inventory.GlobalEntitlements -ge 3)
                                                } # Close out foreach($GlobalApplicationEntitlementGroup in $GlobalApplicationEntitlementGroups)
                                            } # Close out if ($GlobalApplicationEntitlementGroups)
                                        } # Close out section -Style Heading4 'VMware Entitled User or Group Global Machines'
                                    } # Close out if ($InfoLevel.Inventory.GlobalEntitlements -ge 2)
                                } # Close out section -Style Heading3 'Global Entitlements General Information'
                            } # Close out section -Style Heading2 'Global Entitlements'
                        } # Close out if ($InfoLevel.Inventory.GlobalEntitlements -ge 1)
                } # Close out if ($GlobalEntitlements -or $GlobalApplicationEntitlementGroups)
            
            } # Close out section -Style Heading1 'Inventory'
        } # Close out if ($Pools -or $Apps -or $Farms -or $Machines -or $RDSServers -or $PersistentDisks -or $ThinApps -or $GlobalEntitlements -or $GlobalApplicationEntitlementGroups)

        #---------------------------------------------------------------------------------------------#
        #                                      Settings                                               #
        #---------------------------------------------------------------------------------------------#
        
        if ($vCenterServers -or $vCenterHealth -or $Composers -or $Domains -or $SecurityServers -or $GatewayServers -or $ConnectionServers -or $InstantCloneDomainAdmins -or $ProductLicenseingInfo -or $GlobalSettings -or $RDSServers -or $Administrators -or $Roles -or $Permissions -or $AccessGroups -or $CloudPodFederation -or $CloudPodSites -or $EventDataBases -or $GlobalPolicies) {
            PageBreak
            section -Style Heading1 'Settings' {
                LineBreak

                #---------------------------------------------------------------------------------------------#
                #                                      Servers                                                #
                #---------------------------------------------------------------------------------------------#
                
                if ($vCenterServers -or $vCenterHealth -or $Composers -or $Domains -or $SecurityServers -or $GatewayServers -or $ConnectionServers) {
                    section -Style Heading2 'Servers' {

                        #---------------------------------------------------------------------------------------------#
                        #                              vCenter Servers                                                #
                        #---------------------------------------------------------------------------------------------#
                        
                        if ($vCenterServers -or $vCenterHealth -or $Composers -or $Domains) {
                            section -Style Heading3 'vCenter Servers' {

                                #---------------------------------------------------------------------------------------------#
                                #                                vCenterServers                                               #
                                #---------------------------------------------------------------------------------------------#
                                
                                if ($vCenterServers) {
                                    if ($InfoLevel.Settings.Servers.vCenterServers.vCenter -ge 1) {
                                        section -Style Heading4 'Virtual Centers Information' {
                                            section -Style Heading5 "Virtual Center General Information" {
                                                $HorizonVirtualCenterGeneral = foreach($vCenterServer in $vCenterServers) {
                                                    [PSCustomObject]@{
                                                        'vCenter Server Name' = $vCenterServer.serverspec.ServerName
                                                        'vCenter Server Provisioning Enabled' = $vCenterServer.Enabled
                                                    }
                                                } # Close out $HorizonVirtualCenterGeneral = foreach($vCenterServer in $vCenterServers)
                                                $HorizonVirtualCenterGeneral | Table -Name 'Virtual Center General Information' -ColumnWidths 60,40
                                            } # Close out foreach($vCenterServer in $vCenterServers)

                                            if ($InfoLevel.Settings.Servers.vCenterServers.vCenter -ge 2) {
                                                foreach($vCenterServer in $vCenterServers) {
                                                    section -Style Heading5 "Virtual Center $($vCenterServer.serverspec.ServerName)" {
                                                        $HorizonVirtualCenter = [PSCustomObject]@{
                                                            'vCenter Server Name' = $vCenterServer.serverspec.ServerName
                                                            'vCenter Server Description' = $vCenterServer.Description
                                                            #'vCenter Server Display Name' = $vCenterServer.DisplayName
                                                            'vCenter Server Certificate Override' = $vCenterServer.CertificateOverride
                                                            'vCenter Server Provisioning Enabled' = $vCenterServer.Enabled
                                                            'vCenter Server Reclaim Disk Space' = $vCenterServer.SeSparseReclamationEnabled
                                                            'vCenter Server Port' = $vCenterServer.serverspec.Port
                                                            'vCenter Server User SSL' = $vCenterServer.serverspec.UseSSL
                                                            'vCenter Server User Name' = $vCenterServer.serverspec.UserName
                                                            'vCenter Server Type' = $vCenterServer.serverspec.ServerType
                                                            'vCenter Server Port Num' = $vCenterServer.serverspec.Port                  
                                                            'Max Concurrent vCenter Provisioning Operations' = $vCenterServer.Limits.VcProvisioningLimit
                                                            'Max Concurrent Power Operations' = $vCenterServer.Limits.VcPowerOperationsLimit
                                                            'Max Concurrent View Composer Maintenance Operations' = $vCenterServer.Limits.ViewComposerProvisioningLimit
                                                            'Max Concurrent View Composer Provisioning Operations' = $vCenterServer.Limits.ViewComposerMaintenanceLimit
                                                            'Max Concurrent Instant Clone Engine Provisioning Operations' = $vCenterServer.Limits.InstantCloneEngineProvisioningLimit
                                                            'Storage Acceleration Enabled' = $vCenterServer.StorageAcceleratorData.Enabled
                                                            'Storage Accelerator Default Cache Size in MB' = $vCenterServer.StorageAcceleratorData.DefaultCacheSizeMB
                                                        } # Close Out $HorizonVirtualCenter = [PSCustomObject]
                                                        $HorizonVirtualCenter | Table -Name "Virtual Center $($vCenterServer.serverspec.ServerName)" -List
                                                        
                                                        $HorizonVirtualCenterStorageAcceleratorHostOverrides = $vCenterServer.StorageAcceleratorData.HostOverrides        
                                                        foreach($HorizonVirtualCenterStorageAcceleratorHostOverride in $HorizonVirtualCenterStorageAcceleratorHostOverrides) {
                                                            section -Style Heading6 'Horizon Virtual Center Storage Accelerator Overrides' {
                                                                $HorizonVirtualCenterStorageAcceleratorOverrides = [PSCustomObject]@{
                                                                    'Storage Accelerator Host Over Ride Host' = $HorizonVirtualCenterStorageAcceleratorHostOverride.Path
                                                                    'Storage Accelerator Host Over Ride Cache Size in MB' = $HorizonVirtualCenterStorageAcceleratorHostOverride.CacheSizeMB
                                                                    } # Close Out $HorizonVirtualCenterStorageAcceleratorOverrides = [PSCustomObject]
                                                                $HorizonVirtualCenterStorageAcceleratorOverrides | Table -Name 'Horizon Virtual Center Storage Accelerator Overrides' -List
                                                            } # Close out section -Style Heading6 'Horizon Virtual Center Storage Accelerator Overrides'
                                                        } # Close Out foreach($HorizonVirtualCenterStorageAcceleratorHostOverride in $HorizonVirtualCenterStorageAcceleratorHostOverrides)
                                                        
                                                        $vCenterHealthData = $vCenterHealth.data
                                                        foreach($vCenterHeathInfo in $vCenterHealthData) {
                                                            section -Style Heading6 "vCenter $($vCenterServer.serverspec.ServerName) Version Information" {
                                                                $HorizonvCenterHeathInfo = [PSCustomObject]@{
                                                                    'vCenter Name' = $vCenterHeathInfo.Name
                                                                    'vCenter Version' = $vCenterHeathInfo.Version
                                                                    'vCenter Build Number' = $vCenterHeathInfo.Build
                                                                    'vCenter API Version' = $vCenterHeathInfo.ApiVersion
                                                                } # Close Out $HorizonvCenterHeathInfo = [PSCustomObject]
                                                                $HorizonvCenterHeathInfo | Table -Name "vCenter $($vCenterServer.serverspec.ServerName) Version Information" -List
                                                            } # Close out section -Style Heading6 "vCenter $($ESXHost.Name) Version Information"
                                                        } # Close out foreach($vCenterHeathInfo in $vCenterHealthData)
                                                    } # Close out section -Style Heading5 'Horizon Virtual Center'
                                                } # Close out foreach($vCenterServer in $vCenterServers)
                                            } # Close out if ($InfoLevel.Settings.Servers.vCenterServers.vCenter -ge 2) 
                                        } # Close out section -Style Heading4 'Horizon Virtual Centers'
                                    } # Close out if ($InfoLevel.ViewConfiguration.Servers.ESXHosts -ge 1)
                                } # Close out if ($vCenterServers)

                                #---------------------------------------------------------------------------------------------#
                                #                                ESX Hosts                                                    #
                                #---------------------------------------------------------------------------------------------#
                                
                                if ($vCenterHealth) {
                                    if ($InfoLevel.Settings.Servers.vCenterServers.ESXiHosts -ge 1) {
                                        PageBreak
                                        section -Style Heading4 'ESXi Hosts Information' {
                                            $ESXHosts = $vCenterHealth.hostdata

                                            section -Style Heading5 "ESXi Host General Information" {
                                                $HorizonESXHostGeneral = foreach($ESXHost in $ESXHosts) {
                                                    [PSCustomObject]@{
                                                    'ESXi Host Name' = $ESXHost.Name
                                                    'ESXi Host Status' = $ESXHost.Status
                                                    } # Close Out [PSCustomObject]
                                                } # Close Out $HorizonESXHostGeneral = foreach($ESXHost in $ESXHosts)
                                                $HorizonESXHostGeneral | Table -Name 'ESXi Host General Information' -ColumnWidths 60,40
                                            } # Close out section -Style Heading5 'ESXi Host General Information'

                                            if ($InfoLevel.Settings.Servers.vCenterServers.ESXiHosts -ge 2) {
                                                $ii = 0
                                                foreach($ESXHost in $ESXHosts) {
                                                    if ($ESXHost.hostdata.vGPUTypes) {
                                                        $vGPUTypes = [system.String]::Join(",", $ESXHost.vGPUTypes)
                                                    } # Close if ($ESXHost.hostdata.vGPUTypes)
                                                    else {
                                                        $vGPUTypes="n/a"
                                                    } # Close Else
                                                    
                                                    if(($ii % 5) -eq 0){
                                                        PageBreak
                                                    }
                                                    $ii++

                                                    section -Style Heading5 "ESXi Host $($ESXHost.Name) Information" {
                                                        $HorizonESXHost = [PSCustomObject]@{
                                                            'ESXi Host Name' = $ESXHost.Name
                                                            'ESXi Host Version' = $ESXHost.Version
                                                            'ESXi Host API Version' = $ESXHost.APIVersion
                                                            'ESXi Host Status' = $ESXHost.Status
                                                            'ESXi Host Cluster Name' = $ESXHost.ClusterName
                                                            'ESXi Host vGPU Types' = $vGPUTypes
                                                        } # Close Out $HorizonESXHost = [PSCustomObject]
                                                    $HorizonESXHost | Table -Name "ESXi Host $($ESXHost.Name) Information" -List -ColumnWidths 60,40
                                                    } # Close out section -Style Heading5 'ESXi Host Info'
                                                } # Close out foreach($ESXHost in $ESXHosts)
                                            } # Close out if ($InfoLevel.Settings.Servers.vCenterServers.ESXiHosts -ge 2) 
                                        } # Close out section -Style Heading4 'ESXi Host Info'
                                    } # Close out if ($InfoLevel.Settings.Servers.vCenterServers.ESXiHosts -ge 1)
                                } # Close out if ($ESXHosts)

                                #---------------------------------------------------------------------------------------------#
                                #                                DataStores                                                   #
                                #---------------------------------------------------------------------------------------------#
                                
                                if ($vCenterHealth) {
                                    if ($InfoLevel.Settings.Servers.vCenterServers.DataStores -ge 1) {
                                        PageBreak
                                        section -Style Heading4 'Datastore Information' {
                                            $datastores = $vCenterHealth.datastoredata
                                            section -Style Heading5 "Datastore General Information" {
                                                $HorizonDataStoreGeneral = foreach($DataStore in $datastores) {
                                                    [PSCustomObject]@{
                                                        'Horizon Datastore Name' = $DataStore.name
                                                        'Horizon Datastore Accessible' = $DataStore.Accessible
                                                    } # Close Out $HorizonDataStoreGeneral = [PSCustomObject]
                                                } # Close out $HorizonDataStoreGeneral = foreach($DataStore in $datastores)    
                                                $HorizonDataStoreGeneral | Table -Name 'Datastore General Information' -ColumnWidths 60,40
                                            } # Close out section -Style Heading5 "Datastore General Information"

                                            if ($InfoLevel.Settings.Servers.vCenterServers.DataStores -ge 2) {
                                                $ii = 0
                                                foreach($DataStore in $datastores) {
                                                    if(($ii % 5) -eq 0){
                                                        PageBreak
                                                    }
                                                    $ii++
                                                    section -Style Heading5 "Horizon Datastore $($DataStore.name) Information" {
                                                        $HorizonDataStore = [PSCustomObject]@{
                                                            'Horizon Datastore Name' = $DataStore.name
                                                            'Horizon Datastore Accessible' = $DataStore.Accessible
                                                            'Horizon Datastore Path' = $DataStore.Path
                                                            'Horizon Datastore Type' = $DataStore.DataStoreType
                                                            'Horizon Datastore Capacity in MB' = $DataStore.CapacityMB
                                                            'Horizon Datastore Free Space in MB' = $DataStore.FreeSpaceMB
                                                        } # Close Out $HorizonDataStore = [PSCustomObject]                                            
                                                    $HorizonDataStore | Table -Name "Horizon Datastore $($DataStore.name) Information" -List -ColumnWidths 50,50
                                                    } # Close out section -Style Heading5 'Horizon DataStore Info'
                                                } # Close out foreach($DataStore in $DataStores)
                                            } # Close out if ($InfoLevel.Settings.Servers.vCenterServers.DataStores -ge 2)
                                        } # Close out section -Style Heading4 'Horizon DataStores Info'
                                    } # Close out if ($InfoLevel.Settings.Servers.vCenterServers.DataStores -ge 1)
                                } # Close out if ($DataStores)

                                #---------------------------------------------------------------------------------------------#
                                #                                             Composer                                        #
                                #---------------------------------------------------------------------------------------------#
                                
                                if ($Composers) {
                                    if ($InfoLevel.Settings.Servers.vCenterServers.Composers -ge 1) {
                                        PageBreak
                                        section -Style Heading4 'Composer Information' {
                                            foreach($Composer in $Composers) {
                                                $HorizonComposer = [PSCustomObject]@{
                                                    'Composer Enabled' = $Composer.ViewComposerType
                                                    'Composer Server Address' = $Composer.ServerSpec.ServerName
                                                    'Composer Admin Username' = $Composer.ServerSpec.UserName
                                                    'Composer Port' = $Composer.ServerSpec.Port
                                                    'Composer SSL Enabled' = $Composer.ServerSpec.UseSSL
                                                } # Close Out $HorizonComposer = [PSCustomObject]
                                            } # Close out foreach($Composer in $Composers)
                                            $HorizonComposer | Table -Name 'Composer Information' -ColumnWidths 60,50
                                        } # Close out section -Style Heading4 'Composer Information'
                                    } # Close out if ($InfoLevel.Settings.Servers.vCenterServers.Composers -ge 1) {
                                } # Close out if ($Composers) 

                                #---------------------------------------------------------------------------------------------#
                                #                            Active Directory Domains                                         #
                                #---------------------------------------------------------------------------------------------#
                                
                                if ($Domains) {
                                    if ($InfoLevel.Settings.Servers.vCenterServers.ADDomains -ge 1) {
                                        PageBreak
                                        section -Style Heading4 'Active Directory Domains' {
                                            section -Style Heading5 "Active Directory Domains General Information" {
                                                $HorizonDomainGeneral = foreach($Domain in $Domains) {
                                                    [PSCustomObject]@{
                                                    'Domain DNS Name' = $Domain.DNSName
                                                    'Domain NetBIOS Name' = $Domain.NetBiosName
                                                    'NT4 Domain' = $Domain.Nt4Domain                                                
                                                    } # Close Out $HorizonDomain = [PSCustomObject]
                                                } # Close Out section -Style Heading5 "Active Directory Domains General Information"
                                                $HorizonDomainGeneral | Table -Name 'Active Directory Domains General Information' -ColumnWidths 34,33,33
                                            } # Close Out section -Style Heading5 "Active Directory Domains General Information"

                                            if ($InfoLevel.Settings.Servers.vCenterServers.ADDomains -ge 2) {
                                                foreach($Domain in $Domains) {
                                                    PageBreak
                                                    section -Style Heading5 "Active Directory Domains $($Domain.DNSName)" {
                                                        $HorizonDomain = [PSCustomObject]@{
                                                            'Domain DNS Name' = $Domain.DNSName
                                                            'Domain NetBIOS Name' = $Domain.NetBiosName
                                                            'NT4 Domain' = $Domain.Nt4Domain                                                
                                                        } # Close Out $HorizonDomain = [PSCustomObject]
                                                        $HorizonDomain | Table -Name "Active Directory Domains $($Domain.DNSName) Information" -List -ColumnWidths 60,40

                                                        $DomainConnectionServers = $domain.ConnectionServerState
                                                        foreach($DomainConnectionServer in $DomainConnectionServers) {
                                                            $HorizonDomainCSStatus = [PSCustomObject]@{
                                                                '=========================================' = '============================='
                                                                "Horizon Domain Connection Server $($DomainConnectionServer.Connectionservername) Status" = ''
                                                                'Connection Server Name' = $DomainConnectionServer.Connectionservername
                                                                'Connection Server Status' = $DomainConnectionServer.Status
                                                                'Connection Server Trust Relationship' = $DomainConnectionServer.TrustRelationship
                                                                'Connection Server Connection Status' = $DomainConnectionServer.Contactable
                                                            } # Close Out $HorizonDomain = [PSCustomObject]
                                                            $HorizonDomainCSStatus | Table -Name "Active Directory Domains $($Domain.DNSName) Connection Server Status Information" -List -ColumnWidths 60,40
                                                        } # Close Out foreach($DomainConnectionServer in $DomainConnectionServers
                                                    } # Close out section -Style Heading5 "Horizon Domain $($Domain.DNSName)" 
                                                } # Close out foreach($Domain in $Domains)
                                            } # Close out if ($InfoLevel.Settings.Servers.vCenterServers.ADDomains -ge 1)
                                        } # Close out section -Style Heading4 'Horizon Domains'
                                    } # Close out if ($InfoLevel.Settings.Servers.vCenterServers.ADDomains -ge 1) 
                                } # Close out if ($Domains)

                            } # Close out section -Style Heading3 'vCenter Servers'
                        } # Close out if ($vCenterServers -or $vCenterHealth -or $Composers -or $Domains)

                        #---------------------------------------------------------------------------------------------#
                        #                              Security Servers                                                #
                        #---------------------------------------------------------------------------------------------#

                        if ($SecurityServers) {
                            if ($InfoLevel.Settings.Servers.SecurityServers.SecurityServers -ge 1) {
                                PageBreak
                                section -Style Heading3 'Security Servers' {
                                    section -Style Heading4 'Security Server General Information' {
                                        $SecurityServerGeneralInfo = foreach($SecurityServer in $SecurityServers) {
                                            [PSCustomObject]@{
                                                'Security Server Name' = $SecurityServer.general.name
                                                'Security Server Version' = $SecurityServer.general.version
                                                'Security Server Connection Server' = $SecurityServer.general.ConnectionServerName
                                            } # Close Out $HorizonRole = [PSCustomObject]
                                        }
                                        $SecurityServerGeneralInfo | Table -Name 'Security Server General Information' -ColumnWidths 40,30,30

                                        if ($InfoLevel.Settings.Servers.SecurityServers.SecurityServers -ge 2) {
                                            section -Style Heading5 'Security Server Details' {
                                                foreach($SecurityServer in $SecurityServers) {
                                                    section -Style Heading6 "Security Server Details for $($SecurityServer.base.Name)" {
                                                        $SecurityServer = [PSCustomObject]@{
                                                            'Security Server Name' = $SecurityServer.general.name
                                                            'Security Server Address' = $SecurityServer.general.ServerAddress
                                                            'Security Server Connection Server' = $SecurityServer.general.ConnectionServerName
                                                            'Security Server Version' = $SecurityServer.general.version
                                                            'Security Server PCoIP Gateway Installed' = $SecurityServer.general.PcoipSecureGatewayInstalled
                                                            'Security Server External URL' = $SecurityServer.general.ExternalURL
                                                            'Security Server External PCoIP URL' = $SecurityServer.general.ExternalPCoIPURL
                                                            'Security Server External PCoIP IP' = $SecurityServer.general.AuxillaryExternalPCoIPIPv4Address
                                                            'Security Server External Blast URL' = $SecurityServer.general.ExternalAppblastURL
                                                            'Message Security Mode' = $SecurityServer.messagesecurity.MessageSecurityMode
                                                            'Message Security Enhanced Mode Supported' = $SecurityServer.messagesecurity.MessageSecurityEnhancedModeSupported
                                                        } # Close Out $SecurityServer = [PSCustomObject]
                                                    $SecurityServer | Table -Name "Security Server Details for $($SecurityServer.base.Name)" -List -ColumnWidths 50,50
                                                    } # Close out section -Style Heading6 "Security Server Details for $($SecurityServer.base.Name)"
                                                } # Close out foreach($SecurityServer in $SecurityServers)
                                            } # Close out section -Style Heading5 'Security Server Details'
                                        } # Close out if ($InfoLevel.Settings.Servers.SecurityServers.SecurityServers -ge 2)  
                                    } # Close out section -Style Heading4 'Security Server General Information'         
                                } # Close out section -Style Heading3 'Security Servers'
                            } # Close out if ($InfoLevel.Settings.Servers.SecurityServers.SecurityServers -ge 1)
                        } # Close out if ($SecurityServers)            


                        #---------------------------------------------------------------------------------------------#
                        #                              Gateway Servers                                                #
                        #---------------------------------------------------------------------------------------------#

                        if ($GatewayServers) {
                            if ($InfoLevel.Settings.Servers.GatewayServers.GatewayServers -ge 1) {
                                PageBreak
                                section -Style Heading3 'Gateway Servers' {
                                    section -Style Heading4 'Gateway Servers General Information' {
                                        $HorizonGatewayServersGeneral = foreach($GatewayServer in $GatewayServers.generaldata) {
                                            Switch ($GatewayServer.Type)
                                                {
                                                    'AP' {$GatewayType = 'UAG' }
                                                }
                                            [PSCustomObject]@{
                                                'Gateway Server Name' = $GatewayServer.name
                                                'Gateway Type' = $GatewayType
                                            } # Close Out $HorizonGatewayServers = [PSCustomObject]
                                        } # Close out $HorizonGatewayServersGeneral = foreach($GatewayServer in $GatewayServers.generaldata)
                                        $HorizonGatewayServersGeneral | Table -Name 'Gateway Servers General Information' -ColumnWidths 60,40
                                    } # Close out section -Style Heading4 'Gateway Servers General Information'
                                        
                                    if ($InfoLevel.Settings.Servers.GatewayServers.GatewayServers -ge 2) {    
                                        foreach($GatewayServer in $GatewayServers.generaldata) {
                                            Switch ($GatewayServer.Type)
                                            {
                                                'AP' {$GatewayType = 'UAG' }
                                            }

                                            if(($ii % 5) -eq 0){
                                                PageBreak
                                            }
                                            $ii++

                                            section -Style Heading5 "Gateway Server $($GatewayServer.name)" {
                                                $HorizonGatewayServers = [PSCustomObject]@{
                                                    'Gateway Server Name' = $GatewayServer.name
                                                    'Gateway Server IP' = $GatewayServer.Address
                                                    'Gateway Zone Internal' = $GatewayServer.GatewayZoneInternal
                                                    'Gateway Version' = $GatewayServer.Version
                                                    'Gateway Type' = $GatewayType
                                                } # Close Out $HorizonGatewayServers = [PSCustomObject]
                                            $HorizonGatewayServers | Table -Name "Gateway Server $($GatewayServer.name)" -List -ColumnWidths 60,40
                                            } # Close out section -Style Heading5 'Gateway Server'
                                        } # Close out foreach($GatewayServer in $GatewayServers)
                                    } # Close out if ($InfoLevel.Settings.Servers.GatewayServers.GatewayServers -ge 2)
                                } # Close out section -Style Heading3 'Gateway Servers'
                            } # Close out if ($InfoLevel.Settings.Servers.GatewayServers.GatewayServers -ge 1)
                        } # Close out if ($GatewayServers)

                        #---------------------------------------------------------------------------------------------#
                        #                            Connection Servers                                               #
                        #---------------------------------------------------------------------------------------------#
                        
                        if ($ConnectionServers) {
                            if ($InfoLevel.Settings.Servers.ConnectionServers.ConnectionServers -ge 1) {
                                PageBreak
                                section -Style Heading3 'Connection Servers' {
                                    section -Style Heading4 'Connection Servers General Information' {
                                        $HorizonConnectionServerGeneralInfo = foreach($ConnectionServer in $ConnectionServers) {
                                            [PSCustomObject]@{
                                                'Connection Server FQDN' = $ConnectionServer.General.Fqhn
                                                'Enabled' = $ConnectionServer.General.Enabled
                                            } # Close out [PSCustomObject]
                                        } # Close out $HorizonConnectionServerGeneralInfo = foreach($ConnectionServer in $ConnectionServers)
                                        $HorizonConnectionServerGeneralInfo | Table -Name 'VMware Horizon Connection Server Information' -ColumnWidths 60,40
                                    } # Close out section -Style Heading4 'Connection Servers General Information'
                                    
                                    if ($InfoLevel.Settings.Servers.ConnectionServers.ConnectionServers -ge 2) {
                                        
                                        foreach($ConnectionServer in $ConnectionServers) {
                                            $ConnectionServerTags = $ConnectionServer.General | ForEach-Object { $_.Tags} 
                                            $ConnectionServerTagsresult = $ConnectionServerTags -join ', '
                                            PageBreak
                                            section -Style Heading4 "Connection Server $($ConnectionServer.General.Name)" {
                                                $HorizonConnectionServerInfo = [PSCustomObject]@{
                                                    'Host Name' = $ConnectionServer.General.Name
                                                    'Server Address' = $ConnectionServer.General.ServerAddress                    
                                                    'Enabled' = $ConnectionServer.General.Enabled
                                                    'Tags' = $ConnectionServerTagsresult            
                                                    'External URL' = $ConnectionServer.General.ExternalURL
                                                    'External PCoIP URL' = $ConnectionServer.General.ExternalPCoIPURL
                                                    'AuxillaryExternalPCoIPIPv4Address' = $ConnectionServer.General.AuxillaryExternalPCoIPIPv4Address
                                                    'External App Blast URL' = $ConnectionServer.General.ExternalAppblastURL
                                                    'Local Connection Server' = $ConnectionServer.General.LocalConnectionServer
                                                    'Bypass Tunnel' = $ConnectionServer.General.BypassTunnel
                                                    'Bypass PCoIP Gateway' = $ConnectionServer.General.BypassPCoIPGateway
                                                    'Bypass App Blast Gateway' = $ConnectionServer.General.BypassAppBlastGateway
                                                    'Version' = $ConnectionServer.General.Version
                                                    'IP Mode' = $ConnectionServer.General.IpMode
                                                    'FIPs Mode Enabled' = $ConnectionServer.General.FipsModeEnabled
                                                    'FQDN' = $ConnectionServer.General.Fqhn
                                                } # Close Out $HorizonConnectionServerInfo = [PSCustomObject]
                                            $HorizonConnectionServerInfo | Table -Name "Connection Server $($ConnectionServer.General.Name) Information" -List -ColumnWidths 60,40
                                            } # Close out section -Style Heading4 'Connection Server'

                                            if($connectionserver.authentication.samlconfig.SamlAuthenticator) {
                                                $SAMLAuth = $hzServices.SAMLAuthenticator.SAMLAuthenticator_Get($connectionserver.authentication.samlconfig.SamlAuthenticator)
                                                $SAMLAuthList = $hzServices.SAMLAuthenticator.SAMLAuthenticator_list($ConnectionServer.Authentication.SamlConfig.SamlAuthenticators)
                                            } # Close out if($connectionservers.authentication.samlconfig.SamlAuthenticator)

                                            #section -Style Heading4 'Connection Server Authentication' {
                                                $HorizonConnectionServerAuthInfo = [PSCustomObject]@{
                                                    'Smart Card Support' = $ConnectionServer.Authentication.SmartCardSupport
                                                    'Log off When Smart Card Removed' = $ConnectionServer.Authentication.LogoffWhenRemoveSmartCard                    
                                                    'RSA Secure ID Enabled' = $ConnectionServer.Authentication.RsaSecureIdConfig.SecureIdEnabled
                                                    'RSA Secure ID Name Mapping' = $ConnectionServer.Authentication.RsaSecureIdConfig.NameMapping
                                                    'RSA Secure ID Clear Node Secret' = $ConnectionServer.Authentication.RsaSecureIdConfig.ClearNodeSecret
                                                    'RSA Secure ID Security File Data' = $ConnectionServer.Authentication.RsaSecureIdConfig.SecurityFileData
                                                    'RSA Secure ID Security File Uploaded' = $ConnectionServer.Authentication.RsaSecureIdConfig.SecurityFileUploaded
                                                    'Radius Enabled' = $ConnectionServer.Authentication.RadiusConfig.RadiusEnabled
                                                    'Radius Authenticator' = $ConnectionServer.Authentication.RadiusConfig.RadiusAuthenticator
                                                    'Radius Name Mapping' = $ConnectionServer.Authentication.RadiusConfig.RadiusNameMapping
                                                    'Radius SSO' = $ConnectionServer.Authentication.RadiusConfig.RadiusSSO
                                                    'SAML Support' = $ConnectionServer.Authentication.SamlConfig.SamlSupport
                                                    'SAML Authenticator' = $SAMLAuth.base.Label
                                                    'SAML Authenticators' = $SAMLAuthList.base.label
                                                    'Unauthenticated Access Config Enabled' = $ConnectionServer.Authentication.UnauthenticatedAccessConfig.Enabled
                                                    'Unauthenticated Access Default User' = $ConnectionServer.Authentication.UnauthenticatedAccessConfig.DefaultUser
                                                    'Unauthenticated Access User Idle Timeout' = $ConnectionServer.Authentication.UnauthenticatedAccessConfig.UserIdleTimeout
                                                } # Close Out $HorizonConnectionServerAuthInfo = [PSCustomObject]
                                            $HorizonConnectionServerAuthInfo | Table -Name "Connection Server $($ConnectionServer.General.Name) Authentication Information" -List -ColumnWidths 60,40
                                            #} # Close out section -Style Heading4 'Connection Server Authentication'


                                            #section -Style Heading4 'Connection Server Backup' {
                                                $HorizonConnectionServerBackupInfo = [PSCustomObject]@{
                                                    'LDAP Backup Frequency Time' = $ConnectionServer.Backup.LdapBackupFrequencyTime
                                                    'LDAP Backup Max Number' = $ConnectionServer.Backup.LdapBackupMaxNumber                    
                                                    'LDAP Backup Location Folder' = $ConnectionServer.Backup.LdapBackupFolder
                                                } # Close Out $HorizonConnectionServerAuthInfo = [PSCustomObject]
                                            $HorizonConnectionServerBackupInfo | Table -Name "Connection Server $($ConnectionServer.General.Name) Backup Information" -List -ColumnWidths 60,40
                                            #} # Close out section -Style Heading4 'Connection Server Backup'


                                            #section -Style Heading4 'Connection Server Security Pairing' {
                                                #$HorizonConnectionServerSecurityPairing = [PSCustomObject]@{
                                                    
                                                    # Need to find all the security pairing API Calls

                                                #} # Close Out $HorizonConnectionServerAuthInfo = [PSCustomObject]
                                            #$HorizonConnectionServerSecurityPairing | Table -Name 'VMware Horizon Connection Server Security Pairing Information' -List
                                            #} # Close out section -Style Heading4 'Connection Server Security Pairing'


                                            #section -Style Heading4 'Connection Server Message Security' {
                                                $HorizonConnectionServerMessageSecurity = [PSCustomObject]@{
                                                    'RSA Secure ID Security File Data' = $ConnectionServer.MessageSecurity.MessageSecurityEnhancedModeSupported
                                                } # Close Out $HorizonConnectionServerAuthInfo = [PSCustomObject]
                                            $HorizonConnectionServerMessageSecurity | Table -Name "Connection Server $($ConnectionServer.General.Name) Message Security Information" -List -ColumnWidths 60,40
                                            #} # Close out section -Style Heading4 'Connection Server Message Security'
                                        } # Close out foreach($ConnectionServer in $ConnectionServers)
                                    } # Close out if ($InfoLevel.Settings.Servers.ConnectionServers.ConnectionServers -ge 2) 
                                } # Close out section -Style Heading3 'Connection Servers'
                            } # Close out if ($InfoLevel.Settings.Servers.ConnectionServers.ConnectionServers -ge 1)
                        } # Close out if ($ConnectionServers)
                    
                    } # Close out section -Style Heading2 'Servers'
                } # Close out if ($vCenterServers -or $vCenterHealth -or $Composers -or $Domains -or $SecurityServers -or $GatewayServers -or $ConnectionServers)

                #---------------------------------------------------------------------------------------------#
                #                          Instant Clone Domain Accounts                                      #
                #---------------------------------------------------------------------------------------------#
                
                if ($InstantCloneDomainAdmins) {
                    if ($InfoLevel.Settings.InstantClone.InstantCloneDomainAccounts -ge 1) {
                        PageBreak
                        section -Style Heading2 'Instant Clone Domain Accounts' {
                            section -Style Heading3 'Instant Clone Domain Admins' {
                                $HorizonInstantCloneDomainAdmin = foreach($InstantCloneDomainAdmin in $InstantCloneDomainAdmins) {
                                    [PSCustomObject]@{
                                        'Instant Clone Domain Admin User Name' = $InstantCloneDomainAdmin.Base.UserName
                                        'Instant Clone Domain Name' = $InstantCloneDomainAdmin.NamesData.DnsName
                                    } # Close Out $HorizonInstantCloneDomainAdmin = [PSCustomObject]
                                } # Close out foreach($InstantCloneDomainAdmin in $InstantCloneDomainAdmins)
                                $HorizonInstantCloneDomainAdmin | Table -Name 'Instant Clone Domain Admin Information' -ColumnWidths 60,40
                            } # Close out section -Style Heading2 'Instant Clone Domain Accounts'
                        } # Close out section -Style Heading3 'Instant Clone Domain Admins'
                    } # Close out if ($InfoLevel.Settings.Servers.InstantClone.InstantCloneDomainAccounts -ge 1)
                } # Close out if ($InstantCloneDomainAdmin)

                #---------------------------------------------------------------------------------------------#
                #                            Product Licensing and Usage                                      #
                #---------------------------------------------------------------------------------------------#
                
                if ($ProductLicenseingInfo) {
                    if ($InfoLevel.Settings.ProductLicensing.ProductLicensingandUsage -ge 1) {
                        section -Style Heading2 'Product Licensing and Usage' {
                            section -Style Heading3 'Product Licensing and Usage Info' {
                                foreach($ProductLic in $ProductLicenseingInfo) {
                                    $HorizonProductLicInfo = [PSCustomObject]@{
                                        'Is Horizon Environment Licensed' = $ProductLic.Licensed
                                        'Horizon Environment License Key' = $ProductLic.LicenseKey
                                        'Horizon Environment License Expiration' = $ProductLic.ExpirationTime
                                        'Horizon Environment enabled for Composer' = $ProductLic.ViewComposerEnabled
                                        'Horizon Environment enabled for Desktop Launching' = $ProductLic.DesktopLaunchingEnabled
                                        'Horizon Environment enabled for Application Launching' = $ProductLic.ApplicationLaunchingEnabled
                                        'Horizon Environment enabled for Instant Clone' = $ProductLic.InstantCloneEnabled
                                        'Horizon Environment License Usage Model' = $ProductLic.UsageModel
                                    } # Close Out $HorizonInstantCloneDomainAdmin = [PSCustomObject]
                                    $HorizonProductLicInfo | Table -Name 'Product Licensing and Usage Information' -List -ColumnWidths 60,40
                                } # Close out foreach($ProductLic in $ProductLicenseingInfo)
                            } # Close out section -Style Heading3 'Product Licensing and Usage Info'
                        } # Close out section -Style Heading2 'Product Licensing and Usage'
                    } # Close out if ($InfoLevel.Settings.Servers.ProductLicensing.ProductLicensingandUsage -ge 1)
                } # Close out if ($ProductLicenseingInfo)
                
                #---------------------------------------------------------------------------------------------#
                #                                   Global Settings                                           #
                #---------------------------------------------------------------------------------------------#
                
                if ($GlobalSettings) {
                    if ($InfoLevel.Settings.GlobalSettings.GlobalSettings -ge 1) {
                        PageBreak
                        section -Style Heading2 'Global Settings' {
                            section -Style Heading3 'Global Server Settings' {
                                $HorizonGlobalSettings = [PSCustomObject]@{
                                    'Global Settings Client Session Time Out Policy' = $GlobalSettings.GeneralData.ClientIdleSessionTimeoutPolicy
                                    'Global Settings Client Max Session Time Minutes ' = $GlobalSettings.GeneralData.ClientMaxSessionTimeMinutes
                                    'Global Settings Client Idle Session Timeout Policy' = $GlobalSettings.GeneralData.ClientIdleSessionTimeoutPolicy
                                    'Global Settings Client Idle Session Timeout Minutes' = $GlobalSettings.GeneralData.ClientIdleSessionTimeoutMinutes
                                    'Global Settings Client Session Timeout Minutes ' = $GlobalSettings.GeneralData.ClientSessionTimeoutMinutes
                                    'Global Settings Desktop SSO Timeout Policy' = $GlobalSettings.GeneralData.DesktopSSOTimeoutPolicy
                                    'Global Settings Desktop SSO Timeout Minutes' = $GlobalSettings.GeneralData.DesktopSSOTimeoutMinutes
                                    'Global Settings Application SSO Timeout Policy' = $GlobalSettings.GeneralData.ApplicationSSOTimeoutPolicy
                                    'Global Settings Application SSO Timeout Minutes' = $GlobalSettings.GeneralData.ApplicationSSOTimeoutMinutes
                                    'Global Settings View API Session Timeout Minutes' = $GlobalSettings.GeneralData.ViewAPISessionTimeoutMinutes
                                    'Global Settings Pre-Login Message' = $GlobalSettings.GeneralData.PreLoginMessage
                                    'Global Settings Display Warning Before Forced Logoff' = $GlobalSettings.GeneralData.DisplayWarningBeforeForcedLogoff
                                    'Global Settings Forced Logoff Timeout Minutes' = $GlobalSettings.GeneralData.ForcedLogoffTimeoutMinutes
                                    'Global Settings Forced Logoff Message' = $GlobalSettings.GeneralData.ForcedLogoffMessage
                                    'Global Settings Enable Server in Single User Mode' = $GlobalSettings.GeneralData.EnableServerInSingleUserMode
                                    'Global Settings Store CAL on Broker' = $GlobalSettings.GeneralData.StoreCALOnBroker
                                    'Global Settings Store CAL on Client' = $GlobalSettings.GeneralData.StoreCALOnClient
                                    'Global Settings Reauthenticate Secure Tunnel After Interruption' = $GlobalSettings.SecurityData.ReauthSecureTunnelAfterInterruption
                                    'Global Settings Message Security Mode' = $GlobalSettings.SecurityData.MessageSecurityMode
                                    'Global Settings Message Security Status' = $GlobalSettings.SecurityData.MessageSecurityStatus
                                    'Global Settings Enable IP Sec for Security Server Pairing' = $GlobalSettings.SecurityData.EnableIPSecForSecurityServerPairing
                                    'Global Settings Mirage Configuration Enabled' = $GlobalSettings.MirageConfiguration.Enabled
                                    'Global Settings Mirage Configuration URL' = $GlobalSettings.MirageConfiguration.Url
                                } # Close Out $HorizonSecurityServers = [PSCustomObject]
                                $HorizonGlobalSettings | Table -Name 'Global Settings Information' -List -ColumnWidths 60,40            
                            } # Close out section -Style Heading3 'Global Server Settings'                        
                        } # Close out section -Style Heading2 'Global Settings'
                    } # Close out if ($InfoLevel.Settings.Servers.GlobalSettings.GlobalSettings -ge 1) 
                } # Close out if ($GlobalSettings)

                #---------------------------------------------------------------------------------------------#
                #                          Registered Machines                                                #
                #---------------------------------------------------------------------------------------------#
                
                if ($RDSServers) {
                    if ($InfoLevel.Inventory.Machines.RDSHosts -ge 1) {
                        PageBreak
                        section -Style Heading2 'Registered Machines' {
                            section -Style Heading3 'RDS Hosts' {
                                section -Style Heading4 "RDS Hosts General Information" {

                                    $RDSServerGeneralInfo = foreach($RDSServer in $RDSServers) {
                                        [PSCustomObject]@{
                                            'RDS Host Name' = $RDSServer.base.name
                                            'RDS Host Farm Name' = $RDSServer.SummaryData.FarmName
                                            'RDS Host State' = $RDSServer.runtimedata.Status
                                        } # Close Out $HorizonRole = [PSCustomObject]
                                    }
                                    $RDSServerGeneralInfo | Table -Name 'RDS Hosts General Information' -ColumnWidths 40,30,30

                                    if ($InfoLevel.Inventory.Machines.RDSHosts -ge 2) {
                                        section -Style Heading5 "RDS Hosts Details" {
                                            PageBreak
                                            $ii = 0
                                            foreach($RDSServer in $RDSServers) {

                                                # Find Access Group ID Name
                                                foreach($AccessGroup in $AccessGroups) {
                                                    if($AccessGroup.Id.id -eq $RDSServers.base.accessgroup.id){
                                                        $RDSServerAccessgroup = $AccessGroup.Base.Name
                                                        break
                                                    } # if($AccessGroup.Id.id -eq $RDSServers.base.accessgroup.id)
                                                } # Close out foreach($AccessGroup in $AccessGroups)
                                                
                                                if(($ii % 2) -eq 1){
                                                    PageBreak
                                                }
                                                $ii++

                                                section -Style Heading6 "RDS Host Details for $($RDSServer.base.Name)" {
                                                    $RDSServer = [PSCustomObject]@{
                                                        'RDS Host Name' = $RDSServer.base.name
                                                        'RDS Host Description' = $RDSServer.base.Description
                                                        'RDS Host Farm Name' = $RDSServer.SummaryData.FarmName
                                                        'RDS Host Desktop Pool Name' = $RDSServer.SummaryData.DesktopName
                                                        'RDS Host Farm Type' = $RDSServer.SummaryData.FarmType
                                                        'RDS Host Access Group' = $RDSServerAccessgroup
                                                        'RDS Host Message Security Mode' = $RDSServer.MessageSecurityData.MessageSecurityMode
                                                        'RDS Host Message Security Enhanced Mode Supported' = $RDSServer.MessageSecurityData.MessageSecurityEnhancedModeSupported
                                                        'RDS Host Operating System' = $RDSServer.agentdata.OperatingSystem
                                                        'RDS Host Agent Version' = $RDSServer.agentdata.AgentVersion
                                                        'RDS Host Agent Build Number' = $RDSServer.agentdata.AgentBuildNumber
                                                        'RDS Host Remote Experience Agent Version' = $RDSServer.agentdata.RemoteExperienceAgentVersion
                                                        'RDS Host Remote Experience Agent Build Number' = $RDSServer.agentdata.RemoteExperienceAgentBuildNumber
                                                        'RDS Host Max Sessions Type' = $RDSServer.settings.SessionSettings.MaxSessionsType
                                                        'RDS Host Max Sessions Set By Admin' = $RDSServer.settings.SessionSettings.MaxSessionsSetByAdmin
                                                        'RDS Host Agent Max Sessions Type' = $RDSServer.settings.AgentMaxSessionsData.MaxSessionsType
                                                        'RDS Host Agent Max Sessions Set By Admin' = $RDSServer.settings.AgentMaxSessionsData.MaxSessionsSeenByAgent
                                                        'RDS Host Enabled' = $RDSServer.settings.enabled
                                                        'RDS Host Status' = $RDSServer.runtimedata.Status
                                                    } # Close Out $RDSServer = [PSCustomObject]
                                                $RDSServer | Table -Name "RDS Host Details for $($RDSServer.base.Name)" -List -ColumnWidths 50,50
                                                } # Close out section -Style Heading6 "RDS Host Details for $($RDSServer.base.Name)"
                                            } # Close out foreach($RDSServer in $RDSServers)
                                        } # Close out section -Style Heading5 'RDS Host Details'
                                    } # Close out if ($InfoLevel.Inventory.Machines.RDSHosts -ge 2)  
                                } # Close out section -Style Heading4 'RDS Host General Information'
                            } # Close out section -Style Heading3 'Machines'
                        } # Close out section -Style Heading2 'Registered Machines'
                    } # Close out if ($InfoLevel.Inventory.Machines.RDSHosts -ge 1)
                } # Close out if ($RDSServers)

                #---------------------------------------------------------------------------------------------#
                #                                       Administrators                                        #
                #---------------------------------------------------------------------------------------------#
                if ($Administrators -or $Roles -or $Permissions -or $AccessGroups) {
                    PageBreak
                    section -Style Heading2 'Administrators' {

                        #---------------------------------------------------------------------------------------------#
                        #                                 Administrators and Groups                                   #
                        #---------------------------------------------------------------------------------------------#
                        
                        if ($Administrators) {
                            if ($InfoLevel.Settings.Administrators.AdministratorsandGroups -ge 1) {
                                section -Style Heading3 'Administrators and Groups' {
                                    section -Style Heading4 'Administrators General Information' {
                                        $HorizonAdministratorsGeneral = foreach($Administrator in $Administrators) {
                                            # Find Administrator ID Name
                                            $RoleIDNameResults =''
                                            foreach($Permission in $Permissions) {
                                                if($Administrator.PermissionData.Permissions.id -eq $Permission.id.id){
                                                    $RoleIDName = ''
                                                    # Find Role ID Name
                                                        $RoleIDName = ''
                                                        $PermissionGroups = $Permission.base.Role.id
                                                        foreach($PermissionGroup in $PermissionGroups) {
                                                            foreach($Role in $Roles) {
                                                                if($Role.Id.id -eq $PermissionGroup) {
                                                                    $RoleIDName = $Role.base.name
                                                                    break
                                                                } # Close out if($Role.Id.id -eq $PermissionGroup)
                                                            } # Close out foreach($Role in $Roles)
                                                                if($Administrator.PermissionData.Permissions.id.count -gt 1){
                                                                    $RoleIDNameResults += "$RoleIDName, " 
                                                                    $RoleIDName = $RoleIDNameResults.TrimEnd(', ')
                                                                } #Close Out if($PermissionGroups.count -gt 1)
                                                        } # Close out foreach($PermissionGroup in $PermissionGroups)
                                                        Switch ($RoleIDName)
                                                        {
                                                            '' {$RoleIDName = 'N/A'}
                                                            ' ' {$RoleIDName = 'N/A'}
                                                        } # Close out Switch($administratorIDName)   
                                                } # Close out if($Role.data.Permissions.id -eq $Permission.id.id)
                                            } # Close out foreach($Permission in $Permissions)
                                            [PSCustomObject]@{
                                                'Administrator Display Name' = $Administrator.base.DisplayName
                                                'Administrator Permission Role' = $RoleIDName
                                            } # Close out [PSCustomObject]
                                        } # Close out $HorizonAdministratorsGeneral = foreach($Administrator in $Administrators)
                                        $HorizonAdministratorsGeneral | Table -Name 'Administrators General Information' -ColumnWidths 60, 40
                                    
                                        if ($InfoLevel.Settings.Administrators.AdministratorsandGroups -ge 2) {
                                            section -Style Heading5 'Administrators Details' {
                                                PageBreak
                                                $ii = 0
                                                foreach($Administrator in $Administrators) {
                                                    # Find Administrator ID Name
                                                    $RoleIDNameResults =''
                                                    foreach($Permission in $Permissions) {
                                                        if($Administrator.PermissionData.Permissions.id -eq $Permission.id.id){
                                                            $RoleIDName = ''
                                                            # Find Role ID Name
                                                                $RoleIDName = ''
                                                                $PermissionGroups = $Permission.base.Role.id
                                                                foreach($PermissionGroup in $PermissionGroups) {
                                                                    foreach($Role in $Roles) {
                                                                        if($Role.Id.id -eq $PermissionGroup) {
                                                                            $RoleIDName = $Role.base.name
                                                                            break
                                                                        } # Close out if($Role.Id.id -eq $PermissionGroup)
                                                                    } # Close out foreach($Role in $Roles)
                                                                        if($Administrator.PermissionData.Permissions.id.count -gt 1){
                                                                            $RoleIDNameResults += "$RoleIDName, " 
                                                                            $RoleIDName = $RoleIDNameResults.TrimEnd(', ')
                                                                        } #Close Out if($PermissionGroups.count -gt 1)
                                                                } # Close out foreach($PermissionGroup in $PermissionGroups)
                                                                Switch ($RoleIDName)
                                                                {
                                                                    '' {$RoleIDName = 'N/A'}
                                                                    ' ' {$RoleIDName = 'N/A'}
                                                                } # Close out Switch($administratorIDName)   
                                                        } # Close out if($Role.data.Permissions.id -eq $Permission.id.id)
                                                    } # Close out foreach($Permission in $Permissions)

                                                    Switch ($Administrator.base.Group)
                                                    {
                                                        'True' {$Administratorbasegroup = 'Group' }
                                                        'False' {$Administratorbasegroup = 'User' }
                                                    }

                                                    if(($ii % 2) -eq 1){
                                                        PageBreak
                                                    }
                                                    $ii++

                                                    section -Style Heading6 "Administrator Details for $($Administrator.base.Name)" {
                                                        $HorizonAdministrators = [PSCustomObject]@{
                                                            'Administrator Name' = $Administrator.base.Name
                                                            'Administrator First Name' = $Administrator.base.FirstName
                                                            'Administrator Last Name' = $Administrator.base.LastName
                                                            'Administrator Login Name' = $Administrator.base.LoginName
                                                            'Administrator Display Name' = $Administrator.base.DisplayName
                                                            'Administrator Long Display Name' = $Administrator.base.LongDisplayName
                                                            'Is Administrator Assignment a Group of User' = $Administratorbasegroup
                                                            'Administrator Domain' = $Administrator.base.Domain
                                                            'Administrator AD Distinguished Name' = $Administrator.base.AdDistinguishedName
                                                            'Administrator Email' = $Administrator.base.Email
                                                            'Administrator Kiosk User' = $Administrator.base.KioskUser
                                                            'Administrator Phone Number' = $Administrator.base.Phone
                                                            'Administrator Description' = $Administrator.base.Description
                                                            'Administrator in Folder' = $Administrator.base.InFolder
                                                            'Administrator UPN' = $Administrator.base.UserPrincipalName
                                                            'Administrator Permission Role' = $RoleIDName
                                                        } # Close Out $HorizonAdministrators = [PSCustomObject]
                                                    $HorizonAdministrators | Table -Name "Administrator Details for $($Administrator.base.Name)" -List -ColumnWidths 60, 40
                                                    } # Close out section -Style Heading6 'Administrator Details for'
                                                } # Close out foreach(Administrator in $Administrators)
                                            } # Close out section -Style Heading5 'Administrators Details'
                                        } # Close out if ($InfoLevel.Settings.Administrators.AdministratorsandGroups -ge 2) {
                                    } # Close out section -Style Heading4 'Administrators General Information'
                                } # Close out section -Style Heading3 'Administrators and Groups'
                            } # Close out if ($InfoLevel.Settings.Administrators.AdministratorsandGroups -ge 1)
                        } # Close out if ($Administrators) 

                        #---------------------------------------------------------------------------------------------#
                        #                                       Role Privileges                                       #
                        #---------------------------------------------------------------------------------------------#
                        
                        if ($Roles) {
                            if ($InfoLevel.Settings.Administrators.RolePrivileges -ge 1) {
                                PageBreak
                                section -Style Heading3 'Role Privileges' {
                                    section -Style Heading4 'Role Privileges General Information' {
                                        $HorizonRole = foreach($Role in $Roles) {
                                            [PSCustomObject]@{
                                                'Horizon Role Name' = $Role.base.Name
                                                'Horizon Role Description' = $Role.base.Description
                                            } # Close Out $HorizonRole = [PSCustomObject]
                                        }
                                        $HorizonRole | Table -Name 'Role Details' -ColumnWidths 50,50

                                        if ($InfoLevel.Settings.Administrators.RolePrivileges -ge 2) {
                                            section -Style Heading5 'Roles Details' {
                                                foreach($Role in $Roles) {
                                                    # Find Administrator ID Name
                                                    foreach($Permission in $Permissions) {
                                                        if($Role.data.Permissions.id -eq $Permission.id.id){

                                                            $AdministratorIDName = ''
                                                            $PermissionGroups = $Permission.base.UserOrGroup.id
                                                            foreach($PermissionGroup in $PermissionGroups) {

                                                                foreach($Administrator in $Administrators) {
                                                                    if($Administrator.Id.id -eq $PermissionGroup) {
                                                                        $AdministratorIDName = $Administrator.base.name
                                                                        break
                                                                    } # Close out if($Administrator.Id.id -eq $PermissionGroup)
                                                            
                                                                } # Close out foreach($Administrator in $Administrators)
                                                                    if($PermissionGroups.count -gt 1){
                                                                        $AdministratorIDNameResults += "$AdministratorIDName, " 
                                                                        $AdministratorIDName = $AdministratorIDNameResults.TrimEnd(', ')
                                                                    } #Close Out if($PermissionGroups.count -gt 1)
                                                            } # Close out foreach($PermissionGroup in $PermissionGroups)
                                                            Switch ($AdministratorIDName)
                                                            {
                                                                '' {$AdministratorIDName = 'N/A'}
                                                                ' ' {$AdministratorIDName = 'N/A'}
                                                            } # Close out Switch($administratorIDName)
                                                                        
                                                        } # Close out if($Role.data.Permissions.id -eq $Permission.id.id)
                                                    } # Close out foreach($Permission in $Permissions)

                                                    $RolePrivileges = $Role.Base | ForEach-Object { $_.Privileges} 
                                                    $RolePrivilegessresult = $RolePrivileges -join ', '
                                                    
                                                    PageBreak
                                                    section -Style Heading6 "Role $($Role.base.Name)" {
                                                        $HorizonRole = [PSCustomObject]@{
                                                            'Role Name' = $Role.base.Name
                                                            'Role Description' = $Role.base.Description
                                                            'Role Privileges' = $RolePrivilegessresult
                                                            'Role Built-in' = $Role.data.Builtin
                                                            'Role Permission' = $AdministratorIDName
                                                        } # Close Out $HorizonRole = [PSCustomObject]
                                                    $HorizonRole | Table -Name "Role $($Role.base.Name)" -List -ColumnWidths 50,50
                                                    } # Close out section -Style Heading6 'Role'
                                                } # Close out foreach($Role in $Roles)
                                            } # Close out section -Style Heading5 'VMware Roles'
                                        } # Close out if ($InfoLevel.Settings.Administrators.RolePermissions -ge 2)  
                                    } # Close out section -Style Heading4 'Permissions Details'         
                                } # Close out section -Style Heading3 'Role Privileges' 
                            } # Close out if ($InfoLevel.Settings.Administrators.RolePermissions -ge 1)
                        } # Close out if ($Roles)

                        #---------------------------------------------------------------------------------------------#
                        #                                       Role Permissions                                      #
                        #---------------------------------------------------------------------------------------------#
                        
                        if ($Permissions) {
                            if ($InfoLevel.Settings.Administrators.RolePermissions -ge 1) {
                                PageBreak
                                section -Style Heading3 'Role Permissions' {
                                    section -Style Heading4 'Permissions Details' {
                                        $AdministratorIDNameResults = ''
                                        $HorizonPermission = foreach($Permission in $Permissions) {                                                
                                            # Find Administrator ID Name
                                            $AdministratorIDName = ''
                                            $PermissionGroups = $Permission.base.UserOrGroup.id
                                            foreach($PermissionGroup in $PermissionGroups) {

                                                foreach($Administrator in $Administrators) {
                                                    if($Administrator.Id.id -eq $PermissionGroup) {
                                                        $AdministratorIDName = $Administrator.base.name
                                                        break
                                                    } # Close out if($Administrator.Id.id -eq $PermissionGroup)
                                                } # Close out foreach($Administrator in $Administrators)
                                                    if($PermissionGroups.count -gt 1){
                                                        $AdministratorIDNameResults += "$AdministratorIDName, " 
                                                        $AdministratorIDName = $AdministratorIDNameResults.TrimEnd(', ')
                                                    } #Close Out if($PermissionGroups.count -gt 1)
                                            } # Close out foreach($PermissionGroup in $PermissionGroups)
                                            Switch ($AdministratorIDName)
                                            {
                                                '' {$AdministratorIDName = 'N/A'}
                                                ' ' {$AdministratorIDName = 'N/A'}
                                            }
                                        
                                            # Mach Permission Role ID with Role ID
                                            # Find Role ID Name
                                            $RoleIDName = ''
                                            $PermissionGroups = $Permission.base.Role.id
                                            foreach($PermissionGroup in $PermissionGroups) {

                                                foreach($Role in $Roles) {
                                                    if($Role.Id.id -eq $PermissionGroup) {
                                                        $RoleIDName = $Role.base.name
                                                        break
                                                    } # Close out if($Role.Id.id -eq $PermissionGroup)
                                
                                                } # Close out foreach($Role in $Roles)
                                                    if($PermissionGroups.count -gt 1){
                                                        $RoleIDNameResults += "$RoleIDName, " 
                                                        $RoleIDName = $RoleIDNameResults.TrimEnd(', ')
                                                    } #Close Out if($PermissionGroups.count -gt 1)
                                            } # Close out foreach($PermissionGroup in $PermissionGroups)
                                            Switch ($RoleIDName)
                                            {
                                                '' {$RoleIDName = 'N/A'}
                                                ' ' {$RoleIDName = 'N/A'}
                                            }

                                            # Find AccessGroup ID Name
                                            $AccessGroupIDName = ''
                                            $PermissionGroups = $Permission.base.AccessGroup.id
                                            foreach($PermissionGroup in $PermissionGroups) {

                                                foreach($AccessGroup in $AccessGroups) {
                                                    if($AccessGroup.Id.id -eq $PermissionGroup) {
                                                        $AccessGroupIDName = $AccessGroup.base.name
                                                        break
                                                    } # Close out if($AccessGroup.Id.id -eq $PermissionGroup)
                                                } # Close out foreach($AccessGroup in $AccessGroups)
                                                    if($PermissionGroups.count -gt 1){
                                                        $AccessGroupIDNameResults += "$AccessGroupIDName, " 
                                                        $AccessGroupIDName = $AccessGroupIDNameResults.TrimEnd(', ')
                                                    } #Close Out if($PermissionGroups.count -gt 1)
                                            } # Close out foreach($PermissionGroup in $PermissionGroups)
                                            Switch ($AccessGroupIDName)
                                            {
                                                '' {$AccessGroupIDName = 'N/A'}
                                                ' ' {$AccessGroupIDName = 'N/A'}
                                            }

                                            [PSCustomObject]@{
                                                'Permission User or Group Name' = $AdministratorIDName
                                                'Permission Role' = $RoleIDName
                                                'Permission Access Group' = $AccessGroupIDName
                                            } # Close Out $HorizonSecurityServers = [PSCustomObject]
                                        } # Close out $HorizonPermission = foreach($Permission in $Permissions)
                                        $HorizonPermission | Table -Name 'Permission Datails' -ColumnWidths 40,30,30
                                    } # Close out section -Style Heading4 'Permissions Details'
                                } # Close out section -Style Heading3 'Role Permissions'
                            } # Close out if ($InfoLevel.Settings.Administrators.RolePermissions -ge 1)
                        } # Close out if ($Permissions)

                        #---------------------------------------------------------------------------------------------#
                        #                                       Access Groups                                         #
                        #---------------------------------------------------------------------------------------------#
                        
                        if ($AccessGroups) {
                            if ($InfoLevel.Settings.Administrators.AccessGroup -ge 1) {
                                PageBreak
                                section -Style Heading3 'Access Groups' {
                                    section -Style Heading4 'Access Group General Information' {
                                        $AccessGroupGeneralInfo = foreach($AccessGroup in $AccessGroups) {
                                            [PSCustomObject]@{
                                                'Access Group Name' = $AccessGroup.base.Name
                                                'Access Group Description' = $AccessGroup.base.Description
                                                'Access Group Description Parent' = $AccessGroup.base.Parent
                                            } # Close Out $HorizonRole = [PSCustomObject]
                                        }
                                        $AccessGroupGeneralInfo | Table -Name 'Access Group General Information' -ColumnWidths 40,30,30

                                        if ($InfoLevel.Settings.Administrators.AccessGroup -ge 2) {
                                            section -Style Heading5 'Access Group Details' {
                                                $ii = 0
                                                foreach($AccessGroup in $AccessGroups) {
                                                    # Find Administrator ID Name
                                                    $AdministratorIDName = ''
                                                    foreach($AccessGroupID in $AccessGroup.data.Permissions.id) {
                                                        foreach($Permission in $Permissions) {
                                                            if($AccessGroupID -eq $Permission.id.id){
                                                                foreach($PermissionGroup in $Permission.base.UserOrGroup.id) {
                                                                    foreach($Administrator in $Administrators) {
                                                                        if($Administrator.Id.id -eq $PermissionGroup) {
                                                                            $AdministratorIDName = $Administrator.base.name
                                                                            break
                                                                        } # Close out if($Administrator.Id.id -eq $PermissionGroup)
                                                                    } # Close out foreach($Administrator in $Administrators)
                                                                    $AdministratorIDNameResults += "$AdministratorIDName, " 
                                                                    $AdministratorIDName = $AdministratorIDNameResults.TrimEnd(', ')
                                                                } # Close out foreach($PermissionGroup in $PermissionGroups)
                                                                Switch ($AdministratorIDName)
                                                                {
                                                                    '' {$AdministratorIDName = 'N/A'}
                                                                    ' ' {$AdministratorIDName = 'N/A'}
                                                                } # Close out Switch($administratorIDName) 
                                                            } # if($AccessGroupID -eq $Permission.id.id)
                                                        } # Close out foreach($Permission in $Permissions)
                                                        $AdministratorIDName
                                                    } # Close out foreach($AccessGroupID in $AccessGroup.data.Permissions.id)

                                                    if(($ii % 3) -eq 0){
                                                        PageBreak
                                                    }
                                                    $ii++

                                                    section -Style Heading6 "Access Group Details for $($AccessGroup.base.Name)" {
                                                        $HorizonRole = [PSCustomObject]@{
                                                            'Access Group Name' = $AccessGroup.base.Name
                                                            'Access Group Description' = $AccessGroup.base.Description
                                                            'Access Group Description Parent' = $AccessGroup.base.Parent
                                                            'Access Group Permissions' = $AdministratorIDName
                                                        } # Close Out $HorizonRole = [PSCustomObject]
                                                    $HorizonRole | Table -Name "Access Group Details for $($AccessGroup.base.Name)" -List -ColumnWidths 50,50
                                                    } # Close out section -Style Heading6 'Role'
                                                } # Close out foreach($AccessGroup in $AccessGroups)
                                            } # Close out section -Style Heading5 'Access Group Details'
                                        } # Close out if ($InfoLevel.Settings.Administrators.AccessGroup -ge 2)  
                                    } # Close out section -Style Heading4 'Access Group General Information'         
                                } # Close out section -Style Heading3 'Access Groups'
                            } # Close out if ($InfoLevel.Settings.Administrators.AccessGroup -ge 1)
                        } # Close out if ($AccessGroups)

                    } # Close out section -Style Heading2 'Administrators'
                } # Close out if ($Administrators -or $Roles -or $Permissions -or $AccessGroups)

                #---------------------------------------------------------------------------------------------#
                #                                 Cloud Pod Architecture                                      #
                #---------------------------------------------------------------------------------------------#
                
                if ($CloudPodFederation) {
                    
                        if ($InfoLevel.Settings.CloudPodArchitecture.CloudPodArchitecture -ge 1) {
                            PageBreak
                            section -Style Heading2 'Cloud Pod Architecture' {
                                section -Style Heading3 'Cloud Pod Federation General Information' {
                                    $HorizonCloudPodFederationGeneral = [PSCustomObject]@{
                                        'Pod Federation Name' = $CloudPodFederation.data.displayname
                                        'Pod Status' = $CloudPodFederation.LocalPodStatus.status
                                    } # Close Out $HorizonSecurityServers = [PSCustomObject]
                                    $HorizonCloudPodFederationGeneral | Table -Name 'VMware Horizon Cloud Pod Federation Info' -ColumnWidths 60, 40
                                } # Close out section -Style Heading3 'Cloud Pod Federation General Information'

                                if ($InfoLevel.Settings.CloudPodArchitecture.CloudPodArchitecture -ge 2) {
                                    section -Style Heading3 'Cloud Pod Federation Detailed Information' {
                                        $ii = 0
                                        foreach ($CloudPodList in $CloudPodLists) {
                                            $CloudPodSiteInfo = $hzServices.Site.Site_Get($CloudPodList.site)

                                            # Connection Server Info
                                            $CloudPodListEndpoints = $CloudPodList.Endpoints
                                            $CloudPodListEndpointConnectionServerList = ''
                                            foreach($CloudPodListEndpoint in $CloudPodListEndpoints){
                                            $CloudPodListEndpointConnectionServer = $hzServices.PodEndpoint.PodEndpoint_Get($CloudPodListEndpoint)
                                            $CloudPodListEndpointConnectionServerList += $CloudPodListEndpointConnectionServer.name -join "`r`n" | Out-String
                                            }
                                            
                                            # Active Global Entitlements
                                            $CloudPodListActiveGlobalEntitlements = $CloudPodList.ActiveGlobalEntitlements
                                            $CloudPodListActiveGlobalEntitlementList = ''
                                            foreach($CloudPodListActiveGlobalEntitlement in $CloudPodListActiveGlobalEntitlements){
                                            $CloudPodListActiveGlobalEntitlementInfo = $hzServices.GlobalEntitlement.GlobalEntitlement_Get($CloudPodListActiveGlobalEntitlement)
                                            $CloudPodListActiveGlobalEntitlementList += $CloudPodListActiveGlobalEntitlementInfo.Base.DisplayName -join "`r`n" | Out-String
                                            }

                                            # Active Global Application Entitlements
                                            $CloudPodListActiveGlobalApplicationEntitlements = $CloudPodList.ActiveGlobalApplicationEntitlements
                                            $CloudPodListActiveGlobalApplicationEntitlementList = ''
                                            foreach($CloudPodListActiveGlobalApplicationEntitlement in $CloudPodListActiveGlobalApplicationEntitlements){
                                            $CloudPodListActiveGlobalApplicationEntitlementInfo = $hzServices.GlobalApplicationEntitlement.GlobalApplicationEntitlement_Get($CloudPodListActiveGlobalApplicationEntitlement)
                                            $CloudPodListActiveGlobalApplicationEntitlementList += $CloudPodListActiveGlobalApplicationEntitlementInfo.Base.DisplayName -join "`r`n" | Out-String
                                            }

                                            if(($ii % 2) -eq 1){
                                                PageBreak
                                            }
                                            $ii++

                                            $HorizonCloudPodFederationP1 = [PSCustomObject]@{
                                                'Pod Name' = $CloudPodList.DisplayName
                                                'Pod Local' = $CloudPodList.Localpod
                                                'Pod Site' = $CloudPodSiteInfo.Base.DisplayName
                                                'Pod Description' = $CloudPodList.Description
                                                'Pod Cloud Managed' = $CloudPodList.CloudManaged
                                                'Pod Connection Servers' = $CloudPodListEndpointConnectionServerList
                                                'Pod Active Global Entitlements' = $CloudPodListActiveGlobalEntitlementList
                                                'Pod Active Global Application Entitlements' = $CloudPodListActiveGlobalApplicationEntitlementList
                                            } # Close Out $HorizonSecurityServers = [PSCustomObject]
                                            $HorizonCloudPodFederationP1 | Table -Name 'VMware Horizon Cloud Pod Federation Info Part 1' -List -ColumnWidths 60,40
                                        } # Close out foreach ($CloudPodSite in $CloudPodSites)
                                    } # Close out section -Style Heading3 'Cloud Pod Federation Detailed Information'
                                } # Close out if ($InfoLevel.Settings.GlobalSettings.GlobalSettings -ge 1) {
                            } # Close out section -Style Heading2 'Cloud Pod Architecture'
                        } # Close out if ($InfoLevel.Settings.GlobalSettings.GlobalSettings -ge 1)
                    
                } # Close out if ($CloudPodFederation)

                #---------------------------------------------------------------------------------------------#
                #                                            Sites                                            #
                #---------------------------------------------------------------------------------------------#
                
                if ($CloudPodSites) {
                    if ($InfoLevel.Settings.Sites.Sites -ge 1) {
                        PageBreak
                        section -Style Heading2 'Sites' {
                            section -Style Heading3 "Cloud Pod Sites General Information" {

                                $CloudPodSiteGeneralInfo = foreach($CloudPodSite in $CloudPodSites) {
                                    $PodCount = ($CloudPodSite.pods).Count | Out-String
                                    [PSCustomObject]@{
                                        'Cloud Pod Sites Name' = $CloudPodSite.base.DisplayName
                                        'Cloud Pod Sites Description' = $CloudPodSite.base.Description
                                        'Cloud Pod Site Number of Pods' = $PodCount
                                    } # Close Out $HorizonRole = [PSCustomObject]
                                }
                                $CloudPodSiteGeneralInfo | Table -Name 'Cloud Pod Sites General Information' -ColumnWidths 40,30,30

                                if ($InfoLevel.Settings.Sites.Sites -ge 2) {
                                    section -Style Heading4 "Cloud Pod Sites Details" {
                                        $ii = 0
                                        foreach($CloudPodSite in $CloudPodSites) {
                                            
                                            # Find CloudPod Info
                                            foreach($CloudPodList in $CloudPodLists) {
                                                if($CloudPodList.Id.id -eq $CloudPodSite.pods.id){
                                                    $CloudPodDisplayName = $CloudPodList.DisplayName
                                                    break
                                                } # if($AccessGroup.Id.id -eq $RDSServers.base.accessgroup.id)
                                            } # Close out foreach($AccessGroup in $AccessGroups)
                                            
                                            if(($ii % 5) -eq 0){
                                                PageBreak
                                            }
                                            $ii++

                                            section -Style Heading5 "Cloud Pod Site Details for $($CloudPodSite.General.name)" {
                                                $CloudPodSite = [PSCustomObject]@{
                                                    'Cloud Pod Sites Name' = $CloudPodSite.base.DisplayName
                                                    'Cloud Pod Sites Description' = $CloudPodSite.base.Description
                                                    'Cloud Pod Site Pod Name' = $CloudPodDisplayName
                                                } # Close Out $CloudPodSite = [PSCustomObject]
                                            $CloudPodSite | Table -Name "Cloud Pod Site Details for $($CloudPodSite.General.name)" -List -ColumnWidths 50,50
                                            } # Close out section -Style Heading5 "Cloud Pod Sites Details"
                                        } # Close out foreach($CloudPodSite in $CloudPodSites)
                                    } # Close out section -Style Heading4 'Cloud Pod Sites Details'
                                } # Close out if (($InfoLevel.Settings.Sites.Sites -ge 2)  
                            } # Close out section -Style Heading3 'Cloud Pod Sites General Information'         
                        } # Close out section -Style Heading2 'Sites' 
                    } # Close out if (($InfoLevel.Settings.Sites.Sites -ge 1)
                } # Close out if ($CloudPodSites)

                #---------------------------------------------------------------------------------------------#
                #                                    Event Configuration                                      #
                #---------------------------------------------------------------------------------------------#

                if ($EventDataBases) {
                    if ($InfoLevel.Settings.EventConfiguration.EventConfiguration -ge 1) {
                        PageBreak
                        section -Style Heading2 'Event Configuration' {
                            section -Style Heading3 'Horizon Event Database' {
                                foreach($EventDataBase in $EventDataBases) {
                                    $HorizonEventDatabase = [PSCustomObject]@{
                                        'Event Database Enabled' = $EventDataBase.eventdatabaseset
                                        'Event Database Server' = $EventDataBase.database.Server
                                        'Event Database Type' = $EventDataBase.database.Type
                                        'Event Database Port' = $EventDataBase.database.Port
                                        'Event Database Name' = $EventDataBase.database.Name
                                        'Event Database User Name' = $EventDataBase.database.UserName
                                        'Event Database Table Prefix' = $EventDataBase.database.TablePrefix
                                        'Event Database Show Events for' = $EventDataBase.Settings.ShowEventsForTime
                                        'Event Database Classify Events as New for Days' = $EventDataBase.Settings.ClassifyEventsAsNewForDays
                                    } # Close Out $HorizonEventDatabase = [PSCustomObject]
                                    $HorizonEventDatabase | Table -Name 'Event Database Information' -List -ColumnWidths 60,40
                                } # Close out foreach($EventDataBase in $EventDataBases)
                            } # Close out section -Style Heading3 'Horizon Event Database'
                        } # Close out section -Style Heading2 'Event Configuration'
                    } # Close out if ($InfoLevel.Settings.EventConfiguration.EventConfiguration -ge 1)
                } # Close out if ($EventDataBase)
                
                #---------------------------------------------------------------------------------------------#
                #                                     Global Policies                                         #
                #---------------------------------------------------------------------------------------------#
                
                #if ($GlobalPolicies) {
                    #section -Style Heading2 'Global Policies' {

                    #} # Close out section -Style Heading2 'Global Policies'
                #} # Close out if ($GlobalPolicies)

                #---------------------------------------------------------------------------------------------#
                #                                       JMP Configuration                                     #
                #---------------------------------------------------------------------------------------------#
                
                if ($GlobalSettings.JmpConfiguration) {
                    if ($InfoLevel.Settings.JMPConfiguration.JMPConfiguration -ge 1) {
                        section -Style Heading2 'JMP Configuration' {
                            section -Style Heading3 'JMP Configuration Information' {
                                $JMPConfigInfo = foreach($JMPConfig in $GlobalSettings.JmpConfiguration) {
                                    [PSCustomObject]@{
                                        'JMP Server URL' = $JMPConfig.Url
                                    } # Close Out [PSCustomObject]
                                }  # Close Out $JMPConfigInfo = foreach($JMPConfig in $GlobalSettings.JmpConfiguration)
                                $JMPConfigInfo | Table -Name 'JMP Configuration Information' -List -ColumnWidths 60,40
                            } # Close Out section -Style Heading3 'JMP Configuration Information'
                        } # Close out section -Style Heading2 'JMP Configuration'
                    } # Close Out if ($InfoLevel.Settings.JMPConfiguration.JMPConfiguration -ge 1)
                } # Close Out if ($GlobalSettings.JmpConfiguration)

            } # Close out section -Style Heading1 'Settings'
        } # Close out if ($vCenterServers -or $vCenterHealth -or $Composers -or $Domains -or $SecurityServers -or $GatewayServers -or $ConnectionServers -or $InstantCloneDomainAdmins -or $ProductLicenseingInfo -or $GlobalSettings -or $RDSServers -or $Administrators -or $Roles -or $Permissions -or $AccessGroups -or $CloudPodFederation -or $CloudPodSites -or $EventDataBases -or $GlobalPolicies) 

    } # Close out foreach ($HVServer in $Target)

} # Close out function Invoke-AsBuiltReport.VMware.Horizon