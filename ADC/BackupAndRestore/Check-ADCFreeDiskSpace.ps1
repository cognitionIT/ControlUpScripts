<#
.SYNOPSIS
    Check free disk space on the the Citrix ADC.
.DESCRIPTION
    Check free disk space on the the Citrix ADC, using NITRO.
.EXAMPLE
    Check-ADCFreeDiskSpace -NSIP <ipaddress> 
.CONTEXT
    NetScalers
.MODIFICATION_HISTORY
    Esther Barthel, MSc - 02/03/20 - Original code
    Esther Barthel, MSc - 02/03/20 - Standardizing script, based on the ControlUp Scripting Standards (version 0.2)
.LINK
    https://support.citrix.com/article/CTX2295559
.NOTES
    Version:        0.1
    Author:         Esther Barthel, MSc
    Creation Date:  2020-03-02
    Updated:        2020-03-02
                    Standardized the function, based on the ControlUp Standards (v0.2)
    Purpose:        Script Action, created for ControlUp Citrix ADC Management
        
    Copyright (c) cognition IT. All rights reserved.
#>

function Get-CUStoredCredential {
# function created by Ton de Vreede for a standardized usage of the PowerShell Stored Credentials, based on Import-Clixml 
    param (
        [parameter(Mandatory = $true,
            HelpMessage = "The system the credentials will be used for.")]
        [string]$System
    )

    # Get the stored credential object
    $strCUCredFolder = "$([environment]::GetFolderPath('CommonApplicationData'))\ControlUp\ScriptSupport"
    
    try {
        Import-Clixml $strCUCredFolder\$($env:USERNAME)_$($System)_Cred.xml
    }
    catch {
        Write-Error ("The required PSCredential object could not be loaded. " + $_)
    }
}

function Get-ADCCredentials()
{
    <#
    .SYNOPSIS
        Retrieve the Citrix ADC Credentials.
    .DESCRIPTION
        Retrieve the Citrix ADC Credentials from either a stored credentials file or Get-Credential popup.
    .EXAMPLE
        Get-ADCCredentials
    .CONTEXT
        NetScalers
    .MODIFICATION_HISTORY
        Esther Barthel, MSc - 31/12/19 - Original code
        Esther Barthel, MSc - 31/12/19 - Standardizing script, based on the ControlUp Scripting Standards (version 0.2)
    .COMPONENT
        Get-CUStoredCredential - to retreive the XML Credentials file for non-interactive/automated use of this script
        Import-Clixml - https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-clixml?view=powershell-5.1
    .NOTES
        Version:        0.1
        Author:         Esther Barthel, MSc
        Creation Date:  2019-12-31
        Updated:        2019-12-31
                        Standardized the function, based on the ControlUp Standards (v0.2)
        Purpose:        Script Action, created for ControlUp NetScaler Monitoring
        
        Copyright (c) cognition IT. All rights reserved.
    #>
    [CmdletBinding()]
    Param()

    #region script settings
        # Stored ADC Credentials XML file
        $systemName = "ADC"
        $credTargetFolder = "$([environment]::GetFolderPath('CommonApplicationData'))\ControlUp\ScriptSupport"
        $credTarget = "$credTargetFolder\$($Env:Username)_$($systemName)_Cred.xml"
        # Declare ADC Credentials object
        [System.Management.Automation.PSCredential]$adcCredentials = $null
    #endregion

    Write-Verbose ""
    Write-Verbose "------------------------ "
    Write-Verbose "| Get ADC Credentials: | "
    Write-Verbose "------------------------ "
    Write-Verbose ""

    #region Load ADC Credentials either trough XML file import or Get-Credentials
        # Check for Stored Credentials
        If (Test-Path -Path $credTarget)
        # Stored credentials found, import credentials
        {
            try
            {
                $adcCredentials = Get-CUStoredCredential -System $systemName
            }
            catch
            {
                Write-Error ("A [" + $_.Exception.GetType().FullName + "] ERROR occurred. " + $_.Exception.Message)
                Exit
            }
            Write-Verbose "* ADC Credentials: Stored $systemName credentials XML file found. ADC credentials imported for Automated Action support."
        }
        Else
        # No Stored Credentials Found, ask for credentials
        {
            Write-Verbose "* ADC Credentials: Stored $systemName credentials XML file NOT found, using Get-Credential to retrieve ADC credentials."
            $adcCredentials = Get-Credential -Message "Enter your credentials for Citrix ADC $NSIP"
        }
    #endregion

    # Return the ADC Credentials (PSCredential object) for future use in the NITRO functions
    If (!($adcCredentials -eq $null))
    {
        Write-Verbose "* ADC Credentials: credentials returned."
        return $adcCredentials
    }
    Else
    {
        Write-Verbose "* ADC Credentials: NO credentials returned."
        Write-Error "No ADC Credentials retrieved, cannot perform NITRO actions."
        Exit
    }
}

