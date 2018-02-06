function Deny-CertificateRequest {
<#
.ExternalHelp PSPKI.Help.xml
#>
[OutputType('PKI.Utils.ServiceOperationResult')]
[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[ValidateScript({
			if ($_.GetType().FullName -eq "PKI.CertificateServices.DB.RequestRow") {$true} else {$false}
		})]$Request
	)
	process {
		if ((Ping-ICertAdmin $Request.ConfigString)) {
			$CertAdmin = New-Object -ComObject CertificateAuthority.Admin
			try {
				$hresult = $CertAdmin.DenyRequest($Request.ConfigString,$Request.RequestID)
				if ($hresult -eq 0) {
					New-Object PKI.Utils.ServiceOperationResult 0,
							"Successfully denied request with ID = $($Request.RequestID).",
							$Request.RequestID
				} else {
					New-Object PKI.Utils.ServiceOperationResult $hresult,
							"The request's with ID = $($Request.RequestID) current status does not allow this operation.",
							$Request.RequestID
				}
			} finally {[void][Runtime.InteropServices.Marshal]::ReleaseComObject($CertAdmin)}
		} else {Write-ErrorMessage -Source ICertAdminUnavailable -ComputerName $Request.ComputerName}
	}
}