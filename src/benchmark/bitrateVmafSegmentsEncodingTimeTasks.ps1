param(
	# An array of tiles to encode
	[Parameter(Mandatory=$true)][String[]] $tiles,
	# An array of codecs. Codecs must be supported by by FFmpeg
	[Parameter(Mandatory=$true)][String[]] $codecs,
	# An array of presets
	[Parameter(Mandatory=$true)][String[]] $presets,
	# An array of constant quantization parameters between 0 and 51
	[Parameter(Mandatory=$true)][int[]] $qps,
	# An array of heights. The aspect ratio is kept. An height of 0 means no resizing
	[Parameter(Mandatory=$true)][int[]] $heights,
	# The csv file where the data will be saved to
	[Parameter(Mandatory=$true)][String] $outputFile
)

$output = [System.Text.StringBuilder]::new()

# Write the header of the csv file
[void]$output.AppendLine("tile,segment,codec,preset,qp,height,bitrate,meanVmaf,meanPsnrY,meanPsnrCb,meanPsnrCr,time")

foreach ($tile in $tiles)
{
	foreach ($codec in $codecs)
	{
		foreach ($preset in $presets)
		{
			foreach ($qp in $qps)
			{
				foreach ($height in $heights)
				{
                    [void]$output.AppendLine("$tile,,$codec,$preset,$qp,$height,,,,,,")
                }
            }
        }
    }
}

$output.ToString() | Out-File -FilePath $outputFile -Encoding utf8
