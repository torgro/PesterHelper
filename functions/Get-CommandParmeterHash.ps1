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