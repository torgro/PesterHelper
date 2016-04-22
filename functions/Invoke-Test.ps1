function Invoke-Test
{
[cmdletbinding()]
Param(
    [int[]]$id
)
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"
    
    if(-not (Get-Module -Name pester))
    {
        Write-Verbose -Message "$f -  Importing module Pester"
        Import-Module -Name Pester -ErrorAction Stop
    }

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
            $TestObj = "" | Select-Object ID, TotalCount, PassedCount, FailedCount, SkippedCount, Time, Describe
            $TestObj.id = $test.id
            $TestObj.TotalCount = $testItem.TotalCount
            $TestObj.PassedCount = $testItem.PassedCount
            $TestObj.FailedCount = $testItem.FailedCount
            $TestObj.SkippedCount = $testItem.SkippedCount
            $TestObj.Time = $testItem.Time
            $TestObj.Describe = $testItem.TestResult[0].Describe
            Write-Verbose -Message "$f -  Adding test resulsts to array with id $($test.id)"
            [void]$script:TestResults.add($TestObj)
        }
    }
    else
    {
        Write-warning -Message "Test with id $id was not found"
    }
}