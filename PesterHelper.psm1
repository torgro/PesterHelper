﻿function Get-TestList
        $item.id = $i.ToString()
        $item.TestFileName = $testFile.Name
        $item.FunctionName = $testFile.Name.Replace(".Testkeyword","")
        $item.FullName = (Resolve-Path -Path $testFile.FullName).Path
        [void]$allTests.Add($item)
        $i += 1

 function Invoke-Test

 function Show-Test
{



New-Alias -Name Test -Value Invoke-test -Scope Script