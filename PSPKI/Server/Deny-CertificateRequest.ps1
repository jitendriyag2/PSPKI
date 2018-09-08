function Deny-CertificateRequest {
<#
.ExternalHelp PSPKI.Help.xml
#>
[OutputType('SysadminsLV.PKI.Utils.IServiceOperationResult')]
[CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({
            if ($_.GetType().FullName -eq "SysadminsLV.PKI.Management.CertificateServices.Database.AdcsDbRow") {$true} else {$false}
        })]$Request
    )
    process {
        if ((Ping-ICertAdmin $Request.ConfigString)) {
            $CertAdmin = New-Object -ComObject CertificateAuthority.Admin
            try {
                $CertAdmin.DenyRequest($Request.ConfigString,$Request.RequestID)
                New-Object SysadminsLV.PKI.Utils.ServiceOperationResult -ArgumentList `
                    0,
                    "Successfully denied request with ID = $($Request.RequestID).",
                    $Request.RequestID				            
            } catch {
                New-Object SysadminsLV.PKI.Utils.ServiceOperationResult -ArgumentList `
                    $_.Exception.InnerException.InnerException.HResult -Property @{
                        InnerObject = $Request.RequestID
                    }
            } finally {
                [PKI.Utils.CryptographyUtils]::ReleaseCom($CertAdmin)
            }
        } else {Write-ErrorMessage -Source ICertAdminUnavailable -ComputerName $Request.ComputerName}
    }
}