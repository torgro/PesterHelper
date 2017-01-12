function Get-TestList
{
[CmdletBinding()]
Param(
    [string]$Testkeyword = "Tests"
    ,
    [string]$Name = "*"
    ,
    [int[]]$Id
)
    $allTests = New-Object System.Collections.ArrayList

    [int]$i = 0
    foreach ($testFile in (Get-ChildItem -Filter "*$Testkeyword.ps1" -Recurse))
    {
        $item = "" | Select-Object -Property ID, TestFileName, FunctionName, FullName
        $item = [PScustomobject]@{
            ID = $i
            TestFileName = $testFile.Name
            FunctionName = $testFile.Name.Replace(".$Testkeyword","")
            FullName = (Resolve-Path -Path $testFile.FullName).Path
        }
        $null = $allTests.Add($item)       
        $i += 1
    }

    if ($Id -ge 0 -or $id -is [array])
    {
        $allTests | Where-Object id -in $id
    }
    else
    {       
        $allTests | Where-Object TestFileName -like "$Name"
    }
}