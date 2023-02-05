$computerSystem = Get-WmiObject Win32_ComputerSystem
$processor = Get-WmiObject Win32_Processor
$graphicsAdapter = Get-WmiObject Win32_VideoController
$storage = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Select-Object DeviceID, Size, FreeSpace
$operatingSystem = Get-WmiObject Win32_OperatingSystem
$user = Get-WmiObject Win32_UserAccount | Where-Object {$_.Name -eq $env:username}
$ip = (Test-Connection -ComputerName $env:COMPUTERNAME -Count 1).IPV4Address.IPAddressToString

$specifications = @{
    "Nama Komputer" = $computerSystem.Name;
    "Model" = $computerSystem.Model;
    "Processor" = "$($processor.Name) ($($processor.NumberOfCores) cores)";
    "RAM" = "$(( $computerSystem.TotalPhysicalMemory / 1GB )) GB";
    "Sistem Operasi" = $operatingSystem.Caption;
    "Kartu Grafis" = $graphicsAdapter.Name;
    "Penyimpanan" = foreach ($drive in $storage) { "$($drive.DeviceID) ($($drive.Size / 1GB) GB, $($drive.FreeSpace / 1GB) GB tersedia)" };
    "Nama Akun User Windows" = $user.Name;
    "Ip Address" = $ip;
}

$body = "Spesifikasi Komputer:`n"

foreach ($spec in $specifications.GetEnumerator()) {
    $body += "$($spec.Key): $($spec.Value)`n"
}

$from = Read-Host -Prompt "Email Pengirim ?"
$password = Read-Host -Prompt "Password ?" -AsSecureString
$to = Read-Host -Prompt "Email Penerima ?"

$cred = New-Object System.Management.Automation.PSCredential($from, $password)

Send-MailMessage -From $from -To $to -Subject "Spesifikasi Komputer" -Body $body -SmtpServer "smtp.gmail.com" -Port "587" -UseSsl -Credential $cred
