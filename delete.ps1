$PERIOD = "1 week ago"

$currentTime = $('{0:MMddyyyy}{0:HHmmss}' -f (Get-Date))
ForEach ($k in $(git branch -r))
{
	Write-Host "Running $k"
	if (![string]::IsNullOrWhitespace($(git log -1 --since=$PERIOD -s $k.Trim())))
	{
		git branch -r -D $k.Trim()
		"$($k.Trim())	--deleteTime: $('{0:MM/dd/yyyy} {0:HH:mm:ss}' -f (Get-Date))	" | Out-File -FilePath ".\DeletedBranchs-$currentTime.txt" -Append
	}
}