function Get-ADCSystemStats ()
{
    <#
    .SYNOPSIS
        Retrieve system statistics of the Citrix ADC.
    .DESCRIPTION
        Retrieve system statistics of the Citrix ADC, using NITRO.
    .EXAMPLE
        Get-ADCSystemStats -NSIP 192.168.0.99
    .EXAMPLE
        Get-ADCSystemStats -NSIP 192.168.0.99 -NSCredentials $PSCredentialsObject
    .CONTEXT
        NetScalers
    .MODIFICATION_HISTORY
        Esther Barthel, MSc - 02/03/20 - Original code
        Esther Barthel, MSc - 02/03/20 - Standardizing script, based on the ControlUp Scripting Standards (version 0.2)
    .LINK
        https://developer-docs.citrix.com/projects/netscaler-nitro-api/en/latest/statistics/system/system/system/#get-all
    .COMPONENT
        Get-ADCCredential - to retreive the XML Credentials file with the ADC credentials for non-interactive/automated use of this script
    .NOTES
        Version:        0.1
        Author:         Esther Barthel, MSc
        Creation Date:  2020-03-02
        Updated:        2020-03-02
                        Standardized the function, based on the ControlUp Standards (v0.2)
        Purpose:        Script Action, created for ControlUp NetScaler Monitoring
        
        Copyright (c) cognition IT. All rights reserved.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(
            Position=0, 
            Mandatory=$true, 
            HelpMessage='Enter the Citrix ADC IP address to run the script on'
        )]
        [ValidateScript({$_ -match [IPAddress]$_ })]
        [string] $NSIP,
            
        [Parameter(
            Position=1, 
            Mandatory=$false, 
            HelpMessage='Enter a PSCredential object, containing the username and password'
        )]
        [System.Management.Automation.CredentialAttribute()] $ADCCredentials
    )    

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
        # Stored ADC Credentials XML file
        $systemName = "ADC"
        $credTargetFolder = "$([environment]::GetFolderPath('CommonApplicationData'))\ControlUp\ScriptSupport"
        $credTarget = "$credTargetFolder\$($Env:Username)_$($systemName)_Cred.xml"
        # NITRO Constants
        $ContentType = "application/json"
        # turn Verbose mode on
        #$VerbosePreference = "Continue"
        # turn Verbose mode off
        #$VerbosePreference="SilentlyContinue"
    #endregion

    Write-Verbose ""
    Write-Verbose "------------------------------------------- "
    Write-Verbose "| Get Citrix ADC system stats with NITRO: | "
    Write-Verbose "------------------------------------------- "
    Write-Verbose ""

    #region Load ADCCredentials, or ask if none are provided
    If ($null -eq $ADCCredentials)
    {
        $ADCCredentials = Get-ADCCredentials
    }
    #endregion

    # Retieving username and password from PSCredentials object for use with NITRO
    $NSUserName = $ADCCredentials.UserName
    $NSUserPW = $ADCCredentials.GetNetworkCredential().Password

    # ----------------------------------------
    # | Method #1: Using the SessionVariable |
    # ----------------------------------------
    #region Start NITRO Session
        #Force PowerShell to bypass validation for (self-signed) certificates and SSL connections
        # source: https://blogs.technet.microsoft.com/bshukla/2010/04/12/ignoring-ssl-trust-in-powershell-system-net-webclient/ 
        Write-Verbose "* Certificate Validation: Forcing PowerShell to trust all certificates (including the self-signed netScaler certificate)"
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

        #JSON payload
        $LoginJSON = ConvertTo-Json @{
            "login" = @{
                "username"=$NSUserName;
                "password"=$NSUserPW
            }
        }
        try
        {
            # Login to the NetScaler and create a session (stored in $NSSession)
            $invokeRestMethodParams = @{
                Uri             = "https://$NSIP/nitro/v1/config/login"
                Body            = $LoginJSON
                Method          = "Post"
                SessionVariable = "NSSession"
                ContentType     = $ContentType
            }
            $loginresponse = Invoke-RestMethod @invokeRestMethodParams
        }
        catch [System.Management.Automation.ParameterBindingException]
        {
            Write-Error ("A parameter binding ERROR occurred. Please provide the correct NetScaler IP-address. " + $_.Exception.Message)
            Exit
        }
        catch
        {
            If (($_.Exception.Message -like "*Unauthorized*") -and (Test-Path -Path $XMLFile))
            {
                Write-Warning "XML Stored NSCredentials were used, check if the stored NSCredentials are correct for this Citrix ADC (" + $NSIP + ")."
            }
            # Debug: 
            Write-Debug $_.Exception | Format-List -Force
            # Error:
            Write-Error ("A [" + $_.Exception.GetType().FullName + "] ERROR occurred. " + $_.Exception.Message)
            Exit
        }
        # Check for REST API errors
        If ($loginresponse.errorcode -eq 0)
        {
            Write-Verbose "* NITRO: login successful"
        }
    #endregion Start NITRO Session

    # --------------------
    # | Get system stats |
    # --------------------
    #region system
        # start with clean response variable
        $adcNsvpxparam = $null
            
        # Create the Invoke-RestMethod params
        $uri = "https://$NSIP/nitro/v1/stat/system"

        try
        {
            $invokeRestMethodParams = @{
                Uri         = $uri
                Method      = "GET"
                WebSession  = $NSSession
                ContentType = $ContentType
            }
            $adcNssystem = Invoke-RestMethod @invokeRestMethodParams
        }
        catch
        {
            Write-Error $error[0] 
            Exit          
        }

        If ( -not ($adcNssystem.errorcode -eq 0))
        # NITRO errorcode found (or results is empty)
        {
            Write-Error "NITRO: errorcode (" + $adcNssystem.errorcode + ") " + $adcNssystem.message + "."
            Exit
        }

        Write-Verbose "* NITRO: system stats retrieved successful"
        if ($adcNssystem.system)
        {
            $results = $adcNssystem.system
            return $results
        }
        else
        {
            Write-Warning "No system stats found."
        }
    #endregion

    #region End NetScaler NITRO Session
        #Disconnect from the NetScaler (cleanup session)
        $LogOut = @{
            "logout" = @{}
        } | ConvertTo-Json

        try
        {
            # Loout of the NetScaler and remove the session (stored in $NSSession)
            $invokeRestMethodParams = @{
                Uri             = "https://$NSIP/nitro/v1/config/logout"
                Body            = $LogOut
                Method          = "Post"
                WebSession      = $NSSession
                ContentType     = $ContentType
            }
            $logoutresponse = Invoke-RestMethod @invokeRestMethodParams
        }
        catch [System.Management.Automation.ParameterBindingException]
        {
            Write-Error ("A parameter binding ERROR occurred. Please provide the correct NetScaler IP-address. " + $_.Exception.Message)
            Exit
        }
        catch
        {
            # Debug: 
            Write-Debug $_.Exception | Format-List -Force
            # Error:
            Write-Error ("A [" + $_.Exception.GetType().FullName + "] ERROR occurred. " + $_.Exception.Message)
            Exit
        }
        # Check for REST API errors
        If ($logoutresponse.errorcode -eq 0)
        {
            Write-Verbose "* NITRO: logout successful"
        }
    #endregion End NetScaler NITRO Session
}



