function Get-AbrHRZHCvCenter {
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
        Write-PScriboMessage "vCenter Health Check InfoLevel set at $($HealthCheck.vSphere.vCenter)."
        Write-PScriboMessage "vCenter Health information."
    }

    process {
        try {
            if ($vCenterHealth) {
                if ($HealthCheck.vSphere.vcenter) {
                    Section -Style Heading3 "vCenter Health Information" {
                        Paragraph "The following section details on the vCenter health information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()
                        foreach ($VCHealth in $vCenterHealth){
                            $Name=$VCHealth.data.name
                            $TrimmedName = ($Name -replace "https://", "").Split(":")[0].ToLower()
                            $version=$VCHealth.data.version
                            $build=$VCHealth.data.build
                            $apiVersion=$VCHealth.data.apiVersion

                            foreach ($Connectionserver in $VCHealth.connectionServerData){
                                $CertHealth = $Connectionserver.certificateHealth.valid
                                if ($CertHealth -eq "True") {
                                    $CertHealthOUt = "Okay"
                                } else {
                                    $CertHealthOUt = "Invalid"
                                }
                                Write-PScriboMessage "vCenter Health Status Information."
                                $inObj = [ordered] @{
                                    "Name" = $TrimmedName;
                                    "Version"=$version;
                                    "Build"=$build;
                                    "API Version"=$apiVersion;
                                    "Connection Server" = $Connectionserver.name;
                                    "Status" = $Connectionserver.Status;
                                    "Thumbprint Accepted" = $Connectionserver.thumbprintAccepted;
                                    "Certificate Health" = $CertHealth;
                                }

                                $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)
                            }
                        }

                        $TableParams = @{
                            Name = "vCenter Health Information - $($HVEnvironment.toUpper())"
                            List = $false
                            ColumnWidths = 20, 7, 15, 10, 12, 10, 13, 13
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