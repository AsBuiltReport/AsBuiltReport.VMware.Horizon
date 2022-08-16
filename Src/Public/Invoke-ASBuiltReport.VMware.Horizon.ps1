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

    # Check if the required version of VMware PowerCLI is installed
    Get-RequiredModule -Name 'VMware.PowerCLI' -Version '12.7'

    # Import Report Configuration
    $Report = $ReportConfig.Report
    $InfoLevel = $ReportConfig.InfoLevel
    $Options = $ReportConfig.Options


    foreach ($HVEnvironment in $Target) {

        Try {
            $HvServer = Connect-HVServer -Server $HVEnvironment -Credential $Credential -ErrorAction Stop
        }
        Catch {
            Write-PscriboMessage -IsWarning $_.Exception.Message
        }


        # Generate report if connection to Horizon Environment Server Connection is successful
        if ($HvServer) {

            #Environment Varibles

            # Assign a variable to obtain the API Extension Data
            $hzServices = $hvServer.ExtensionData

            # Define HV Query Services
            $Queryservice = new-object vmware.hv.queryserviceservice

            try {
                # Machines
                $MachinesQueryDefn = New-Object VMware.Hv.QueryDefinition
                $MachinesQueryDefn.queryentitytype='MachineSummaryView'
                $MachinesqueryResults = $Queryservice.QueryService_Create($hzServices, $MachinesQueryDefn)
                $Machines = foreach ($Machinesresult in $MachinesqueryResults.results) {
                    $hzServices.machine.machine_get($Machinesresult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            }
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }


            try {
                # RDS Servers
                $RDSServerQueryDefn = New-Object VMware.Hv.QueryDefinition
                $RDSServerQueryDefn.queryentitytype='RDSServerSummaryView'
                $RDSServerqueryResults = $Queryservice.QueryService_Create($hzServices, $RDSServerQueryDefn)
                $RDSServers = foreach ($RDSServerresult in $RDSServerqueryResults.results) {
                    $hzServices.RDSServer.RDSServer_GetSummaryView($RDSServerresult.id)
                }
                $queryservice.QueryService_DeleteAll($hzServices)
            }
            catch {
                Write-PscriboMessage -IsWarning $_.Exception.Message
            }

            section -Style Heading1 "$($HVEnvironment)" {
                if ($InfoLevel.UsersAndGroups.PSObject.Properties.Value -ne 0) {
                    Section -Style Heading2 'Users and Groups' {
                        Get-AbrHRZLocalEntitlement
                        Get-AbrHRZHomeSite
                        Get-AbrHRZUnauthenticatedACL
                    }
                }

                if ($InfoLevel.Inventory.PSObject.Properties.Value -ne 0) {
                    section -Style Heading2 'Inventory' {
                        Get-AbrHRZPoolsInfo
                        Get-AbrHRZApplicationInfo
                        Get-AbrHRZFarmInfo
                        Get-AbrHRZGlobalEntitlement
                    }
                }

                section -Style Heading2 'Settings' {
                    if ($InfoLevel.Settings.Servers.PSObject.Properties.Value -ne 0) {
                        section -Style Heading3 'Servers' {

                            Get-AbrHRZVcenterInfo
                            Get-AbrHRZESXiInfo
                            Get-AbrHRZDatastoreInfo
                            Get-AbrHRZADDomainInfo
                            Get-AbrHRZUAGInfo
                            Get-AbrHRZConnectionServerInfo

                        }
                    }

                    Get-AbrHRZInstantClone
                    Get-AbrHRZLicenseInfo
                    Get-AbrHRZGlobalSetting
                    Get-AbrHRZRegisteredMachine

                    if ($InfoLevel.Settings.Administrators.PSObject.Properties.Value -ne 0) {
                        section -Style Heading3 'Administrators' {
                            Get-AbrHRZAdminGroupInfo
                            Get-AbrHRZRolePrivilege
                            Get-AbrHRZRolePermission
                            Get-AbrHRZAccessGroup

                        }
                    }

                    Get-AbrHRZEventConfInfo
                }
            }
        }
    }
}