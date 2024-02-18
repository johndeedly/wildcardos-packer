#!/usr/bin/env pwsh
[CmdletBinding(DefaultParameterSetName='Fail')]
Param(
    [Parameter(Mandatory=$False)]
    [switch]$PxeBoot,
    [Parameter(Mandatory=$False)]
    [switch]$PxeServe,
    [Parameter(Mandatory=$False)]
    [switch]$PxeImage,
    [Parameter(Mandatory=$False)]
    [switch]$VerboseOutput,
    [Parameter(Mandatory=$False)]
    [switch]$DualBoot,
    [Parameter(Mandatory=$False)]
    [switch]$Encryption,
    [Parameter(ParameterSetName='StageTarget')]
	[Parameter(ParameterSetName='Mandatory')]
    [switch]$Bootstrap,
    [Parameter(ParameterSetName='StageTarget')]
	[Parameter(ParameterSetName='Mandatory')]
    [switch]$Cinnamon,
    [Parameter(ParameterSetName='BuildTarget')]
    [Parameter(ParameterSetName='Mandatory')]
    [switch]$Archlinux,
    [Parameter(ParameterSetName='BuildTarget')]
    [Parameter(ParameterSetName='Mandatory')]
    [switch]$Ubuntu,
    [Parameter(ParameterSetName='BuildTarget')]
    [Parameter(ParameterSetName='Mandatory')]
    [switch]$Rockylinux,
    [Parameter(Mandatory=$True)]
    [string]$StageName,
    [Parameter(ParameterSetName='Fail', DontShow)] 
    ${-} = $(
        if ($PScmdlet.ParameterSetName -eq 'Fail') { 
            throw "Please specify one build and stage target." 
        }
    )
)

if ($VerboseOutput) {
	Write-Host ":: Verbose output enabled"
	$env:PKR_VAR_verbose = "true"
}
if ($Archlinux) {
	Write-Host ":: Building Arch Linux"
	$env:PKR_VAR_build_arch = "archlinux"
}
if ($Ubuntu) {
	Write-Host ":: Building Ubuntu"
	$env:PKR_VAR_build_arch = "ubuntu"
}
if ($Rockylinux) {
	Write-Host ":: Building Rocky Linux"
	$env:PKR_VAR_build_arch = "rockylinux"
}
if ($DualBoot) {
	Write-Host ":: Dualboot enabled"
	$env:PKR_VAR_dualboot = "true"
}
if ($Encryption) {
	Write-Host ":: Encryption enabled"
	$env:PKR_VAR_encryption = "true"
}
if ($Bootstrap) {
	Write-Host ":: Bootstrap stage enabled"
	$env:PKR_VAR_bootstrap = "true"
}
if ($Cinnamon) {
	Write-Host ":: Cinnamon stage enabled"
	$env:PKR_VAR_cinnamon = "true"
}
if ($PxeBoot) {
	if ($Archlinux) {
		Write-Host ":: Pxe boot enabled"
		$env:PKR_VAR_pxeboot = "true"
	} else {
		Write-Host ":: Pxe boot on ubuntu nor rockylinux is supported"
	}
}
if ($PxeServe) {
	if ($Archlinux) {
		Write-Host ":: Pxe providing boot services enabled"
		$env:PKR_VAR_pxeserve = "true"
	} else {
		Write-Host ":: Pxe serving on ubuntu nor rockylinux is supported"
	}
}
if ($PxeImage) {
	if ($Archlinux) {
		Write-Host ":: Pxe image generation enabled"
		$env:PKR_VAR_pxeimage = "true"
	} else {
		Write-Host ":: Pxe image on ubuntu nor rockylinux is supported"
	}
}
Write-Host ":: Stage name is $($StageName)"
$env:PKR_VAR_stage = "$($StageName)"


$WebClient = New-Object System.Net.WebClient
$data = $WebClient.DownloadString("https://archlinux.org/download/")
$match = [regex]::Match($data, 'magnet:.*?dn=archlinux-(.*?)-x86_64.iso')
if ($match.Success) {
	$env:PKR_VAR_yearmonthday = $match.Groups[1].Value
}

