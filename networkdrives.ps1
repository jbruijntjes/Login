P:\General                          \\Districon01.districon.local\Project        
Q:\Departments              \\Districon01.districon.local\Afdeling
S:\ProjectArchive            \\Districon01.districon.local\ProjectArchief
T:\Storage                           \\Districon01.districon.local\Storage


New-PSDrive –Name "P" –PSProvider FileSystem –Root "\\Districon01.districon.local\Project" –Persist
New-PSDrive –Name “Q” –PSProvider FileSystem –Root “\\Districon01.districon.local\Project” –Persist
New-PSDrive –Name “S” –PSProvider FileSystem –Root “\\Districon01.districon.local\ProjectArchief” –Persist
New-PSDrive –Name “T” –PSProvider FileSystem –Root “\\Districon01.districon.local\Storage” –Persist



Start-Transcript -Path $(Join-Path $env:temp "DriveMapping.log")

$driveMappingConfig=@()


######################################################################
#                section script configuration                        #
######################################################################

<#
   Add your internal Active Directory Domain name and custom network drives below
#>

$dnsDomainName= "districon.local"


$driveMappingConfig+= [PSCUSTOMOBJECT]@{
    DriveLetter = "P"
    UNCPath= "\\Districon01.districon.local\Project"
    Description="Project"
}


$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "Q"
    UNCPath= "\\Districon01.districon.local\Afdeling"
    Description="Afdeling"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "S"
    UNCPath= "\\Districon01.districon.local\ProjectArchief"
    Description="ProjectArchief"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "S"
    UNCPath= "\\Districon01.districon.local\Storage"
    Description="Storage"
}

######################################################################
#               end section script configuration                     #
######################################################################

$connected=$false
$retries=0
$maxRetries=3

Write-Output "Starting script..."
do {
    
    if (Resolve-DnsName $dnsDomainName -ErrorAction SilentlyContinue){
    
        $connected=$true

    } else{
 
        $retries++
        
        Write-Warning "Cannot resolve: $dnsDomainName, assuming no connection to fileserver"
 
        Start-Sleep -Seconds 3
 
        if ($retries -eq $maxRetries){
            
            Throw "Exceeded maximum numbers of retries ($maxRetries) to resolve dns name ($dnsDomainName)"
        }
    }
 
}while( -not ($Connected))

#Map drives
    $driveMappingConfig.GetEnumerator() | ForEach-Object {

        Write-Output "Mapping network drive $($PSItem.UNCPath)"

        New-PSDrive -PSProvider FileSystem -Name $PSItem.DriveLetter -Root $PSItem.UNCPath -Description $PSItem.Description -Persist -Scope global

        (New-Object -ComObject Shell.Application).NameSpace("$($PSItem.DriveLEtter):").Self.Name=$PSItem.Description
}

Stop-Transcript