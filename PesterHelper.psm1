$script:TestFiles
function Edit-Test
{
[cmdletbinding()]
Param(
    [int[]]$id
)
    if(-not (Get-Module -Name pester))    {        Import-Module Pester    }        $GetTests = Get-TestList -Id $id    if($GetTests)    {              if(Get-Command -Name psedit)        {                        foreach($GetTest in $GetTests)            {                psedit $GetTest.FullName            }        }        else        {            Write-Warning "Use Powershell ISE for a more powerfull edit experience"            notepad.exe $test.fullname        }    }    else    {        Write-warning -Message "Test with id $id was not found"    }
}

function Get-TestList{[CmdletBinding()]Param(    [string]$Testkeyword = "Tests"    ,    [string]$Name    ,    [int[]]$Id)    $allTests = New-Object System.Collections.ArrayList    [int]$i = 0    foreach($testFile in (Get-ChildItem -Filter "*$Testkeyword.ps1" -Recurse))    {        $item = "" | Select ID, TestFileName, FunctionName, FullName
        $item.ID = $i
        $item.TestFileName = $testFile.Name
        $item.FunctionName = $testFile.Name.Replace(".Testkeyword","")
        $item.FullName = (Resolve-Path -Path $testFile.FullName).Path
        [void]$allTests.Add($item)
        $i += 1    }    if($Id -ge 0 -or $id -is [array])    {              $allTests | where id -in $id    }    else    {            if(-not $name)        {            $Name = "*"        }        $allTests | where TestFileName -like "$Name"    }}

function Invoke-Test{Param(    [int[]]$id)    if(-not (Get-Module -Name pester))    {        Import-Module Pester    }        $Alltests = Get-TestList -Id $id    if($Alltests)    {        Foreach($test in $Alltests)        {            Invoke-Pester -Script $test.fullname        }    }    else    {        Write-warning -Message "Test with id $id was not found"    }}

function Show-Test
{[CmdletBinding()]Param(    [string]$Testkeyword = "Tests"    ,    [switch]$Grid)    $tests = Get-ChildItem -Filter "*$Testkeyword.ps1" -Recurse    if($Grid -and (Get-Command -Name Out-GridView))    {        $Selected = $tests | Sort-Object -Property LastWriteTime -Descending | Out-GridView -Title "Tests available" -PassThru        $invoke = $null        if($Selected)        {            $invoke = Read-Host -Prompt "Invoke selected test(s)? Y/(N)"            if(-not (Get-Module -Name pester))            {                Import-Module Pester            }            foreach($test in $Selected)            {                Invoke-Pester -Script $test.fullname            }        }          }    else    {        $tests    }}

New-Alias -Name Test -Value Invoke-test
New-Alias -Name Edit -Value Edit-Test
Export-ModuleMember -Function * -Alias *
