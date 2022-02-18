function Invoke-AsBuiltReport.VMware.Horizon {
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

    param (
        [String[]] $Target,
        [PSCredential] $Credential
    )

    # Import Report Configuration
    $Report = $ReportConfig.Report
    $InfoLevel = $ReportConfig.InfoLevel
    $Options = $ReportConfig.Options


    $ErrorActionPreference = “SilentlyContinue”

    foreach ($HVEnvironment in $Target) {

        Try {
            $HvServer = Connect-HVServer -Server $HVEnvironment -Credential $Credential -ErrorAction Stop
        }
        Catch {
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
            $hzServices = $hvServer.ExtensionData

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
            #$SecurityServers = $hzServices.SecurityServer.SecurityServer_List()

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
            $pools = foreach ($poolresult in $poolqueryResults.results) {
                $hzServices.desktop.desktop_get($poolresult.id)
            }
            $queryservice.QueryService_DeleteAll($hzServices)

            # Application Pools
            $AppQueryDefn = New-Object VMware.Hv.QueryDefinition
            $AppQueryDefn.queryentitytype='ApplicationInfo'
            $AppqueryResults = $Queryservice.QueryService_Create($hzServices, $AppQueryDefn)
            $Apps = foreach ($Appresult in $AppqueryResults.results) {
                $hzServices.Application.Application_Get($Appresult.id)
            }
            $queryservice.QueryService_DeleteAll($hzServices)

            # Thin Apps

            # Global Entitlements
            $GlobalEntitlementGroupsQueryDefn = New-Object VMware.Hv.QueryDefinition
            $GlobalEntitlementGroupsQueryDefn.queryentitytype='GlobalEntitlementSummaryView'
            $GlobalEntitlementGroupsqueryResults = $Queryservice.QueryService_Create($hzServices, $GlobalEntitlementGroupsQueryDefn)
            $GlobalEntitlements = foreach ($GlobalEntitlementGroupsResult in $GlobalEntitlementGroupsqueryResults.results) {
                $hzServices.GlobalEntitlement.GlobalEntitlement_Get($GlobalEntitlementGroupsResult.id)
            }
            $queryservice.QueryService_DeleteAll($hzServices)

            # Entitled User Or Group Global
            $GlobalApplicationEntitlementGroupsQueryDefn = New-Object VMware.Hv.QueryDefinition
            $GlobalApplicationEntitlementGroupsQueryDefn.queryentitytype='GlobalApplicationEntitlementInfo'
            $GlobalApplicationEntitlementGroupsqueryResults = $Queryservice.QueryService_Create($hzServices, $GlobalApplicationEntitlementGroupsQueryDefn)
            $GlobalApplicationEntitlementGroups = foreach ($GlobalApplicationEntitlementGroupsResult in $GlobalApplicationEntitlementGroupsqueryResults.results) {
                $hzServices.GlobalApplicationEntitlement.GlobalApplicationEntitlement_Get($GlobalApplicationEntitlementGroupsResult.id)
            }
            $queryservice.QueryService_DeleteAll($hzServices)

            # EntitledUserOrGroupGlobalMachine Info
            $EntitledUserOrGroupGlobalMachineQueryDefn = New-Object VMware.Hv.QueryDefinition
            $EntitledUserOrGroupGlobalMachineQueryDefn.queryentitytype='EntitledUserOrGroupGlobalSummaryView'
            $EntitledUserOrGroupGlobalMachinequeryResults = $Queryservice.QueryService_Create($hzServices, $EntitledUserOrGroupGlobalMachineQueryDefn)
            $EntitledUserOrGroupGlobalMachines = foreach ($EntitledUserOrGroupGlobalMachineresult in $EntitledUserOrGroupGlobalMachinequeryResults.results) {
                $hzServices.EntitledUserOrGroup.EntitledUserOrGroup_GetGlobalSummaryView($EntitledUserOrGroupGlobalMachineresult.id)
            }
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
            $farms = foreach ($farmresult in $farmqueryResults.results) {
                $hzServices.farm.farm_get($farmresult.id)
            }
            $queryservice.QueryService_DeleteAll($hzServices)

            # Machines
            $MachinesQueryDefn = New-Object VMware.Hv.QueryDefinition
            $MachinesQueryDefn.queryentitytype='MachineSummaryView'
            $MachinesqueryResults = $Queryservice.QueryService_Create($hzServices, $MachinesQueryDefn)
            $Machines = foreach ($Machinesresult in $MachinesqueryResults.results) {
                $hzServices.machine.machine_get($Machinesresult.id)
            }
            $queryservice.QueryService_DeleteAll($hzServices)

            # RDS Servers
            $RDSServerQueryDefn = New-Object VMware.Hv.QueryDefinition
            $RDSServerQueryDefn.queryentitytype='RDSServerSummaryView'
            $RDSServerqueryResults = $Queryservice.QueryService_Create($hzServices, $RDSServerQueryDefn)
            $RDSServers = foreach ($RDSServerresult in $RDSServerqueryResults.results) {
                $hzServices.RDSServer.RDSServer_GetSummaryView($RDSServerresult.id)
            }
            $queryservice.QueryService_DeleteAll($hzServices)

            # Persistent Disks
            try {
                $PersistentDisksQueryDefn = New-Object VMware.Hv.QueryDefinition
                $PersistentDisksQueryDefn.queryentitytype='PersistentDiskInfo'
                $PersistentDisksqueryResults = $Queryservice.QueryService_Create($hzServices, $PersistentDisksQueryDefn)
                $PersistentDisks = foreach ($PersistentDisksresult in $PersistentDisksqueryResults.results) {
                    $hzServices.PersistentDisk.PersistentDisk_Get($PersistentDisksresult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            }
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }

            # Global Policies

            # Sessions
            $SessionsQueryDefn = New-Object VMware.Hv.QueryDefinition
            $SessionsQueryDefn.queryentitytype='SessionLocalSummaryView'
            $SessionsqueryResults = $Queryservice.QueryService_Create($hzServices, $SessionsQueryDefn)
            $Sessions = foreach ($Sessionsresult in $SessionsqueryResults.results) {
                $hzServices.Session.Session_GetLocalSummaryView($Sessionsresult.id)
            }
            $queryservice.QueryService_DeleteAll($hzServices)

            # Base Images
            try {
                $BaseImageVMList = $hzServices.BaseImageVM.BaseImageVM_List($vCenterServers.id)
                $CompatibleBaseImageVMs = $BaseImageVMList | Where-Object {
                    ($_.IncompatibleReasons.InUseByDesktop -eq $false) -and
                    ($_.IncompatibleReasons.InUseByLinkedCloneDesktop -eq $false) -and
                    ($_.IncompatibleReasons.ViewComposerReplica -eq $false) -and
                    ($_.IncompatibleReasons.UnsupportedOS -eq $false) -and
                    ($_.IncompatibleReasons.NoSnapshots -eq $false) -and
                    (($null -eq $_.IncompatibleReasons.InstantInternal) -or ($_.IncompatibleReasons.InstantInternal -eq $false))
                }
            }
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }

            # Unauthenticated Access
            $unauthenticatedAccessList = $hzServices.UnauthenticatedAccessUser.UnauthenticatedAccessUser_List()

            section -Style Heading1 "$($HVEnvironment)" {
                if ($EntitledUserOrGroupLocalMachines -or $HomeSites -or $unauthenticatedAccessList) {
                    if ($InfoLevel.UsersAndGroups.Entitlements -ge 1) {
                        Section -Style Heading2 'Users and Groups' {
                            Get-AbrHRZLocalEntitlement
                            Get-AbrHRZHomeSite
                        }
                    }
                }
            }
        }
    }
}