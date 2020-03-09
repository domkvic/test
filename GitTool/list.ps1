Get-Content "$PSScriptRoot\config" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
$gitPath = $h.Get_Item("GitLocalPath")
$PERIOD = $h.Get_Item("Period")
Write-Host "Running Config Period: $PERIOD"
Write-Host "==================================="
$currentTime = $('{0:MMddyyyy}{0:HHmmss}' -f (Get-Date))

ForEach ($k in $(git -C $gitPath branch -r))
{
	Write-Host "Running branch $k"
	if ([string]::IsNullOrWhitespace($(git log -1 --since=$PERIOD -s $k.Trim())))
	{
		"latest commit: $(git -C $gitPath log -1 --format=%cd -s $k.Trim()) --$($k.Trim())" | Out-File -FilePath ".\Branchs-$currentTime.txt" -Append
	}
}