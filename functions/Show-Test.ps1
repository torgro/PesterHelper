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













 


