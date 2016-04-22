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
    foreach($testFile in (Get-ChildItem -Filter "*$Testkeyword.ps1" -Recurse))
    {
        $item = "" | Select-Object -Property ID, TestFileName, FunctionName, FullName
        $item.ID = $i
        $item.TestFileName = $testFile.Name
        $item.FunctionName = $testFile.Name.Replace(".$Testkeyword","")
        $item.FullName = (Resolve-Path -Path $testFile.FullName).Path
        $null = $allTests.Add($item)
        $i += 1
    }

    if($Id -ge 0 -or $id -is [array])
    {
        $allTests | where id -in $id
    }
    else
    {       
        $allTests | where TestFileName -like "$Name"
    }
}