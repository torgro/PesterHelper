﻿$script:TestFiles

function Get-TestList{[CmdletBinding()]Param(    [string]$Testkeyword = "Tests"    ,    [string]$Name = "*"    ,    [int]$Id)    $allTests = New-Object System.Collections.ArrayList    $i = 0    foreach($testFile in (Get-ChildItem -Filter "*$Testkeyword.ps1" -Recurse))    {        $item = "" | Select ID, TestFileName, FunctionName, FullName
        $item.id = $i.ToString()
        $item.TestFileName = $testFile.Name
        $item.FunctionName = $testFile.Name.Replace(".Testkeyword","")
        $item.FullName = (Resolve-Path -Path $testFile.FullName).Path
        [void]$allTests.Add($item)
        $i += 1    }    $script:TestFiles = $allTests    if($id)    {        $allTests | where id -eq $id    }    else    {            $allTests | where TestFileName -like "$Name"    }}

function Invoke-Test{Param(    [int]$id)    if(-not (Get-Module -Name pester))    {        Import-Module Pester    }        $test = Get-TestList -Id $id    if($test)    {        Invoke-Pester -Script $test.fullname    }    else    {        Write-warning -Message "Test with id $id was not found"    }}

function Show-Test
{[CmdletBinding()]Param(    [string]$Testkeyword = "Tests"    ,    [switch]$Grid)    $tests = Get-ChildItem -Filter "*$Testkeyword.ps1" -Recurse    if($Grid -and (Get-Command -Name Out-GridView))    {        $Selected = $tests | Sort-Object -Property LastWriteTime -Descending | Out-GridView -Title "Tests available" -PassThru        $invoke = $null        if($Selected)        {            $invoke = Read-Host -Prompt "Invoke selected test(s)? Y/(N)"            if(-not (Get-Module -Name pester))            {                Import-Module Pester            }            foreach($test in $Selected)            {                Invoke-Pester -Script $test.fullname            }        }          }    else    {        $tests    }}

New-Alias -Name Test -Value Invoke-test -Scope Script
