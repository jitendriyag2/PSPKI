function Add-CertificateTemplateAcl {
<#
.ExternalHelp PSPKI.Help.xml
#>
[OutputType('PKI.Security.SecurityDescriptor2[]')]
[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelinebyPropertyName = $true)]
		[Alias('AclObject','Acl')]
		[PKI.Security.SecurityDescriptor2[]]$InputObject,
		[Security.Principal.NTAccount[]]$User,
		[Security.AccessControl.AccessControlType]$AccessType,
		[PKI.Security.TemplateRight[]]$AccessMask
	)
	begin {
		if ($PSBoundParameters.Verbose) {$VerbosePreference = "Contine"}
		if ($PSBoundParameters.Debug) {$DebugPreference = "Continue"}
	}
	process {
		foreach ($Acl in $InputObject) {
			foreach ($u in $User) {
				Write-Verbose "processing user: '$u'"
				Write-Verbose "Check whether the user account is valid"
				try {$SID = ((New-Object Security.Principal.NTAccount $u).Translate([Security.Principal.SecurityIdentifier])).Value}
				catch {
					Write-Error -Category ObjectNotFound -ErrorId "ObjectNotFoundException" `
					-Message "The user account '$u' is not valid"
					return
				}
				$u = ((New-Object Security.Principal.SecurityIdentifier $SID).Translate([Security.Principal.NTAccount])).Value
				Write-Debug "User's '$u' account SID '$SID'"
				if ($Acl.Access | Where-Object {$_.IdentityReference -eq $u -and $_.AccessType -eq $AccessType}) {
					Write-Verbose "Found existing ACE for the current user"
					for ($n = 0; $n -lt $Acl.Access.Length; $n++) {
						Write-Debug "Processing entry # '$n'"
						if ($Acl.Access[$n].IdentityReference -eq $u -and $Acl.Access[$n].AccessType -eq $AccessType) {
							Write-Debug "The current user's matching entry: '$n'"
							foreach ($Mask in $AccessMask) {
								if ($Acl.Access[$n].Permissions -notcontains "FullControl" -and $Acl.Access[$n].Permissions -notcontains $Mask) {
									Write-Debug "Add '$mask' permission for the current user"
									$Acl.Access[$n].Permissions += $Mask
								}
							}
						}
					}
				} else {
					Write-Verbose "No matching ACEs for the user '$u'"
					Write-Debug "Creating new ACE for the user '$u', access type '$AccessType', access mask `'$($AccessMask -join ',')`'"
					$Acl.Access += New-Object PKI.Security.AccessControlEntry2 -Property @{
						IdentityReference = $u;
						AccessType = $AccessType;
						Permissions = $AccessMask
					}
				}
			}
			$Acl
		}
	}
}