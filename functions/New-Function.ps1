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