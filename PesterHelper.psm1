$script:TestFiles = @()
 $script:TestResults = New-Object -TypeName System.Collections.ArrayList
function Edit-Test
{
[cmdletbinding()]
Param(
    [int[]]$id
    ,
    [switch]$Function
)
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
    
    if(-not (Get-Module -Name pester))
    {
        Write-Verbose -Message "$f -  Importing module Pester"
        Import-Module -Name Pester -ErrorAction Stop
    }
    
    $GetTests = Get-TestList -Id $id    

    if($GetTests)
    {      
        if($Function)
        {
            if(Get-Command -Name psedit)
            {            
                foreach($GetTest in $GetTests)
                {
                    Write-Verbose -Message "$f -  Path is $($GetTest.FullName.replace($GetTest.TestFileName,$GetTest.FunctionName))"
                    psedit ($GetTest.FullName.replace($GetTest.TestFileName,$GetTest.FunctionName))
                }
            }
            else
            {
                Write-Warning "Use Powershell ISE for a more powerfull edit experience"
                return $GetTests
            }
        }
        if(Get-Command -Name psedit)
        {            
            foreach($GetTest in $GetTests)
            {
                psedit $GetTest.FullName
            }
        }
        else
        {
            Write-Warning "Use Powershell ISE for a more powerfull edit experience"
            foreach($GetTest in $GetTests)
            {
                notepad.exe $GetTest.fullname
            } 
        }
    }
    else
    {
        Write-warning -Message "Test with id $id was not found"
    }
}

function Get-CommandParmeterHash
{
[cmdletbinding()]
Param(
    [Parameter(ValueFromPipeline)]
    [string]$Name
)
begin
{
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
}
Process
{
    Write-Verbose "$f -  Getting command [$Name]"
    $cmdlet = Get-Command -Name $Name -ErrorAction SilentlyContinue
    $params = @{}
    $newLine = [environment]::NewLine
    $cmd = '$parm = @{' + $newLine
    $pre = "    "
    foreach ($key in $cmdlet.Parameters.Keys)
    {
        if ($key -notin [System.Management.Automation.Cmdlet]::CommonParameters)
        {
            $cmd += $pre + $key + " = ''" + $newLine
        }
    }
    $cmd += "}"
    
    if ($cmdlet)
    {
        $cmd
    }    
}
}

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

function Get-TestResult{[CmdletBinding()]Param(    [int[]]$Id)    $f = $MyInvocation.InvocationName    Write-Verbose -Message "$f - START"    if(-not $Id)    {        Write-Verbose -Message "$f -  Returning all results"        return $script:TestResults        break    }    Write-Verbose -Message "$f -  Getting results for specific id's"    foreach($index in $id)    {        $script:TestResults[$index]    }}

#Requires -Version 4.0 -Modules Pester
function Invoke-Test
{
[cmdletbinding()]
Param(
    [int[]]$id
)
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"

    if($id.Count -eq 0)
    {
        Write-Verbose -Message "$f -  Invoking pester for all"
        Invoke-Pester
        break
    }
    
    $Alltests = Get-TestList -Id $id

    if($Alltests)
    {        
        Write-Verbose -Message "$f -  Invoking pester for selection ($($id[0])..$($id[-1]))"
        Foreach($test in $Alltests)
        {
            $testItem = Invoke-Pester -Script $test.fullname -PassThru
            $testObj = [PSCustomObject]@{
                ID = $test.id
                TotalCount = $testItem.TotalCount
                PassedCount = $testItem.PassedCount
                FailedCount = $testItem.FailedCount
                SkippedCount = $testItem.SkippedCount
                Time = (Get-Date).ToLongTimeString()
                Describe = $testItem.TestResult[0].Describe
            }
            
            Write-Verbose -Message "$f -  Adding test resulsts to array with id $($test.id)"
            $null = $script:TestResults.add($TestObj)
        }
    }
    else
    {
        Write-warning -Message "Test with id $id was not found"
    }
}

