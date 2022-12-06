#region Config
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$client = "Company"
$logPath = "$ENV:ProgramData\$client\Logs"
$logFile = "$logPath\PwNotificationDetection.log"
$user = whoami /upn
$funcUri = 'https://{putURIhere}'
$UserContext = [Security.Principal.WindowsIdentity]::GetCurrent()
$WindirTemp = Join-Path $Env:Windir -Childpath "Temp"
 
Switch ($UserContext) {
    { $PSItem.Name -Match       "System"    } { Write-Output "Running as System" ; $logPath =  $WindirTemp }
    { $PSItem.Name -NotMatch    "System"    } { Write-Output "Not running System" }
    Default { Write-Output "Could not translate Usercontext" }
}
#endregion
#region logging
if (!(Test-Path -Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force
}
Start-Transcript -Path $logFile -Force
#endregion
#region Remediation script

#region Get parameters and user pw timespan
    $fParams = @{
        Method      = 'Get'
        Uri         = "$funcUri&user=$user"
        ContentType = 'Application/Json'
    }
    $json = Invoke-RestMethod @fParams
#endregion
#region compare timespan
    $TimeSpan = $json.TimeSpan
    $NotifPeriod = $json.notificationPeriod
    If (($TimeSpan -le $NotifPeriod) -and ($TimeSpan -ge 0)) {
        Write-Output "Password Expires after $TimeSpan days"
        Stop-Transcript
        Exit 1
    }
    elseif ($TimeSpan -le 0) {
        $TimeSpan = $TimeSpan -replace "-",""
        Write-Output "Password Expired since $TimeSpan days"
        Stop-Transcript
        Exit 1
    }
    else {
        Write-Output "Password not expires since more than "
        Stop-Transcript
        Exit 0
    }
#endregion


