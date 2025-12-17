param(
    # The path and file of the CSV file that specifies the tasks to execute.
	# It must have the following columns :
	# tile,segment,codec,preset,qp,height,bitrate,meanVmaf,meanPsnrY,meanPsnrCb,meanPsnrCr,time
    [Parameter(Mandatory=$true)][String] $inputFile,
    # The duration in seconds of each segment
	[Parameter(Mandatory=$true)][int] $segmentTime,
	# Inserts a key frame every $segmentGOP frames
	[Parameter(Mandatory=$true)][int] $segmentGOP,
    # The path and filename of the CSV file that contains the VMAF logs
    [Parameter(Mandatory=$true)][String] $logsFile,
	# The path and filename of the CSV file that contains the results
	[Parameter(Mandatory=$true)][String] $outputFile
)

# This is required since the "-UseQuotes" option of "Export-Csv" is only available starting from PowerShell 7
if ($PSVersionTable.PSVersion.Major -lt 7)
{
    throw "PowerShell version must be 7 or greater."
}

# Import the required functions
. $PSScriptRoot\ffmpegFunctions.ps1

# Make the operations consistent regardless of the user's system locale (e.g., doubles will always be saved using a dot decimal separator)
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::InvariantCulture

# Load the tasks to execute
$tasks = Import-Csv $inputFile

# Make a copy of the tasks that we can modify
$output = [System.Collections.ArrayList] $tasks

# Create the temporary directory where the segments will be saved
$segmentsDirectory = [guid]::NewGuid().ToString("N")

New-Item -ItemType Directory -Path $segmentsDirectory | Out-Null

$previousTile = ""

# For each task
foreach ($task in $tasks)
{
	# Skip the task if it is already completed
	if (![string]::IsNullOrEmpty($task.segment))
	{
		continue
	}

	$tile = $task.tile
	$codec = $task.codec
	$preset = $task.preset
	$qp = $task.qp
	$height = $task.height

	# Create the raw segments if they dont exist already
	if ($tile -ne $previousTile)
	{
		# Delete the previous raw segments
		Remove-Item "$segmentsDirectory\*" -Force

		$rawSegmentsPath = Join-Path -Path $segmentsDirectory -ChildPath "output_%d.y4m"

		ffmpeg -loglevel error -i $tile -f segment -segment_time $segmentTime -reset_timestamps 1 $rawSegmentsPath
	}

	# Find the amount of segments (ignore segments that are less than $segmentTime by flooring the value)
	$tileProbe = (Probe $tile).streams[0]
	$numSegments = [math]::floor($tileProbe.duration / $segmentTime)

	$logsOutput = @()

	# Encode the segment and get its bitrate and visual quality
	for ($segment = 0; $segment -lt $numSegments; $segment++)
	{
		$referencePath = Join-Path -Path $segmentsDirectory -ChildPath "output_$segment.y4m"
		$distortedPath = Join-Path -Path $segmentsDirectory -ChildPath "output_$segment.mp4"
		# We use a JSON log file because libvmaf will calculate the pooled metrics (mean, min, max) for us
		$logPath = $segmentsDirectory + "/log.json"

		# Transcode the segment
		$encodingTime = Transcode $referencePath $codec $qp $height $preset $segmentGOP $distortedPath

		# Evaluate it's visual quality
		$visualQuality = VisualQuality $distortedPath $referencePath $logPath

		# Append the encoding data results
		[void]$output.Add([PSCustomObject]@{
			tile = $tile
			segment = $segment
			codec = $codec
			preset = $preset
			qp = $qp
			height = $height
			bitrate = (Probe $distortedPath).streams[0].bit_rate
			meanVmaf = $visualQuality.pooled_metrics.vmaf.mean
			meanPsnrY = $visualQuality.pooled_metrics.psnr_y.mean
			meanPsnrCb = $visualQuality.pooled_metrics.psnr_cb.mean
			meanPsnrCr = $visualQuality.pooled_metrics.psnr_cr.mean
			time = $encodingTime
		})

		# Extract and append the VMAF log results
		$logs = @($visualQuality.frames | ForEach-Object { $_ })
				| Select-Object -Property frameNum -ExpandProperty metrics

		$logs = $logs | Select-Object `
			@{Name="tile"; Expression={$tile}}, `
			@{Name="segment"; Expression={$segment}}, `
			@{Name="codec"; Expression={$codec}}, `
			@{Name="preset"; Expression={$preset}}, `
			@{Name="qp"; Expression={$qp}}, `
			@{Name="height"; Expression={$height}}, `
			@{Name = "frame"; Expression = {$_.frameNum}}, `
			* -ExcludeProperty frameNum

		$logsOutput += $logs
	}

	# Remove the completed task
	$output.Remove($task)

	# Save the encoding data to CSV
	$output | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8 -UseQuotes AsNeeded

	# Append the VMAF logs to CSV
	$logsOutput | Export-Csv -Append -Path $logsFile -NoTypeInformation -Encoding UTF8 -UseQuotes AsNeeded

	# Delete the encoded videos
	Remove-Item "$segmentsDirectory\*.mp4" -Force

	$previousTile = $tile
}

# Delete the temporary directory before exiting
Remove-Item $segmentsDirectory -Recurse | Out-Null
