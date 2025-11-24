param(
    # The path and file of the CSV file that specifies the tasks to execute.
	# It must have the following columns :
	# tile,codec,preset,qp,height,repetition,numFrames,time
    [Parameter(Mandatory=$true)][String] $inputFile,
    # The duration in seconds of each segment
	[Parameter(Mandatory=$true)][int] $segmentTime,
	# Inserts a key frame every $segmentGOP frames
	[Parameter(Mandatory=$true)][int] $segmentGOP,
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

# The number of frames in each video.
# We store this information to avoid repeating long computations.
$framesCount = @{}

foreach ($task in $tasks)
{
    if (![string]::IsNullOrEmpty($task.time))
	{
        $framesCount[$task.tile] = $task.numFrames
    }
}

# Process the tasks
foreach ($task in $tasks)
{
	# Skip the task if it is already completed
	if (![string]::IsNullOrEmpty($task.time))
	{
		continue
	}

	$tile = $task.tile
	$codec = $task.codec
	$preset = $task.preset
	$qp = $task.qp
	$height = $task.height
    $repetition = $task.repetition

    # Segment and encode the videos and get the encoding time
    $encodingTime = SegmentAndTranscode $tile $codec $qp $height $preset $gop $segmentTime "$segmentsDirectory\output_%d.mp4"

    # Get the number of frames in the video
    if(-Not ($framesCount.ContainsKey($tile)))
    {
        $numFrames = CountFrames $tile
        $framesCount[$tile] = $numFrames
    }

    $numFrames = $framesCount[$tile]

    # Append the results
    [void]$output.Add([PSCustomObject]@{
        tile = $tile
        segment = $segment
        codec = $codec
        preset = $preset
        qp = $qp
        height = $height
        repetition = $repetition
        numFrames = $numFrames
        time = $encodingTime
    })

    # Remove the completed task
	$output.Remove($task)

    # Save the CSV results
	$output | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8 -UseQuotes AsNeeded

    # Delete the previous videos. This must be done since overwritting the videos with FFmpeg slows down the process
    Remove-Item "$segmentsDirectory\*" -Force
}

# Delete the temporary directory before exiting
Remove-Item $segmentsDirectory -Recurse | Out-Null
