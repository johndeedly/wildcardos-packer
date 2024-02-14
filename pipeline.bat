@echo off
powershell -nop -c "[Environment]::CurrentDirectory = $PWD.Path; $xyz = [ScriptBlock]::Create([System.IO.File]::ReadAllText('pipeline.ps1')); & $xyz %*"
