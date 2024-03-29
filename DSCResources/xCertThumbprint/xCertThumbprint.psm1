function Get-TargetResource
{
  [CmdletBinding()]
  [OutputType([System.Collections.Hashtable])]
  param
  (
    [parameter(Mandatory = $true)]
    [System.String]
    $Subject
  )

  $thumbprinttable = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object -FilterScript {
    $_.subject -eq "CN=$Subject"
  }

  $thumbprint = $thumbprinttable.Thumbprint
  $Subject = $thumbprinttable.Subject
    
  $returnValue = @{
    Thumbprint = [System.String]$thumbprint
    Subject    = [System.String]$Subject
  }
    
  $returnValue
}


function Set-TargetResource
{
  [CmdletBinding()]
  param
  (
    [parameter(Mandatory = $true)]
    [System.String]
    $Subject,

    [System.String]
    $File = 'C:\Temp\Thumbprint.txt',

    [System.String]
    $thumbprint,

    [ValidateSet('Present','Absent')]
    [System.String]
    $Ensure
  )

  $content = Get-ChildItem -Path Cert:\LocalMachine\My |
  Where-Object -FilterScript {
    $_.subject -eq "CN=$Subject"
  } |
  Select-Object -Property Thumbprint -ExpandProperty Thumbprint

  if ($Ensure -eq 'Present')
  {
    Write-Verbose -Message "Getting the Certificate Thumbprint $content and writing it to $File."

    $available = Get-TargetResource $File

    if ($Ensure -eq 'Present')
    {      
      Set-Content -Path $File -Value $content -Force
      Write-Verbose -Message "Writing Thumbprint to $File."
    }
  }
  else 
  {
    Remove-Item $File -Force
  }
}


function Test-TargetResource
{
  [CmdletBinding()]
  [OutputType([System.Boolean])]
  param
  (
    [parameter(Mandatory = $true)]
    [System.String]
    $Subject,

    [System.String]
    $File,

    [System.String]
    $thumbprint,

    [ValidateSet('Present','Absent')]
    [System.String]
    $Ensure
  )

  Write-Verbose -Message "Is there a thumbprint file available for subject CN=$Subject ?"

  $test = Get-Content -LiteralPath 'C:\Temp\thumbprint.txt' -ErrorAction SilentlyContinue

  $test2 = Get-ChildItem -Path Cert:\LocalMachine\My |
  Where-Object -FilterScript {
    $_.subject -eq "CN=$Subject"
  } |
  Select-Object -Property Thumbprint -ExpandProperty Thumbprint

  if ($test -eq $test2)
  {
    Write-Host -Object 'True'
    $true
  }
  Else 
  {
    Write-Host -Object 'False'
    $False
  }
}


Export-ModuleMember -Function *-TargetResource

