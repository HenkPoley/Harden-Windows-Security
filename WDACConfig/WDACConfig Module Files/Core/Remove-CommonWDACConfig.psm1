Function Remove-CommonWDACConfig {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$CertCN,
        [parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$CertPath,
        [parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$SignToolPath,
        [parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$UnsignedPolicyPath,
        [parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$SignedPolicyPath,
        [parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$StrictKernelPolicyGUID,
        [parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$StrictKernelNoFlightRootsPolicyGUID,
        [parameter(Mandatory = $false, DontShow = $true)][System.Management.Automation.SwitchParameter]$LastUpdateCheck
    )
    begin {
        # Importing the $PSDefaultParameterValues to the current session, prior to everything else
        . "$ModuleRootPath\CoreExt\PSDefaultParameterValues.ps1"

        # Create User configuration folder if it doesn't already exist
        if (-NOT (Test-Path -Path "$UserAccountDirectoryPath\.WDACConfig\")) {
            New-Item -ItemType Directory -Path "$UserAccountDirectoryPath\.WDACConfig\" -Force -ErrorAction Stop | Out-Null
            Write-Verbose -Message 'The .WDACConfig folder in the current user folder has been created because it did not exist.'
        }

        # Create User configuration file if it doesn't already exist
        if (-NOT (Test-Path -Path "$UserAccountDirectoryPath\.WDACConfig\UserConfigurations.json")) {
            New-Item -ItemType File -Path "$UserAccountDirectoryPath\.WDACConfig\" -Name 'UserConfigurations.json' -Force -ErrorAction Stop | Out-Null
            Write-Verbose -Message 'The UserConfigurations.json file in \.WDACConfig\ folder has been created because it did not exist.'
        }

        # Delete the entire User Configs if a more specific parameter wasn't used
        # This method is better than $PSBoundParameters since it also contains common parameters
        if (!$CertCN -And !$CertPath -And !$SignToolPath -And !$UnsignedPolicyPath -And !$SignedPolicyPath -And !$StrictKernelPolicyGUID -And !$StrictKernelNoFlightRootsPolicyGUID -And !$LastUpdateCheck) {
            Remove-Item -Path "$UserAccountDirectoryPath\.WDACConfig\" -Recurse -Force
            Write-Verbose -Message 'User Configurations for WDACConfig module have been deleted.'

            # set a boolean value that returns from the Process and End blocks as well
            [System.Boolean]$ReturnAndDone = $true

            Return
        }

        # Read the current user configurations
        [System.Object[]]$CurrentUserConfigurations = Get-Content -Path "$UserAccountDirectoryPath\.WDACConfig\UserConfigurations.json"

        # If the file exists but is corrupted and has bad values, rewrite it
        try {
            $CurrentUserConfigurations = $CurrentUserConfigurations | ConvertFrom-Json
        }
        catch {
            Set-Content -Path "$UserAccountDirectoryPath\.WDACConfig\UserConfigurations.json" -Value ''
        }

        # An object to hold the User configurations
        $UserConfigurationsObject = [PSCustomObject]@{
            SignedPolicyPath                    = ''
            UnsignedPolicyPath                  = ''
            SignToolCustomPath                  = ''
            CertificateCommonName               = ''
            CertificatePath                     = ''
            StrictKernelPolicyGUID              = ''
            StrictKernelNoFlightRootsPolicyGUID = ''
            LastUpdateCheck                     = ''
        }
    }
    process {

        if ($true -eq $ReturnAndDone) { return }

        if ($SignedPolicyPath) {
            Write-Verbose -Message 'Removing the SignedPolicyPath'
            $UserConfigurationsObject.SignedPolicyPath = ''
        }
        else {
            $UserConfigurationsObject.SignedPolicyPath = $CurrentUserConfigurations.SignedPolicyPath
        }

        if ($UnsignedPolicyPath) {
            Write-Verbose -Message 'Removing the UnsignedPolicyPath'
            $UserConfigurationsObject.UnsignedPolicyPath = ''
        }
        else {
            $UserConfigurationsObject.UnsignedPolicyPath = $CurrentUserConfigurations.UnsignedPolicyPath
        }

        if ($SignToolPath) {
            Write-Verbose -Message 'Removing the SignToolPath'
            $UserConfigurationsObject.SignToolCustomPath = ''
        }
        else {
            $UserConfigurationsObject.SignToolCustomPath = $CurrentUserConfigurations.SignToolCustomPath
        }

        if ($CertPath) {
            Write-Verbose -Message 'Removing the CertPath'
            $UserConfigurationsObject.CertificatePath = ''
        }
        else {
            $UserConfigurationsObject.CertificatePath = $CurrentUserConfigurations.CertificatePath
        }

        if ($CertCN) {
            Write-Verbose -Message 'Removing the CertCN'
            $UserConfigurationsObject.CertificateCommonName = ''
        }
        else {
            $UserConfigurationsObject.CertificateCommonName = $CurrentUserConfigurations.CertificateCommonName
        }

        if ($StrictKernelPolicyGUID) {
            Write-Verbose -Message 'Removing the StrictKernelPolicyGUID'
            $UserConfigurationsObject.StrictKernelPolicyGUID = ''
        }
        else {
            $UserConfigurationsObject.StrictKernelPolicyGUID = $CurrentUserConfigurations.StrictKernelPolicyGUID
        }

        if ($StrictKernelNoFlightRootsPolicyGUID) {
            Write-Verbose -Message 'Removing the StrictKernelNoFlightRootsPolicyGUID'
            $UserConfigurationsObject.StrictKernelNoFlightRootsPolicyGUID = ''
        }
        else {
            $UserConfigurationsObject.StrictKernelNoFlightRootsPolicyGUID = $CurrentUserConfigurations.StrictKernelNoFlightRootsPolicyGUID
        }

        if ($LastUpdateCheck) {
            Write-Verbose -Message 'Removing the LastUpdateCheck'
            $UserConfigurationsObject.LastUpdateCheck = ''
        }
        else {
            $UserConfigurationsObject.LastUpdateCheck = $CurrentUserConfigurations.LastUpdateCheck
        }
    }
    end {

        if ($true -eq $ReturnAndDone) { return }

        # Update the User Configurations file
        Write-Verbose -Message 'Saving the changes'
        $UserConfigurationsObject | ConvertTo-Json | Set-Content -Path "$UserAccountDirectoryPath\.WDACConfig\UserConfigurations.json"
    }
    <#
.SYNOPSIS
    Removes common values for parameters used by WDACConfig module
.LINK
    https://github.com/HotCakeX/Harden-Windows-Security/wiki/Remove-CommonWDACConfig
.DESCRIPTION
    Removes common values for parameters used by WDACConfig module from the User Configurations JSON file. If you don't use it with any parameters, then all User Configs will be deleted.
.COMPONENT
    Windows Defender Application Control, ConfigCI PowerShell module, WDACConfig module
.FUNCTIONALITY
    Removes common values for parameters used by WDACConfig module from the User Configurations JSON file. If you don't use it with any parameters, then all User Configs will be deleted.
.PARAMETER SignedPolicyPath
    Removes the SignedPolicyPath from User Configs
.PARAMETER UnsignedPolicyPath
    Removes the UnsignedPolicyPath from User Configs
.PARAMETER CertCN
    Removes the CertCN from User Configs
.PARAMETER SignToolPath
    Removes the SignToolPath from User Configs
.PARAMETER CertPath
    Removes the CertPath from User Configs
.PARAMETER StrictKernelPolicyGUID
    Removes the StrictKernelPolicyGUID from User Configs
.PARAMETER StrictKernelNoFlightRootsPolicyGUID
    Removes the StrictKernelNoFlightRootsPolicyGUID from User Configs
.PARAMETER LastUpdateCheck
    Using DontShow for this parameter which prevents common parameters from being displayed too
.INPUTS
    System.Management.Automation.SwitchParameter
.OUTPUTS
    System.String
#>
}