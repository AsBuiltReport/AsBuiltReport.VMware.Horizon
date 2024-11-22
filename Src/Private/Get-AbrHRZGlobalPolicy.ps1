function Get-AbrHRZGlobalpolicy {
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

    [CmdletBinding()]
    param (
    )

    begin {
        Write-PScriboMessage "Global Policies InfoLevel set at $($InfoLevel.Settings.GlobalPolicies.GlobalPolicies)."
        Write-PScriboMessage "Collecting Global Policies information."
    }

    process {
        try {
            if ($GlobalPolicies) {
                if ($InfoLevel.Settings.GlobalPolicies.GlobalPolicies -ge 1) {
                    Section -Style Heading2 "Global Policies" {
                        Paragraph "The following section details on the Global Policies information for $($HVEnvironment.toUpper())."
                        BlankLine
                        $OutObj = @()

                        Write-PScriboMessage "Discovered Global Policies Information."
                        $inObj = [ordered] @{
                            'Allow Multimedia Redirection' = $GlobalPolicies.GlobalPolicies.AllowMultimediaRedirection
                            'Allow USB Access' = $GlobalPolicies.GlobalPolicies.AllowUSBAccess
                            'Allow Remote Mode' = $GlobalPolicies.GlobalPolicies.AllowRemoteMode
                            'Allow PCoIP Hardware Acceleration' = $GlobalPolicies.GlobalPolicies.AllowPCoIPHardwareAcceleration
                            'PCoIP Hardware Acceleration Priority' = $GlobalPolicies.GlobalPolicies.PcoipHardwareAccelerationPriority
                        }

                        $OutObj += [pscustomobject](ConvertTo-HashToYN $inObj)

                        $TableParams = @{
                            Name = "Global Policies - $($HVEnvironment.toUpper())"
                            List = $true
                            ColumnWidths = 50, 50
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