$computerSystem = Get-WmiObject Win32_ComputerSystem
$processor = Get-WmiObject Win32_Processor
$graphicsAdapter = Get-WmiObject Win32_VideoController
$storage = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Select-Object DeviceID, Size, FreeSpace
$operatingSystem = Get-WmiObject Win32_OperatingSystem
$user = Get-WmiObject Win32_UserAccount | Where-Object {$_.Name -eq $env:username}

$specifications = @{
    "Nama Komputer" = $computerSystem.Name;
    "Model" = $computerSystem.Model;
    "Processor" = "$($processor.Name) ($($processor.NumberOfCores) cores)";
    "RAM" = "$(( $computerSystem.TotalPhysicalMemory / 1GB )) GB";
    "Sistem Operasi" = $operatingSystem.Caption;
    "Kartu Grafis" = $graphicsAdapter.Name;
    "Penyimpanan" = foreach ($drive in $storage) { "$($drive.DeviceID) ($($drive.Size / 1GB) GB, $($drive.FreeSpace / 1GB) GB tersedia)" };
    "Nama Akun User Windows" = $user.Name;
}

$body = "Spesifikasi Komputer:`n"

foreach ($spec in $specifications.GetEnumerator()) {
    $body += "$($spec.Key): $($spec.Value)`n"
}

Send-MailMessage -From "babufiondel@gmail.com" -To "faizbagusp@gmail.com" -Subject "Spesifikasi Komputer" -Body $body -SmtpServer "smtp.gmail.com" -Port "587" -UseSsl -Credential (New-Object System.Management.Automation.PSCredential("babufiondel@gmail.com",(ConvertTo-SecureString "zqkvexkrcnnjpzxi" -AsPlainText -Force)))
