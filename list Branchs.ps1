$PERIOD = "1 week ago"

"" | Out-File -FilePath D:\File.txt
ForEach ($k in $(git branch))
{
	Write-Host "Running $k"
	if ([string]::IsNullOrWhitespace($(git log -1 --since=$PERIOD -s $k.Trim())))
	{
		$k | Out-File -FilePath D:\File.txt -Append
	}
}