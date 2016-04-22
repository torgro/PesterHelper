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
        $escapedSearchFor = [regex]::Escape($SearchFor)

        $SearchForMatch = $content | Select-String -Pattern "$escapedSearchFor" -AllMatches
        $ReplaceCount = $SearchForMatch.Matches.Count
        Write-Verbose -Message "$f -  '$SearchFor' was replaced with '$ReplaceWith' $ReplaceCount time(s) in file $file.Name"
        
        if ($cmdlet.ShouldProcess($file, "Saving content"))
        {
            Write-Verbose -Message "$f -  Saving file '$($file.Name)'"
            Set-Content -Path (Resolve-Path -Path $file.FullName).Path -Value $NewContent -Encoding UTF8
        }
        #Set-Content -Path (Resolve-Path -Path $file.FullName).Path -Value $NewContent -Encoding UTF8
    }
}

END
{
    Write-Verbose -Message "$f - END"
}
}