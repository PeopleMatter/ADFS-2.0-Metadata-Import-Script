write-host "### Please ensure your metadata file is in c:\metadata before continuing ###`n`n"

if ($args.length -eq 2)
{
    $name = $args[0]
    $metadata = $args[1]
}
else
{
    write-host "###############################################################################"
    write-host " No command-line arguments detected or improper number of arguments."
    write-host "If you want to run this script from the commandline, use the following format:"
    write-host "./adddeveloper.ps1 trustName metadataFileName"
    write-host "###############################################################################`n`n"
    
    write-host "Adding ADFS snap-in" -foregroundcolor Green
    add-pssnapin Microsoft.adfs.powershell
    
    write-host "Name of relying party trust to create: "
    $name = read-host
    
    write-host "Name of federation metadata file: "
    $metadata = read-host
}
    
write-host -foregroundcolor green "`nChecking to see if RelyingPartyTrust with name '$name' is already in use"
$inuse = (get-adfsrelyingpartytrust -name $name)

if ($inuse -ne $Null)
{
    $identifier = [string] (get-adfsrelyingpartytrust -name $name).Identifier
    write-host -foregroundcolor cyan "`nRelying party trust is already in use with identifier $identifier"
    
    write-host "`nDo you want to remove this existing RelyingPartyTrust? (y/n): "
    $removeTrust = read-host
    
    if (($removeTrust.toLower() -eq 'y') -or ($removeTrust.toLower() -eq 'yes'))
    {
        remove-adfsrelyingpartytrust -TargetName $name
        
        write-host "`nExisting relying party removed."
    }
    else
    {
        write-host "`nNot removing existing RelyingPartyTrust.  Exiting."
        write-host "Press any key to continue."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        exit
    } 
}
 
add-adfsrelyingpartytrust -Name $name -MetaDataFile c:\Metadata\$metadata
    
write-host "`nGetting identifier from new relying party trust`n"
$identifier = [string] (get-adfsrelyingpartytrust -name $name).Identifier
write-host "Identifier found: $identifier"
    
write-host "`nSetting Issuance Transform Rules using xxxxxxxx's Trust as source`n"
$transformRules = (get-adfsrelyingpartytrust -name xxxxxxxx).IssuanceTransformRules
set-adfsrelyingpartytrust -TargetIdentifier $identifier -IssuanceTransformRules $transformRules
    
write-host "Setting Claims Accepted using xxxxxxxx Trust as source`n"
$claimsAccepted = (get-adfsrelyingpartytrust -name xxxxxxxx).ClaimsAccepted
set-adfsrelyingpartytrust -TargetIdentifier $identifier -ClaimAccepted $claimsAccepted
    
$endPoint = (get-adfsrelyingpartytrust -name $name).WSFedEndpoint
    
if ($endpoint -eq $Null)
{
    write-host "The federation endpoint could not be found in the metadata file."
    write-host "Do you want to add the identifier as the WS Federation endpoint? (y/n): "
    $choice = read-host
        
    if (($choice.toLower() -eq 'y') -or ($choice.toLower() -eq 'yes'))
    {
        set-adfsrelyingpartytrust -TargetIdentifier $identifier -WSFedEndpoint $identifier
           
        write-host "WS-Federation Endpoint set."
            
        $endpoint = $identifier
    }
        
        
}     
clear
write-host "### Relying Party Trust creation complete. ###" 
write-host "Please review the relying party trust info on next screen`n`n"
write-host "Press any key to continue"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

clear
write-host "Name of RelyingPartyTrust: " -nonewline -foregroundcolor green
write-host "$name"
write-host "Identifier of RelyingPartyTrust: " -nonewline -foregroundcolor green
write-host "$identifier"
write-host "WS-FederationEndpoint: " -nonewline -foregroundcolor green
write-host "$endpoint"

write-host "Press any key to continue"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
clear

write-host "`nIssuance Transform Rules`n " -foregroundcolor green
write-host "$transformRules"
write-host "`nClaims Accepted`n " -foregroundcolor green
write-host "$claimsAccepted"

write-host "Press any key to exit"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

