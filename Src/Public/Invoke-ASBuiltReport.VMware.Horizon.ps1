function Invoke-AsBuiltReport.VMware.Horizon {
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

    param (
        [String[]] $Target,
        [PSCredential] $Credential
    )

    if ($psISE) {
        Write-Error -Message "You cannot run this script inside the PowerShell ISE. Please execute it from the PowerShell Command Window."
        break
    }

    Write-PScriboMessage -Plugin "Module" -IsWarning "Please refer to the AsBuiltReport.VMware.Horizon github website for more detailed information about this project."
    Write-PScriboMessage -Plugin "Module" -IsWarning "Do not forget to update your report configuration file after each new version release."
    Write-PScriboMessage -Plugin "Module" -IsWarning "Documentation: https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon"
    Write-PScriboMessage -Plugin "Module" -IsWarning "Issues or bug reporting: https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon/issues"
    Write-PScriboMessage -Plugin "Module" -IsWarning "This project is community maintained and has no sponsorship from VMware/Omnissa, its employees or any of its affiliates."

    Try {
        $InstalledVersion = Get-Module -ListAvailable -Name AsBuiltReport.VMware.Horizon -ErrorAction SilentlyContinue | Sort-Object -Property Version -Descending | Select-Object -First 1 -ExpandProperty Version

        if ($InstalledVersion) {
            Write-PScriboMessage -IsWarning "AsBuiltReport.VMware.Horizon $($InstalledVersion.ToString()) is currently installed."
            $LatestVersion = Find-Module -Name AsBuiltReport.VMware.Horizon -Repository PSGallery -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version
            if ($LatestVersion -gt $InstalledVersion) {
                Write-PScriboMessage -IsWarning "AsBuiltReport.VMware.Horizon $($LatestVersion.ToString()) is available."
                Write-PScriboMessage -IsWarning "Run 'Update-Module -Name AsBuiltReport.VMware.Horizon -Force' to install the latest version."
            }
        }
    } Catch {
        Write-PScriboMessage -IsWarning $_.Exception.Message
    }

    # Check if the required version of VMware PowerCLI is installed
    Get-RequiredModule -Name 'VMware.PowerCLI' -Version '13.2'

    # Import Report Configuration
    $Report = $ReportConfig.Report
    $InfoLevel = $ReportConfig.InfoLevel
    $Options = $ReportConfig.Options


    foreach ($HVEnvironment in $Target) {

        Try {
            $HvServer = Connect-HVServer -Server $HVEnvironment -Credential $Credential -ErrorAction Stop
        } Catch {
            Write-PScriboMessage -IsWarning $_.Exception.Message
        }


        # Generate report if connection to Horizon Environment Server Connection is successful
        if ($HvServer) {

            #Environment Varibles

            # Assign a variable to obtain the API Extension Data
            $hzServices = $hvServer.ExtensionData

            # Define HV Query Services
            $Queryservice = New-Object vmware.hv.queryserviceservice

            # Virtual Centers
            $vCenterServers = try { $hzServices.VirtualCenter.VirtualCenter_List() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # vCenter Health, ESX Hosts, and DataStores
            $vCenterHealth = try { $hzServices.VirtualCenterHealth.VirtualCenterHealth_List() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # ESXHosts
            #$esxhosts = $vCenterHealth

            # DataStores
            #$datastores = $vCenterHealth

            # Domains
            $domains = try { $hzServices.ADDomainHealth.ADDomainHealth_List() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # Connection Server Info
            $connectionservers = try { $hzServices.ConnectionServer.ConnectionServer_List() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # Connection Server Health
            $ConnectionServersHealth = try { $hzServices.ConnectionServerHealth.ConnectionServerHealth_List() }  catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # GateWay Server Info
            $GatewayServers = try { $hzServices.Gateway.Gateway_List() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # Instant Clone Domain Admins
            $InstantCloneDomainAdmins = try { $hzServices.InstantCloneEngineDomainAdministrator.InstantCloneEngineDomainAdministrator_List() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # AD Domains
            $ADDomains = try { $hzServices.ADDomain.ADDomain_List() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # Product Licensing Info
            $ProductLicenseingInfo = try { $hzServices.License.License_Get() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # Product Usage Info
            $UsageStatisticsInfo = try { $hzServices.UsageStatistics.UsageStatistics_GetLicensingCounters() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # Global Settings
            $GlobalSettings = try { $hzServices.GlobalSettings.GlobalSettings_Get() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # Administrators
            $Administrators = try { $hzServices.AdminUserOrGroup.AdminUserOrGroup_List() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # Cloud Pod Architecture
            $CloudPodFederation = try { $hzServices.PodFederation.PodFederation_Get() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # Sites
            $CloudPodSites = try { $hzServices.Site.Site_List() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }
            $CloudPodLists = try { $hzServices.Pod.Pod_List() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # Event Database Info
            $EventDataBases = try { $hzServices.EventDatabase.EventDatabase_Get() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # Syslog Info
            $Syslog = try { $hzServices.Syslog.Syslog_Get() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # Virtual Centers
            $vCenterServers = try { $hzServices.VirtualCenter.VirtualCenter_List() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # Global Policies
            try {
                $GlobalPoliciesService = New-Object VMware.Hv.PoliciesService
                $GlobalPolicies = $GlobalPoliciesService.Policies_Get($hvServer.ExtensionData, $null, $null)
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            # Unauthenticated Access
            $unauthenticatedAccessList = try { $hzServices.UnauthenticatedAccessUser.UnauthenticatedAccessUser_List() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            try {
                $EntitledUserOrGroupLocalMachineQueryDefn = New-Object VMware.Hv.QueryDefinition
                $EntitledUserOrGroupLocalMachineQueryDefn.queryentitytype = 'EntitledUserOrGroupLocalSummaryView'
                $EntitledUserOrGroupLocalMachinequeryResults = $Queryservice.QueryService_Create($hzServices, $EntitledUserOrGroupLocalMachineQueryDefn)
                $EntitledUserOrGroupLocalMachines = foreach ($EntitledUserOrGroupLocalMachineresult in $EntitledUserOrGroupLocalMachinequeryResults.results) { $hzServices.EntitledUserOrGroup.EntitledUserOrGroup_GetLocalSummaryView($EntitledUserOrGroupLocalMachineresult.id) }
                $queryservice.QueryService_DeleteAll($hzServices)
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            try {
                # Home Site Info
                $HomesiteQueryDefn = New-Object VMware.Hv.QueryDefinition
                $HomesiteQueryDefn.queryentitytype = 'UserHomeSiteInfo'
                $HomesitequeryResults = $Queryservice.QueryService_Create($hzServices, $HomesiteQueryDefn)
                $Homesites = foreach ($Homesiteresult in $HomesitequeryResults.results) {
                    $hzServices.UserHomeSite.UserHomeSite_GetInfos($Homesiteresult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            try {
                # Pool Info
                $PoolQueryDefn = New-Object VMware.Hv.QueryDefinition
                $PoolQueryDefn.queryentitytype = 'DesktopSummaryView'
                $poolqueryResults = $Queryservice.QueryService_Create($hzServices, $PoolQueryDefn)
                $Pools = foreach ($poolresult in $poolqueryResults.results) {
                    $hzServices.desktop.desktop_get($poolresult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            try {
                # Desktop Assignment Info
                $DesktopAssignmentViewQueryDefn = New-Object VMware.Hv.QueryDefinition
                $DesktopAssignmentViewQueryDefn.queryentitytype = 'DesktopAssignmentView'
                $DesktopAssignmentViewResults = $Queryservice.QueryService_Create($hzServices, $DesktopAssignmentViewQueryDefn)
                $DesktopAssignmentViewResultsData = $DesktopAssignmentViewResults.results
                $queryservice.QueryService_DeleteAll($hzServices)
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            try {
                # Application Pools
                $AppQueryDefn = New-Object VMware.Hv.QueryDefinition
                $AppQueryDefn.queryentitytype = 'ApplicationInfo'
                $AppqueryResults = $Queryservice.QueryService_Create($hzServices, $AppQueryDefn)
                $Apps = foreach ($Appresult in $AppqueryResults.results) {
                    $hzServices.Application.Application_Get($Appresult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            try {
                # Global Entitlements
                $GlobalEntitlementGroupsQueryDefn = New-Object VMware.Hv.QueryDefinition
                $GlobalEntitlementGroupsQueryDefn.queryentitytype = 'GlobalEntitlementSummaryView'
                $GlobalEntitlementGroupsqueryResults = $Queryservice.QueryService_Create($hzServices, $GlobalEntitlementGroupsQueryDefn)
                $GlobalEntitlements = foreach ($GlobalEntitlementGroupsResult in $GlobalEntitlementGroupsqueryResults.results) {
                    $hzServices.GlobalEntitlement.GlobalEntitlement_Get($GlobalEntitlementGroupsResult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            try {
                # Entitled User Or Group Global
                $GlobalApplicationEntitlementGroupsQueryDefn = New-Object VMware.Hv.QueryDefinition
                $GlobalApplicationEntitlementGroupsQueryDefn.queryentitytype = 'GlobalApplicationEntitlementInfo'
                $GlobalApplicationEntitlementGroupsqueryResults = $Queryservice.QueryService_Create($hzServices, $GlobalApplicationEntitlementGroupsQueryDefn)
                $GlobalApplicationEntitlementGroups = foreach ($GlobalApplicationEntitlementGroupsResult in $GlobalApplicationEntitlementGroupsqueryResults.results) {
                    $hzServices.GlobalApplicationEntitlement.GlobalApplicationEntitlement_Get($GlobalApplicationEntitlementGroupsResult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            try {
                # EntitledUserOrGroupGlobalMachine Info
                $EntitledUserOrGroupGlobalMachineQueryDefn = New-Object VMware.Hv.QueryDefinition
                $EntitledUserOrGroupGlobalMachineQueryDefn.queryentitytype = 'EntitledUserOrGroupGlobalSummaryView'
                $EntitledUserOrGroupGlobalMachinequeryResults = $Queryservice.QueryService_Create($hzServices, $EntitledUserOrGroupGlobalMachineQueryDefn)
                $EntitledUserOrGroupGlobalMachines = foreach ($EntitledUserOrGroupGlobalMachineresult in $EntitledUserOrGroupGlobalMachinequeryResults.results) {
                    $hzServices.EntitledUserOrGroup.EntitledUserOrGroup_GetGlobalSummaryView($EntitledUserOrGroupGlobalMachineresult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            # Entitled Global Users and Groups
            try {
                # EntitledUserOrGroupGlobal Info
                $EntitledUserOrGroupGlobalQueryDefn = New-Object VMware.Hv.QueryDefinition
                $EntitledUserOrGroupGlobalQueryDefn.queryentitytype = 'EntitledUserOrGroupGlobalSummaryView'
                $EntitledUserOrGroupGlobalqueryResults = $Queryservice.QueryService_Create($hzServices, $EntitledUserOrGroupGlobalQueryDefn)
                $EntitledUserOrGroupGlobals = foreach ($EntitledUserOrGroupGlobalresult in $EntitledUserOrGroupGlobalqueryResults.results) {
                    $hzServices.EntitledUserOrGroup.EntitledUserOrGroup_GetGlobalSummaryView($EntitledUserOrGroupGlobalresult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }


            # Permissions
            $Permissions = try { $hzServices.Permission.Permission_List() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # Roles
            $Roles = try { $hzServices.Role.Role_List() } catch { Write-PScriboMessage -IsWarning $_.Exception.Message }

            # Access Groups
            $AccessGroups = $hzServices.AccessGroup.AccessGroup_List()

            try {
                # Farm Info
                $FarmdQueryDefn = New-Object VMware.Hv.QueryDefinition
                $FarmdQueryDefn.queryentitytype = 'FarmSummaryView'
                $FarmqueryResults = $Queryservice.QueryService_Create($hzServices, $FarmdQueryDefn)
                $Farms = foreach ($farmresult in $farmqueryResults.results) {
                    $hzServices.farm.farm_get($farmresult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            try {
                # Machines
                $MachinesQueryDefn = New-Object VMware.Hv.QueryDefinition
                $MachinesQueryDefn.queryentitytype = 'MachineSummaryView'
                $MachinesqueryResults = $Queryservice.QueryService_Create($hzServices, $MachinesQueryDefn)
                $Machines = foreach ($Machinesresult in $MachinesqueryResults.results) {
                    $hzServices.machine.machine_get($Machinesresult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }


            try {
                # RDS Servers
                $RDSServerQueryDefn = New-Object VMware.Hv.QueryDefinition
                $RDSServerQueryDefn.queryentitytype = 'RDSServerSummaryView'
                $RDSServerqueryResults = $Queryservice.QueryService_Create($hzServices, $RDSServerQueryDefn)
                $RDSServers = foreach ($RDSServerresult in $RDSServerqueryResults.results) {
                    $hzServices.RDSServer.RDSServer_GetSummaryView($RDSServerresult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            # Base Images
            try {
                $BaseImageVMList = $vCenterServers | ForEach-Object { $hzServices.BaseImageVM.BaseImageVM_List($_.id, $null) }
                $CompatibleBaseImageVMs = $BaseImageVMList | Where-Object {
                    ($_.IncompatibleReasons.InUseByDesktop -eq $false) -and
                    ($_.IncompatibleReasons.InUseByLinkedCloneDesktop -eq $false) -and
                    ($_.IncompatibleReasons.ViewComposerReplica -eq $false) -and
                    ($_.IncompatibleReasons.UnsupportedOS -eq $false) -and
                    ($_.IncompatibleReasons.NoSnapshots -eq $false) -and
                    (($null -eq $_.IncompatibleReasons.InstantInternal) -or ($_.IncompatibleReasons.InstantInternal -eq $false))
                }
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            # Registerd Physical Machines
            Try {
                $RegisteredPhysicalMachineInfoQueryDefn = New-Object VMware.Hv.QueryDefinition
                $RegisteredPhysicalMachineInfoQueryDefn.queryentitytype = 'RegisteredPhysicalMachineInfo'
                $RegisteredPhysicalMachineResults = $Queryservice.QueryService_Create($hzServices, $RegisteredPhysicalMachineInfoQueryDefn)
                $RegisteredPhysicalMachines = foreach ($RegisteredPhysicalMachineresult in $RegisteredPhysicalMachineResults.results) { $hzServices.RegisteredPhysicalMachine.RegisteredPhysicalMachine_Get($RegisteredPhysicalMachineResult.id) }
                $queryservice.QueryService_DeleteAll($hzServices)
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            try {
                # Template Images
                $TemplateVMList = $vCenterServers | ForEach-Object { $hzServices.VmTemplate.VmTemplate_List($_.id) }
                $CompatibleTemplateVMs = $TemplateVMList | Where-Object {
                    ($_.IncompatibleReasons.UnsupportedOS -eq $false)
                }
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            try {
                # CEIP Info
                $CEIP = $hzServices.CEIP.CEIP_Get()
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            try {
                # Global Access Group Info
                $GlobalAccessGroups = $hzServices.GlobalAccessGroup.GlobalAccessGroup_List()
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }

            try {
                # Gateway Certificates
                $script:GatewayCerts = $hzServices.GlobalSettings.GlobalSettings_ListGatewayCertificates()
            } catch {
                Write-PScriboMessage -IsWarning $_.Exception.Message
            }
            Section -Style Heading1 "$($HVEnvironment.toUpper())" {
                Get-AbrHRZInfrastructure
            }

            if ($InfoLevel.UsersAndGroups.PSObject.Properties.Value -ne 0) {
                Section -Style Heading1 'Users and Groups' {
                    Paragraph 'The following section provides information about the permissions that control which remote desktops and applications your users can access.'
                    Get-AbrHRZLocalEntitlement
                    Get-AbrHRZHomeSite
                    Get-AbrHRZUnauthenticatedACL
                }
            }

            if ($InfoLevel.Inventory.PSObject.Properties.Value -ne 0) {
                Section -Style Heading1 'Inventory' {
                    Paragraph 'The following section provides detailed information about desktop, application, farm pools and global entitlement permissions that control which remote desktops and applications your users can access.'
                    Get-AbrHRZDesktopPool
                    Get-AbrHRZApplicationPool
                    Get-AbrHRZFarm
                    Get-AbrHRZMachine
                    Get-AbrHRZGlobalEntitlement
                }
            }

            Section -Style Heading1 'Settings' {
                Paragraph 'The following section provides detailed information about the configuration of the components that comprise the Horizon Server infrastructure.'
                if ($InfoLevel.Settings.Servers.PSObject.Properties.Value -ne 0) {
                    Section -Style Heading2 'Servers' {
                        Get-AbrHRZVcenter
                        Get-AbrHRZDatastore
                        Get-AbrHRZESXi
                        Get-AbrHRZUAG
                        Get-AbrHRZConnectionServer
                        Get-AbrHRZGatewayCert
                    }
                }

                #Get-AbrHRZADDomain
                Get-AbrHRZDomain
                Get-AbrHRZCertMgmt
                Get-AbrHRZLicense
                Get-AbrHRZGlobalSetting
                Get-AbrHRZRegisteredMachine

                if ($InfoLevel.Settings.Administrators.PSObject.Properties.Value -ne 0) {
                    Section -Style Heading2 'Administrators' {
                        Get-AbrHRZAdminGroup
                        Get-AbrHRZRolePrivilege
                        Get-AbrHRZRolePermission
                        Get-AbrHRZAccessGroup
                        Get-AbrHRZFederationAccessGroup
                    }
                }

                Get-AbrHRZCloudPod
                Get-AbrHRZSite
                Get-AbrHRZEventConf
                Get-AbrHRZGlobalpolicy
            }
        }
    }
}
