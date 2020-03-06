$PERIOD = "1 week ago"

$currentTime = $('{0:MMddyyyy}{0:HHmmss}' -f (Get-Date))
ForEach ($k in $(git branch -r))
{
	Write-Host "Running $k"
	if ([string]::IsNullOrWhitespace($(git log -1 --since=$PERIOD -s $k.Trim())))
	{
		"$($k.Trim())    --latest commit: $(git log -1 --format=%cd -s $k.Trim())" | Out-File -FilePath ".\Branchs-$currentTime.txt" -Append
	}
}