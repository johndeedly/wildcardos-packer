@echo off
setlocal enableDelayedExpansion
set NL=^

set command=[CmdletBinding(DefaultParameterSetName='Fail')]!NL!^
Param(!NL!^
    [Parameter(Mandatory=$False)]!NL!^
    [switch]$PxeBoot,!NL!^
    [Parameter(Mandatory=$False)]!NL!^
    [switch]$VerboseOutput,!NL!^
    [Parameter(Mandatory=$False)]!NL!^
    [switch]$DualBoot,!NL!^
    [Parameter(Mandatory=$False)]!NL!^
    [switch]$Encryption,!NL!^
    [Parameter(ParameterSetName='BuildTarget')]!NL!^
    [switch]$Archlinux,!NL!^
    [Parameter(ParameterSetName='BuildTarget')]!NL!^
    [switch]$Ubuntu,!NL!^
    [Parameter(ParameterSetName='BuildTarget')]!NL!^
    [switch]$Rockylinux,!NL!^
    [Parameter(Mandatory=$True)]!NL!^
    [string]$StageName,!NL!^
    [Parameter(ParameterSetName='Fail', DontShow)] !NL!^
    ${-} = $(!NL!^
        if ($PScmdlet.ParameterSetName -eq 'Fail') { !NL!^
            throw "Please specify at least one build target." !NL!^
        }!NL!^
    )!NL!^
)!NL!^
[Environment]::CurrentDirectory = $PWD.Path!NL!^
$sb = [Scriptblock]::Create([System.IO.File]::ReadAllText('pipeline.ps1'))!NL!^
Invoke-Command -ScriptBlock $sb -ArgumentList (,$PSBoundParameters.PxeBoot,$PSBoundParameters.VerboseOutput,$PSBoundParameters.DualBoot,$PSBoundParameters.Encryption,$PSBoundParameters.Archlinux,$PSBoundParameters.Ubuntu,$PSBoundParameters.RockyLinux,$PSBoundParameters.StageName)!NL!

powershell -nop -c !command! %*
