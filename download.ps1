# http://rprokhorov.ru/?p=254
Clear-host
# Подавляем вывод
$ErrorActionPreference = "silentlycontinue"
# Присваивание переменных
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
    write-host "Существующая версия файла - $ver1"
    if (!(Test-Path "$DistribPath\temp\$FileName")){
        New-Item -Path $DistribPath\temp -ItemType "directory" -ErrorAction Silentlycontinue |out-null
        write-host
    }
	# Указываем куда будем сохранять скачиваемый файл
	$destination = "$DistribPath\temp\$FileName"
    # Скачивание файла
    write-host "Скачиваем файл с сервера"
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($DownLoadURL, $destination)
    $ver2 = ((dir $DistribPath\temp -Filter $FileName -ErrorAction Silentlycontinue).versioninfo).fileversion
	#проверим контрольные суммы
	$hash1 = Get-FileHash $DistribPath\$FileName -Algorithm MD5 |select -exp hash
	$hash2 = Get-FileHash $DistribPath\temp\$FileName -Algorithm MD5 |select -exp hash
	if ($hash1 -eq $hash2){
		write-host "Подтверждаю, что файл на сервере не обновился"
		del $DistribPath\temp -recurse
	}
	else{
		Write-warning "Файл на сервере обновился"
        write-host "Новая версия файла - $ver2"
        try{
            Move-Item $DistribPath\temp\$FileName -Destination $DistribPath -Force
			del $DistribPath\temp
			start silent-install.bat
        }
        catch{
            $host.version
            Write-Host "Если номера сборки и/или ревизии имеют значение -1, это означает что установлен beta - релиз PowerShell. В финальном релизе данные номера будут иметь значение 0."
        }
		pause
	}
}

Write-Host "-===========-" -ForegroundColor Green