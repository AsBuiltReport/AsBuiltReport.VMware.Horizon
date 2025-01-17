function Get-AbrHRZHCDomain {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of VMware Horizon in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of VMware Horizon in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        1.1.5
        Author:         Chris Hildebrandt, Karl Newick
        Twitter:        @childebrandt42, @karlnewick
        Editor:         Jonathan Colon, @jcolonfzenpr
        Twitter:        @asbuiltreport
        Github:         AsBuiltReport
        Credits:        Iain Brighton (@iainbrighton) - PScribo module, Wouter Kursten - Health Check


    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon
    #>

    [CmdletBinding()]
    param (
    )

    begin {
        Write-PScriboMessage "Domain Health Check InfoLevel set at $($HealthCheck.OtherComponents.Domains)."
        Write-PScriboMessage "Domain Health information."
    }

    process {
        try {
            if ($Domains) {
                if ($HealthCheck.OtherComponents.Domains) {
                    Section -Style Heading3 "Domain Health Information" {
                        Paragraph "The following section details on the Domain health information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()
                        foreach ($Domain in $Domains){
                            $TrustRel = $Domain.ConnectionServerState[0].TrustRelationship
                            $DomainSat = $Domain.ConnectionServerState[0].Status
                            $AllTrustRelSame = $true
                            $AllDomainStatSame = $true

                            foreach($CSDomainStatus in $Domain.ConnectionServerState){
                                if ($CSDomainStatus.TrustRelationship -ne $TrustRel) {
                                    $AllTrustRelSame = $false
                                    break
                                }
                                if ($CSDomainStatus.Status -ne $DomainSat) {
                                    $AllDomainStatSame = $false
                                    break
                                }
                            }

                            if ($AllTrustRelSame) {
                                $TrustOut = $TrustRel
                            } else {
                                $TrustOut = "Trust relationships are not identical."
                            }
                            if ($AllDomainStatSame) {
                                $DomainOut = $DomainSat
                            } else {
                                $DomainOut = "Status is not consistent"
                            }

                            Write-PScriboMessage "Domain Health Status Information."
                            $inObj = [ordered] @{
                                "Domain Name" = $domain.NetBiosName;
                                "Status" = $DomainOut;
                                "Trust Relationship" = $TrustOut;
                            }

                            $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                        }

                        $TableParams = @{
                            Name = "Domain Health Information - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 30, 35, 35
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