$hosturl = "http://ftp.halifax.rwth-aachen.de/archlinux/"
$remotepath = "$($hosturl)iso/$($env:PKR_VAR_yearmonthday)/archlinux-$($env:PKR_VAR_yearmonthday)-x86_64.iso"
$localpath = "archlinux-$($env:PKR_VAR_yearmonthday)-x86_64.iso"
Write-Host "<= $($remotepath)"
Write-Host "=> $($localpath)"
if (-Not (Test-Path($localpath))) {
	Invoke-WebRequest -UserAgent "Mozilla/5.0 (X11; Linux x86_64; rv:103.0) Gecko/20100101 Firefox/103.0" -Uri $remotepath -OutFile $localpath
}

$hashsrc = (Get-FileHash $localpath -Algorithm "SHA256").Hash.ToLower()
$remotehash = "$($hosturl)iso/$($env:PKR_VAR_yearmonthday)/sha256sums.txt"
$hash = $WebClient.DownloadString($remotehash)
if ($hash -match '^[a-fA-F0-9]+(?=.*?\.iso)(?!.*?bootstrap)') {
	$hashdst = $matches[0].ToLower()
	if ($hashsrc -ne $hashdst) {
		Write-Host "[!] download is broken"
		break
	} else {
		Write-Host "$($hashsrc)  $($localpath)"
	}
}

if (-Not (Test-Path($localpath))) {
	Write-Host "[!] no iso named $($localpath) in working directory"
	break
}

$datestr = $env:PKR_VAR_yearmonthday.replace('.', '/')
(((Get-Content 'CIDATA/user-data') -replace 'Server=.*?$', "Server=https://archive.archlinux.org/repos/$($datestr)/`$repo/os/`$arch") -join "`n") + "`n" | Set-Content -NoNewline -Encoding UTF8NoBOM -Force 'CIDATA/user-data'

function Packer-BuildAppliance {
	param([Parameter()][string]$SearchFileName, [Parameter()][string]$Filter, [Parameter()][string]$ArgList)
	$runit = $false
	if ([System.String]::IsNullOrEmpty($SearchFileName)) {
		$runit = $true
	} else {
		$files = [System.IO.Directory]::GetFiles($PWD.ProviderPath + "/output", $SearchFileName, [System.IO.SearchOption]::AllDirectories)	
		if (-Not([System.String]::IsNullOrEmpty($Filter))) {
			$files = [Linq.Enumerable]::Where($files, [Func[string,bool]]{ param($x) $x -match $Filter })
		}
		$file = [Linq.Enumerable]::FirstOrDefault($files)
		Write-Host $file
		if ([System.String]::IsNullOrEmpty($file)) {
			$runit = $true
		}
	}
	if ($runit) {
		if ($IsWindows -or $env:OS) {
			$env:PKR_VAR_sound_driver = "dsound"
			$env:PKR_VAR_accel_graphics = "off"
			$process = Start-Process -PassThru -Wait -NoNewWindow -FilePath "packer.exe" -ArgumentList $ArgList
			return $process.ExitCode
		} else {
			$env:PKR_VAR_sound_driver = "pulse"
			$env:PKR_VAR_accel_graphics = "on"
			$process = Start-Process -PassThru -Wait -FilePath "packer" -ArgumentList $ArgList
			return $process.ExitCode
		}
	}
	return 0
}

New-Item -Path $PWD.ProviderPath -Name "output" -ItemType "directory" -Force | Out-Null
$env:PACKER_LOG=1
if ($IsWindows -or $env:OS) {
  # VBOX
  $env:PACKER_LOG_PATH="output/wildcardos-packerlog.txt"
  if ((Packer-BuildAppliance -SearchFileName "*wildcardos*$($env:PKR_VAR_build_arch)-$($env:PKR_VAR_stage)-$($env:PKR_VAR_yearmonthday)*.ovf" -ArgList "build -force -on-error=ask -only=virtualbox-iso.default packer/wildcardos.pkr.hcl") -ne 0) {
  	break
  }
} else {
  # QEMU
  $env:PACKER_LOG_PATH="output/wildcardos-packerlog.txt"
  if ((Packer-BuildAppliance -SearchFileName "*wildcardos*$($env:PKR_VAR_build_arch)-$($env:PKR_VAR_stage)-$($env:PKR_VAR_yearmonthday)*.qcow2" -ArgList "build -force -on-error=ask -only=qemu.default packer/wildcardos.pkr.hcl") -ne 0) {
  	break
  }
}
