function Get-TestList{[CmdletBinding()]Param(    [string]$Testkeyword = "Tests"    ,    [string]$Name = "*"    ,    [int]$Id)    $allTests = New-Object System.Collections.ArrayList    $i = 0    foreach($testFile in (Get-ChildItem -Filter "*$Testkeyword.ps1" -Recurse))    {        $item = "" | Select ID, TestFileName, FunctionName, FullName
        $item.id = $i.ToString()
        $item.TestFileName = $testFile.Name
        $item.FunctionName = $testFile.Name.Replace(".Testkeyword","")
        $item.FullName = (Resolve-Path -Path $testFile.FullName).Path
        [void]$allTests.Add($item)
        $i += 1    }    $script:TestFiles = $allTests    if($id)    {        $allTests | where id -eq $id    }    else    {            $allTests | where TestFileName -like "$Name"    }}