@echo off
powershell -nop -c "[Environment]::CurrentDirectory = $PWD.Path; Invoke-Expression(""& { $([System.IO.File]::ReadAllText('pipeline.ps1')) } %*"")"
