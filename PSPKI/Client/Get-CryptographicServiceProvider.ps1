function Get-CryptographicServiceProvider {
<#
.ExternalHelp PSPKI.Help.xml
#>
[OutputType('SysadminsLV.PKI.Cryptography.CspProviderInfoCollection')]
[CmdletBinding()]
    param(
        [string]$Name
    )
    if ([string]::IsNullOrWhiteSpace($Name)) {
        [SysadminsLV.PKI.Cryptography.CspProviderInfoCollection]::GetProviderInfo()
    } else {
        [SysadminsLV.PKI.Cryptography.CspProviderInfoCollection]::GetProviderInfo($Name)
    }    
}