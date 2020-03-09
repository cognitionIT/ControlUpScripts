<#
.SYNOPSIS
    Store WVD required credentials in an encrypted XML file.
.DESCRIPTION
    Store WVD required credentials in an encrypted XML file, using Export-Clixml.
.EXAMPLE
    Set-WVDCredentials 
.CONTEXT
    Windows Virtual Desktops
.MODIFICATION_HISTORY
    Esther Barthel, MSc - 09/03/20 - Original code
    Esther Barthel, MSc - 09/03/20 - Standardizing script, based on the ControlUp Scripting Standards (version 0.2)

.LINK
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-clixml?view=powershell-5.1
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-clixml?view=powershell-5.1
.NOTES
    Version:        0.1
    Author:         Esther Barthel, MSc
    Creation Date:  2020-03-09
    Updated:        2020-03-09
                    Standardized the function, based on the ControlUp Standards (v0.2)
    Purpose:        Script Action, created for ControlUp Citrix ADC Management
        
    Copyright (c) cognition IT. All rights reserved.
#>


function Get-WVDStoredCredentials {
    <#
    .SYNOPSIS
        Retrieve the Azure WVD Credentials.
    .DESCRIPTION
        Retrieve the Azure WVDC Credentials from a stored credentials file.
    .EXAMPLE
        Get-WVDCredentials
    .CONTEXT
        Windows Virtual Desktops
    .MODIFICATION_HISTORY
        Esther Barthel, MSc - 31/12/19 - Original code
        Esther Barthel, MSc - 31/12/19 - Standardizing script, based on the ControlUp Scripting Standards (version 0.2)
    .COMPONENT
        Import-Clixml - https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-clixml?view=powershell-5.1
    .NOTES
        Version:        0.1
        Author:         Esther Barthel, MSc
        Creation Date:  2020-03-03
        Updated:        2020-03-01
                        Standardized the function, based on the ControlUp Standards (v0.2)
        Purpose:        Script Action, created for ControlUp NetScaler Monitoring
        
        Copyright (c) cognition IT. All rights reserved.
    #>
    [CmdletBinding()]
    Param()

    #region ControlUp Script Standards - version 0.2
        #Requires -Version 3.0

        # Configure a larger output width for the ControlUp PowerShell console
        [int]$outputWidth = 400
        # Altering the size of the PS Buffer
        $PSWindow = (Get-Host).UI.RawUI
        $WideDimensions = $PSWindow.BufferSize
        $WideDimensions.Width = $outputWidth
        $PSWindow.BufferSize = $WideDimensions

        # Ensure Debug information is shown, without the confirmation question after each Write-Debug
        If ($PSBoundParameters['Debug']) {$DebugPreference = "Continue"}
        If ($PSBoundParameters['Verbose']) {$VerbosePreference = "Continue"}
        $ErrorActionPreference = "Stop"
    #endregion

    #region script settings
        # Stored Credentials XML file
        $System = "WVD"
        $strWVDCredFolder = "$([environment]::GetFolderPath('CommonApplicationData'))\ControlUp\ScriptSupport"
        $WVDCredentials = $null
    #endregion

    Write-Verbose ""
    Write-Verbose "------------------------------ "
    Write-Verbose "| Get Azure WVD Credentials: | "
    Write-Verbose "------------------------------ "
    Write-Verbose ""

    If (Test-Path -Path "$($strCUCredFolder)\$($env:USERNAME)_$($System)_Cred.xml")
    {
        try 
        {
           $WVDCredentials = Import-Clixml $strWVDCredFolder\$($env:USERNAME)_$($System)_Cred.xml
        }
        catch 
        {
            Write-Error ("The required PSCredential object could not be loaded. " + $_)
        }
    }
    Else
    {
        Write-Error "The Stored Credentials file cannot be found!"
    }
    return $WVDCredentials
}


function Set-WVDStoredCredentials {
    <#
    .SYNOPSIS
        Retrieve the Azure WVD Credentials.
    .DESCRIPTION
        Retrieve the Azure WVDC Credentials from a stored credentials file.
    .EXAMPLE
        Get-WVDCredentials
    .CONTEXT
        Windows Virtual Desktops
    .MODIFICATION_HISTORY
        Esther Barthel, MSc - 31/12/19 - Original code
        Esther Barthel, MSc - 31/12/19 - Standardizing script, based on the ControlUp Scripting Standards (version 0.2)
    .COMPONENT
        Import-Clixml - https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-clixml?view=powershell-5.1
    .NOTES
        Version:        0.1
        Author:         Esther Barthel, MSc
        Creation Date:  2020-03-03
        Updated:        2020-03-01
                        Standardized the function, based on the ControlUp Standards (v0.2)
        Purpose:        Script Action, created for ControlUp NetScaler Monitoring
        
        Copyright (c) cognition IT. All rights reserved.
    #>
    [CmdletBinding()]
    Param()

    #region ControlUp Script Standards - version 0.2
        #Requires -Version 3.0

        # Configure a larger output width for the ControlUp PowerShell console
        [int]$outputWidth = 400
        # Altering the size of the PS Buffer
        $PSWindow = (Get-Host).UI.RawUI
        $WideDimensions = $PSWindow.BufferSize
        $WideDimensions.Width = $outputWidth
        $PSWindow.BufferSize = $WideDimensions

        # Ensure Debug information is shown, without the confirmation question after each Write-Debug
        If ($PSBoundParameters['Debug']) {$DebugPreference = "Continue"}
        If ($PSBoundParameters['Verbose']) {$VerbosePreference = "Continue"}
        $ErrorActionPreference = "Stop"
    #endregion

    #region script settings
        # Stored Credentials XML file
        $System = "WVD"
        $strWVDCredFolder = "$([environment]::GetFolderPath('CommonApplicationData'))\ControlUp\ScriptSupport"
        $WVDCredentials = $null
    #endregion

    Write-Verbose ""
    Write-Verbose "------------------------------ "
    Write-Verbose "| Get Azure WVD Credentials: | "
    Write-Verbose "------------------------------ "
    Write-Verbose ""

    If (Test-Path -Path "$($strCUCredFolder)\$($env:USERNAME)_$($System)_Cred.xml")
    {
        try 
        {
           $WVDCredentials = Import-Clixml $strWVDCredFolder\$($env:USERNAME)_$($System)_Cred.xml
        }
        catch 
        {
            Write-Error ("The required PSCredential object could not be loaded. " + $_)
        }
    }
    Else
    {
        Write-Error "The Stored Credentials file cannot be found!"
    }
    return $WVDCredentials
}





#------------------------#
# Script Action workflow #
#------------------------#
Write-Host ""

## Retrieve input parameters
#$WVD = $args[0]
#$checkOnly = $args[1]

## Testing Script
Get-WVDStoredCredentials


