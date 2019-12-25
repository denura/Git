# http://rprokhorov.ru/?p=254
Clear-host
# ��������� �����
$ErrorActionPreference = "silentlycontinue"
# ������������ ����������
$Software = "Git"
$DistribPath = ".\"
$FileName = "Git-64-bit.exe"
$URLPage = "https://git-scm.com/download/win"

Write-Host "-===========-" -ForegroundColor Green
Write-Host "Product: $Software"

$HttpContent = Invoke-WebRequest -URI $URLPage -UseBasicParsing

$HttpContent.Links | Foreach{
    if ($_.href -match "-64-bit.exe"){
        ($DownLoadURL = $_.href)
    }
}

if (Test-Path "$DistribPath\$FileName"){
    $ver1 = ((dir $DistribPath -Filter $FileName -ErrorAction Silentlycontinue).versioninfo).fileversion
    write-host "������������ ������ ����� - $ver1"
    if (!(Test-Path "$DistribPath\temp\$FileName")){
        New-Item -Path $DistribPath\temp -ItemType "directory" -ErrorAction Silentlycontinue |out-null
        write-host
    }
	# ��������� ���� ����� ��������� ����������� ����
	$destination = "$DistribPath\temp\$FileName"
    # ���������� �����
    write-host "��������� ���� � �������"
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($DownLoadURL, $destination)
    $ver2 = ((dir $DistribPath\temp -Filter $FileName -ErrorAction Silentlycontinue).versioninfo).fileversion
	#�������� ����������� �����
	$hash1 = Get-FileHash $DistribPath\$FileName -Algorithm MD5 |select -exp hash
	$hash2 = Get-FileHash $DistribPath\temp\$FileName -Algorithm MD5 |select -exp hash
	if ($hash1 -eq $hash2){
		write-host "�����������, ��� ���� �� ������� �� ���������"
		del $DistribPath\temp -recurse
	}
	else{
		Write-warning "���� �� ������� ���������"
        write-host "����� ������ ����� - $ver2"
        try{
            Move-Item $DistribPath\temp\$FileName -Destination $DistribPath -Force
			del $DistribPath\temp
			start silent-install.bat
        }
        catch{
            $host.version
            Write-Host "���� ������ ������ �/��� ������� ����� �������� -1, ��� �������� ��� ���������� beta - ����� PowerShell. � ��������� ������ ������ ������ ����� ����� �������� 0."
        }
		pause
	}
}

Write-Host "-===========-" -ForegroundColor Green