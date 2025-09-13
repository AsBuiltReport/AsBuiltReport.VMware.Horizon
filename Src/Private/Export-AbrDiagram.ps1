function Export-AbrDiagram {
    <#
    .SYNOPSIS
        Function used to build the settings needed to call Export-Diagrammer (Diagrammer.Core)

    .DESCRIPTION
        The Export-AbrDiagram function build the settings needed to call Export-Diagrammer (Diagrammer.Core)
        to export a diagram in PDF, PNG, SVG, or base64 formats using PSgraph.
    .NOTES
        Version:        0.1.1
        Author:         AsBuiltReport Organization
        Twitter:        @AsBuiltReport
        Github:         AsBuiltReport

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.VMware.Horizon
    #>

    # Don't remove this line (Don't touch it!)
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingCmdletAliases", "", Scope = "Function")]

    [CmdletBinding()]
    param (
        $DiagramObject,
        [string] $MainDiagramLabel = 'Change Me',
        [Parameter(Mandatory = $true)]
        [string] $FileName,
        [string] $Orientation = 'Portrait'
    )

    begin {
        Write-PScriboMessage -Message "EnableDiagrams set to $($Options.EnableDiagrams)."
    }

    process {
        if ($Options.EnableDiagrams) {
            Write-PScriboMessage -Message "Loading export diagram settings"

            $RootPath = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
            [System.IO.FileInfo]$IconPath = Join-Path -Path $RootPath -ChildPath 'icons'

            $DiagramParams = @{
                'FileName' = $FileName
                'OutputFolderPath' = $OutputFolderPath
                'MainDiagramLabel' = $MainDiagramLabel
                'MainDiagramLabelFontsize' = 28
                'MainDiagramLabelFontcolor' = '#565656'
                'MainDiagramLabelFontname' = 'Segoe UI Black'
                'IconPath' = $IconPath
                'ImagesObj' = $Images
                'LogoName' = 'AsBuiltReport_LOGO'
                'SignatureLogoName' = 'AsBuiltReport_Signature'
                'WaterMarkText' = $Options.DiagramWaterMark
                'Direction' = 'top-to-bottom'
            }

            if ($Options.DiagramTheme -eq 'Black') {
                $DiagramParams.add('MainGraphBGColor', 'Black')
                $DiagramParams.add('Edgecolor', 'White')
                $DiagramParams.add('Fontcolor', 'White')
                $DiagramParams.add('NodeFontcolor', 'White')
                $DiagramParams.add('WaterMarkColor', 'White')
            } elseif ($Options.DiagramTheme -eq 'Neon') {
                $DiagramParams.add('MainGraphBGColor', 'grey14')
                $DiagramParams.add('Edgecolor', 'gold2')
                $DiagramParams.add('Fontcolor', 'gold2')
                $DiagramParams.add('NodeFontcolor', 'gold2')
                $DiagramParams.add('WaterMarkColor', '#FFD700')
            } else {
                $DiagramParams.add('WaterMarkColor', '#333333')
            }

            if ($Options.ExportDiagrams) {
                if (-not $Options.ExportDiagramsFormat) {
                    $DiagramFormat = 'png'
                } else {
                    $DiagramFormat = $Options.ExportDiagramsFormat
                }
                $DiagramParams.Add('Format', $DiagramFormat)
            } else {
                $DiagramParams.Add('Format', "base64")
            }

            if ($Options.EnableDiagramDebug) {

                $DiagramParams.Add('DraftMode', $True)

            }

            if ($Options.EnableDiagramSignature) {
                $DiagramParams.Add('Signature', $True)
                $DiagramParams.Add('AuthorName', $Options.SignatureAuthorName)
                $DiagramParams.Add('CompanyName', $Options.SignatureCompanyName)
            }

            if ($Options.ExportDiagrams) {
                try {
                    Write-PScriboMessage -Message "Generating $MainDiagramLabel diagram"
                    $Graph = $DiagramObject
                    if ($Graph) {
                        Write-PScriboMessage -Message "Saving $MainDiagramLabel diagram"
                        $Diagram = New-Diagrammer @DiagramParams -InputObject $Graph
                        if ($Diagram) {
                            foreach ($OutputFormat in $DiagramFormat) {
                                Write-Information -MessageData "Saved '$($FileName).$($OutputFormat)' diagram to '$($OutputFolderPath)'." -InformationAction Continue
                            }
                        }
                    }
                } catch {
                    Write-PScriboMessage -IsWarning -Message "Unable to export the $MainDiagramLabel Diagram: $($_.Exception.Message)"
                }
            }
            try {
                $DiagramParams.Remove('Format')
                $DiagramParams.Add('Format', "base64")

                $Graph = $DiagramObject
                $Diagram = New-Diagrammer @DiagramParams -InputObject $Graph
                if ($Diagram) {
                    if ((Get-DiaImagePercent -GraphObj $Diagram).Width -gt 600) { $ImagePrty = 30 } else { $ImagePrty = 50 }
                    Section -Style Heading2 $MainDiagramLabel -Orientation $Orientation {
                        Image -Base64 $Diagram -Text "$MainDiagramLabel" -Percent $ImagePrty -Align Center
                        Paragraph "Image preview: Opens the image in a new tab to view it at full resolution." -Tabs 2
                    }
                }
            } catch {
                Write-PScriboMessage -IsWarning -Message "Unable to generate the $MainDiagramLabel Diagram: $($_.Exception.Message)"
            }
        }
    }

    end {}
}