#Requires -Version 4.0 -Modules Pester
function New-Function {

<#
.SYNOPSIS
    Creates a new PowerShell function in the specified location.
 
.DESCRIPTION
    New-Function is an advanced function that creates a new PowerShell function in the
    specified location including creating a Pester test for the new function.
 
.PARAMETER Name
    Name of the function.

.PARAMETER Path
    Path of the location where to create the function. This location must already exist.
 
.EXAMPLE
     New-Function -Name Get-PSVersion -Path "$env:ProgramFiles\WindowsPowerShell\Modules\MyModule"

.INPUTS
    None
 
.OUTPUTS
    System.IO.FileInfo
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    [OutputType('System.IO.FileInfo')]
    param (
        [ValidateScript({
          If ((Get-Verb -Verb ($_ -replace '-.*$')).Verb) {
            $true
          }
          else {
            Throw "'$_' does NOT use an approved Verb."
          }
        })]
        [string]$Name
        ,        
        [string]$Path
    )
    $currentPath = (Get-Location).Path

    if (-not $Path)
    {
        $Path = $currentPath
    }
    
    $FunctionPath = Join-Path -Path $Path -ChildPath "Functions"

    Write-Verbose -Message "$f -  Functionpath = [$FunctionPath]"

    if (Test-Path -Path $FunctionPath) 
    {
        $FunctionPath = Join-Path -Path $FunctionPath -ChildPath "$Name.ps1"        
    }
    else 
    {
        $FunctionPath = Join-Path -Path $Path -ChildPath "$Name.ps1"
    }

    $testsPath = Join-Path -Path $Path -ChildPath "Tests"

    if (Test-Path -Path $testsPath)
    {
        $testsPath = Join-Path -Path $testsPath -ChildPath "$name.Tests.ps1"
    }
    else 
    {
        $testsPath = Join-Path -Path $Path -ChildPath "$name.Tests.ps1"
    }

    Write-Verbose -Message "$f -  Function path is [$FunctionPath]"
    Write-Verbose -Message "$f -  TestPath path is [$testsPath]"
    
    if (-not(Test-Path -Path $FunctionPath)) 
    {    
        Out-File -FilePath $testsPath -Encoding utf8
        Set-Content -Path $FunctionPath -Value @"
#Requires -Version 4.0
function $($Name)
{
<#
.SYNOPSIS
    Brief synopsis about the function.
 
.DESCRIPTION
    Detailed explanation of the purpose of this function.
 
.PARAMETER Param1
    The purpose of param1.

.PARAMETER Param2
    The purpose of param2.
 
.EXAMPLE
     $($Name) -Param1 'Value1', 'Value2'

.EXAMPLE
     'Value1', 'Value2' | $($Name)

.EXAMPLE
     $($Name) -Param1 'Value1', 'Value2' -Param2 'Value'
 
.INPUTS
    String
 
.OUTPUTS
    PSCustomObject
 
.NOTES
    Author:  Tore Groneng
    Website: www.firstpoint.no
    Twitter: @ToreGroneng
#>
    [CmdletBinding()]
    [OutputType('PSCustomObject')]
    param (
        [Parameter(
            Mandatory, 
            ValueFromPipeline)]
        [string[]]`$Param1
        ,
        [ValidateNotNullOrEmpty()]
        [string]`$Param2
    )

    BEGIN 
    {
        `$f = `$MyInvocation.InvocationName
        Write-Verbose -Message "`$f - START"
    }

    PROCESS 
    {       
        foreach (`$Param in `$Param1) 
        {
            
        }
    }

    END 
    {
        Write-Verbose -Message "`$f - END"
    }

}
"@
    
    }
    else 
    {
        Write-Error -Message 'Unable to create function. Specified file already exists!'
    }    
    
    Get-ChildItem -File -Path $FunctionPath, $testsPath 
}

#Requires -Version 4.0 -Modules Pester
function Show-Test
{
[CmdletBinding()]
Param(
    [string]$Testkeyword = "Tests"
    ,
    [switch]$Grid
)
    $tests = Get-ChildItem -Filter "*$Testkeyword.ps1" -Recurse -File
    $f = $MyInvocation.InvocationName
    if($Grid -and (Get-Command -Name Out-GridView))
    {
        $Selected = $tests | Sort-Object -Property LastWriteTime -Descending | Out-GridView -Title "Tests available" -PassThru
        $invoke = $null

        if($Selected)
        {
            $invoke = Read-Host -Prompt "Invoke selected test(s)? Y/(N)"

            if ($invoke -eq "Y")
            {
                foreach($test in $Selected)
                {
                    Invoke-Pester -Script $test.fullname
                }
            }            
        }              
    }
    else
    {
        $tests
    }
}













 




function Update-ScriptLine
{
[CmdletBinding(SupportsShouldProcess=$true)]
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

    if (-not ($SearchFor) -or -not($ReplaceWith))
    {
        Write-Verbose -Message "$f -  Nothing to do"
    }
}

PROCESS
{
    foreach ($file in $files)
    {
        if ($file.PSIsContainer -eq $true)
        {
            Write-Verbose -Message "$f -  item is directory, skipping"
            continue
        }

        $content = Get-Content -Path $file.FullName -ReadCount 0 -Encoding UTF8 -Raw
        $NewContent = $content.Replace($SearchFor,$ReplaceWith)
        $escapedSearchFor = [regex]::Escape($SearchFor)

        $SearchForMatch = $content | Select-String -Pattern "$escapedSearchFor" -AllMatches
        $ReplaceCount = $SearchForMatch.Matches.Count
        Write-Verbose -Message "$f -  '$SearchFor' was replaced with '$ReplaceWith' $ReplaceCount time(s) in file $file.Name"
        
        if ($cmdlet.ShouldProcess($file, "Saving content"))
        {
            Write-Verbose -Message "$f -  Saving file '$($file.Name)'"
            Set-Content -Path (Resolve-Path -Path $file.FullName).Path -Value $NewContent -Encoding UTF8
        }        
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}

New-Alias -Name Test -Value Invoke-test
New-Alias -Name Edit -Value Edit-Test
New-Alias -Name Tests -Value Get-TestList
Export-ModuleMember -Function * -Alias *
