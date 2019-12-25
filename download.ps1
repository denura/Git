# http://rprokhorov.ru/?p=254
Clear-host
# Подавляем вывод
$ErrorActionPreference = "silentlycontinue"
# Присваивание переменных
$Software = "Git"
$DistribPath = '.\'
$FileName = 'Git-64-bit.exe'
$URLPage = 'https://git-scm.com/download/win'

# Получаем всё содержимое страницы в переменную $html
#$html = (New-Object System.Net.WebClient).DownloadString($URLPage)

# Получаем номер символа конца версии программы. при этом длина версии меньше 20 символов
#$ver_char_start = $html.IndexOf('</a><div class="button-wrap__version">Punto Switcher')

# Используем Regular Expressions (http://powershell.com/cs/blogs/ebookv2/archive/2012/03/20/chapter-13-text-and-regular-expressions.aspx), чтобы "отрезать" ненужные нам символы
#$version = $html.Substring($ver_char_start+53,11) -replace "[^0-9.]"
#$html = $html.Substring($ver_char_start-200,200)

# Получаем ссылку на скачивание. Она всегда одинакова. http://download.yandex.ru/punto/PuntoSwitcherSetup.exe

Write-Host "-===========-" -ForegroundColor Green
Write-Host "Product: $Software"
#Write-Host "Version: "$version

$HttpContent = Invoke-WebRequest -URI $URLPage -UseBasicParsing

$HttpContent.Links | Foreach{
    if ($_.href -match "-64-bit.exe")
    {
        ($DownLoadURL = $_.href)
    }
}

#$HttpContent.Links | fl innerText, href

if (Test-Path "$DistribPath\$FileName")
{
    #write-host "Такой файл у нас уже есть" -ForegroundColor Red
    $ver1 = ((dir $DistribPath -Filter $FileName -ErrorAction Silentlycontinue).versioninfo).fileversion
    write-host "Существующая версия файла - $ver1"
	#write-host "Однако, проверим контрольные суммы"
    if (!(Test-Path "$DistribPath\temp\$FileName"))
    {
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
	$hash1 = Get-FileHash $DistribPath\$FileName -Algorithm MD5 |select -exp hash
	$hash2 = Get-FileHash $DistribPath\temp\$FileName -Algorithm MD5 |select -exp hash
	if ($hash1 -eq $hash2)
	{
		write-host "Подтверждаю, что файл на сервере не обновился"
		del $DistribPath\temp -recurse
	}
	else
	{
		Write-warning "Файл на сервере обновился"
        write-host "Новая версия файла - $ver2"
		#$verold = dir $DistribPath\$version\$FileName -Filter PuntoSwitcherSetup.exe | select @{n="Version";e={$_.versioninfo.fileversion}}
		#$vernew = dir $DistribPath\$FileName -Filter PuntoSwitcherSetup.exe | select @{n="Version";e={$_.versioninfo.fileversion}}
		# (gi $DistribPath\$version\$FileName).versioninfo.ProductVersion | fl *
		# (gi $DistribPath\$FileName).versioninfo.ProductVersion | fl *
		#dir $DistribPath -Filter $FileName -rec | %{$_.versioninfo.fileversion}
		# Write-Host "Старая версия" $verold
		# Write-Host "Новая версия" $vernew
        try
        {
            Move-Item $DistribPath\temp\$FileName -Destination $DistribPath -Force
			del $DistribPath\temp
			start silent-install.bat
        }
        catch
        {
            #Write-Host "Необходимо обновить Powershell до 5 версии"
            $host.version
            #get-host | select version
            Write-Host "Если номера сборки и/или ревизии имеют значение -1, это означает что установлен beta - релиз PowerShell. В финальном релизе данные номера будут иметь значение 0."
            #update-help
            #Get-Hotfix -Id KB3000850 |ft -AutoSize
            #Start-Process iexplore -ArgumentList "https://www.microsoft.com/en-us/download/details.aspx?id=50395" -wait -windowstyle Maximized
            #Start-Process Win8.1AndW2K12R2-KB3134758-x64.msu -ArgumentList "quiet promtrestart" -wait
            
        }
		pause
	}
}

Write-Host "-===========-" -ForegroundColor Green


#function Send-Email-anonymously_PuntoSwitcher ($version, $url)
#{
    #$User = "anonymous"
    #$PWord = ConvertTo-SecureString –String "anonymous" –AsPlainText -Force
    #$Creds = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $user, $pword
    #Send-MailMessage -To avberezin@yamoney.ru -From SoftwareCheck@yamoney.ru -Subject "Вышла новая версия $Software" -Body "Version: $version `nOriginal link: $url `nDownloaded in: $destination" -SmtpServer "mail.yamoney.ru" -Credential $Creds -Encoding Default
#}