#------------------------#
# Script Action workflow #
#------------------------#
Write-Host ""

## Retrieve input parameters
#$NSIP = $args[0]

## Testing Script
$NSIP = "192.168.56.99"

# Initiate variables
[System.Management.Automation.PSCredential]$adcCreds = $null

# Step 0: Retrieve ADC Credentials
$adcCreds = Get-ADCCredentials #-Verbose

# Step 2: Check nsversion
Write-Host "* Step 2: Retrieve the Citrix ADC system stats: " -ForegroundColor Yellow -NoNewline
$nssystemstats = Get-ADCSystemStats -NSIP $NSIP -ADCCredentials $adcCreds #-Verbose -Debug
Write-Host "SUCCESS" -ForegroundColor Green
$nssystemstats | Select-Object cpuusage, numcpus, memusagepcnt, memuseinmb, disk0perusage, disk1perusage, disk0size, disk0used, disk0avail, disk1size, disk1used, disk1avail

$nssystemstats | Select-Object @{Name="flash usage (%)";Expression={$_.disk0perusage}}, 
                               @{Name="var usage (%)";Expression={$_.disk1perusage}}, 
                               @{Name="flash size (MB)";Expression={"{0:n0}" -f ($_.disk0size)}}, 
                               @{Name="flash used (MB)";Expression={"{0:n0}" -f ($_.disk0used)}},
                               @{Name="flash available (MB)";Expression={"{0:n0}" -f ($_.disk0avail)}},
                               @{Name="var size (MB)";Expression={"{0:n0}" -f ($_.disk1size)}}, 
                               @{Name="var used (MB)";Expression={"{0:n0}" -f ($_.disk1used)}},
                               @{Name="var available (MB)";Expression={"{0:n0}" -f ($_.disk1avail)}}

$varAvailableMB = $nssystemstats.disk1avail
$varUsedPercentage = $nssystemstats.disk1perusage

If ($varUsedPercentage -le 90)
{
    Write-Host "$($varUsedPercentage)% diskspace used, enough space to create a new backup"
}
Else
{
    Write-Host "$($varUsedPercentage)% diskspace used, free up space before creating a new backup" 
}
