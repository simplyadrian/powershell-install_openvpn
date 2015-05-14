# Powershell 2.0

# Stop and fail script when a command fails.
$errorActionPreference = "Stop"

# load library functions
$rsLibDstDirPath = "$env:rs_sandbox_home\RightScript\lib"
. "$rsLibDstDirPath\tools\PsOutput.ps1"
. "$rsLibDstDirPath\tools\ResolveError.ps1"
. "$rsLibDstDirPath\win\Version.ps1"

#Add OpenVPN cert to key store.
$openvpn_cert = "OpenVPN-cert.cer"
cd "$env:RS_ATTACH_DIR"
certutil -addstore "TrustedPublisher" $openvpn_cert

try
{
    # detects if server OS is 64Bit or 32Bit 
    # Details http://msdn.microsoft.com/en-us/library/system.intptr.size.aspx
    if (Is32bit)
    {                        
        Write-Host "32 bit operating system"   
        $openvpn_path = join-path $env:programfiles "OpenVPN"
    } 
    else
    {                        
        Write-Host "64 bit operating system"     
        $openvpn_path = join-path $env:programfiles "OpenVPN"
    }

    if (test-path $openvpn_path)
    {
        Write-Output "OpenVPN already installed. Skipping installation."
        exit 0
    }

    Write-Host "Installing OpenVPN to $openvpn_path"

    $openvpn_binary = "openvpn-install-2.3.2-I003-x86_64.exe"
    cd "$env:RS_ATTACH_DIR"
    cmd /c $openvpn_binary /S

    #Permanently update windows Path
    if (Test-Path $openvpn_path) {
        [environment]::SetEnvironmentvariable("PATH", $env:PATH+";"+$openvpn_path, "Machine")
    } 
    Else 
    {
        throw "Failed to install OpenVPN. Aborting."
    }

}
catch
{
    ResolveError
    exit 1
}
