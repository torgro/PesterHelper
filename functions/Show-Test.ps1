function Show-Test
{
[CmdletBinding()]
Param(
    [string]$Testkeyword = "Tests"
    ,
    [switch]$Grid
)
    $tests = Get-ChildItem -Filter "*$Testkeyword.ps1" -Recurse

    if($Grid -and (Get-Command -Name Out-GridView))
    {
        $Selected = $tests | Sort-Object -Property LastWriteTime -Descending | Out-GridView -Title "Tests available" -PassThru
        $invoke = $null

        if($Selected -eq "y")
        {
            $invoke = Read-Host -Prompt "Invoke selected test(s)? Y/(N)"

            if(-not (Get-Module -Name pester))
            {
                Write-Verbose -Message "$f -  Importing module Pester"
                Import-Module -Name Pester -ErrorAction Stop
            }

            foreach($test in $Selected)
            {
                Invoke-Pester -Script $test.fullname
            }
        }      
    }
    else
    {
        $tests
    }
}
