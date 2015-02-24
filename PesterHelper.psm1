$script:TestFiles
function Edit-Test
{
[cmdletbinding()]
Param(
    [int[]]$id
    ,
    [switch]$Function
)
    if(-not (Get-Module -Name pester))    {        Import-Module Pester    }        $GetTests = Get-TestList -Id $id    if($Function)    {        if(Get-Command -Name psedit)        {                        foreach($GetTest in $GetTests)            {                Write-Verbose -Message "path is $($GetTest.FullName.replace($GetTest.TestFileName,$GetTest.FunctionName))"                psedit ($GetTest.FullName.replace($GetTest.TestFileName,$GetTest.FunctionName))            }        }        else        {            Write-Error -Exception "not implemented" -Category NotImplemented            $GetTests        }    }    if($GetTests)    {              if(Get-Command -Name psedit)        {                        foreach($GetTest in $GetTests)            {                psedit $GetTest.FullName            }        }        else        {            Write-Warning "Use Powershell ISE for a more powerfull edit experience"            foreach($GetTest in $GetTests)            {                notepad.exe $GetTest.fullname            }                    }    }    else    {        Write-warning -Message "Test with id $id was not found"    }
}

function Get-TestList{[CmdletBinding()]Param(    [string]$Testkeyword = "Tests"    ,    [string]$Name    ,    [int[]]$Id)    $allTests = New-Object System.Collections.ArrayList    [int]$i = 0    foreach($testFile in (Get-ChildItem -Filter "*$Testkeyword.ps1" -Recurse))    {        $item = "" | Select ID, TestFileName, FunctionName, FullName
        $item.ID = $i
        $item.TestFileName = $testFile.Name
        $item.FunctionName = $testFile.Name.Replace(".$Testkeyword","")
        $item.FullName = (Resolve-Path -Path $testFile.FullName).Path
        [void]$allTests.Add($item)
        $i += 1    }    if($Id -ge 0 -or $id -is [array])    {              $allTests | where id -in $id    }    else    {            if(-not $name)        {            $Name = "*"        }        $allTests | where TestFileName -like "$Name"    }}

function Invoke-Test{Param(    [int[]]$id)    if(-not (Get-Module -Name pester))    {        Import-Module Pester    }        $Alltests = Get-TestList -Id $id    if($Alltests)    {        Foreach($test in $Alltests)        {            Invoke-Pester -Script $test.fullname        }    }    else    {        Write-warning -Message "Test with id $id was not found"    }}

function Show-Test
{[CmdletBinding()]Param(    [string]$Testkeyword = "Tests"    ,    [switch]$Grid)    $tests = Get-ChildItem -Filter "*$Testkeyword.ps1" -Recurse    if($Grid -and (Get-Command -Name Out-GridView))    {        $Selected = $tests | Sort-Object -Property LastWriteTime -Descending | Out-GridView -Title "Tests available" -PassThru        $invoke = $null        if($Selected)        {            $invoke = Read-Host -Prompt "Invoke selected test(s)? Y/(N)"            if(-not (Get-Module -Name pester))            {                Import-Module Pester            }            foreach($test in $Selected)            {                Invoke-Pester -Script $test.fullname            }        }          }    else    {        $tests    }}

function Update-ScriptLine
{
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true)]
    [Alias("Path","PSpath")]
    [System.IO.FileInfo[]]$files
    ,
    [string]$SearchFor
    ,
    [string]$ReplaceWith
)
BEGIN
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"

    if(-not ($SearchFor) -or -not($ReplaceWith))
    {
        Write-Verbose -Message "$f -  Nothing to do"
    }
}

PROCESS
{
    foreach($file in $files)
    {
        if($file.PSIsContainer -eq $true)
        {
            Write-Verbose -Message "$f -  item is directory, skipping"
            continue
        }

        $content = Get-Content -Path $file.FullName -ReadCount 0 -Encoding UTF8 -Raw
        $NewContent = $content.Replace($SearchFor,$ReplaceWith)

        $SearchForMatch = $content | Select-String -Pattern "$SearchFor" -AllMatches
        $ReplaceCount = $SearchForMatch.Matches.Count
        Write-Verbose -Message "$f -  '$SearchFor' was replaced with '$ReplaceWith' $ReplaceCount time(s)"

        Write-Verbose -Message "$f -  Saving file '$($file.Name)'"
        Set-Content -Path (Resolve-Path -Path $file.FullName).Path -Value $NewContent -Encoding UTF8
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}

New-Alias -Name Test -Value Invoke-test
New-Alias -Name Edit -Value Edit-Test
Export-ModuleMember -Function * -Alias *
