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